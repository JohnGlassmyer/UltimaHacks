package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;

class CopyEdit implements Edit {
	private final int source;
	private final int length;
	private final int destination;

	CopyEdit(int sourceStart, int length, int destinationStart) {
		this.source = sourceStart;
		this.length = length;
		this.destination = destinationStart;
	}

	@Override
	public void apply(SeekableByteChannel channel) throws IOException {
		byte[] bytes = Util.read(channel, source, length);

		Util.write(channel, destination, bytes);
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
