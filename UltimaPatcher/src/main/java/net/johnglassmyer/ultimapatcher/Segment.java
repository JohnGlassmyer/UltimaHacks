package net.johnglassmyer.ultimapatcher;

import java.util.Optional;

class Segment {
	final SegmentInfo info;
	final Optional<Overlay> optionalOverlay;

	Segment(SegmentInfo info, Optional<Overlay> optionalOverlay) {
		this.info = info;
		this.optionalOverlay = optionalOverlay;
	}
}
