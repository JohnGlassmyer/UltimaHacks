package net.johnglassmyer.ultimapatcher;

import java.util.function.UnaryOperator;

@FunctionalInterface
interface ExecutableEditOperation extends UnaryOperator<ExecutableEditState> {
	default ExecutableEditOperation andThen(ExecutableEditOperation after) {
		return state -> after.apply(apply(state));
	}
}
