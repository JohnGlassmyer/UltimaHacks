package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;

import com.google.protobuf.ByteString;

import net.johnglassmyer.ultimahacks.common.HackProto;

class OverwriteEdit implements Edit {
	private final int start;
	private final byte[] replacementBytes;

	OverwriteEdit(int startInFile, byte[] replacementBytes) {
		this.start = startInFile;
		this.replacementBytes = replacementBytes;
	}

	@Override
	public void applyToFile(SeekableByteChannel channel) throws IOException {
		Util.write(channel, start, replacementBytes);
	}

	@Override
	public net.johnglassmyer.ultimahacks.common.HackProto.Edit toProtoMessage() {
		HackProto.Edit.Builder editBuilder = HackProto.Edit.newBuilder();
		HackProto.OverwriteEdit.Builder overwriteBuilder = editBuilder.getOverwriteBuilder();
		overwriteBuilder.setStart(start);
		overwriteBuilder.setData(ByteString.copyFrom(replacementBytes));

		return editBuilder.build();
	}

	@Override
	public String toString() {
		return String.format(
				"%s(start: %X, length: %X)",
				OverwriteEdit.class.getSimpleName(),
				start,
				replacementBytes.length);
	}
}
