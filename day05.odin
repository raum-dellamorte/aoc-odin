package aoc2022

import "core:strings"

day05 :: proc() {
  println("Day 05: Supply Stacks\n")
  
  input_file := #load("day05-input", string)
  input, _ := strings.split(input_file, "\n")
  
  ilen := len(input)
  
  stacks_ln := 0
  
  digits := bit_set['1'..='9']{'1', '2', '3', '4', '5', '6', '7', '8', '9'} 
  
  for i in 0..<ilen {
    if strings.trim_space(input[i])[0] == '1' {
      stacks_ln = i
      break
    }
  }
  
  if !(stacks_ln > 0) {
    println("Malformed Input")
  }
   
  instructions := input[(stacks_ln + 2) :]
  for len(instructions[len(instructions) - 1]) < 2 {
    instructions = instructions[:len(instructions) - 1]
  }
  
  stacks_str := input[stacks_ln]
  
  stacks: [dynamic][dynamic]rune = make([dynamic][dynamic]rune, 0,9)
  clean_stacks :: proc(x: [dynamic][dynamic]rune) {
    #reverse for xx in x {
      delete(xx)
    }
    delete(x)
  }
  defer clean_stacks(stacks)
  print_stacks :: proc(x: [dynamic][dynamic]rune) {
    print("\n")
    n := 0
    for i in x {
      if len(i) > n { n = len(i) }
    }
    for y in 1..=n {
      iy := n - y
      for z in 0..<len(x) {
        if len(x[z]) > iy {
          printf(" %v", x[z][iy])
        } else { print("  ") }
      }
      print("\n")
    }
    for y in 1..=len(x) {
      printf(" %v", y)
    }
    print("\n\n")
  }
  
  for i in 0..<len(stacks_str) {
    if rune(stacks_str[i]) in digits {
      out := make([dynamic]rune, 0, 9 * stacks_ln)
      for ii in 1..=stacks_ln {
        v := rune(input[stacks_ln - ii][i])
        if !strings.is_ascii_space(v) {
          append(&out, v)
        }
      }
      append(&stacks, out)
    }
  }
  
  print_stacks(stacks)
  
  for i, j in instructions {
    // println(i)
    instruction := strings.split(i, " ")
    move := parse_int(instruction[1]) or_else 0
    from := parse_int(instruction[3]) or_else 0
    from = from - 1
    to := parse_int(instruction[5]) or_else 0
    to = to - 1
    tmp := make([dynamic]rune,0,move)
    for _ in 0..<move {
      if len(stacks[from]) > 0 {
        append(&tmp, pop(&stacks[from]))
      } else {
        println("Error? Empty stack at:", j + stacks_ln + 2)
      }
    }
    for len(tmp) > 0 {
      append(&stacks[to], pop(&tmp))
    }
  }
  print("\n")
  
  println("Final State:")
  print_stacks(stacks)
  print("Output: ")
  for i in 0..<len(stacks) {
    if len(stacks[i]) > 0 {
      print(pop(&stacks[i]))
    } else {
      print(' ')
    }
  }
  print("\n")
}