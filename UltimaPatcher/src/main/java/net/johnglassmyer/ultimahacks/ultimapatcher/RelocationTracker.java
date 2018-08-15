package net.johnglassmyer.ultimahacks.ultimapatcher;

import static java.util.stream.IntStream.range;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.NavigableSet;
import java.util.Set;
import java.util.TreeSet;

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

	Collection<Edit> produceEdits() {
		Collection<Edit> edits = new ArrayList<>();

		LoadModule loadModule = executable.loadModule;
		edits.addAll(loadModule.relocationTable.produceEdits(loadModuleRelocations));

		relocationsForOverlay.forEach((segmentIndex, relocations) -> {
			Overlay overlay = executable.segments.get(segmentIndex).optionalOverlay.get();
			edits.addAll(overlay.relocationTable.produceEdits(relocations));
		});

		return edits;
	}
}
