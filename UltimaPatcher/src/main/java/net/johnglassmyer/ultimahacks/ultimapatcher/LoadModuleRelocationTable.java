package net.johnglassmyer.ultimahacks.ultimapatcher;

import static java.nio.ByteOrder.LITTLE_ENDIAN;

import java.nio.ByteBuffer;
import java.util.SortedSet;

import com.google.common.collect.ImmutableSet;

class LoadModuleRelocationTable extends RelocationTable {
	static private final int RELOCATION_TABLE_COUNT_FILE_OFFSET = 6;

	static LoadModuleRelocationTable create(int startInFile, byte[] tableBytes) {
		ImmutableSet.Builder<Integer> addressesBuilder = ImmutableSet.builder();
		ByteBuffer buffer = ByteBuffer.wrap(tableBytes);
		buffer.order(LITTLE_ENDIAN);
		for (int i = 0; i < tableBytes.length / (2 * Short.BYTES); i++) {
			int offset = Short.toUnsignedInt(buffer.getShort());
			int segment = Short.toUnsignedInt(buffer.getShort());
			addressesBuilder.add(segment * Util.PARAGRAPH_SIZE + offset);
		}

		return new LoadModuleRelocationTable(startInFile, addressesBuilder.build());
	}

	LoadModuleRelocationTable(int startInFile, ImmutableSet<Integer> originalAddresses) {
		super(startInFile, originalAddresses);
	}

	@Override
	protected OverwriteEdit produceCountEdit(int newCount) {
		ByteBuffer buffer = Util.littleEndianBytes(Short.BYTES);
		buffer.putShort((short) newCount);

		return new OverwriteEdit(
				"relocation count in MZ header",
				RELOCATION_TABLE_COUNT_FILE_OFFSET,
				buffer.array());
	}

	@Override
	protected OverwriteEdit produceTableEdit(SortedSet<Integer> addresses) {
		ByteBuffer buffer = Util.littleEndianBytes(addresses.size() * (2 * Short.BYTES));
		for (int address : addresses) {
			int offsetPart = address % Util.PARAGRAPH_SIZE;
			buffer.putShort((short) offsetPart);

			int segmentPart = address / Util.PARAGRAPH_SIZE;
			buffer.putShort((short) segmentPart);
		}

		return new OverwriteEdit("load-module relocation table", startInFile, buffer.array());
	}
}
