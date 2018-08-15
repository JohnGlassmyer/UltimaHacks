package net.johnglassmyer.ultimahacks.ultimapatcher;

class PatchApplicationException extends RuntimeException {
	static final private long serialVersionUID = 1L;

	PatchApplicationException(String message) {
		super(message);
	}
}
