package aoc2022

import "core:strings"

// bslen :: proc(bs: $E)
// where $E  {
    
// }

CharSet :: bit_set['a'..='z']

day06 :: proc() {
    println("Day 06: Tuning Trouble\n")
    
    input_file := #load("day06-input", string)
    stream := strings.trim_space(input_file)
    // println("This is a test\n",stream)
    
    uniq_str :: proc(len_of_uniq_str: int, stream: string) -> int {
        l := len(stream)
        min := len_of_uniq_str - 1
        out := -1
        loop: for i in min..<l {
            if strings.is_space(rune(stream[i])) {
                continue
            }
            tester := CharSet {}
            // print(stream[(i-3):(i+1)])
            for c in stream[(i-min):(i+1)] {
                if c in tester {
                    continue loop
                }
                tester += {c}
            }
            out = i + 1
            break loop
        }
        return out
    }
    out := uniq_str(4,stream)
    println("start-of-packet marker:", out)
    out2 := uniq_str(14,stream)
    println("start-of-message marker:", out2)
    
}