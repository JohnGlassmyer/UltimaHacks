package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.io.RandomAccessFile;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class OverwriteEdit extends Edit {
	static private final Logger L = LogManager.getLogger(OverwriteEdit.class);

	private final int startInFile;
	private final byte[] replacementBytes;

	OverwriteEdit(int startInFile, byte[] replacementBytes) {
		this.startInFile = startInFile;
		this.replacementBytes = replacementBytes;
	}

	@Override
	void apply(RandomAccessFile file) throws IOException {
		L.info(String.format("writing 0x%X bytes at 0x%X", replacementBytes.length, startInFile));

		file.seek(startInFile);
		file.write(replacementBytes);
	}

	@Override
	public String toString() {
		return String.format(
				"%s(start: %X, length: %X)",
				OverwriteEdit.class.getSimpleName(),
				startInFile,
				replacementBytes.length);
	}
}
