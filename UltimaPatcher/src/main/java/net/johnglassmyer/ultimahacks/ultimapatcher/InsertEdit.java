package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;
import java.util.Optional;

import net.johnglassmyer.ultimahacks.proto.HackProto;

class InsertEdit implements Edit {
	static Optional<Edit> fromProtoEdit(HackProto.Edit protoEdit) {
		if (!protoEdit.hasInsert()) {
			return Optional.empty();
		}

		HackProto.InsertEdit insert = protoEdit.getInsert();

		return Optional.of(new InsertEdit(
				Optional.empty(), insert.getStart(), insert.getLength()));
	}

	private final Optional<String> explanation;
	private final int start;
	private final int length;

	private InsertEdit(Optional<String> explanation, int start, int length) {
		this.explanation = explanation;
		this.start = start;
		this.length = length;
	}

	InsertEdit(String explanation, int start, int length) {
		this(Optional.of(explanation), start, length);
	}

	@Override
	public Optional<String> explanation() {
		return explanation;
	}

	@Override
	public void applyToFile(SeekableByteChannel channel) throws IOException {
		byte[] tail = Util.read(channel, start, (int) (channel.size() - start));

		// insert zero-bytes
		Util.write(channel, start, new byte[length]);

		Util.write(channel, start + length, tail);
	}

	@Override
	public HackProto.Edit toProtoMessage() {
		HackProto.Edit.Builder editBuilder = HackProto.Edit.newBuilder();
		HackProto.InsertEdit.Builder insertBuilder = editBuilder.getInsertBuilder();
		insertBuilder.setStart(start);
		insertBuilder.setLength(length);

		return editBuilder.build();
	}

	@Override
	public String toString() {
		return String.format(
				"%s(position: %X, length: %X)",
				InsertEdit.class.getSimpleName(),
				start,
				length);
	}
}
