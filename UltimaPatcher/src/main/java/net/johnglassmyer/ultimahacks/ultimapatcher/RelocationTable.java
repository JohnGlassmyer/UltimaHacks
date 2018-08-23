package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.SortedSet;
import com.google.common.collect.ImmutableSet;

abstract class RelocationTable {
	final int startInFile;
	final ImmutableSet<Integer> originalAddresses;

	protected RelocationTable(int startInFile, ImmutableSet<Integer> originalAddresses) {
		this.startInFile = startInFile;
		this.originalAddresses = originalAddresses;
	}

	List<OverwriteEdit> produceEdits(SortedSet<Integer> replacementAddresses) {
		if (replacementAddresses.equals(originalAddresses)) {
			return Collections.emptyList();
		}

		List<OverwriteEdit> edits = new ArrayList<>();
		if (replacementAddresses.size() != originalAddresses.size()) {
			edits.add(produceCountEdit(replacementAddresses.size()));
		}

		edits.add(produceTableEdit(Collections.unmodifiableSortedSet(replacementAddresses)));

		return edits;
	}

	protected abstract OverwriteEdit produceCountEdit(int newCount);

	protected abstract OverwriteEdit produceTableEdit(SortedSet<Integer> relocationSitesInFile);
}
