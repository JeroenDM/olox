package main

import "core:fmt"
import "core:os"
import "lox"

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


main :: proc() {

	// manual_example()

	data, ok := os.read_entire_file("demo.lox", context.allocator)
	if !ok {
		fmt.print("ERROR: Failed to read file.")
	}
	defer delete(data, context.allocator)

	code := string(data)

	fmt.printf("%s\n", data)

	
}
