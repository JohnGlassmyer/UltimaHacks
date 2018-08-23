package net.johnglassmyer.ultimahacks.ultimapatcher;

import static java.util.stream.IntStream.range;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NavigableSet;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

import com.google.common.collect.Maps;

class RelocationTracker {
	static RelocationTracker forExecutable(Executable executable) {
		NavigableSet<Integer> loadModuleRelocations = new TreeSet<>(
				executable.loadModule.relocationTable.originalAddresses);

		Map<Integer, NavigableSet<Integer>> overlayMap = new HashMap<>();
		range(0, executable.segments.size()).forEach(segmentIndex -> {
			Segment segment = executable.segments.get(segmentIndex);
			segment.optionalOverlay.ifPresent(overlay ->
				overlayMap.put(segmentIndex, new TreeSet<>(
						overlay.relocationTable.originalAddresses)));
		});

		return new RelocationTracker(executable, loadModuleRelocations, overlayMap);
	}

	private final Executable executable;
	private final NavigableSet<Integer> loadModuleRelocations;
	private final Map<Integer, NavigableSet<Integer>> relocationsForOverlay;

	RelocationTracker(
			Executable executable,
			NavigableSet<Integer> loadModuleRelocations,
			Map<Integer, NavigableSet<Integer>> relocationsForOverlay) {
		this.executable = executable;
		this.loadModuleRelocations = loadModuleRelocations;
		this.relocationsForOverlay = relocationsForOverlay;
	}

	void replaceInRange(
			int segmentIndex, int fromOffset, int toOffset, Set<Integer> relocationOffsets) {
		if (!relocationsForOverlay.containsKey(segmentIndex)) {
			Segment segment = executable.segments.get(segmentIndex);
			int base = segment.tableEntry.segmentBase * Util.PARAGRAPH_SIZE;
			loadModuleRelocations.subSet(base + fromOffset, base + toOffset).clear();
			relocationOffsets.forEach(offset -> loadModuleRelocations.add(base + offset));
		} else {
			NavigableSet<Integer> overlayRelocations = relocationsForOverlay.get(segmentIndex);
			overlayRelocations.subSet(fromOffset, toOffset).clear();
			overlayRelocations.addAll(relocationOffsets);
		}
	}

	List<Edit> produceEdits() {
		List<Edit> edits = new ArrayList<>();
		edits.addAll(produceAndCheckLoadModuleEdits());
		edits.addAll(produceAndCheckOverlayEdits());
		return edits;
	}

	List<OverwriteEdit> produceAndCheckLoadModuleEdits() {
		List<OverwriteEdit> loadModuleEdits =
				executable.loadModule.relocationTable.produceEdits(loadModuleRelocations);

		int loadModuleStartInFile = executable.loadModule.mzHeader.loadModuleStartInFile();

		loadModuleEdits.forEach(edit -> {
			if (loadModuleStartInFile < edit.getStart() + edit.length()) {
				throw new IllegalStateException(String.format(
						"relocation table edit %s for load module overlaps load module at %X",
						edit,
						loadModuleStartInFile));
			}
		});

		return loadModuleEdits;
	}

	List<OverwriteEdit> produceAndCheckOverlayEdits() {
		Map<Integer, List<OverwriteEdit>> editsBySegmentIndex =
				Maps.transformEntries(relocationsForOverlay, (segmentIndex, relocations) -> {
			return executable.segments.get(segmentIndex).optionalOverlay
					.map(overlay -> overlay.relocationTable.produceEdits(relocations)).get();
		});

		OptionalNavigableSet<Integer> sortedOverlayStarts = OptionalNavigableSet.of(
				executable.segments.stream()
						.flatMap(s -> s.optionalOverlay.stream())
						.map(o -> o.startInFile)
						.sorted()
						.collect(Collectors.toCollection(TreeSet::new)));

		editsBySegmentIndex.forEach((segmentIndex, edits) -> {
			executable.segments.get(segmentIndex).optionalOverlay
					.flatMap(overlay -> sortedOverlayStarts.optionalHigher(overlay.startInFile))
					.ifPresent(nextOverlayStart -> edits.stream()
							.filter(edit -> nextOverlayStart < edit.getStart() + edit.length())
							.findFirst()
							.ifPresent(overlappingEdit -> {
			throw new IllegalStateException(String.format(
					"relocation table edit %s for overlay %d overlaps following overlay at %X",
					overlappingEdit,
					segmentIndex,
					nextOverlayStart));
		}));});

		return editsBySegmentIndex.values().stream()
				.flatMap(List::stream)
				.collect(Collectors.toList());
	}
}
