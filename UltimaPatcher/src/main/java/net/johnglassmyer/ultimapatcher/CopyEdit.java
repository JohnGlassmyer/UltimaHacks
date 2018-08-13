package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;
import java.util.Optional;

import net.johnglassmyer.ultimahacks.common.HackProto;

class CopyEdit implements Edit {
	static Optional<Edit> fromProtoEdit(HackProto.Edit protoEdit) {
		if (!protoEdit.hasCopy()) {
			return Optional.empty();
		}

		HackProto.CopyEdit copy = protoEdit.getCopy();

		return Optional.of(new CopyEdit(copy.getSource(), copy.getLength(), copy.getDestination()));
	}

	private final int source;
	private final int length;
	private final int destination;

	CopyEdit(int sourceStart, int length, int destinationStart) {
		this.source = sourceStart;
		this.length = length;
		this.destination = destinationStart;
	}

	@Override
	public void applyToFile(SeekableByteChannel channel) throws IOException {
		byte[] bytes = Util.read(channel, source, length);

		Util.write(channel, destination, bytes);
	}

	@Override
	public net.johnglassmyer.ultimahacks.common.HackProto.Edit toProtoMessage() {
		HackProto.Edit.Builder editBuilder = HackProto.Edit.newBuilder();
		HackProto.CopyEdit.Builder copyBuilder = editBuilder.getCopyBuilder();
		copyBuilder.setSource(source);
		copyBuilder.setLength(length);
		copyBuilder.setDestination(destination);

		return editBuilder.build();
	}

	@Override
	public String toString() {
		return String.format(
				"%s(source: %X, length: %X, destination: %X)",
				CopyEdit.class.getSimpleName(),
				source,
				length,
				destination);
	}
}
