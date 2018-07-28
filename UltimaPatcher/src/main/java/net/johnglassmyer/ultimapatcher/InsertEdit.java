package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.io.RandomAccessFile;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class InsertEdit extends Edit {
	static private final Logger L = LogManager.getLogger(InsertEdit.class);

	private final int positionInFile;
	private final int length;

	InsertEdit(int positionInFile, int length) {
		this.positionInFile = positionInFile;
		this.length = length;
	}

	@Override
	void apply(RandomAccessFile file) throws IOException {
		L.info(String.format("inserting 0x%X bytes at 0x%X", length, positionInFile));

		int fileRemainderLength = (int) (file.length() - positionInFile);
		byte[] fileRemainder = Util.readBytes(file, positionInFile, fileRemainderLength);

		byte[] insertedZeros = new byte[length];
		file.seek(positionInFile);
		file.write(insertedZeros);

		file.seek(positionInFile + length);
		file.write(fileRemainder);
	}

	@Override
	public String toString() {
		return String.format(
				"%s(position: %X, length: %X)",
				InsertEdit.class.getSimpleName(),
				positionInFile,
				length);
	}
}
