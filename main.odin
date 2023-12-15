package main

import "core:fmt"
import "core:os"
import "lox"


main :: proc() {

	// manual_example()
	args := os.args
	fmt.println("args: {}", args)

	if len(args) == 1 {
		repl()
	} else if len(args) == 2 {
		run_file(args[1])
	} else {
		fmt.println("Usage: olox [path]\n")
		os.exit(64)
	}

}

repl :: proc() {
	fmt.println("Stating lox repl.")
	buffer: [1024]u8
	for {
		fmt.print("> ")
		n, ok := os.read(os.stdin, buffer[:])
		if ok != os.ERROR_NONE {
			panic("ERROR: failed to read line from stdin")
		}
		if buffer[0] == '\n' {
			break
		}
		line := string(buffer[:n])
		fmt.println(line)
	}
}

run_file :: proc(file: string) {
	data, ok := os.read_entire_file(file, context.allocator)
	if !ok {
		fmt.eprintf("Could not open file \"%s\".\n", file)
		os.exit(74)
	}
	defer delete(data, context.allocator)

	code := string(data)

	fmt.printf("%s\n", data)
}

manual_example :: proc() {
	using lox

	init_vm()
	defer delete_vm()

	chunk: Chunk
	defer delete_chunk(&chunk)

	// idx := add_constant(&chunk, 1.2)

	add_code(&chunk, Opcode.CONSTANT, 1)
	add_code(&chunk, add_constant(&chunk, 1.2), 1)
	add_code(&chunk, Opcode.CONSTANT, 1)
	add_code(&chunk, add_constant(&chunk, 3.4), 1)

	add_code(&chunk, Opcode.ADD, 1)

	add_code(&chunk, Opcode.CONSTANT, 1)
	add_code(&chunk, add_constant(&chunk, 5.6), 1)

	add_code(&chunk, Opcode.DIVIDE, 1)

	add_code(&chunk, Opcode.NEGATE, 1)

	add_code(&chunk, Opcode.RETURN, 2)
	disassemble_chunk(&chunk, "test chunk")

	fmt.println("--- interpret ---")
	res := lox.interpret(&chunk)
	fmt.printf("{}\n", res)
}
