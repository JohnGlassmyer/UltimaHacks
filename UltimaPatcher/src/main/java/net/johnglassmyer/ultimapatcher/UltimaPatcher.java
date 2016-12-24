package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;
import static java.util.Comparator.comparingInt;
import static net.johnglassmyer.ultimapatcher.Util.rethrowIoException;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.stream.Collectors;
import java.util.NavigableMap;
import java.util.Optional;
import java.util.Set;
import java.util.TreeMap;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import joptsimple.OptionException;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

/**
 * Applies patches to MS-DOS executables with overlays (originally, to Ultima VII's U7.EXE).
 * <p>
 * Adds patch-specified segment relocations to relocation tables and delists relocations previously
 * existing in patched bytes.
 */
public class UltimaPatcher {
	static class Options {
		static private Options parseFromCommandLine(String[] args) throws OptionException {
			OptionParser optionParser = new OptionParser();

			OptionSpec<String> exeOption = optionParser.accepts("exe")
					.withRequiredArg();
			OptionSpec<Void> showRelocationDetailsOption = optionParser.accepts("show_relocation_details")
					.availableIf(exeOption);

			OptionSpec<String> patchOption = optionParser.accepts("patch")
					.requiredUnless(exeOption)
					.withRequiredArg();
			OptionSpec<Void> showPatchBytesOption = optionParser.accepts("show_patch_bytes")
					.availableIf(patchOption);

			OptionSpec<Void> expandLastOverlayOption = optionParser.accepts("expand_last_overlay")
					.availableIf(exeOption)
					.availableUnless(patchOption);

			OptionSpec<Void> ignoreTargetFileLengthOption =
					optionParser.accepts("ignore_target_file_length")
							.availableIf(exeOption, patchOption);

			OptionSet optionSet = optionParser.parse(args);

			return new Options(
					getOptionally(optionSet, exeOption),
					getOptionally(optionSet, patchOption),
					optionSet.has(showRelocationDetailsOption),
					optionSet.has(showPatchBytesOption),
					optionSet.has(expandLastOverlayOption),
					optionSet.has(ignoreTargetFileLengthOption));
		}

		static <T> Optional<T> getOptionally(OptionSet optionSet, OptionSpec<T> option) {
			if (optionSet.has(option)) {
				return Optional.of(optionSet.valueOf(option));
			} else {
				return Optional.empty();
			}
		}

		final Optional<String> optionalExePath;
		final Optional<String> optionalPatchPath;
		final boolean showRelocationDetails;
		final boolean showPatchBytes;
		final boolean expandLastOverlay;
		final boolean ignoreTargetFileLength;

		Options(
				Optional<String> optionalExePath,
				Optional<String> optionalPatchPath,
				boolean showRelocationDetails,
				boolean showPatchBytes,
				boolean expandLastOverlay,
				boolean ignoreTargetFileLength) {
			this.optionalExePath = optionalExePath;
			this.optionalPatchPath = optionalPatchPath;
			this.showRelocationDetails = showRelocationDetails;
			this.showPatchBytes = showPatchBytes;
			this.expandLastOverlay = expandLastOverlay;
			this.ignoreTargetFileLength = ignoreTargetFileLength;
		}
	}

	static private final Logger L = LogManager.getLogger(UltimaPatcher.class);

	static public void main(String[] args) throws IOException {
		Options options;
		try {
			options = Options.parseFromCommandLine(args);
		} catch (OptionException e) {
			logUsage();

			System.exit(-0xDEADBEEF);

			options = null;
		}

		Optional<Executable> optionalExecutable = options.optionalExePath
				.map(rethrowIoException(p -> readExeFile(Paths.get(p))));

		Optional<Patch> optionalPatch = options.optionalPatchPath
				.map(rethrowIoException(p -> readPatchFile(Paths.get(p))));

		if (optionalExecutable.isPresent() && optionalPatch.isPresent()) {
			Executable executable = optionalExecutable.get();
			executable.logSummary();

			Patch patch = optionalPatch.get();
			patch.logSummary();

			if (patch.targetFileLength != executable.fileLength
					&& !options.ignoreTargetFileLength) {
				L.error(String.format(
						"Patch target file length 0x%X differs from executable length 0x%X."
						+ " Use --ignore_target_file_length to bypass this check.",
						patch.targetFileLength,
						executable.fileLength));
				System.exit(0xDEADBEEF);
			}

			Collection<OverwriteEdit> edits;
			try {
				edits = producePatchEdits(patch, executable, options.showPatchBytes);
			} catch (PatchApplicationException e) {
				L.error(e);

				throw new RuntimeException("Cannot apply patch.", e);
			}

			applyEdits(executable.path, edits);
		} else if (optionalExecutable.isPresent()) {
			Executable executable = optionalExecutable.get();

			if (options.expandLastOverlay) {
				executable.logSummary();

				Collection<Edit> edits;
				try {
					edits = executable.expandLastOverlay();
				} catch (PatchApplicationException e) {
					L.error(e);

					throw new RuntimeException("Cannot expand last overlay.", e);
				}

				applyEdits(executable.path, edits);
			} else {
				executable.logDetails();
				if (options.showRelocationDetails) {
					executable.readAndLogRelocationSiteDetails();
				}
			}
		} else if (optionalPatch.isPresent()) {
			optionalPatch.get().logDetails();
		}
	}

