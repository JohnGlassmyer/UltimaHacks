package net.johnglassmyer.ultimapatcher;

import static java.util.stream.IntStream.range;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.SortedSet;

import com.google.common.collect.ImmutableSet;

class OverlayRelocationTable extends RelocationTable {
	static OverlayRelocationTable create(
			int stubStartInFile, int tableStartInFile, byte[] tableBytes, int segmentIndex) {
		int byteCountInFile = stubStartInFile + OverlayStub.RELOCATION_BYTE_COUNT_OFFSET;

		ImmutableSet.Builder<Integer> offsetsBuilder = ImmutableSet.builder();
		ByteBuffer buffer = ByteBuffer.wrap(tableBytes);
		buffer.order(ByteOrder.LITTLE_ENDIAN);
		range(0, tableBytes.length / Short.BYTES).forEach(i -> {
			offsetsBuilder.add(Short.toUnsignedInt(buffer.getShort()));
		});

		return new OverlayRelocationTable(
				tableStartInFile, offsetsBuilder.build(), byteCountInFile, segmentIndex);
	}

	OverlayRelocationTable(
			int startInFile,
			ImmutableSet<Integer> originalAddresses,
			int byteCountInFile,
			int segmentIndex) {
		super(startInFile, originalAddresses);

		this.byteCountInFile = byteCountInFile;
		this.segmentIndex = segmentIndex;
	}

	private final int byteCountInFile;
	private final int segmentIndex;

	@Override
	protected OverwriteEdit produceCountEdit(int newCount) {
		ByteBuffer buffer = Util.littleEndianBytes(Short.BYTES);
		buffer.putShort((short) (newCount * Short.BYTES));

		return new OverwriteEdit(
				"overlay " + segmentIndex + " relocation size", byteCountInFile, buffer.array());
	}

	@Override
	protected OverwriteEdit produceTableEdit(SortedSet<Integer> relocationAddresses) {
		ByteBuffer buffer = Util.littleEndianBytes(relocationAddresses.size() * Short.BYTES);
		for (int address : relocationAddresses) {
			buffer.putShort((short) address);
		};

		return new OverwriteEdit(
				"overlay " + segmentIndex + " relocation table", startInFile, buffer.array());
	}
}
