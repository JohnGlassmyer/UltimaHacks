package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;
import static java.util.stream.IntStream.range;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.NavigableSet;
import java.util.Optional;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class Executable {
	static private final Logger L = LogManager.getLogger(Executable.class);

	final Path path;
	final LoadModule loadModule;
	final List<Segment> segments;
	final int fileLength;
	private final MzHeader mzHeader;
	private final FbovHeader fbovHeader;

	Executable(Path path,
			int fileLength,
			MzHeader mzHeader,
			LoadModule loadModule,
			FbovHeader fbovHeader,
			List<Segment> segments) {
		this.path = path;
		this.fileLength = fileLength;
		this.mzHeader = mzHeader;
		this.loadModule = loadModule;
		this.fbovHeader = fbovHeader;
		this.segments = segments;
	}

	void logSummary() {
		logPathAndFileLength();
	}

	void logDetails(boolean showOverlayProcs) {
		logPathAndFileLength();
		L.info("");

		mzHeader.logDetails();
		L.info("");

		fbovHeader.logDetails();
		L.info("");

		L.info(String.format("%d segments: (flags: C=code, O=overlay, D=data)", segments.size()));
		L.info("index |  *8  | base:offsets   | start  | flags | sp (p) | ovcods | ovcodl | ovrels | rt f/ cap");
		L.info("------+------+----------------+--------+-------+--------+--------+--------+--------+----------");

		if (showOverlayProcs) {
			L.info(" proc   stub   code                                       in exe");
			L.info("-------------------------------------------------------------------");
		}

		boolean lastWasOverlay = true;
		for (int iSegment = 0; iSegment < segments.size(); iSegment++) {
			Segment segment = segments.get(iSegment);

			int segmentStartInTable = iSegment * SegmentInfo.LENGTH;
			String codeIndicator = segment.info.isCode() ? "C" : "-";
			String overlayIndicator = segment.info.isOverlay() ? "O" : "-";
			String dataIndicator = segment.info.isData() ? "D" : "-";
			int startInFile = calculateSegmentStartInFile(segment);
			String textWithoutOverlayInfo = String.format(
					" %4d | %04X | %04X:%04X-%04X | %06X |  %s%s%s  |",
					iSegment,
					segmentStartInTable,
					segment.info.segmentBase,
					segment.info.startOffset,
					segment.info.endOffset,
					startInFile,
					codeIndicator,
					overlayIndicator,
					dataIndicator);

			if (segment.optionalOverlay.isPresent()) {
				if (!lastWasOverlay && showOverlayProcs) {
					L.info("------+------+----------------+--------+-------+--------+--------+--------+--------+----------");
				}

				Overlay overlay = segment.optionalOverlay.get();
				RelocationTableEditor tableEditor = overlay.createRelocationTableEditor();
				SortedSet<Integer> relocationSitesInFile = tableEditor.getOriginalRelocationSitesInFile();
				int overlayRelocationCount = relocationSitesInFile.size();
				int spareBytes = calculateSpareBytesAfterSegment(segment);
				int procSpace = spareBytes < 0 ? 0 : spareBytes / StubProc.LENGTH;

				L.info(String.format(
						"%s %2d (%1d) | %06X | %06X | %06X | %4d/%4d ",
						textWithoutOverlayInfo,
						spareBytes,
						procSpace,
						overlay.getCodeStart(),
						overlay.getCodeLength(),
						tableEditor.getTableStartInFile(),
						tableEditor.getCapacity() - overlayRelocationCount,
						tableEditor.getCapacity()));

				if (showOverlayProcs) {
					L.info("------+------+----------------+--------+-------+--------+--------+--------+--------+----------");

					List<StubProc> procs = overlay.stub.procs;
					range(0, procs.size()).forEach(iProc -> {
						L.info(String.format(
								" %4d   %04X   %04X                                       %06X",
								iProc,
								OverlayStub.HEADER_LENGTH + iProc * StubProc.LENGTH,
								procs.get(iProc).startInOverlay,
								overlay.getCodeStart() + procs.get(iProc).startInOverlay));
					});
					// TODO: print "...." for each spare proc space in stub?
					if (!procs.isEmpty()) {
						L.info("------+------+----------------+--------+-------+--------+--------+--------+--------+----------");
					}
				}

				lastWasOverlay = true;
			} else {
				L.info(textWithoutOverlayInfo);

				lastWasOverlay = false;
			}
		}
	}

	private int calculateSegmentStartInFile(Segment segment) {
		return mzHeader.calculcateLoadModuleStartInFile()
				+ segment.info.segmentBase * Util.PARAGRAPH_SIZE
				+ segment.info.startOffset;
	}

	private int calculateSpareBytesAfterSegment(Segment segment) {
		int segmentStart = calculateSegmentStartInFile(segment);

		NavigableSet<Integer> segmentStarts = new TreeSet<>();
		segments.stream().map(this::calculateSegmentStartInFile).forEach(segmentStarts::add);
		Optional<Integer> optionalFollowingSegmentStart =
				Optional.ofNullable(segmentStarts.higher(segmentStart));

		int spareBytesEnd = optionalFollowingSegmentStart.orElse(fileLength);

		int segmentEnd = segmentStart + segment.info.getLength();
		return spareBytesEnd - segmentEnd;
	}

	private void logPathAndFileLength() {
		L.info(new HexValueMessage(fileLength, String.format("executable length (%s)", path)));
	}

	void listRelocations() throws IOException {
		for (int relocation : loadModule.createRelocationTableEditor().getOriginalRelocationSitesInFile()) {
			L.info(String.format("0x%06X (0x%06X in load module)", relocation, relocation - loadModule.getCodeStart()));
		}

		for (int i = 0; i < segments.size(); i++) {
			Segment segment = segments.get(i);
			if (segment.optionalOverlay.isPresent()) {
				Overlay overlay = segment.optionalOverlay.get();
				for (int relocation : overlay.createRelocationTableEditor().getOriginalRelocationSitesInFile()) {
					L.info(String.format("0x%06X (0x%06X in overlay %d)", relocation, relocation - overlay.getCodeStart(), i));
				}
			}
		}
	}

	Collection<Patchable> getPatchables() {
		Collection<Patchable> patchables = new ArrayList<>();
		patchables.add(loadModule);
		for (Segment segment : segments) {
			if (segment.optionalOverlay.isPresent()) {
				patchables.add(segment.optionalOverlay.get());
			}
		}
		return patchables;
	}

	Set<Integer> collectRelocationFileOffsets() {
		SortedSet<Integer> relocationFileOffsets = new TreeSet<>();
		for (Patchable patchable : getPatchables()) {
			RelocationTableEditor tableEditor = patchable.createRelocationTableEditor();
			relocationFileOffsets.addAll(tableEditor.getOriginalRelocationSitesInFile());
		}
		return relocationFileOffsets;
	}

	List<Edit> expandOverlay(int segmentIndex, int newOverlayLength)
			throws PatchApplicationException {
		if (segmentIndex > segments.size()) {
			throw new PatchApplicationException(
					String.format("No segment %d in executable.", segmentIndex));
		}

		Segment stubSegment = segments.get(segmentIndex);
		if (!stubSegment.optionalOverlay.isPresent()) {
			throw new PatchApplicationException(
					String.format("Segment %d is not an overlay segment.", segmentIndex));
		}

		L.info("Attempting to expand overlay segment {}.", segmentIndex);

		Overlay overlay = stubSegment.optionalOverlay.get();
		OverlayStub stub = overlay.stub;

		int spareBytes = calculateSpareBytesAfterSegment(stubSegment);
		if (spareBytes < StubProc.LENGTH) {
			throw new PatchApplicationException(String.format(
					"No room in segment %s overlay stub for more procs.", segmentIndex));
		}

		int addedProcCount = spareBytes / StubProc.LENGTH;
		L.info("Stub has room for {} additional procs.", addedProcCount);

		/**
		 * Ultima VII code seems to use around 1 relocation (2 bytes) per 50 code bytes.
		 */
		double codeFraction = 50 / (double) 52;
		int newCodeLength = (int) (newOverlayLength * codeFraction);
		int newRelocationTableLength = newOverlayLength - newCodeLength;
		L.info(String.format("New overlay code length is 0x%X", newCodeLength));
		L.info(String.format("New relocation table length is 0x%X", newRelocationTableLength));
		if (newCodeLength < overlay.getCodeLength()) {
			throw new PatchApplicationException("New code length < old code length.");
		}
		if (newRelocationTableLength < stub.relocationTableByteCount) {
			throw new PatchApplicationException(
					"New relocation table length < old relocation table length.");
		}

		int lastOverlayStartInFile = segments.stream()
				.flatMap(s -> s.optionalOverlay.stream())
				.mapToInt(o -> o.getCodeStart())
				.max()
				.getAsInt();
		boolean wasAlreadyLastOverlay = overlay.getCodeStart() == lastOverlayStartInFile;

		// Don't move the overlay if it is already the last thing in the file.
		int newOverlayCodeStart;
		if (wasAlreadyLastOverlay) {
			L.info("Overlay will remain at end of file");
			newOverlayCodeStart = overlay.getCodeStart();
		} else {
			L.info(String.format("Overlay will be moved to end of file at 0x%X", fileLength));
			newOverlayCodeStart = fileLength;
		}

		L.info("New procs (stub proc -> overlay proc):");
		List<Integer> procStartsInOverlay = new ArrayList<>();
		// Space the added procs at 0x100-byte intervals in the overlay code segment.
		for (int iAddedProc = 0; iAddedProc < addedProcCount; iAddedProc++) {
			int procStartInOverlay = overlay.getCodeLength() + iAddedProc * 0x100;
			procStartsInOverlay.add(procStartInOverlay);
			int stubProcOffset =
					OverlayStub.HEADER_LENGTH + (stub.procs.size() + iAddedProc) * StubProc.LENGTH;
			L.info(String.format(
					"0x%04X:0x%04X / 0x%04X:0x%04X -> eop:0x%04X",
					stubSegment.info.segmentBase,
					stubProcOffset,
					segmentIndex * SegmentInfo.LENGTH,
					stubProcOffset,
					procStartInOverlay));
		}

		List<Edit> edits = new ArrayList<>();
		{
			/**
			 * edit to FBOV header: increase overlay code size
			 */
			int editStartInFile = mzHeader.calculateMzFileSize()
					+ FbovHeader.OVERLAY_BYTE_COUNT_OFFSET;
			ByteBuffer buffer = bufferWrappingBytes(4);
			int newOverlayByteCount = fbovHeader.overlayByteCount + newOverlayLength;
			buffer.putInt(newOverlayByteCount);
			edits.add(new OverwriteEdit(editStartInFile, buffer.array()));
		}
		{
			/**
			 * edit to segment table: increase length of stub segment
			 */
			int editStartInFile = fbovHeader.segmentTableStartInFile
					+ segmentIndex * SegmentInfo.LENGTH
					+ SegmentInfo.END_OFFSET_OFFSET;
			ByteBuffer buffer = bufferWrappingBytes(2);
			int newStubEndOffset = stubSegment.info.endOffset + addedProcCount * StubProc.LENGTH;
			buffer.putShort((short) newStubEndOffset);
			edits.add(new OverwriteEdit(editStartInFile, buffer.array()));
		}
		{
			/**
			 * edit to stub header:
			 * - set overlay start to current end of file
			 * - increase code size
			 * - (leave relocation byte count as-is)
			 * - increase proc count
			 */
			int editStartInFile = stub.startInFile + 4;
			ByteBuffer buffer = bufferWrappingBytes(10);
			int newOverlayStartFromFbovEnd =
					newOverlayCodeStart - (mzHeader.calculateMzFileSize() + FbovHeader.LENGTH);
			buffer.putInt(newOverlayStartFromFbovEnd);
			buffer.putShort((short) (newCodeLength));
			buffer.putShort((short) (stub.relocationTableByteCount));
			buffer.putShort((short) (stub.procs.size() + addedProcCount));
			edits.add(new OverwriteEdit(editStartInFile, buffer.array()));
		}
		{
			/**
			 * edits to stub: add 5-byte entry for each new proc
			 */
			for (int iProc = 0; iProc < procStartsInOverlay.size(); iProc++) {
				int editStartInFile = stub.startInFile
						+ OverlayStub.HEADER_LENGTH
						+ (stub.procs.size() + iProc) * StubProc.LENGTH;
				byte[] bytes = StubProc.bytesFor(procStartsInOverlay.get(iProc));
				edits.add(new OverwriteEdit(editStartInFile, bytes));
			}
		}
		{
			/**
			 * new overlay edits:
			 * - make room for code + relocation table at end of file
			 * - copy overlay code to end of file (if it's not already there)
			 * - copy overlay relocation table to end of file
			 * - set bytes at proc starts to 0xCB (retf instruction)
			 */
			int additionalFileLength;
			if (wasAlreadyLastOverlay) {
				additionalFileLength = newOverlayLength -
						(overlay.getCodeLength() + overlay.stub.relocationTableByteCount);
			} else {
				additionalFileLength = newOverlayLength;
			}
			edits.add(new InsertEdit(fileLength, additionalFileLength));

			if (!wasAlreadyLastOverlay) {
				edits.add(new CopyEdit(
						overlay.getCodeStart(), overlay.getCodeLength(), newOverlayCodeStart));
			}

			edits.add(new CopyEdit(
					overlay.getCodeStart() + overlay.getCodeLength(),
					stub.relocationTableByteCount,
					newOverlayCodeStart + newCodeLength));

			for (int procStartInOverlay : procStartsInOverlay) {
				int procStartInFile = newOverlayCodeStart + procStartInOverlay;
				edits.add(new OverwriteEdit(procStartInFile, new byte[] {
						(byte) 0xCB
				}));
			}
		}
		{
			/**
			 * old overlay edit: zero-out old code and relocation table
			 */
			// TODO
//			new byte[]
//			edits.add(new OverwriteEdit(overlay.getCodeStart(), replacementBytes))
		}

		// Assuming that there's nothing in the file after the last overlay.

		return edits;
	}

	private static ByteBuffer bufferWrappingBytes(int byteCount) {
		ByteBuffer buffer = ByteBuffer.wrap(new byte[byteCount]);
		buffer.order(LITTLE_ENDIAN);
		return buffer;
	}
}
