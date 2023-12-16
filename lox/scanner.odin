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

///////////////////////////////////////////////////////////////////////////////
// Main scanner switch 
///////////////////////////////////////////////////////////////////////////////

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

	case '"':
		return scan_string(s)
	}

	if is_digit(c) {
		return scan_number(s)
	}

	if is_alpha(c) {
		return scan_identifier(s)
	}


	return error_token("Unexpected character.")
}

///////////////////////////////////////////////////////////////////////////////
// Scan special thingies. 
///////////////////////////////////////////////////////////////////////////////

scan_string :: proc(s: ^Scanner) -> Token {
	for (peek(s) != '"' && !is_at_end(s)) {
		if (peek(s) == '\n') {s.line += 1}
		advance(s)
	}

	if (is_at_end(s)) {return error_token("Unterminated string.")}
	advance(s) // skip past the closing quote.
	return make_token(s, .STRING) // TODO

}

scan_number :: proc(s: ^Scanner) -> Token {
	for is_digit(peek(s)) {advance(s)}

	//A dot must be follower by a digit!
	for peek(s) == '.' && is_digit(peek_next(s)) {
		advance(s)
	}

	for is_digit(peek(s)) {advance(s)}

	return make_token(s, .NUMBER)
}

scan_identifier :: proc(s: ^Scanner) -> Token {
	for (is_alpha_numeric(peek(s)) && !is_at_end(s)) {
		advance(s)
	}
	return make_token(s, .IDENTIFIER)
}


///////////////////////////////////////////////////////////////////////////////
// Utilities
///////////////////////////////////////////////////////////////////////////////

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
		case '\n':
			s.line += 1
			advance(s)
		case '/':
			if peek_next(s) == '/' {
				for peek(s) != '\n' && !is_at_end(s) {advance(s)}
			}
		case:
			return
		}
	}
}

peek :: proc(s: ^Scanner) -> u8 {
	return s.source[s.current]
}


peek_next :: proc(s: ^Scanner) -> u8 {
	if is_at_end(s) {return '?'} 	// TODO
	return s.source[s.current + 1]
}

is_digit :: proc(c: u8) -> bool {
	switch c {
	case '0' ..= '9':
		return true
	case:
		return false
	}
}


is_alpha :: proc(c: u8) -> bool {
	switch c {
	case 'A' ..= 'Z', 'a' ..= 'z', '_':
		return true
	case:
		return false
	}
}

is_alpha_numeric :: proc(c: u8) -> bool {
	return is_alpha(c) || is_digit(c)
}
