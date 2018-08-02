package net.johnglassmyer.ultimapatcher;

import java.util.Collection;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class Patch {
	static private final Logger L = LogManager.getLogger(Patch.class);

	final String description;
	final int targetFileLength;
	final Collection<PatchBlock> blocks;

	Patch(String description, int targetFileLength, Collection<PatchBlock> blocks) {
		this.description = description;
		this.targetFileLength = targetFileLength;
		this.blocks = blocks;
	}

	void logSummary() {
		logDescription();
	}

	void logDetails() {
		logDescription();

		L.info(String.format("patch has target file length of 0x%X", targetFileLength));

		for (PatchBlock block : blocks) {
			block.logDetails();
		}
	}

	private void logDescription() {
		L.info(String.format("patch \"%s\" with %d block(s)", description, blocks.size()));
	}
}
