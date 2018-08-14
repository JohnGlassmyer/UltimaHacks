package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;
import java.util.Optional;

import net.johnglassmyer.ultimahacks.common.HackProto;

interface Edit {
	Optional<String> explanation();

	void applyToFile(SeekableByteChannel channel) throws IOException;

	HackProto.Edit toProtoMessage();
}
