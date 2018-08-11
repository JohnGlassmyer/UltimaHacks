package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.nio.channels.SeekableByteChannel;

interface Edit {
	void apply(SeekableByteChannel channel) throws IOException;
}
