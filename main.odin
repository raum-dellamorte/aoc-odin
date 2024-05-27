package aoc2022

import "core:fmt"
import "core:os"
import "core:strconv"

print :: fmt.print
printf :: fmt.printf
println :: fmt.println
parse_int :: strconv.parse_int

main :: proc() {
    if len(os.args) < 2 {
        return
    }
    switch os.args[1] {
        case "day01": day01()
        case "day02": day02()
        case "day03": day03()
        case "day04": day04()
        case "day05": day05()
        case "day06": day06()
        case "day07": day07()
        case "day08": day08()
        case "day09": day09()
    }
}
