package lox

import "core:fmt"
import "core:log"


STACK_MAX :: 256

InterpretResult :: enum {
	OK,
	COMPILE_ERROR,
	RUNTIME_ERROR,
}


VM :: struct {
	chunk: ^Chunk,
	ip:    u8, // TODO raw pointer aritmatic in array faster?
	stack: [STACK_MAX]Value,
	top:   int,
}

vm: VM

init_vm :: proc() {}

delete_vm :: proc() {}

@(private = "file")
reset_stack :: proc() {
	vm.top = 0
}

@(private = "file")
push :: proc(value: Value) {
	vm.stack[vm.top] = value
	vm.top += 1
}

@(private = "file")
pop :: proc() -> Value {
	vm.top -= 1
	return vm.stack[vm.top]
}

interpret :: proc(source: string) -> InterpretResult {
	chunk: Chunk
	defer delete_chunk(&chunk)

	if !compile(source, &chunk) {
		return .COMPILE_ERROR
	}

	vm.chunk = &chunk
	add_code(&chunk, Opcode.CONSTANT, 1)
	add_code(&chunk, add_constant(&chunk, 1.2), 1)
	add_code(vm.chunk, Opcode.RETURN, 1)
	vm.ip = 0

	return run()
}


// interpret :: proc(chunk: ^Chunk) -> InterpretResult {
// 	if len(chunk.code) == 0 {
// 		return .OK
// 	}

// 	vm.chunk = chunk
// 	vm.ip = 0
// 	return run()
// }

binary_op :: proc(op: proc(_: Value, _: Value) -> Value) {
	b := pop() // First b, then a!!
	a := pop()
	push(op(a, b))
}

run :: proc() -> InterpretResult {
	read_byte :: proc() -> u8 {
		b := vm.chunk.code[vm.ip]
		vm.ip += 1
		return b
	}

	read_constant :: proc() -> Value {
		return vm.chunk.constants[read_byte()]
	}

	for {
		when ODIN_DEBUG {
			fmt.print("         ")
			for i := 0; i < vm.top; i += 1 {
				fmt.print("[ ")
				print_value(vm.stack[i])
				fmt.print(" ]")
			}
			fmt.println()
			disassemble_instruction(vm.chunk, auto_cast vm.ip)
		}
		instruction: Opcode = auto_cast read_byte()
		#partial switch instruction {
		case .RETURN:
			print_value(pop())
			fmt.println()
			return .OK
		case .CONSTANT:
			value := read_constant()
			push(value)
		case .NEGATE:
			push(-pop())
		// my code
		case .ADD:
			binary_op(proc(a: Value, b: Value) -> Value {return a + b})
		case .SUBSTRACT:
			binary_op(proc(a: Value, b: Value) -> Value {return a - b})
		case .MULTIPLY:
			binary_op(proc(a: Value, b: Value) -> Value {return a * b})
		case .DIVIDE:
			binary_op(proc(a: Value, b: Value) -> Value {return a / b})
		// end my code
		}
	}
	return .OK
}
