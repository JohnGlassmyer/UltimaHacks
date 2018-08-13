package net.johnglassmyer.ultimapatcher;

import java.util.Collection;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class Patch {
	static private final Logger L = LogManager.getLogger(Patch.class);

	final String description;
	final int targetLength;
	final Collection<PatchBlock> blocks;

	Patch(String description, int targetLength, Collection<PatchBlock> blocks) {
		this.description = description;
		this.targetLength = targetLength;
		this.blocks = blocks;
	}

	void logDescription(boolean showPatchBytes) {
		L.info(String.format("patch \"%s\" with %d block(s)", description, blocks.size()));
		L.info(String.format("  target file length of 0x%X", targetLength));
		for (PatchBlock block : blocks) {
			block.logInfo(showPatchBytes);
		}
	}
}
