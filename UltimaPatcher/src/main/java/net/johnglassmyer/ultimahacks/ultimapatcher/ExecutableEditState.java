package net.johnglassmyer.ultimahacks.ultimapatcher;

import com.google.common.collect.ImmutableList;

class ExecutableEditState {
	static ExecutableEditState startingWith(Executable executable) {
		return new ExecutableEditState(executable, ImmutableList.of());
	}

	final Executable executable;
	final ImmutableList<Edit> accumulatedEdits;

	ExecutableEditState(Executable executable, ImmutableList<Edit> edits) {
		this.executable = executable;
		this.accumulatedEdits = edits;
	}
}
