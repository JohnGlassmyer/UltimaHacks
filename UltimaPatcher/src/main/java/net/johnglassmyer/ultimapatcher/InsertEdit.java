package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;

class InsertEdit implements Edit {
	private final int start;
	private final int length;

	InsertEdit(int positionInFile, int length) {
		this.start = positionInFile;
		this.length = length;
	}

	@Override
	public void apply(SeekableByteChannel channel) throws IOException {
		byte[] tail = Util.read(channel, start, (int) (channel.size() - start));

		// insert zero-bytes
		Util.write(channel, start, new byte[length]);

		Util.write(channel, start + length, tail);
	}

	@Override
	public String toString() {
		return String.format(
				"%s(position: %X, length: %X)",
				InsertEdit.class.getSimpleName(),
				start,
				length);
	}
}