	static private void logUsage() {
		L.info("For executable info:");
		L.info("  java -jar UltimaPatcher.jar --exe=<exeFile> [--show_relocation_details]");
		L.info("For patch info:");
		L.info("  java -jar UltimaPatcher.jar --patch=<patchFile> [--show_patch_bytes]");
		L.info("To add as many procs as possible to the executable's last overlay:");
		L.info("  java -jar UltimaPatcher.jar --exe=<exeFile> --expand_last_ovelay");
		L.info("To apply patch to executable:");
		L.info("  java -jar UltimaPatcher.jar --exe=<exeFile> --patch=<patchFile>");
	}

	static private Collection<OverwriteEdit> producePatchEdits(
			Patch patch, Executable exe, boolean showPatchBytes)
					throws PatchApplicationException {
		List<PatchBlock> sortedBlocks = new ArrayList<>(patch.blocks);
		sortedBlocks.sort(comparingInt(b -> b.startInExe));

		PatchBlock lastBlock = null;
		for (PatchBlock block : sortedBlocks) {
			if (lastBlock != null) {
				int lastBlockEnd = lastBlock.startInExe + lastBlock.codeBytes.length;
				if (lastBlockEnd > block.startInExe) {
					throw new PatchApplicationException(String.format(
							"block for 0x%X overlaps block for 0x%X",
							block.startInExe,
							lastBlock.startInExe));
				}
			}

			for (Integer relocationOffset : block.relocationSitesInBlock) {
				if (relocationOffset > block.codeBytes.length) {
					throw new PatchApplicationException(String.format(
							"block for 0x%X of length 0x%X has out-of-range relocation offset 0x%X",
							block.startInExe,
							block.codeBytes.length,
							relocationOffset));
				}
			}
		}

		NavigableMap<Integer, Patchable> patchablesByStart = new TreeMap<>();
		for (Patchable patchable : exe.getPatchables()) {
			patchablesByStart.put(patchable.getCodeStart(), patchable);
		}

		Collection<OverwriteEdit> edits = new ArrayList<>();

		Map<Patchable, RelocationTableEditor> relocationTableEditors = new HashMap<>();

		// <<multiple blocks could affect the mz relocation table>>
		// <<multiple blocks could affect each overlay relocation table>>
		for (PatchBlock block : patch.blocks) {
			block.logSummary();

			int blockStart = block.startInExe;
			int blockEnd = blockStart + block.codeBytes.length;

			Entry<Integer, Patchable> lastBeforeStart = patchablesByStart.floorEntry(blockStart);
			if (lastBeforeStart == null) {
				throw new PatchApplicationException(String.format(
						"block for 0x%X does not start within a patchable segment", blockStart));
			}

			Patchable patchable = lastBeforeStart.getValue();
			if (blockEnd > patchable.getCodeStart() + patchable.getCodeLength()) {
				throw new PatchApplicationException(String.format(
						"block for 0x%X crosses boundaries of patchable segment", blockStart));
			}

			RelocationTableEditor relocationTableEditor = relocationTableEditors.computeIfAbsent(
					patchable, p -> p.createRelocationTableEditor());

			Set<Integer> newRelocationFileOffsets = block.relocationSitesInBlock
					.stream().map(o -> blockStart + o).collect(Collectors.toSet());

			relocationTableEditor.replaceRelocationsInRange(
					blockStart, blockEnd, newRelocationFileOffsets);

			edits.add(new OverwriteEdit(blockStart, block.codeBytes));

			L.info("");
		}

		for (RelocationTableEditor relocationTableEditor : relocationTableEditors.values()) {
			edits.addAll(relocationTableEditor.generateEdits());
		}

		return edits;
	}

	static private void applyEdits(
			Path exePath, Collection<? extends Edit> edits) throws IOException {
		// TODO: throw if OverwriteEdits overlap or extend beyond EOF
		// (statefully, with respect to previous InsertEdits

		try (RandomAccessFile file = new RandomAccessFile(exePath.toFile(), "rwd")) {
			for (Edit edit : edits) {
				edit.apply(file);
			}
		}
	}

