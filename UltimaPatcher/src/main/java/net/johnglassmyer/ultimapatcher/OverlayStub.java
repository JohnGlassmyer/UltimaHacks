package net.johnglassmyer.ultimapatcher;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class OverlayStub {
	static final int HEADER_LENGTH = 0x20;
	static final int RELOCATION_TABLE_BYTE_COUNT_OFFSET = 10;

	static OverlayStub create(int startInFile, byte[] bytes) {
		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		buffer.order(ByteOrder.LITTLE_ENDIAN);

		int firstByte = Byte.toUnsignedInt(buffer.get(0));
		if (firstByte != 0xCD) {
			String message = String.format("Overlay stub has unexpected first byte: 0x%02X", firstByte);
			throw new IllegalArgumentException(message);
		}

		// Assuming that no DOS game executable is > 2GB in size
		int overlayStartFromFbovEnd = buffer.getInt(4);
		int codeSize = Short.toUnsignedInt(buffer.getShort(8));
		int relocationTableByteCount = Short.toUnsignedInt(buffer.getShort(RELOCATION_TABLE_BYTE_COUNT_OFFSET));

		int procCount = Short.toUnsignedInt(buffer.getShort(12));
		List<StubProc> procs = new ArrayList<>(procCount);
		for (int i = 0; i < procCount; i++) {
			int procStart = HEADER_LENGTH + i * StubProc.LENGTH;
			int procEnd = procStart + StubProc.LENGTH;
			procs.add(StubProc.parseFrom(Arrays.copyOfRange(bytes, procStart, procEnd)));
		}

		return new OverlayStub(
				startInFile, overlayStartFromFbovEnd, codeSize, relocationTableByteCount, procs);
	}

	OverlayStub(
			int startInFile,
			int overlayStartFromFbovEnd,
			int codeSize,
			int relocationTableByteCount,
			List<StubProc> procs) {
		this.startInFile = startInFile;
		this.overlayStartFromFbovEnd = overlayStartFromFbovEnd;
		this.codeSize = codeSize;
		this.relocationTableByteCount = relocationTableByteCount;
		this.procs = procs;
	}

	final int startInFile;
	final int overlayStartFromFbovEnd;
	final int codeSize;
	final int relocationTableByteCount;
	final List<StubProc> procs;
}
