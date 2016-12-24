package net.johnglassmyer.ultimapatcher;

class BadSignatureException extends RuntimeException {
	static private final long serialVersionUID = 1L;

	BadSignatureException(String expected, String actual) {
		String.format("Bad signature \"%s\"; expected \"%s\"", actual, expected);
	}
}
