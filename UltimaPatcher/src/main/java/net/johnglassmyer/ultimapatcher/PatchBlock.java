package net.johnglassmyer.ultimapatcher;

import java.util.Collection;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class PatchBlock {
	static private final Logger L = LogManager.getLogger(PatchBlock.class);

	final int segmentIndex;
	final int startOffset;
	final byte[] codeBytes;
	final Collection<Integer> relocationsWithinBlock;

	PatchBlock(
			int segmentIndex,
			int startOffset,
			byte[] codeBytes,
			Collection<Integer> relocationsWithinBlock) {
		this.segmentIndex = segmentIndex;
		this.startOffset = startOffset;
		this.codeBytes = codeBytes;
		this.relocationsWithinBlock = relocationsWithinBlock;
	}

	int endOffset() {
		return startOffset + codeBytes.length;
	}

	String formatAddress() {
		return String.format("%d:0x%04X", segmentIndex, startOffset);
	}

	void logInfo(boolean includeCodeBytes) {
		L.info(String.format("block for %d:0x%04X of length 0x%X having %d relocation site(s)",
				segmentIndex, startOffset, codeBytes.length, relocationsWithinBlock.size()));

		if (includeCodeBytes) {
			StringBuilder stringBuilder = new StringBuilder();
			for (int i = 0; i < codeBytes.length; i++) {
				if (i % Util.PARAGRAPH_SIZE == 0) {
					stringBuilder.append("    ");
				}
				stringBuilder.append(String.format("%02X", codeBytes[i]));
				stringBuilder.append(String.format(relocationsWithinBlock.contains(i) ? "-" : " "));
				if ((i + 1) % Util.PARAGRAPH_SIZE == 0) {
					L.info(stringBuilder.toString());
					stringBuilder.setLength(0);
				}
			}
			if (stringBuilder.length() > 0) {
				L.info(stringBuilder.toString());
			}
		}
	}
}
