package aoc2022

import "core:fmt"
import "core:strings"

day04 :: proc() {
    println("Day 04: Camp Cleanup\n")

    input_file := #load("day04-input", string)
    input, _ := strings.split(input_file, "\n")
    
    get_section :: proc(section: string) -> [2]int {
        nums := strings.split(section, "-")
        x, _ := parse_int(nums[0])
        y, _ := parse_int(nums[1])
        out := [2]int{x,y,}
        return out
    }
    contains :: proc(a: [2]int, b: [2]int) -> bool {
        return a[0] >= b[0] && a[1] <= b[1]
    }
    contains_digit :: proc(a: [2]int, b: int) -> bool {
        return a[0] <= b && b <= a[1]
    }
    contains_any :: proc(a: [2]int, b: [2]int) -> bool {
        return contains_digit(a,b[0]) || contains_digit(a,b[1])
    }
    
    acc1 := 0
    acc2 := 0
    
    for line in input {
        if len(line) == 0 {
            continue
        }
        ln := strings.split(line, ",")
        if len(ln) != 2 { 
            println("line failed to split:",line,ln)
            continue
        }
        a := get_section(ln[0])
        b := get_section(ln[1])
        if contains(a,b) || contains(b,a) {
            acc1 += 1
        }
        if contains_any(a,b) || contains_any(b,a) {
            acc2 += 1
        }
    }
    
    println("Complete Overlap:", acc1, "  Partial Overlap:", acc2)
}