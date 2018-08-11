package net.johnglassmyer.ultimapatcher;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class MzHeader {
	static final int LENGTH = 0x1C;
	static private final Logger L = LogManager.getLogger(MzHeader.class);
	static private final int PAGE_SIZE = 512;
	static private final String MZ_SIGNATURE = "MZ";

	static MzHeader parseFrom(byte[] bytes) {
		Util.checkBytesLength(bytes, LENGTH);

		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		buffer.order(ByteOrder.LITTLE_ENDIAN);
		buffer.position(0);

		String signature = new String(new byte[] {
				buffer.get(0),
				buffer.get(1)
		}, StandardCharsets.US_ASCII);

		if (!signature.equals(MZ_SIGNATURE)) {
			throw new BadSignatureException(MZ_SIGNATURE, signature);
		}

		int lastPageSize = Short.toUnsignedInt(buffer.getShort(2));
		int filePages = Short.toUnsignedInt(buffer.getShort(4));
		int relocationCount = Short.toUnsignedInt(buffer.getShort(6));
		int headerParagraphs = Short.toUnsignedInt(buffer.getShort(8));
		int relocationStart = Short.toUnsignedInt(buffer.getShort(0x18));

		return new MzHeader(signature, lastPageSize, filePages, relocationCount, headerParagraphs, relocationStart);
	}

	private MzHeader(String signature, int lastPageSize, int filePages, int relocationCount, int headerParagraphs,
			int relocationStart) {
		this.signature = signature;
		this.lastPageSize = lastPageSize;
		this.filePages = filePages;
		this.relocationCount = relocationCount;
		this.headerParagraphs = headerParagraphs;
		this.relocationTableStartInFile = relocationStart;
	}

	final String signature;
	final int lastPageSize;
	final int filePages;
	final int relocationCount;
	final int headerParagraphs;
	final int relocationTableStartInFile;

	void logDetails() {
		L.info(String.format("MZ executable header", signature));
		L.info(new HexValueMessage(lastPageSize, "last page size"));
		L.info(new HexValueMessage(filePages, "file pages"));
		L.info(new HexValueMessage(calculateMzFileSize(), "MZ file size"));
		L.info(new HexValueMessage(relocationTableStartInFile, "relocation table start"));
		L.info(new HexValueMessage(relocationCount, "relocation count"));
		L.info(new HexValueMessage(loadModuleStartInFile(), "load module start"));
	}

	int calculateMzFileSize() {
		int shortage = (lastPageSize == 0) ? 0 : PAGE_SIZE - lastPageSize;
		return filePages * PAGE_SIZE - shortage;
	}

	int loadModuleStartInFile() {
		return headerParagraphs * Util.PARAGRAPH_SIZE;
	}
}
