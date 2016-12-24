package net.johnglassmyer.ultimapatcher;

interface Patchable {
	int getCodeStart();

	int getCodeLength();

	RelocationTableEditor createRelocationTableEditor();
}
