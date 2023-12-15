package lox

import "core:fmt"

compile :: proc(source: string) {
	scanner: Scanner
	init_scanner(&scanner, transmute([]u8)source)

	for {
		token := scan_token(&scanner)
		fmt.printf("{}\n", token)

		if token.type == .EOF {break}
	}
}
