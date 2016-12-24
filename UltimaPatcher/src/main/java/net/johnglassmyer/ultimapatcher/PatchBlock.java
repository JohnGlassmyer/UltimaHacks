package net.johnglassmyer.ultimapatcher;

import java.util.Collection;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class PatchBlock {
	static private final Logger L = LogManager.getLogger(PatchBlock.class);

	final int startInExe;
	final byte[] codeBytes;
	final Collection<Integer> relocationSitesInBlock;

	PatchBlock(int startInExe, byte[] codeBytes, Collection<Integer> relocationSitesInBlock) {
		this.startInExe = startInExe;
		this.codeBytes = codeBytes;
		this.relocationSitesInBlock = relocationSitesInBlock;
	}

	void logSummary() {
		logInfo(false);
	}

	void logDetails() {
		logInfo(true);
	}

	private void logInfo(boolean includeCodeBytes) {
		L.info(String.format("block for offset 0x%X of length 0x%X having %d relocation site(s)",
				startInExe, codeBytes.length, relocationSitesInBlock.size()));

		if (includeCodeBytes) {
			StringBuilder stringBuilder = new StringBuilder();
			for (int i = 0; i < codeBytes.length; i++) {
				if (i % Util.PARAGRAPH_SIZE == 0) {
					stringBuilder.append("    ");
				}
				stringBuilder.append(String.format("%02X", codeBytes[i]));
				stringBuilder.append(String.format(relocationSitesInBlock.contains(i) ? "-" : " "));
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
