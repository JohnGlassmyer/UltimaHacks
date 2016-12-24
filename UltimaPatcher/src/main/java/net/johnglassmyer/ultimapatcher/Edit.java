package net.johnglassmyer.ultimapatcher;

import java.io.IOException;
import java.io.RandomAccessFile;

abstract class Edit {
	abstract void apply(RandomAccessFile file) throws IOException;
}
