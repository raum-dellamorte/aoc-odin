package aoc2022

import "core:fmt"
import "core:strings"

day03 :: proc() {
    println("Day 03: Rucksack Reorganization\n")
    
    input_file := #load("day03-input", string)
    input, _ := strings.split(input_file, "\n")
    
    item_priority :: proc(chr: u8) -> int {
        out := 0
        switch chr {
            case 'a'..='z': out = int(chr) - 96
            case 'A'..='Z': out = int(chr) - 38
        }
        return out
    }
    Priority_Set :: bit_set[1..=52]
    gt := 0
    badge_gt := 0
    
    igrp := 0
    grp_ps : [3]Priority_Set = {{}, {}, {}}
    
    for line in input {
        sz := len(line)
        if sz == 0 {
            continue
        }
        hsz := sz/2
        pack1, pack2 := line[0:hsz], line[hsz:sz]
        packset1, packset2 : Priority_Set = {} , {}
        for i in 0..<hsz {
            packset1 += Priority_Set{item_priority(pack1[i])}
            packset2 += Priority_Set{item_priority(pack2[i])}
        }
        grp_ps[igrp] = packset1 + packset2
        res := packset1 & packset2
        for n in 1..=52 {
            if n in res {
                print("Item Priority", n, " ")
                gt += n
                break
            }
        }
        if igrp += 1; igrp == 3 {
            igrp = 0
            test := grp_ps[0] & grp_ps[1] & grp_ps[2]
            for n in 1..=52 {
                if n in test {
                    println("Group Badge:",n)
                    badge_gt += n
                    break
                }
            }
        }
    }
    println("\nGrand Total:",gt," Badge Total:",badge_gt)
}
