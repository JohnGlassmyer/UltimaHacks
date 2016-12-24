package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.function.Function;

class Util {
	static final int PARAGRAPH_SIZE = 0x10;

	interface IoFunction<T, U> {
		U perform(T t) throws IOException;
	}

	static <T, U> Function<T, U> rethrowIoException(IoFunction<T, U> ioOperation) {
		return new Function<T, U>() {
			@Override
			public U apply(T t) {
				try {
					return ioOperation.perform(t);
				} catch (IOException e) {
					throw new RuntimeException(e);
				}
			}
		};
	}

	static void printHexValue(long overlayCodeStart, String label) {
		System.out.format("0x%8X %s\n", overlayCodeStart, label);
	}

	static int roundUpToParagraph(int value) {
		int remainder = value % PARAGRAPH_SIZE;
		return (remainder == 0) ? value : value - remainder + PARAGRAPH_SIZE;
	}

	static void checkBytesLength(byte[] bytes, long expected) {
		if (expected != bytes.length) {
			String message = String.format("expected %d bytes, got %d", expected, bytes.length);
			throw new IllegalArgumentException(message);
		}
	}

	static byte[] readBytes(RandomAccessFile file, long start, int length) throws IOException {
		byte[] bytes = new byte[length];
		file.seek(start);
		file.readFully(bytes);
		return bytes;
	}
}
