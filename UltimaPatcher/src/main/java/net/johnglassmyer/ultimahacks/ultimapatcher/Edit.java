package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;
import java.util.Optional;

import net.johnglassmyer.ultimahacks.proto.HackProto;

interface Edit {
	Optional<String> explanation();

	void applyToFile(SeekableByteChannel channel) throws IOException;

	HackProto.Edit toProtoMessage();
}
