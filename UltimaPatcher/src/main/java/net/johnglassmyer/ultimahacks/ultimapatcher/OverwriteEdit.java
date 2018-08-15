package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;
import java.util.Optional;

import com.google.protobuf.ByteString;

import net.johnglassmyer.ultimahacks.proto.HackProto;

class OverwriteEdit implements Edit {
	static Optional<Edit> fromProtoEdit(HackProto.Edit protoEdit) {
		if (!protoEdit.hasOverwrite()) {
			return Optional.empty();
		}

		HackProto.OverwriteEdit overwrite = protoEdit.getOverwrite();

		return Optional.of(new OverwriteEdit(
				Optional.empty(), overwrite.getStart(), overwrite.getData().toByteArray()));
	}

	private final Optional<String> explanation;
	private final int start;
	private final byte[] data;

	private OverwriteEdit(Optional<String> explanation, int start, byte[] data) {
		this.explanation = explanation;
		this.start = start;
		this.data = data;
	}

	OverwriteEdit(String explanation, int start, byte[] data) {
		this(Optional.of(explanation), start, data);
	}

	@Override
	public Optional<String> explanation() {
		return explanation;
	}

	@Override
	public void applyToFile(SeekableByteChannel channel) throws IOException {
		Util.write(channel, start, data);
	}

	@Override
	public HackProto.Edit toProtoMessage() {
		HackProto.Edit.Builder editBuilder = HackProto.Edit.newBuilder();
		HackProto.OverwriteEdit.Builder overwriteBuilder = editBuilder.getOverwriteBuilder();
		overwriteBuilder.setStart(start);
		overwriteBuilder.setData(ByteString.copyFrom(data));

		return editBuilder.build();
	}

	@Override
	public String toString() {
		return String.format(
				"%s(start: %X, length: %X)",
				OverwriteEdit.class.getSimpleName(),
				start,
				data.length);
	}
}
