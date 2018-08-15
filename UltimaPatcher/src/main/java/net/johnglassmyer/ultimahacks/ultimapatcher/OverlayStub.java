package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class OverlayStub {
	static final int RELOCATION_BYTE_COUNT_OFFSET = 0x0A;
	static final int HEADER_LENGTH = 0x20;

	static OverlayStub create(byte[] bytes) {
		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		buffer.order(ByteOrder.LITTLE_ENDIAN);

		int firstByte = Byte.toUnsignedInt(buffer.get(0));
		if (firstByte != 0xCD) {
			throw new IllegalArgumentException(String.format(
					"Overlay stub has unexpected first byte: 0x%02X", firstByte));
		}

		// Assuming that no DOS game executable is > 2GB in size
		int overlayStartFromFbovEnd = buffer.getInt(4);
		int codeSize = Short.toUnsignedInt(buffer.getShort(8));
		int relocationTableByteCount = Short.toUnsignedInt(
				buffer.getShort(RELOCATION_BYTE_COUNT_OFFSET));

		int procCount = Short.toUnsignedInt(buffer.getShort(12));
		List<StubProc> procs = new ArrayList<>(procCount);
		for (int i = 0; i < procCount; i++) {
			int procStart = HEADER_LENGTH + i * StubProc.LENGTH;
			int procEnd = procStart + StubProc.LENGTH;
			procs.add(StubProc.parseFrom(Arrays.copyOfRange(bytes, procStart, procEnd)));
		}

		return new OverlayStub(overlayStartFromFbovEnd, codeSize, relocationTableByteCount, procs);
	}

	OverlayStub(
			int overlayStartFromFbovEnd,
			int codeSize,
			int relocationTableLength,
			List<StubProc> procs) {
		this.overlayStartFromFbovEnd = overlayStartFromFbovEnd;
		this.codeSize = codeSize;
		this.relocationTableLength = relocationTableLength;
		this.procs = procs;
	}

	final int overlayStartFromFbovEnd;
	final int codeSize;
	final int relocationTableLength;
	final List<StubProc> procs;
}
