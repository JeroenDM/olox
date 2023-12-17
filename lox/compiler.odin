package lox

import "core:fmt"

Parser :: struct {
	current:    Token,
	previous:   Token,
	scanner:    ^Scanner,
	had_error:  bool,
	panic_mode: bool,
}


compile :: proc(source: string, chunk: ^Chunk) -> bool {
	_ = chunk
	scanner: Scanner
	init_scanner(&scanner, transmute([]u8)source)

	parser: Parser
	parser.scanner = &scanner
	parser.had_error = false
	parser.panic_mode = false

	error_at(&parser, Token{.EOF, 0, 0, 123}, "test error")
	error_at(&parser, Token{.VAR, 0, 2, 123}, "test error")

	advance(&parser)
	expression(&parser)
	consume(&parser, .EOF, "Expect end of expression.")
	return !parser.had_error

	// for {
	// 	token := scan_token(&scanner)
	// 	// fmt.printf("{}\n", token)
	// 	fmt.printf(
	// 		"type: %-16s\tlexeme: %-10s\t line: %d\n",
	// 		token.type,
	// 		source[token.start:token.start + token.lenght],
	// 		token.line,
	// 	)

	// 	if token.type == .EOF {break}
	// }
	// return true
}

@(private = "file")
advance :: proc(self: ^Parser) {
	self.previous = self.current

	for {
		self.current = scan_token(self.scanner)
		if self.current.type != .ERROR {break}
		error_at_current(self, "TODO error at current")
	}
}

@(private = "file")
expression :: proc(self: ^Parser) {}

@(private = "file")
consume :: proc(self: ^Parser, type: TokenType, error_msg: string) {
	if self.current.type == type {
		advance(self)
		return
	}
	error_at_current(self, error_msg)
}

@(private = "file")
error_at :: proc(self: ^Parser, token: Token, msg: string) {
	if self.panic_mode {return} 	// supress new errors
	self.panic_mode = true

	fmt.eprintf("[line %d] Error", token.line)

	if token.type == .EOF {
		fmt.eprintf(" at end")
	} else if token.type == .ERROR {
		// nothing
	} else {
		fmt.eprintf("at '%s'", self.scanner.source[token.start:][:token.lenght])
	}

	fmt.eprintf(": %s\n", msg)
}

@(private = "file")
error_at_current :: proc(self: ^Parser, msg: string) {
	error_at(self, self.current, msg)
}

// error at previous
@(private = "file")
error :: proc(self: ^Parser, msg: string) {
	error_at(self, self.previous, msg)
}
