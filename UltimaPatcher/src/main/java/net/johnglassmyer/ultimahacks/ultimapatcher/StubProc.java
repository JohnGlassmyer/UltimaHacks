package net.johnglassmyer.ultimahacks.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.nio.ByteBuffer;

class StubProc {
	static int LENGTH = 5;

	static byte[] bytesFor(int procStartInOverlay) {
		byte[] bytes = new byte[5];
		bytes[0] = (byte) 0xCD;
		bytes[1] = 0x3F;
		bytes[2] = (byte) (procStartInOverlay & 0xFF);
		bytes[3] = (byte) ((procStartInOverlay >> 8) & 0xFF);
		bytes[4] = 0; // TODO: when is this other than zero?
		return bytes;
	}

	static StubProc parseFrom(byte[] procBytes) {
		ByteBuffer buffer = ByteBuffer.wrap(procBytes);
		buffer.order(LITTLE_ENDIAN);

		int startInOverlay = Short.toUnsignedInt(buffer.getShort(2));

		return new StubProc(startInOverlay);
	}

	final int startInOverlay;

	StubProc(int startInOverlay) {
		this.startInOverlay = startInOverlay;
	}
}
