package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;
import static net.johnglassmyer.uncheckers.IoUncheckers.callUncheckedIoRunnable;
import static net.johnglassmyer.uncheckers.IoUncheckers.callUncheckedIoSupplier;
import static net.johnglassmyer.uncheckers.IoUncheckers.uncheckIoBiFunction;
import static net.johnglassmyer.uncheckers.IoUncheckers.uncheckIoFunction;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.SeekableByteChannel;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import java.util.Optional;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Streams;
import com.google.common.jimfs.Jimfs;

import joptsimple.OptionException;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;
import joptsimple.util.PathConverter;
import joptsimple.util.PathProperties;
import net.johnglassmyer.ultimahacks.common.HackProto;
import net.johnglassmyer.ultimapatcher.Segment.Patchable;

/**
 * Applies patches to MS-DOS executables with overlays (originally, to Ultima VII's U7.EXE).
 * <p>
 * Adds patch-specified segment relocations to relocation tables and delists relocations previously
 * existing in patched bytes.
 */
public class UltimaPatcher {
	static class Options {
		private static final PathConverter EXISTING_FILE_PATH_CONVERTER =
				new PathConverter(PathProperties.FILE_EXISTING);

		static Options parseFromCommandLine(String[] args) throws OptionException {
			OptionParser optionParser = new OptionParser();

			OptionSpec<Path> exe = optionParser.accepts("exe")
					.withRequiredArg()
					.withValuesConvertedBy(EXISTING_FILE_PATH_CONVERTER);

			OptionSpec<Void> listRelocations = optionParser.accepts("list-relocations")
					.availableIf(exe);

			OptionSpec<Void> showOverlayProcs = optionParser.accepts("show-overlay-procs")
					.availableIf(exe);

			OptionSpec<String> expandOverlay = optionParser.accepts("expand-overlay")
					.availableIf(exe)
					.withRequiredArg()
					.ofType(String.class);

			OptionSpec<Path> patch = optionParser.accepts("patch")
					.requiredUnless(exe)
					.withRequiredArg()
					.withValuesConvertedBy(EXISTING_FILE_PATH_CONVERTER);

			OptionSpec<Void> writeToExe = optionParser.accepts("write-to-exe")
					.availableIf(exe);

			OptionSpec<Path> writeHack = optionParser.accepts("write-hack-proto")
					.availableIf(exe)
					.availableUnless(writeToExe)
					.withRequiredArg()
					.withValuesConvertedBy(new PathConverter());

			OptionSpec<Void> showPatchBytes = optionParser.accepts("show-patch-bytes")
					.availableIf(patch);

			OptionSpec<Void> ignoreExeLength = optionParser.accepts("ignore-exe-length")
					.availableIf(exe, patch);

			OptionSet optionSet = optionParser.parse(args);

			return new Options(
					optionSet.valueOfOptional(exe),
					optionSet.has(listRelocations),
					optionSet.has(showOverlayProcs),
					optionSet.valuesOf(expandOverlay),
					optionSet.valuesOf(patch),
					optionSet.has(writeToExe),
					optionSet.valueOfOptional(writeHack),
					optionSet.has(showPatchBytes),
					optionSet.has(ignoreExeLength));
		}

		final Optional<Path> exe;
		final boolean listRelocations;
		final boolean showOverlayProcs;
		final List<String> expandOverlay;
		final List<Path> patch;
		final boolean writeToExe;
		final Optional<Path> writeHack;
		final boolean showPatchBytes;
		final boolean ignoreExeLength;

		Options(
				Optional<Path> exe,
				boolean listRelocations,
				boolean showOverlayProcs,
				List<String> expandOverlay,
				List<Path> patch,
				boolean writeToExe,
				Optional<Path> writeHack,
				boolean showPatchBytes,
				boolean ignoreExeLength) {
			this.exe = exe;
			this.listRelocations = listRelocations;
			this.showOverlayProcs = showOverlayProcs;
			this.expandOverlay = expandOverlay;
			this.patch = patch;
			this.writeToExe = writeToExe;
			this.writeHack = writeHack;
			this.showPatchBytes = showPatchBytes;
			this.ignoreExeLength = ignoreExeLength;
		}
	}

	private static final Logger L = LogManager.getLogger(UltimaPatcher.class);

