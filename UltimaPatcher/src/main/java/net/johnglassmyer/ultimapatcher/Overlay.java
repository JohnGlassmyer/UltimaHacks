package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

class Overlay implements Patchable {
	static private List<Integer> parseRelocationSitesInOverlay(byte[] bytes) {
		List<Integer> sitesInOverlay = new ArrayList<>();
		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		buffer.order(LITTLE_ENDIAN);
		for (int i = 0; i < bytes.length / OverlayRelocationTableEditor.BYTES_PER_ENTRY; i++) {
			sitesInOverlay.add(Short.toUnsignedInt(buffer.getShort()));
		}

		return sitesInOverlay;
	}

	private class OverlayRelocationTableEditor extends RelocationTableEditor {
		static private final int BYTES_PER_ENTRY = 2;

		private final int capacity;

		OverlayRelocationTableEditor(
				Collection<Integer> relocationSitesInFile,
				int capacity) {
			super(relocationSitesInFile, capacity);
			this.capacity = capacity;
		}

		@Override
		protected OverwriteEdit generateCountEdit(int newCount) {
			int byteCount = newCount * BYTES_PER_ENTRY;

			byte[] bytes = new byte[2];
			bytes[0] = (byte) (byteCount & 0xFF);
			bytes[1] = (byte) ((byteCount >> 8) & 0xFF);

			int countPositionInFile = Overlay.this.stub.startInFile
					+ OverlayStub.RELOCATION_TABLE_BYTE_COUNT_OFFSET;
			return new OverwriteEdit(countPositionInFile, bytes);
		}

		@Override
		protected OverwriteEdit generateTableEdit(List<Integer> relocationSitesInFile) {
			byte[] bytes = new byte[capacity * BYTES_PER_ENTRY];
			ByteBuffer buffer = ByteBuffer.wrap(bytes);
			buffer.order(LITTLE_ENDIAN);

			for (int i = 0; i < relocationSitesInFile.size(); i++) {
				int siteInOverlay = relocationSitesInFile.get(i) - Overlay.this.startInFile;
				buffer.putShort(i * BYTES_PER_ENTRY, (short) siteInOverlay);
			}

			return new OverwriteEdit(getTableStartInFile(), bytes);
		}

		@Override
		protected int getTableStartInFile() {
			return Overlay.this.startInFile + stub.codeSize;
		}
	}

	final OverlayStub stub;
	private final int startInFile;
	private final int endInFile;
	private final byte[] relocationTableBytes;

	Overlay(OverlayStub stubHeader, int startInFile, int endInFile, byte[] relocationTableBytes) {
		this.stub = stubHeader;
		this.startInFile = startInFile;
		this.endInFile = endInFile;
		this.relocationTableBytes = relocationTableBytes;
	}

	@Override
	public int getCodeStart() {
		return startInFile;
	}

	@Override
	public int getCodeLength() {
		return stub.codeSize;
	}

	@Override
	public RelocationTableEditor createRelocationTableEditor() {
		int spaceForRelocationTable = (endInFile - startInFile) - stub.codeSize;
		int capacity = spaceForRelocationTable / OverlayRelocationTableEditor.BYTES_PER_ENTRY;

		Collection<Integer> relocationSitesInFile = new ArrayList<>();
		for (int siteInOverlay : parseRelocationSitesInOverlay(relocationTableBytes)) {
			int siteInFile = startInFile + siteInOverlay;
			relocationSitesInFile.add(siteInFile);
		}

		return new OverlayRelocationTableEditor(relocationSitesInFile, capacity);
	}
}
