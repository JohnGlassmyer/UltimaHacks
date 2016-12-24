package net.johnglassmyer.ultimapatcher;

import org.apache.logging.log4j.message.Message;

class HexValueMessage implements Message {
	private static final long serialVersionUID = 1L;

	HexValueMessage(int value) {
		this(value, null);
	}

	HexValueMessage(int value, String label) {
		this.value = value;
		this.label = label;
	}

	private int value;
	private String label;

	@Override
	public String getFormattedMessage() {
		if (label == null) {
			return String.format("0x%8X", value);
		} else {
			return String.format("0x%8X %s", value, label);
		}
	}

	@Override
	public String getFormat() {
		return getFormattedMessage();
	}

	@Override
	public Object[] getParameters() {
		return null;
	}

	@Override
	public Throwable getThrowable() {
		return null;
	}
}
