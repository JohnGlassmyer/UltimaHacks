package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.io.RandomAccessFile;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class CopyEdit extends Edit {
	static private final Logger L = LogManager.getLogger(CopyEdit.class);

	private final int source;
	private final int length;
	private final int destination;

	CopyEdit(int sourceStart, int length, int destinationStart) {
		this.source = sourceStart;
		this.length = length;
		this.destination = destinationStart;
	}

	@Override
	void apply(RandomAccessFile file) throws IOException {
		L.info(String.format(
				"copying 0x%X bytes from 0x%X to 0x%X", length, source, destination));

		byte[] bytes = new byte[length];
		file.seek(source);
		file.readFully(bytes);

		file.seek(destination);
		file.write(bytes);
	}

	@Override
	public String toString() {
		return String.format(
				"%s(source: %X, length: %X, destination: %X)",
				CopyEdit.class.getSimpleName(),
				source,
				length,
				destination);
	}
}
