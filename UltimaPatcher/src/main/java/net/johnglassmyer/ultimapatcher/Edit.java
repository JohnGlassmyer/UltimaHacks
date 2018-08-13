package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;

import net.johnglassmyer.ultimahacks.common.HackProto;

interface Edit {
	void applyToFile(SeekableByteChannel channel) throws IOException;

	HackProto.Edit toProtoMessage();
}
