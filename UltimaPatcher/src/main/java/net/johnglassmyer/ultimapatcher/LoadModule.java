package net.johnglassmyer.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;

class LoadModule implements Patchable {
	static private class LoadModuleRelocationTableEditor extends RelocationTableEditor {
		static private final int RELOCATION_TABLE_COUNT_FILE_OFFSET = 6;
		static private final int BYTES_PER_ENTRY = 4;

		private final int capacity;
		private final int tableStartInFile;
		private final int loadModuleStartInFile;

		LoadModuleRelocationTableEditor(
				Collection<Integer> relocationSitesInFile, int capacity, int tableStartInFile, int loadModuleStartInFile) {
			super(relocationSitesInFile, capacity);
			this.capacity = capacity;
			this.tableStartInFile = tableStartInFile;
			this.loadModuleStartInFile = loadModuleStartInFile;
		}

		@Override
		protected OverwriteEdit generateCountEdit(int newCount) {
			byte[] bytes = new byte[2];
			bytes[0] = (byte) (newCount & 0xFF);
			bytes[1] = (byte) ((newCount >> 8) & 0xFF);

			return new OverwriteEdit(RELOCATION_TABLE_COUNT_FILE_OFFSET, bytes);
		}

		@Override
		protected OverwriteEdit generateTableEdit(List<Integer> relocationSitesInFile) {
			byte[] bytes = new byte[capacity * BYTES_PER_ENTRY];
			ByteBuffer buffer = ByteBuffer.wrap(bytes);
			buffer.order(LITTLE_ENDIAN);

			for (int i = 0; i < relocationSitesInFile.size(); i++) {
				int relocationSiteInLoadModule = relocationSitesInFile.get(i) - loadModuleStartInFile;

				int offsetPart = relocationSiteInLoadModule % Util.PARAGRAPH_SIZE;
				buffer.putShort(i * BYTES_PER_ENTRY, (short) offsetPart);

				int segmentPart = relocationSiteInLoadModule / Util.PARAGRAPH_SIZE;
				buffer.putShort(i * BYTES_PER_ENTRY + 2, (short) segmentPart);
			}

			return new OverwriteEdit(tableStartInFile, bytes);
		}

		@Override
		protected int getTableStartInFile() {
			return tableStartInFile;
		}
	}

	private final MzHeader mzHeader;
	private final Collection<Integer> relocationsSitesInLoadModule;

	LoadModule(MzHeader mzHeader, Collection<Integer> relocationSitesInLoadModule) {
		this.mzHeader = mzHeader;
		this.relocationsSitesInLoadModule = new HashSet<>(relocationSitesInLoadModule);
	}

	@Override
	public int getCodeStart() {
		return mzHeader.calculcateLoadModuleStartInFile();
	}

	@Override
	public int getCodeLength() {
		return mzHeader.calculateMzFileSize();
	}

	@Override
	public RelocationTableEditor createRelocationTableEditor() {
		int loadModuleStartInFile = mzHeader.calculcateLoadModuleStartInFile();

		Collection<Integer> sitesInFile = new ArrayList<Integer>();
		for (int siteInLoadModule : relocationsSitesInLoadModule) {
			sitesInFile.add(loadModuleStartInFile + siteInLoadModule);
		}

		// assuming there's nothing between the relocation table and the load module
		int tableByteLength = loadModuleStartInFile - mzHeader.relocationTableStartInFile;
		int capacity = tableByteLength / LoadModuleRelocationTableEditor.BYTES_PER_ENTRY;

		return new LoadModuleRelocationTableEditor(
				sitesInFile, capacity, mzHeader.relocationTableStartInFile, loadModuleStartInFile);
	}
}
