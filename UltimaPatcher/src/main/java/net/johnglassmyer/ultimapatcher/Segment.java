package net.johnglassmyer.ultimapatcher;

import java.util.Optional;

class Segment {
	interface Patchable {
		int startInFile();

		int startOffset();

		int endOffset();
	}

	final SegmentTableEntry tableEntry;
	final int startInFile;
	final Optional<Overlay> optionalOverlay;

	Segment(SegmentTableEntry tableEntry, int startInFile, Optional<Overlay> optionalOverlay) {
		this.tableEntry = tableEntry;
		this.startInFile = startInFile;
		this.optionalOverlay = optionalOverlay;
	}

	Patchable patchable() {
		return new Patchable() {
			@Override
			public int startInFile() {
				return optionalOverlay.map(overlay -> overlay.startInFile)
						.orElse(startInFile);
			}

			@Override
			public int startOffset() {
				return optionalOverlay.map(overlay -> 0)
						.orElse(tableEntry.startOffset);
			}

			@Override
			public int endOffset() {
				return optionalOverlay.map(overlay -> overlay.stub.codeSize)
						.orElse(tableEntry.endOffset);
			}
		};
	}
}