	static private Patch readPatchFile(Path patchPath) throws IOException {
		byte[] patchFileBytes = Files.readAllBytes(patchPath);
		ByteBuffer buffer = ByteBuffer.wrap(patchFileBytes);
		buffer.order(LITTLE_ENDIAN);

		int offsetInPatch = buffer.capacity();

		offsetInPatch -= Integer.BYTES;
		int descriptionLength = buffer.getInt(offsetInPatch);

		offsetInPatch -= descriptionLength;
		byte[] descriptionBytes = new byte[descriptionLength];
		buffer.position(offsetInPatch);
		buffer.get(descriptionBytes);
		String description = new String(descriptionBytes, StandardCharsets.US_ASCII);

		offsetInPatch -= Integer.BYTES;
		int targetFileLength = buffer.getInt(offsetInPatch);

		offsetInPatch -= Integer.BYTES;
		int blockCount = buffer.getInt(offsetInPatch);

		List<PatchBlock> patchBlocks = new ArrayList<>(blockCount);
		for (int iBlock = 0; iBlock < blockCount; iBlock++) {
			offsetInPatch -= Integer.BYTES;
			int startInExe = buffer.getInt(offsetInPatch);

			offsetInPatch -= Integer.BYTES;
			int relocationCount = buffer.getInt(offsetInPatch);

			List<Integer> relocationOffsets = new ArrayList<>(relocationCount);
			for (int iRelocation = 0; iRelocation < relocationCount; iRelocation++) {
				offsetInPatch -= Integer.BYTES;
				relocationOffsets.add(buffer.getInt(offsetInPatch));
			}

			offsetInPatch -= Integer.BYTES;
			int blockLength = buffer.getInt(offsetInPatch);

			byte[] codeBytes = new byte[blockLength];
			offsetInPatch -= blockLength;
			buffer.position(offsetInPatch);
			buffer.get(codeBytes);

			patchBlocks.add(new PatchBlock(startInExe, codeBytes, relocationOffsets));
		}

		patchBlocks.sort(comparingInt(b -> b.startInExe));

		return new Patch(description, targetFileLength, patchBlocks);
	}

	static private Executable readExeFile(Path exePath) throws IOException {
		RandomAccessFile file = new RandomAccessFile(exePath.toFile(), "r");

		MzHeader mzHeader = MzHeader.parseFromBytes(Util.readBytes(file, 0, MzHeader.LENGTH));

		List<Integer> mzRelocationsInLoadModule = parseMzRelocationsInLoadModule(
				Util.readBytes(file, mzHeader.relocationTableStartInFile, mzHeader.relocationCount * 4));
		LoadModule loadModule = new LoadModule(mzHeader, mzRelocationsInLoadModule);

		FbovHeader fbovHeader = FbovHeader
				.parseFrom(Util.readBytes(file, mzHeader.calculateMzFileSize(), FbovHeader.LENGTH));

		List<SegmentInfo> segmentInfos = new ArrayList<>();
		long segmentInfoStart = fbovHeader.segmentTableStartInFile;
		int fbovHeaderEnd = mzHeader.calculateMzFileSize() + FbovHeader.LENGTH;
		for (int iSegment = 0; iSegment < fbovHeader.segmentCount; iSegment++) {
			segmentInfos.add(SegmentInfo.parseFrom(Util.readBytes(file, segmentInfoStart, SegmentInfo.LENGTH)));

			segmentInfoStart += SegmentInfo.LENGTH;
		}

		// Assuming that each overlay ends where the next overlay starts,
		// or at the end of the file.
		List<Segment> segments = new ArrayList<>();
		ListIterator<SegmentInfo> iterator = segmentInfos.listIterator(segmentInfos.size());
		int followingOverlayStart = (int) file.length();
		while (iterator.hasPrevious()) {
			SegmentInfo segmentInfo = iterator.previous();

			Optional<Overlay> optionalOverlay;
			if (segmentInfo.isOverlay()) {
				int stubStart = mzHeader.calculcateLoadModuleStartInFile()
						+ segmentInfo.segmentBase * Util.PARAGRAPH_SIZE;
				OverlayStub stubHeader = OverlayStub.create(
						stubStart, Util.readBytes(file, stubStart, segmentInfo.getLength()));

				int overlayStart = fbovHeaderEnd + stubHeader.overlayStartFromFbovEnd;

				int tableStart = overlayStart + stubHeader.codeSize;
				byte[] relocationTableBytes = Util.readBytes(
						file, tableStart, stubHeader.relocationTableByteCount);

				int overlayEnd = followingOverlayStart;
				followingOverlayStart = overlayStart;

				optionalOverlay = Optional.of(
						new Overlay(stubHeader, overlayStart, overlayEnd, relocationTableBytes));
			} else {
				optionalOverlay = Optional.empty();
			}

			segments.add(new Segment(segmentInfo, optionalOverlay));
		}
		Collections.reverse(segments);

		return new Executable(exePath, file.length(), mzHeader, loadModule, fbovHeader, segments);
	}

	private static List<Integer> parseMzRelocationsInLoadModule(byte[] relocationTableBytes) {
		ByteBuffer buffer = ByteBuffer.wrap(relocationTableBytes);
		buffer.order(LITTLE_ENDIAN);

		List<Integer> relocationAddresses = new ArrayList<>();
		int relocationCount = relocationTableBytes.length / 4;
		for (int i = 0; i < relocationCount; i++) {
			short offset = buffer.getShort();
			short segment = buffer.getShort();
			relocationAddresses.add(segment * Util.PARAGRAPH_SIZE + offset);
		}

		return relocationAddresses;
	}
}
