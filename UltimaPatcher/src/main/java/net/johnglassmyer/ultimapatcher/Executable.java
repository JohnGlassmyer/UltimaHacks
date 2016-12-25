package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.OptionalInt;
import java.util.Set;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.concurrent.atomic.LongAdder;
import java.util.stream.IntStream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class Executable {
	static private final Logger L = LogManager.getLogger(Executable.class);

	final Path path;
	final LoadModule loadModule;
	final List<Segment> segments;
	final long fileLength;
	private final MzHeader mzHeader;
	private final FbovHeader fbovHeader;

	Executable(Path path,
			long fileLength,
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

	void logDetails() {
		logPathAndFileLength();

		mzHeader.logDetails();
		L.info("");

		fbovHeader.logDetails();
		L.info("");

		L.info(String.format("%d segments: (flags: C=code, O=overlay, D=data)", segments.size()));
		L.info("index | base | stof | start  | flags | ovcods | ovcodl | rtabst | rt free/cap");
		L.info("------+------+------+--------+-------+--------+--------+--------+-------------");
		for (int iSegment = 0; iSegment < segments.size(); iSegment++) {
			Segment segment = segments.get(iSegment);

			int startInTable = iSegment * SegmentInfo.LENGTH;
			String codeIndicator = segment.info.isCode() ? "C" : "-";
			String overlayIndicator = segment.info.isOverlay() ? "O" : "-";
			String dataIndicator = segment.info.isData() ? "D" : "-";
			int startInFile = mzHeader.calculcateLoadModuleStartInFile()
					+ segment.info.segmentBase * Util.PARAGRAPH_SIZE;
			String textWithoutOverlayInfo = String.format(
					" %4d | %04X | %04X | %06X |  %s%s%s ",
					iSegment,
					segment.info.segmentBase,
					startInTable,
					startInFile,
					codeIndicator,
					overlayIndicator,
					dataIndicator);

			if (segment.optionalOverlay.isPresent()) {
				Overlay overlay = segment.optionalOverlay.get();
				RelocationTableEditor tableEditor = overlay.createRelocationTableEditor();
				SortedSet<Integer> relocationSitesInFile = tableEditor.getOriginalRelocationSitesInFile();
				int overlayRelocationCount = relocationSitesInFile.size();
				String overlayInfoText = String.format(
						" | %06X | %06X | %06X | %4d/%4d",
						overlay.getCodeStart(),
						overlay.getCodeLength(),
						tableEditor.getTableStartInFile(),
						tableEditor.getCapacity() - overlayRelocationCount,
						tableEditor.getCapacity());
				L.info(textWithoutOverlayInfo + overlayInfoText);

				// TODO: finish proc logging and add a command-line option to enable it
				if (false) {
					for (StubProc proc : overlay.stub.procs) {
						L.info(String.format("    %04X", proc.startInOverlay));
					}
				}
			} else {
				L.info(textWithoutOverlayInfo);
			}
		}
	}

	private void logPathAndFileLength() {
		L.info(String.format("executable %s of length:", path));
		L.info(new HexValueMessage((int) fileLength));
		L.info("");
	}

	void readAndLogRelocationSiteDetails() throws IOException {
		RandomAccessFile exeFile = new RandomAccessFile(path.toFile(), "r");

		SortedMap<Integer, Optional<PrecedingInstruction>> relocations = new TreeMap<>();
		for (int fileOffset : collectRelocationFileOffsets()) {
			relocations.put(fileOffset, parsePrecedingInstruction(exeFile, fileOffset));
		}

		List<Integer> relocationsWithoutInstructions = new ArrayList<>();
		Map<PrecedingInstruction, LongAdder> countForPrecedingInstruction = new HashMap<>();
		for (Map.Entry<Integer, Optional<PrecedingInstruction>> entry : relocations.entrySet()) {
			Optional<PrecedingInstruction> maybePreceding = entry.getValue();
			if (maybePreceding.isPresent()) {
				PrecedingInstruction instruction = maybePreceding.get();
				countForPrecedingInstruction.computeIfAbsent(
						instruction, k -> new LongAdder()).increment();
			} else {
				relocationsWithoutInstructions.add(entry.getKey());
			}
		}

		L.info("opcodes preceding relocation offsets:");
		for (Map.Entry<PrecedingInstruction, LongAdder> entry : countForPrecedingInstruction.entrySet()) {
			LongAdder adder = entry.getValue();
			PrecedingInstruction precedingInstruction = entry.getKey();
			L.info(String.format("%10d %s", adder.longValue(), precedingInstruction));
			if (!relocationsWithoutInstructions.isEmpty()) {
				L.info(String.format("%10d <no recognized preceding instruction>",
						relocationsWithoutInstructions.size()));
			}
		}
		L.info("");

		if (!relocationsWithoutInstructions.isEmpty()) {
			L.info("relocation file offsets with no recognized preceding instructions:");
			for (int offset : relocationsWithoutInstructions) {
				L.info(new HexValueMessage(offset));
			}
		}
		L.info("");
	}

	private Optional<PrecedingInstruction> parsePrecedingInstruction(
			RandomAccessFile file, int fileOffset) throws IOException {
		int precedingBytesToConsider = 4;
		byte[] precedingBytes = Util.readBytes(
				file, fileOffset - precedingBytesToConsider, precedingBytesToConsider);

		// TODO: use IntStream.range(...) and return the Optional more succinctly
		for (int i = 1; i <= precedingBytes.length; i++) {
			int precedingByte = Byte.toUnsignedInt(precedingBytes[precedingBytes.length - i]);
			Optional<PrecedingInstruction> optionalPreceding = PrecedingInstruction.forPrecedingByte(i, precedingByte);
			if (optionalPreceding.isPresent()) {
				return optionalPreceding;
			}
		}

		return Optional.empty();
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

	List<Edit> expandLastOverlay() throws PatchApplicationException {
		OptionalInt optionalLastOverlaySegmentIndex = IntStream.range(0, segments.size())
				.filter(i -> segments.get(i).optionalOverlay.isPresent())
				.reduce((i1, i2) -> i2);
		if (!optionalLastOverlaySegmentIndex.isPresent()) {
			throw new PatchApplicationException("Executable has no overlays.");
		}

		int segmentIndex = optionalLastOverlaySegmentIndex.getAsInt();
		Segment segment = segments.get(segmentIndex);
		L.info("Segment {} is last overlay segment.", segmentIndex);

		Overlay overlay = segment.optionalOverlay.get();
		OverlayStub stub = overlay.stub;

		int stubEnd = stub.startInFile
				+ OverlayStub.HEADER_LENGTH
				+ stub.procs.size() * StubProc.LENGTH;
		int paragraphEnd = Util.roundUpToParagraph(stubEnd);
		int addedProcCount = (paragraphEnd - stubEnd) / StubProc.LENGTH;
		L.info("Stub has room for {} additional procs.", addedProcCount);
		if (addedProcCount < 1) {
			throw new PatchApplicationException("No room in overlay for more procs.");
		}

		int codeLength = overlay.getCodeLength();

		/**
		 * Ultima VII code seems to use around 1 relocation per 50 code bytes. For a full (0x10000)
		 * segment of code + relocations, that means about 0xF630 code bytes and 0x9D0 relocation
		 * bytes.
		 */
		// TODO: Code or relocation table might already be longer than this value;
		// results here would be negative.
		int addedCodeLength = 0xF630 - codeLength;
		int addedRelocationTableLength = 0x9D0 - stub.relocationTableByteCount;

		L.info("Offsets of new procs in overlay segment:");
		List<Integer> procStartsInOverlay = new ArrayList<>();
		// Apportion added code bytes equally (mod paragraph alignment) among added procs.
		int equalProcCodeLength = Util.roundUpToParagraph(addedCodeLength / addedProcCount);
		int accumulatedCodeLength = 0;
		for (int iProc = 0; iProc < addedProcCount; iProc++) {
			int procStartInOverlay = codeLength + accumulatedCodeLength;
			procStartsInOverlay.add(procStartInOverlay);
			L.info(new HexValueMessage(procStartInOverlay));

			int procCodeLength = (iProc < addedProcCount - 1)
					? equalProcCodeLength : addedCodeLength - accumulatedCodeLength;
			accumulatedCodeLength += procCodeLength;
		}

		List<Edit> edits = new ArrayList<>();
		{
			/**
			 * edit to segment table: increase length of stub segment
			 */
			int editStartInFile = fbovHeader.segmentTableStartInFile
					+ segmentIndex * SegmentInfo.LENGTH
					+ SegmentInfo.END_OFFSET_LENGTH;
			ByteBuffer buffer = bufferWrappingBytes(2);
			buffer.putShort((short) (segment.info.endOffset + addedProcCount * StubProc.LENGTH));
			edits.add(new OverwriteEdit(editStartInFile, buffer.array()));
		}
		{
			/**
			 * edits to stub header: - increase code size - increase proc count
			 */
			int editStartInFile = stub.startInFile + 8;
			ByteBuffer buffer = bufferWrappingBytes(6);
			buffer.putShort((short) (stub.codeSize + addedCodeLength));
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
			 * edits to overlay: - insert bytes after relocation table - insert bytes before
			 * relocation table - set bytes at proc starts to 0xCB (retf instruction)
			 */
			int overlayCodeEnd = overlay.getCodeStart() + codeLength;
			int relocationTableEnd = overlayCodeEnd + stub.relocationTableByteCount;
			edits.add(new InsertEdit(relocationTableEnd, addedRelocationTableLength));
			edits.add(new InsertEdit(overlayCodeEnd, addedCodeLength));

			for (int procStartInOverlay : procStartsInOverlay) {
				int procStartInFile = overlay.getCodeStart() + procStartInOverlay;
				edits.add(new OverwriteEdit(procStartInFile, new byte[] {
						(byte) 0xCB
				}));
			}
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
