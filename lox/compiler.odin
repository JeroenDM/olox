package lox

import "core:fmt"

compile :: proc(source: string) {
	scanner: Scanner
	init_scanner(&scanner, transmute([]u8)source)

	for {
		token := scan_token(&scanner)
		// fmt.printf("{}\n", token)
		fmt.printf(
			"type: %-16s\tlexeme: %-10s\t line: %d\n",
			token.type,
			source[token.start:token.start + token.lenght],
			token.line,
		)

		if token.type == .EOF {break}
	}
}
