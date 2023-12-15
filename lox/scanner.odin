package lox

import "core:fmt"

Scanner :: struct {
	start:   int,
	current: int,
	line:    int,
	source:  []u8,
}

TokenType :: enum {
	// Single-character tokens.
	LEFT_PAREN,
	RIGHT_PAREN,
	LEFT_BRACE,
	RIGHT_BRACE,
	COMMA,
	DOT,
	MINUS,
	PLUS,
	SEMICOLON,
	SLASH,
	STAR,

	// One or two character tokens.
	BANG,
	BANG_EQUAL,
	EQUAL,
	EQUAL_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL,

	// Literals.
	IDENTIFIER,
	STRING,
	NUMBER,

	// Keywords.
	AND,
	CLASS,
	ELSE,
	FALSE,
	FOR,
	FUN,
	IF,
	NIL,
	OR,
	PRINT,
	RETURN,
	SUPER,
	THIS,
	TRUE,
	VAR,
	WHILE,
	ERROR,
	EOF,
}

Token :: struct {
	type:   TokenType,
	start:  int,
	lenght: int,
	line:   int,
}

init_scanner :: proc(s: ^Scanner, source: []u8) {
	s.start = 0
	s.current = 0
	s.line = 1
	s.source = source
}


scan_token :: proc(s: ^Scanner) -> Token {
	skip_withspace(s)

	s.start = s.current
	if is_at_end(s) {
		return make_token(s, .EOF)
	}


	c := advance(s)

	switch c {
	case '(':
		return make_token(s, .LEFT_PAREN)
	case ')':
		return make_token(s, .RIGHT_PAREN)
	case '{':
		return make_token(s, .LEFT_BRACE)
	case '}':
		return make_token(s, .RIGHT_BRACE)
	case ';':
		return make_token(s, .SEMICOLON)
	case ',':
		return make_token(s, .COMMA)
	case '.':
		return make_token(s, .DOT)
	case '-':
		return make_token(s, .MINUS)
	case '+':
		return make_token(s, .PLUS)
	case '/':
		return make_token(s, .SLASH)
	case '*':
		return make_token(s, .STAR)

	case '!':
		return make_token(s, match(s, '=') ? .BANG_EQUAL : .BANG)
	case '=':
		return make_token(s, match(s, '=') ? .EQUAL_EQUAL : .EQUAL)
	case '<':
		return make_token(s, match(s, '=') ? .LESS_EQUAL : .LESS)
	case '>':
		return make_token(s, match(s, '=') ? .GREATER_EQUAL : .GREATER)
	}

	return error_token("Unexpected character.")
}

is_at_end :: proc(s: ^Scanner) -> bool {
	return !(s.current < len(s.source))
}

make_token :: proc(s: ^Scanner, t: TokenType) -> Token {
	return Token{t, s.start, s.current - s.start, s.line}
}

error_token :: proc(msg: string) -> Token {
	return Token{.ERROR, 0, 0, 1}
}

advance :: proc(s: ^Scanner) -> u8 {
	s.current += 1
	return s.source[s.current - 1]
}

match :: proc(s: ^Scanner, expected: u8) -> bool {
	if is_at_end(s) {return false}
	if expected != s.source[s.current] {return false}
	s.current += 1
	return true
}

skip_withspace :: proc(s: ^Scanner) {
	for {
		if is_at_end(s) {return}
		switch peek(s) {
		case ' ', '\r', '\t':
			advance(s)
		case:
			return
		}
	}
}

peek :: proc(s: ^Scanner) -> u8 {
	return s.source[s.current]
}
