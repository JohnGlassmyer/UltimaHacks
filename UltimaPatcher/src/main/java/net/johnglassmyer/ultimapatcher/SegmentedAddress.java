package net.johnglassmyer.ultimapatcher;

import static com.google.common.base.Verify.verify;

class SegmentAndOffset {
	static SegmentAndOffset fromString(String string) {
		String[] segments = string.split(":");
		verify(segments.length == 2);

		int segmentIndex = Integer.valueOf(segments[0]);
		verify(segmentIndex >= 0);

		int offset = Integer.decode(segments[1]);
		verify(offset >= 0);

		return new SegmentAndOffset(segmentIndex, offset);
	}

	final int segmentIndex;
	final int offset;

	private SegmentAndOffset(int segmentIndex, int offset) {
		this.segmentIndex = segmentIndex;
		this.offset = offset;
	}
}
