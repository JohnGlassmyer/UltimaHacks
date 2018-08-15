package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;
import java.util.Optional;

import net.johnglassmyer.ultimahacks.proto.HackProto;

class CopyEdit implements Edit {
	static Optional<Edit> fromProtoEdit(HackProto.Edit protoEdit) {
		if (!protoEdit.hasCopy()) {
			return Optional.empty();
		}

		HackProto.CopyEdit copy = protoEdit.getCopy();

		return Optional.of(new CopyEdit(
				Optional.empty(), copy.getSource(), copy.getLength(), copy.getDestination()));
	}

	private final Optional<String> explanation;
	private final int source;
	private final int length;
	private final int destination;

	private CopyEdit(Optional<String> explanation, int source, int length, int destination) {
		this.explanation = explanation;
		this.source = source;
		this.length = length;
		this.destination = destination;
	}

	CopyEdit(String explanation, int source, int length, int destination) {
		this(Optional.of(explanation), source, length, destination);
	}

	@Override
	public Optional<String> explanation() {
		return explanation;
	}

	@Override
	public void applyToFile(SeekableByteChannel channel) throws IOException {
		byte[] bytes = Util.read(channel, source, length);

		Util.write(channel, destination, bytes);
	}

	@Override
	public HackProto.Edit toProtoMessage() {
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
