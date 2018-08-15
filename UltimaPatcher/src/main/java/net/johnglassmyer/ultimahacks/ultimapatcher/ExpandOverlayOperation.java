package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.util.List;
import java.util.function.BiFunction;

import com.google.common.collect.ImmutableList;

class ExpandOverlayOperation implements ExecutableEditOperation {
	private final int segmentIndex;
	private final int newLength;
	private final BiFunction<Executable, List<Edit>, Executable> editSimulator;

	ExpandOverlayOperation(
			int segmentIndex,
			int newLength,
			BiFunction<Executable, List<Edit>, Executable> editSimulator) {
		this.segmentIndex = segmentIndex;
		this.newLength = newLength;
		this.editSimulator = editSimulator;
	}

	@Override
	public ExecutableEditState apply(ExecutableEditState state) {
		List<Edit> expandEdits = state.executable.expandOverlay(segmentIndex, newLength);
		Executable expandedExecutable = editSimulator.apply(state.executable, expandEdits);

		ImmutableList.Builder<Edit> combinedEdits = ImmutableList.builder();
		combinedEdits.addAll(state.accumulatedEdits);
		combinedEdits.addAll(expandEdits);
		return new ExecutableEditState(expandedExecutable, combinedEdits.build());
	}
}
