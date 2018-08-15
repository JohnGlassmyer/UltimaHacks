package net.johnglassmyer.ultimahacks.ultimapatcher;

import static com.google.common.base.Verify.verify;

class SegmentAndOffset {
	private static final String INVALID_ADDRESS_MESSAGE_TEMPLATE =
			"\"%s\" is not a valid segmented address; should be segmentIndex:offset";

	static SegmentAndOffset fromString(String string) {
		String[] segments = string.split(":");
		verify(segments.length == 2, INVALID_ADDRESS_MESSAGE_TEMPLATE, string);

		int segmentIndex = Integer.valueOf(segments[0]);
		verify(segmentIndex >= 0, INVALID_ADDRESS_MESSAGE_TEMPLATE, string);

		int offset = Integer.decode(segments[1]);
		verify(offset >= 0, INVALID_ADDRESS_MESSAGE_TEMPLATE, string);

		return new SegmentAndOffset(segmentIndex, offset);
	}

	final int segmentIndex;
	final int offset;

	private SegmentAndOffset(int segmentIndex, int offset) {
		this.segmentIndex = segmentIndex;
		this.offset = offset;
	}
}
