package lox

// import "core:testing"

Opcode :: enum u8 {
	CONSTANT,
	ADD,
	SUBSTRACT,
	MULTIPLY,
	DIVIDE,
	NEGATE,
	RETURN,
}

Chunk :: struct {
	code:      [dynamic]u8,
	// lines:     [dynamic]int,
	lines : RLVec,
	constants: [dynamic]Value,
}

delete_chunk :: proc(chunk: ^Chunk) {
	delete(chunk.code)
	delete(chunk.lines)
	delete(chunk.constants)
}

add_code_u8 :: proc(chunk: ^Chunk, oc: u8, line: int) {
	append(&chunk.code, oc)
	append_rl(&chunk.lines, line)
}

add_code_enum :: proc(chunk: ^Chunk, oc: Opcode, line: int) {
	append(&chunk.code, cast(u8)(oc))
	append_rl(&chunk.lines, line)
}

add_code :: proc {
	add_code_u8,
	add_code_enum,
}

add_constant :: proc(chunk: ^Chunk, value: Value) -> u8 {
	append(&chunk.constants, value)
	// TODO: do we need bound check?
	return cast(u8)(len(chunk.constants) - 1)
}

// when ODIN_TEST {
// 	expect  :: testing.expect
// 	log     :: testing.log
// } else {
// 	expect  :: proc(t: ^testing.T, condition: bool, message: string, loc := #caller_location) {
// 		// TEST_count += 1
// 		// if !condition {
// 		// 	TEST_fail += 1
// 		// 	fmt.printf("[%v] %v\n", loc, message)
// 		// 	return
// 		// }
// 	}
// 	log :: proc(t: ^testing.T, v: any, loc := #caller_location) {
// 		// fmt.printf("[%v] ", loc)
// 		// fmt.printf("log: %v\n", v)
// 	}
// }

// @(test)
// test_dummy :: proc(t : ^testing.T) {
// 	expect(t, 1 == 2, "1 is 2")
// }