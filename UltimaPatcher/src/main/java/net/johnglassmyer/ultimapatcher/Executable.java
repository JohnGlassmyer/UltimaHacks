package net.johnglassmyer.ultimapatcher;

import static java.util.stream.IntStream.range;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;
import java.util.NavigableSet;
import java.util.Optional;
import java.util.TreeSet;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import net.johnglassmyer.ultimapatcher.Segment.Patchable;

class Executable {
	private static final Logger L = LogManager.getLogger(Executable.class);

	static Executable readFromFile(Path exePath) throws IOException {
		FileChannel file = FileChannel.open(exePath, StandardOpenOption.READ);

		MzHeader mzHeader = MzHeader.parseFrom(Util.read(file, 0, MzHeader.LENGTH));

		LoadModule loadModule; {
			int tableStartInFile = mzHeader.relocationTableStartInFile;
			byte[] tableBytes = Util.read(
					file, mzHeader.relocationTableStartInFile, mzHeader.relocationCount * 4);
			LoadModuleRelocationTable table = LoadModuleRelocationTable.create(
					tableStartInFile, tableBytes);
			loadModule = new LoadModule(mzHeader, table);
		}

		FbovHeader fbovHeader = FbovHeader.create(
				Util.read(file, mzHeader.calculateMzFileSize(), FbovHeader.LENGTH));
		int fbovHeaderEnd = mzHeader.calculateMzFileSize() + FbovHeader.LENGTH;

		List<Segment> segments = new ArrayList<>();
		for (int segmentIndex = 0; segmentIndex < fbovHeader.segmentCount; segmentIndex++) {
			int entryStart = fbovHeader.segmentTableStartInFile
					+ segmentIndex * SegmentTableEntry.LENGTH;
			SegmentTableEntry segmentTableEntry = SegmentTableEntry.create(
					Util.read(file, entryStart, SegmentTableEntry.LENGTH));

			int segmentStartInFile = mzHeader.loadModuleStartInFile()
					+ segmentTableEntry.segmentBase * Util.PARAGRAPH_SIZE;

			Optional<Overlay> optionalOverlay;
			if (segmentTableEntry.isOverlay()) {
				OverlayStub stub = OverlayStub.create(
						Util.read(file, segmentStartInFile, segmentTableEntry.getLength()));

				int overlayStartInFile = fbovHeaderEnd + stub.overlayStartFromFbovEnd;

				int tableStartInFile = overlayStartInFile + stub.codeSize;
				byte[] tableBytes = Util.read(file, tableStartInFile, stub.relocationTableLength);
				OverlayRelocationTable table = OverlayRelocationTable.create(
						segmentStartInFile, tableStartInFile, tableBytes, segmentIndex);

				optionalOverlay = Optional.of(new Overlay(stub, overlayStartInFile, table));
			} else {
				optionalOverlay = Optional.empty();
			}

			segments.add(new Segment(segmentTableEntry, segmentStartInFile, optionalOverlay));
		}

		return new Executable(
				exePath, (int) file.size(), mzHeader, loadModule, fbovHeader, segments);
	}

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

