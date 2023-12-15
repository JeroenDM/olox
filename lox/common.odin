package lox

import "core:fmt"


@(private = "file")
pair :: struct {
	count: int,
	value: int,
}


// Runtime length encoding array
RLVec :: [dynamic]pair

append_rl :: proc(v: ^RLVec, line: int) {
	if (len(v) == 0) {
		append(v, pair{count = 1, value = line})
	} else if v[len(v) - 1].value == line {
		v[len(v) - 1].count += 1
	} else {
		append(v, pair{count = 1, value = line})
	}
}

get_at_rl :: proc(v: ^RLVec, idx: int) -> int {
	i, j := 0, 0
	for i <= idx {
		i += v[j].count
		j += 1
	}
	assert(j > 0)
	return v[j - 1].value

}


import "core:testing"

when ODIN_TEST {

	@(test)
	test_rl :: proc(t: ^testing.T) {

		test_vec := make([dynamic]int, 0, 10)
		defer delete(test_vec)

		append(&test_vec, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4)

		sut: RLVec
		defer delete(sut)

		for v in test_vec {
			append_rl(&sut, v)
		}

		for v, i in test_vec {
			testing.expect_value(t, get_at_rl(&sut, i), v)
		}

	}
}
