package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.nio.ByteBuffer;

class SegmentInfo {
	static final int LENGTH = 8;
	static final int END_OFFSET_OFFSET = 2;

	static SegmentInfo parseFrom(byte[] bytes) {
		Util.checkBytesLength(bytes, LENGTH);

		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		buffer.order(LITTLE_ENDIAN);

		int segmentBase = Short.toUnsignedInt(buffer.getShort(0));
		int endOffset = Short.toUnsignedInt(buffer.getShort(END_OFFSET_OFFSET));
		int flags = Short.toUnsignedInt(buffer.getShort(4));
		int startOffset = Short.toUnsignedInt(buffer.getShort(6));
		return new SegmentInfo(segmentBase, flags, startOffset, endOffset);
	}

	final int segmentBase;
	final int flags;
	final int startOffset;
	final int endOffset;

	private SegmentInfo(int segmentBase, int flags, int startOffset, int endOffset) {
		this.segmentBase = segmentBase;
		this.flags = flags;
		this.startOffset = startOffset;
		this.endOffset = endOffset;
	}

	boolean isCode() {
		return (flags & 1) != 0;
	}

	boolean isOverlay() {
		return (flags & 2) != 0;
	}

	boolean isData() {
		return (flags & 4) != 0;
	}

	int getLength() {
		return endOffset - startOffset;
	}
}
