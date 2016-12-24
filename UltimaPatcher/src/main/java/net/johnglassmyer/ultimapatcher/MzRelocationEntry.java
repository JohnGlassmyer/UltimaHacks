package net.johnglassmyer.ultimapatcher;

class MzRelocationEntry {
	final int segment;
	final int offset;

	MzRelocationEntry(int segment, int offset) {
		this.segment = segment;
		this.offset = offset;
	}

	int calculateAddress() {
		return segment * Util.PARAGRAPH_SIZE + offset;
	}
}
