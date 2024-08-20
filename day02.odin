package aoc2022

import "core:strings"

day02 :: proc() {
  println("Day 02: Rock Paper Scissors\n")
  
  input_file := #load("day02-input", string)
  input, _ := strings.split(input_file, "\n")
  
  /*
    1pt A X ROCK
    2pt B Y PAPER
    3pt C Z SCISSORS
    0pt LOSS
    3pt DRAW
    6pt WIN
  */

  RPS :: enum {
    ROCK = 1,
    PAPER = 2,
    SCISSORS = 3,
  }
  Round :: struct {
    x, y: RPS,
  }
  SCORE :: enum {
    LOSS = 0,
    DRAW = 3,
    WIN = 6,
  }
  lose_round :: proc(opp: RPS) -> RPS {
    res: RPS
    switch opp {
    case .ROCK: res = .SCISSORS
    case .PAPER: res = .ROCK
    case .SCISSORS: res = .PAPER
    }
    return res
  }
  win_round :: proc(opp: RPS) -> RPS {
    res: RPS
    switch opp {
    case .ROCK: res = .PAPER
    case .PAPER: res = .SCISSORS
    case .SCISSORS: res = .ROCK
    }
    return res
  }
  score := 0
  for round in input {
    if len(round) == 0 {
      continue
    }
    println(round)
    opponent: RPS
    codemonkey: RPS
    this_round: Round
    round_result: SCORE
    this_score: = 0
    switch round[0] {
    case 'A': opponent = .ROCK
    case 'B': opponent = .PAPER
    case 'C': opponent = .SCISSORS
    }
    switch round[2] {     // Part B Solution    // Part A Solution
    case 'X': codemonkey = lose_round(opponent) // .ROCK
    case 'Y': codemonkey = opponent       // .PAPER
    case 'Z': codemonkey = win_round(opponent)  // .SCISSORS
    }
    this_score += int(codemonkey)
    this_round = Round{opponent, codemonkey}
    switch this_round {
    case Round{.ROCK, .PAPER}, 
        Round{.PAPER, .SCISSORS}, 
        Round{.SCISSORS, .ROCK}: round_result = .WIN
    case Round{.ROCK, .ROCK}, 
        Round{.PAPER, .PAPER}, 
        Round{.SCISSORS, .SCISSORS}: round_result = .DRAW
    case Round{.ROCK, .SCISSORS}, 
        Round{.PAPER, .ROCK}, 
        Round{.SCISSORS, .PAPER}: round_result = .LOSS
    }
    this_score += int(round_result)
    score += this_score
    println("Opponent:", opponent, "  CodeMonkey:", codemonkey)
    println("Outcome:", round_result, "  Score:", this_score)
  }
  println("\nFinal Score:", score)
}