package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class FbovHeader {
	static final int LENGTH = 16;
	static final int OVERLAY_BYTE_COUNT_OFFSET = 4;
	static private final String FBOV_SIGNATURE = "FBOV";
	static private final Logger L = LogManager.getLogger(FbovHeader.class);

	static FbovHeader create(byte[] bytes) {
		ByteBuffer buffer = ByteBuffer.wrap(bytes);
		buffer.order(ByteOrder.LITTLE_ENDIAN);

		byte[] signatureBytes = new byte[4];
		buffer.get(signatureBytes, 0, 4);
		String signature = new String(signatureBytes, StandardCharsets.US_ASCII);
		if (!signature.equals(FBOV_SIGNATURE)) {
			throw new BadSignatureException(FBOV_SIGNATURE, signature);
		}

		return new FbovHeader(buffer.getInt(4), buffer.getInt(8), buffer.getInt(12));
	}

	private FbovHeader(int overlayByteCount, int segmentTableStartInFile, int segmentCount) {
		this.overlayByteCount = overlayByteCount;
		this.segmentTableStartInFile = segmentTableStartInFile;
		this.segmentCount = segmentCount;
	}

	final int overlayByteCount;
	final int segmentTableStartInFile;
	final int segmentCount;

	void logDetails() {
		L.info("FBOV overlay header");
		L.info(new HexValueMessage(overlayByteCount, "overlay byte count"));
		L.info(new HexValueMessage(segmentTableStartInFile, "segment table start in file"));
		L.info(new HexValueMessage(segmentCount, "segment count"));
	}
}
