package aoc2022

import "core:strings"

day01 :: proc() {
  println("Day 01: Calorie Counting\n")
  
  input_file := #load("day01-input", string)
  input, _ := strings.split(input_file, "\n\n")
  
  maxcal := [3]int{0,0,0}
  elfnum := [3]int{0,0,0} // AOC does not ask to keep track of which elf is which
  for s, i in input {
    vals, _ := strings.split(s, "\n")
    t: = 0
    for val in vals {
      x, _ := parse_int(val)
      t += x
    }
    switch {
    case t > maxcal.x: maxcal, elfnum = {t, maxcal.x, maxcal.y}, {i+1, elfnum.x, elfnum.y}
    case t > maxcal.y: maxcal, elfnum = {maxcal.x, t, maxcal.y}, {elfnum.x, i+1, elfnum.y}
    case t > maxcal.z: maxcal.z, elfnum.z = t, i+1
    }
    printf("Elf #%03v has %v calories\n", i+1, t)
  }
  printf("\n\nElf #%03v is in 1st place with %v calories!\n", 
    elfnum.x, maxcal.x)
  printf("Elf #%03v is in 2nd place with %v calories!\n", 
    elfnum.y, maxcal.y)
  printf("Elf #%03v is in 3nd place with %v calories!\n", 
    elfnum.z, maxcal.z)
  println("The total calories between our top 3 elves is",
    maxcal.x + maxcal.y + maxcal.z)

}