package lox

import "core:fmt"

disassemble_chunk :: proc(chunk: ^Chunk, name: string) {
	fmt.printf("== {} ==\n", name)
	offset: int = 0
	for offset < len(chunk.code) {
		offset = disassemble_instruction(chunk, offset)
	}
}

disassemble_instruction :: proc(chunk: ^Chunk, offset: int) -> int {
	fmt.printf("%04d  ", offset)

	line := get_at_rl(&chunk.lines, offset)
	if (offset > 0 && line == get_at_rl(&chunk.lines, offset - 1)) {
		fmt.print("   | ")
	} else {
		fmt.printf("%4d ", line)
	}

	code := cast(Opcode)(chunk.code[offset])
	switch code {
	case .CONSTANT:
		return constant_instruction(fmt.aprintf("{}", code), chunk, offset)
	case .RETURN, .ADD, .SUBSTRACT, .MULTIPLY, .DIVIDE, .NEGATE:
		return simple_instruction(fmt.aprintf("{}", code), offset)
	case:
		// TODO: why should I need this, switch completeness is checked at compile time?
		// panic(fmt.aprintf("Unimplemented opcode {}", code))
		fmt.printf("Unknow opcode {}\n", code)
		return offset + 1
	}
}

simple_instruction :: proc(name: string, offset: int) -> int {
	fmt.printf("{}\n", name)
	return offset + 1
}

constant_instruction :: proc(name: string, chunk: ^Chunk, offset: int) -> int {
	idx := chunk.code[offset + 1]
	fmt.printf("%-16s %4d '", name, idx)
	print_value(chunk.constants[idx])
	fmt.printf("'\n")
	return offset + 2
}
