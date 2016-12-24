package net.johnglassmyer.ultimapatcher;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

abstract class RelocationTableEditor {
	static private Logger L = LogManager.getLogger(RelocationTableEditor.class);

	private final Set<Integer> originalRelocationSitesInFile;
	private final SortedSet<Integer> relocationSitesInFile;
	private final int capacity;

	protected RelocationTableEditor(Collection<Integer> originalRelocationSitesInFile, int capacity) {
		this.originalRelocationSitesInFile = new HashSet<>(originalRelocationSitesInFile);
		this.relocationSitesInFile = new TreeSet<>(originalRelocationSitesInFile);
		this.capacity = capacity;
	}

	void replaceRelocationsInRange(
			int startInFile, int endInFile, Collection<Integer> newRelocationSitesInFile)
					throws PatchApplicationException {
		Iterator<Integer> iterator = relocationSitesInFile.iterator();
		while (iterator.hasNext()) {
			int existingRelocation = iterator.next();
			if ((startInFile <= existingRelocation && existingRelocation < endInFile)
					&& !newRelocationSitesInFile.contains(existingRelocation)) {
				L.info(String.format("removing existing relocation at 0x%X", existingRelocation));
				iterator.remove();
			}
		}

		for (Integer newRelocation : newRelocationSitesInFile) {
			if (!relocationSitesInFile.contains(newRelocation)) {
				if (relocationSitesInFile.size() + 1 > capacity) {
					throw new PatchApplicationException(String.format(
							"no room in relocation table at 0x%X for offset 0x%X", getTableStartInFile(), newRelocation));
				}

				L.info(String.format("adding new relocation at 0x%X", newRelocation));
				relocationSitesInFile.add(newRelocation);
			} else {
				L.info(String.format("relocation at 0x%X already exists", newRelocation));
			}
		}
	}

	SortedSet<Integer> getOriginalRelocationSitesInFile() {
		return new TreeSet<Integer>(originalRelocationSitesInFile);
	}

	int getCapacity() {
		return capacity;
	}

	Collection<OverwriteEdit> generateEdits() {
		if (relocationSitesInFile.equals(originalRelocationSitesInFile)) {
			return Collections.emptySet();
		}

		OverwriteEdit countEdit = generateCountEdit(relocationSitesInFile.size());
		OverwriteEdit tableEdit = generateTableEdit(new ArrayList<>(relocationSitesInFile));
		return Arrays.asList(countEdit, tableEdit);
	}

	protected abstract OverwriteEdit generateCountEdit(int newCount);

	protected abstract OverwriteEdit generateTableEdit(List<Integer> relocationSitesInFile);

	protected abstract int getTableStartInFile();
}