	public static void main(String[] args) {
		Options options;
		try {
			options = Options.parseFromCommandLine(args);
		} catch (OptionException e) {
			L.error(e);

			logUsage();

			System.exit(-0xDEADBEEF);

			options = null;
		}

		List<Patch> patches = options.patch.stream()
				.map(uncheckIoFunction(UltimaPatcher::readPatchFile))
				.collect(Collectors.toList());

		if (options.exe.isPresent()) {
			Path exePath = options.exe.get();

			Executable expandedExecutable;
			ImmutableList<Edit> expandOverlayEdits; {
				Executable executable = callUncheckedIoSupplier(
						() -> Executable.readFromFile(exePath));
				executable.logSummary();

				ExecutableEditState expandedExecutableState =
						withExpandedOverlays(executable, options.expandOverlay);
				expandedExecutable = expandedExecutableState.executable;
				expandOverlayEdits = expandedExecutableState.accumulatedEdits;
			}

			if (!patches.isEmpty()) {
				L.info(patches.size() + " patches:");
				for (Patch patch : patches) {
					patch.logDescription(options.showPatchBytes);
					if (patch.targetFileLength != expandedExecutable.fileLength
							&& !options.ignoreExeLength) {
						L.error(String.format(
								"Patch target file length 0x%X differs from executable length 0x%X."
								+ " Use --ignore-exe-length to bypass this check.",
								patch.targetFileLength,
								expandedExecutable.fileLength));
						System.exit(0xDEADBEEF);
					}
				}
			}

			ImmutableList<Edit> patchEdits = editsForPatches(expandedExecutable, patches);

			ImmutableList<Edit> expandAndPatchEdits; {
				ImmutableList.Builder<Edit> builder = ImmutableList.builder();
				builder.addAll(expandOverlayEdits);
				builder.addAll(patchEdits);
				expandAndPatchEdits = builder.build();
			}

			if (!expandAndPatchEdits.isEmpty()) {
				L.info("{} resulting edits:", expandAndPatchEdits.size());
				expandAndPatchEdits.forEach(L::info);

				if (options.writeToExe) {
					L.info("writing to exe {}", exePath);
					applyEdits(exePath, expandAndPatchEdits);
				} else if (options.writeHack.isPresent()) {
					Path hackPath = options.writeHack.get();
					L.info("writing hack proto to {}", hackPath);
					writeHackProto(hackPath, expandAndPatchEdits);
				} else {
					L.info("edits seem valid; use --write-to-exe to patch the executable"
							+ " or --write-hack-proto to compile edits into a file");
				}
			} else {
				if (options.listRelocations) {
					expandedExecutable.listRelocations();
				} else {
					expandedExecutable.logDetails(options.showOverlayProcs);
				}
			}
		} else if (!patches.isEmpty()) {
			L.info(patches.size() + " patches:");
			for (Patch patch : patches) {
				patch.logDescription(options.showPatchBytes);
			}
		}
	}

	private static void logUsage() {
		L.info("For executable info:");
		L.info("  java -jar UltimaPatcher.jar"
				+ " --exe=<exeFile> [--list-relocations | --show-overlay-procs]");
		L.info("For patch info:");
		L.info("  java -jar UltimaPatcher.jar --patch=<patchFile> [--show-patch-bytes]");
		L.info("To apply patches directly to an executable:");
		L.info("  java -jar UltimaPatcher.jar --exe=<exeFile> "
				+ " --expand-overlay=<segmentIndex>:<newLength>..."
				+ " --patch=<patchFile>..."
				+ " --write-to-exe");
		L.info("To compile patches to a hack proto:");
		L.info("  java -jar UltimaPatcher.jar --exe=<exeFile> "
				+ " --expand-overlay=<segmentIndex>:<newLength>..."
				+ " --patch=<patchFile>..."
				+ " --write-hack=<hackProtoFile>");
	}

	private static Patch readPatchFile(Path patchPath) throws IOException {
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
			int segmentIndex = buffer.getInt(offsetInPatch);

			offsetInPatch -= Integer.BYTES;
			int startWithinSegment = buffer.getInt(offsetInPatch);

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

			patchBlocks.add(new PatchBlock(
					segmentIndex, startWithinSegment, codeBytes, relocationOffsets));
		}

