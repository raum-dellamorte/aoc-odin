package aoc2022

import "core:strings"

day08 :: proc() {
  println("Day 08: Treetop Tree House\n")
  
  input_file := #load("day08-input", string)
  forrest := strings.split(strings.trim_space(input_file), "\n")
  
  length := len(forrest)
  len1 := length - 1
  width := len(forrest[0])
  wid1 := width - 1
  visible := length * 2 + (width - 2) * 2
  vis := true
  visplus := false
  highscore := 0
  score := 0
  nc,sc,ec,wc := 0,0,0,0
  
  for y in 1..<len1 {
    trees: for x in 1..<wid1 {
      c := forrest[y][x]
      nc,sc,ec,wc = 0,0,0,0
      visplus = false
      vis = true
      north: for i in 1..=y {
        nc += 1
        if forrest[y-i][x] >= c {
          vis = false
          break
        }
      }
      if vis && !visplus { visible += 1 ; visplus = true }
      vis = true
      south: for i in (y+1)..<length {
        sc += 1
        if forrest[i][x] >= c {
          vis = false
          break
        }
      }
      if vis && !visplus { visible += 1 ; visplus = true }
      vis = true
      east: for i in 1..=x {
        ec += 1
        if forrest[y][x-i] >= c {
          vis = false
          break
        }
      }
      if vis && !visplus { visible += 1 ; visplus = true }
      vis = true
      west: for i in (x+1)..<width {
        wc += 1
        if forrest[y][i] >= c {
          vis = false
          break
        }
      }
      if vis && !visplus { visible += 1 }
      score = nc * ec * sc * wc
      if score > highscore {
        highscore = score
      }
    }
  }
  println("Number of visible trees:", visible)
  println("Highest Tree Score is:", highscore)
}