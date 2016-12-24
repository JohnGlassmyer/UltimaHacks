package net.johnglassmyer.ultimapatcher;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

class PrecedingInstruction {
	static final private Collection<PrecedingInstruction> INSTRUCTIONS;

	static {
		/*
		 * Some of the x86 instructions that accept 16-bit immediate operands
		 * that could be segment values.
		 *
		 * source: http://www.mathemainzel.info/files/x86asmref.html
		 */
		List<PrecedingInstruction> instructions = new ArrayList<>();
		instructions.add(new PrecedingInstruction(1, 0x68, "PUSH"));
		instructions.add(new PrecedingInstruction(1, 0xB8, "MOV AX"));
		instructions.add(new PrecedingInstruction(1, 0xB9, "MOV CX"));
		instructions.add(new PrecedingInstruction(1, 0xBA, "MOV DX"));
		instructions.add(new PrecedingInstruction(1, 0xBB, "MOV BX"));
		instructions.add(new PrecedingInstruction(1, 0xBC, "MOV SP"));
		instructions.add(new PrecedingInstruction(1, 0xBD, "MOV BP"));
		instructions.add(new PrecedingInstruction(1, 0xBE, "MOV SI"));
		instructions.add(new PrecedingInstruction(1, 0xBF, "MOV DI"));
		instructions.add(new PrecedingInstruction(3, 0x9A, "CALL FAR"));
		instructions.add(new PrecedingInstruction(3, 0xC7, "MOV rmw"));
		instructions.add(new PrecedingInstruction(3, 0xEA, "JMP FAR"));
		instructions.add(new PrecedingInstruction(4, 0xC7, "MOV rmw"));
		INSTRUCTIONS = Collections.unmodifiableList(instructions);
	}

	static Optional<PrecedingInstruction> forPrecedingByte(int offset, int opcode) {
		for (PrecedingInstruction instruction : INSTRUCTIONS) {
			if (instruction.offset == offset && instruction.opcode == opcode) {
				return Optional.of(instruction);
			}
		}

		return Optional.empty();
	}

	private PrecedingInstruction(int offset, int opcode, String text) {
		this.offset = offset;
		this.opcode = opcode;
		this.text = text;
	}

	final int offset;
	final int opcode;
	final String text;

	@Override
	public String toString() {
		return String.format("%02X at -%d (%s)", opcode, offset, text);
	}
}
