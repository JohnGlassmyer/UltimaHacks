package net.johnglassmyer.ultimapatcher;

class Overlay {
	final OverlayStub stub;
	final int startInFile;
	final OverlayRelocationTable relocationTable;

	Overlay(
			OverlayStub stubHeader,
			int startInFile,
			OverlayRelocationTable relocationTable) {
		this.stub = stubHeader;
		this.startInFile = startInFile;
		this.relocationTable = relocationTable;
	}
}