	Optional<Integer> segmentIndexForFileOffset(int fileOffset) {
		// Linear search is good enough (?)
		return range(0, segments.size()).boxed()
				.filter(segmentIndex -> {
					Patchable patchable = segments.get(segmentIndex).patchable();
					return patchable.startInFile() <= fileOffset
							&& fileOffset < patchable.endInFile();
				})
				.findFirst();
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

			int segmentStartInTable = iSegment * SegmentTableEntry.LENGTH;
			String codeIndicator = segment.tableEntry.isCode() ? "C" : "-";
			String overlayIndicator = segment.tableEntry.isOverlay() ? "O" : "-";
			String dataIndicator = segment.tableEntry.isData() ? "D" : "-";
			int startInFile = calculateSegmentStartInFile(segment);
			String textWithoutOverlayInfo = String.format(
					" %4d | %04X | %04X:%04X-%04X | %06X |  %s%s%s  |",
					iSegment,
					segmentStartInTable,
					segment.tableEntry.segmentBase,
					segment.tableEntry.startOffset,
					segment.tableEntry.endOffset,
					startInFile,
					codeIndicator,
					overlayIndicator,
					dataIndicator);

			if (segment.optionalOverlay.isPresent()) {
				if (!lastWasOverlay && showOverlayProcs) {
					L.info("------+------+----------------+--------+-------+--------+--------+--------+--------+----------");
				}

				Overlay overlay = segment.optionalOverlay.get();
				RelocationTable table = overlay.relocationTable;
				int spareBytes = calculateSpareBytesAfterSegment(segment);
				int procSpace = spareBytes < 0 ? 0 : spareBytes / StubProc.LENGTH;

				// TODO: display capacity of table

				L.info(String.format(
						"%s %2d (%1d) | %06X | %06X | %06X | %4d",
						textWithoutOverlayInfo,
						spareBytes,
						procSpace,
						overlay.startInFile,
						overlay.stub.codeSize,
						table.startInFile,
						table.originalAddresses.size()));

				if (showOverlayProcs) {
					L.info("------+------+----------------+--------+-------+--------+--------+--------+--------+----------");

					List<StubProc> procs = overlay.stub.procs;
					range(0, procs.size()).forEach(iProc -> {
						L.info(String.format(
								" %4d   %04X   %04X                                       %06X",
								iProc,
								OverlayStub.HEADER_LENGTH + iProc * StubProc.LENGTH,
								procs.get(iProc).startInOverlay,
								overlay.startInFile + procs.get(iProc).startInOverlay));
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

	void listRelocations() {
		for (int relocation : loadModule.relocationTable.originalAddresses) {
			int relocationInFile = loadModule.mzHeader.loadModuleStartInFile() + relocation;
			L.info(String.format("0x%06X (0x%06X in load module)", relocationInFile, relocation));
		}

		range(0, segments.size()).forEach(segmentIndex -> {
			Segment segment = segments.get(segmentIndex);
			segment.optionalOverlay.ifPresent(overlay -> {
				for (int relocationOffset : overlay.relocationTable.originalAddresses) {
					int relocationInFile = overlay.startInFile + relocationOffset;
					L.info(String.format("0x%06X (0x%04X in overlay %d)",
							relocationInFile, relocationOffset, segmentIndex));
				}
			});
		});
	}

	List<Edit> expandOverlay(int segmentIndex, int newOverlayLength) {
		if (segmentIndex > segments.size()) {
			throw new PatchApplicationException(
					String.format("No segment %d in executable", segmentIndex));
		}

		Segment stubSegment = segments.get(segmentIndex);
		if (!stubSegment.optionalOverlay.isPresent()) {
			throw new PatchApplicationException(
					String.format("Segment %d is not an overlay segment", segmentIndex));
		}

		L.info(String.format(
				"Attempting to expand overlay %d to a length of 0x%04X",
				segmentIndex,
				newOverlayLength));

		Overlay overlay = stubSegment.optionalOverlay.get();
		OverlayStub stub = overlay.stub;

		int spareBytes = calculateSpareBytesAfterSegment(stubSegment);
		if (spareBytes < StubProc.LENGTH) {
			throw new PatchApplicationException(String.format(
					"No room in segment %s overlay stub for more procs", segmentIndex));
		}

		int addedProcCount = spareBytes / StubProc.LENGTH;
		L.info("  Stub has room for {} additional procs", addedProcCount);

		/**
		 * Ultima VII code seemed to need around 2 bytes of relocation data per 50 code bytes.
		 * However, my patches use somewhat more, perhaps because they tend to consist largely of
		 * (far/relocated) calls to procedures from the original game.
		 */
		double relocationFraction = (double) 2 / 40;
		int newCodeLength = (int) (newOverlayLength * (1 - relocationFraction));
		int newRelocationTableLength = newOverlayLength - newCodeLength;
		L.info(String.format("  New overlay code length is 0x%X", newCodeLength));
		L.info(String.format("  New relocation table length is 0x%X", newRelocationTableLength));
		if (newCodeLength < stub.codeSize) {
			throw new PatchApplicationException("New code length < old code length");
		}
		if (newRelocationTableLength < stub.relocationTableLength) {
			throw new PatchApplicationException(
					"New relocation table length < old relocation table length");
		}

		int lastOverlayStartInFile = segments.stream()
				.flatMap(s -> s.optionalOverlay.stream())
				.mapToInt(o -> o.startInFile)
				.max()
				.getAsInt();
		boolean wasAlreadyLastOverlay = overlay.startInFile == lastOverlayStartInFile;

		// Don't move the overlay if it is already the last thing in the file.
		int newOverlayCodeStart;
		if (wasAlreadyLastOverlay) {
			L.info("  Overlay will remain at end of file");
			newOverlayCodeStart = overlay.startInFile;
		} else {
			L.info(String.format("  Overlay will be moved to end of file at 0x%X", fileLength));
			newOverlayCodeStart = fileLength;
		}

		L.info("  New procs (stub proc -> overlay proc):");
		List<Integer> procStartsInOverlay = new ArrayList<>();
		// Space the added procs at 0x100-byte intervals in the overlay code segment.
		for (int iAddedProc = 0; iAddedProc < addedProcCount; iAddedProc++) {
			int procStartInOverlay = stub.codeSize + iAddedProc * 0x100;
			procStartsInOverlay.add(procStartInOverlay);
			int stubProcOffset =
					OverlayStub.HEADER_LENGTH + (stub.procs.size() + iAddedProc) * StubProc.LENGTH;
			L.info(String.format(
					"    0x%04X/0x%04X:0x%04X -> %d:0x%04X",
					stubSegment.tableEntry.segmentBase,
					segmentIndex * SegmentTableEntry.LENGTH,
					stubProcOffset,
					segmentIndex,
					procStartInOverlay));
		}

		List<Edit> edits = new ArrayList<>();
		{
			/**
			 * edit to FBOV header: increase overlay code size
			 */
			int editStartInFile = mzHeader.calculateMzFileSize()
					+ FbovHeader.OVERLAY_BYTE_COUNT_OFFSET;
			ByteBuffer buffer = Util.littleEndianBytes(4);
			int newOverlayByteCount = fbovHeader.overlayByteCount + newOverlayLength;
			buffer.putInt(newOverlayByteCount);
			edits.add(new OverwriteEdit(
					"overlay code size in FBOV header", editStartInFile, buffer.array()));
		}
		{
			/**
			 * edit to segment table: increase length of stub segment
			 */
			int editStartInFile = fbovHeader.segmentTableStartInFile
					+ segmentIndex * SegmentTableEntry.LENGTH
					+ SegmentTableEntry.END_OFFSET_OFFSET;
			ByteBuffer buffer = Util.littleEndianBytes(2);
			int newStubEndOffset = stubSegment.tableEntry.endOffset + addedProcCount * StubProc.LENGTH;
			buffer.putShort((short) newStubEndOffset);
			edits.add(new OverwriteEdit(
					"length of stub " + segmentIndex, editStartInFile, buffer.array()));
		}
		{
			/**
			 * edit to stub header:
			 * - set overlay start to current end of file
			 * - increase code size
			 * - (leave relocation byte count as-is)
			 * - increase proc count
			 */
			int editStartInFile = stubSegment.startInFile + 4;
			ByteBuffer buffer = Util.littleEndianBytes(10);
			int newOverlayStartFromFbovEnd =
					newOverlayCodeStart - (mzHeader.calculateMzFileSize() + FbovHeader.LENGTH);
			buffer.putInt(newOverlayStartFromFbovEnd);
			buffer.putShort((short) (newCodeLength));
			buffer.putShort((short) (stub.relocationTableLength));
			buffer.putShort((short) (stub.procs.size() + addedProcCount));
			edits.add(new OverwriteEdit(
					"overlay metadata in stub " + segmentIndex, editStartInFile, buffer.array()));
		}
		{
			/**
			 * edits to stub: add 5-byte entry for each new proc
			 */
			for (int iProc = 0; iProc < procStartsInOverlay.size(); iProc++) {
				int procIndex = stub.procs.size() + iProc;
				int editStartInFile = stubSegment.startInFile
						+ OverlayStub.HEADER_LENGTH
						+ procIndex * StubProc.LENGTH;
				byte[] bytes = StubProc.bytesFor(procStartsInOverlay.get(iProc));
				edits.add(new OverwriteEdit(
						"proc " + procIndex + " in stub " + segmentIndex, editStartInFile, bytes));
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
						(stub.codeSize + stub.relocationTableLength);
			} else {
				additionalFileLength = newOverlayLength;
			}
			edits.add(new InsertEdit(
					"lengthen file", fileLength, additionalFileLength));

			if (!wasAlreadyLastOverlay) {
				edits.add(new CopyEdit(
						String.format("overlay %d to end of file", segmentIndex),
						overlay.startInFile,
						stub.codeSize,
						newOverlayCodeStart));
			}

			edits.add(new CopyEdit(
					String.format("relocation table of overlay %d", segmentIndex),
					overlay.startInFile + stub.codeSize,
					stub.relocationTableLength,
					newOverlayCodeStart + newCodeLength));

			for (int procStartInOverlay : procStartsInOverlay) {
				int procStartInFile = newOverlayCodeStart + procStartInOverlay;
				edits.add(new OverwriteEdit(
						"RETF at proc start "
								+ Util.formatAddress(segmentIndex, procStartInOverlay),
						procStartInFile,
						new byte[] { (byte) 0xCB }));
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

	private int calculateSegmentStartInFile(Segment segment) {
		return mzHeader.loadModuleStartInFile()
				+ segment.tableEntry.segmentBase * Util.PARAGRAPH_SIZE
				+ segment.tableEntry.startOffset;
	}

	private int calculateSpareBytesAfterSegment(Segment segment) {
		int segmentStart = calculateSegmentStartInFile(segment);

		NavigableSet<Integer> segmentStarts = new TreeSet<>();
		segments.stream().map(this::calculateSegmentStartInFile).forEach(segmentStarts::add);
		Optional<Integer> optionalFollowingSegmentStart =
				Optional.ofNullable(segmentStarts.higher(segmentStart));

		int spareBytesEnd = optionalFollowingSegmentStart.orElse(fileLength);

		int segmentEnd = segmentStart + segment.tableEntry.getLength();
		return spareBytesEnd - segmentEnd;
	}

	private void logPathAndFileLength() {
		L.info(new HexValueMessage(fileLength, String.format("executable length (%s)", path)));
	}
}
