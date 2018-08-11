package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.SeekableByteChannel;

class Util {
	static final int PARAGRAPH_SIZE = 0x10;

	static void printHexValue(long overlayCodeStart, String label) {
		System.out.format("0x%8X %s\n", overlayCodeStart, label);
	}

	static void checkBytesLength(byte[] bytes, long expected) {
		if (expected != bytes.length) {
			String message = String.format("expected %d bytes, got %d", expected, bytes.length);
			throw new IllegalArgumentException(message);
		}
	}

	static byte[] read(SeekableByteChannel channel, long start, int length) throws IOException {
		channel.position(start);

		ByteBuffer buffer = ByteBuffer.wrap(new byte[length]);
		while (buffer.hasRemaining()) {
			int readLength = channel.read(buffer);
			if (readLength < 0) {
				throw new IllegalStateException("read past end of channel");
			}
		}

		return buffer.array();
	}

	static void write(SeekableByteChannel channel, long start, byte[] bytes) throws IOException {
		channel.position(start);

		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		while (buffer.hasRemaining()) {
			channel.write(buffer);
		}
	}

	@Deprecated
	static final String TODO_USE_FOREACHWITHINDEX =
			"TODO: once Guava has Streams.forEachWithIndex, use it instead of Streams.mapWithIndex";

	static ByteBuffer littleEndianBytes(int byteCount) {
		ByteBuffer buffer = ByteBuffer.wrap(new byte[byteCount]);
		buffer.order(LITTLE_ENDIAN);
		return buffer;
	}
}