		return new Patch(description, targetFileLength, patchBlocks);
	}

	private static ExecutableEditState withExpandedOverlays(
			Executable executable, List<String> expandOverlayArgs) {
		ExecutableEditOperation expandOverlaysOperation = expandOverlayArgs.stream()
				.map(expandOverlayArg -> {
					String[] segments = expandOverlayArg.split(":");
					int segmentIndex = Integer.valueOf(segments[0]);
					int newLength = Integer.decode(segments[1]);
					L.info(String.format(
							"expand segment %d to length of 0x%04X", segmentIndex, newLength));
					return (ExecutableEditOperation) new ExpandOverlayOperation(
							segmentIndex,
							newLength,
							uncheckIoBiFunction(UltimaPatcher::applyEditsInMemory));
				})
				.reduce(state -> state, (op1, op2) -> op1.andThen(op2));

		return expandOverlaysOperation.apply(ExecutableEditState.startingWith(executable));
	}

	private static Executable applyEditsInMemory(Executable executable, List<Edit> edits)
			throws IOException {
		// applying the edits to an in-memory file and then reading the edited executable
		// from scratch is hackish, but doing this is easier than re-writing the Executable class.

		byte[] exeBytes;
		try (FileChannel exeChannel = FileChannel.open(executable.path, StandardOpenOption.READ)) {
			exeBytes = Util.read(exeChannel, 0, (int) exeChannel.size());
		}

		FileSystem jimfs = Jimfs.newFileSystem();
		Path tempExePath = jimfs.getPath("temp.exe");
		try (FileChannel tempExeChannel = FileChannel.open(
				tempExePath, StandardOpenOption.CREATE, StandardOpenOption.WRITE)) {
			Util.write(tempExeChannel, 0, exeBytes);
		}

		applyEdits(tempExePath, edits);
		return Executable.readFromFile(tempExePath);
	}

	private static ImmutableList<Edit> editsForPatches(Executable executable, List<Patch> patches) {
		List<PatchBlock> blocks = patches.stream()
				.flatMap(p -> p.blocks.stream())
				.collect(Collectors.toList());

		List<PatchBlock> blocksBySegmentAndOffset = blocks.stream()
				.sorted(Comparator.comparing((PatchBlock b) -> b.segmentIndex)
						.thenComparing(b -> b.startOffset))
				.collect(Collectors.toList());

		Streams.forEachPair(
				blocksBySegmentAndOffset.stream(),
				blocksBySegmentAndOffset.stream().skip(1),
				(precedingBlock, block) -> {
			if (block.segmentIndex == precedingBlock.segmentIndex
					&& block.startOffset < precedingBlock.endOffset()) {
				throw new PatchApplicationException(String.format(
						"block for %s overlaps block for %s",
						block.formatAddress(),
						precedingBlock.formatAddress()));
			}
		});

		ImmutableList<Edit> edits; {
			ImmutableList.Builder<Edit> builder = ImmutableList.builder();

			RelocationTracker relocationTracker = RelocationTracker.forExecutable(executable);

			for (PatchBlock block : blocks) {
				Patchable patchable = Optional.of(executable.segments.get(block.segmentIndex))
						.map(Segment::patchable)
						.orElseThrow(() -> new PatchApplicationException(String.format(
							"no segment for block for %s", block.formatAddress())));

				if (block.startOffset < patchable.startOffset()
						|| block.endOffset() > patchable.endOffset()) {
					throw new PatchApplicationException(String.format(
							"block for %s is outside bounds of segment", block.formatAddress()));
				}

				for (Integer relocationWithinBlock : block.relocationsWithinBlock) {
					if (!(0 <= relocationWithinBlock
							&& relocationWithinBlock < block.codeBytes.length)) {
						throw new PatchApplicationException(String.format(
								"block for %s has out-of-range relocation offset 0x%X",
								block.formatAddress(),
								relocationWithinBlock));
					}
				}

				Set<Integer> relocationOffsets = block.relocationsWithinBlock.stream()
						.map(r -> block.startOffset + r)
						.collect(Collectors.toSet());

				relocationTracker.replaceInRange(
						block.segmentIndex,
						block.startOffset,
						block.endOffset(),
						relocationOffsets);

				builder.add(new OverwriteEdit(
						patchable.startInFile() + block.startOffset, block.codeBytes));
			}

			builder.addAll(relocationTracker.produceEdits());

			edits = builder.build();
		}

		return edits;
	}

	private static void applyEdits(Path filePath, Iterable<Edit> edits) {
		callUncheckedIoRunnable(() -> {
			try (SeekableByteChannel channel = FileChannel.open(
					filePath, StandardOpenOption.READ, StandardOpenOption.WRITE)) {
				for (Edit edit : edits) {
					edit.applyToFile(channel);
				}
			}
		});
	}

	private static void writeHackProto(Path hackPath, ImmutableList<Edit> expandAndPatchEdits) {
		HackProto.Hack.Builder hackBuilder = HackProto.Hack.newBuilder();
		expandAndPatchEdits.stream()
				.map(Edit::toProtoMessage)
				.forEachOrdered(hackBuilder::addEdit);

		callUncheckedIoRunnable(() ->
				Files.write(hackPath, hackBuilder.build().toByteArray()));
	}
}
