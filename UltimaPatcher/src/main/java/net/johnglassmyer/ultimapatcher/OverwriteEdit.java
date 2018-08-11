package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;

class OverwriteEdit implements Edit {
	private final int start;
	private final byte[] replacementBytes;

	OverwriteEdit(int startInFile, byte[] replacementBytes) {
		this.start = startInFile;
		this.replacementBytes = replacementBytes;
	}

	@Override
	public void apply(SeekableByteChannel channel) throws IOException {
		Util.write(channel, start, replacementBytes);
	}

	@Override
	public String toString() {
		return String.format(
				"%s(start: %X, length: %X)",
				OverwriteEdit.class.getSimpleName(),
				start,
				replacementBytes.length);
	}
}
