package aoc2022

import "core:strings"

day07 :: proc() {
  println("Day 07: No Space Left On Device\n")
  
  input_file := #load("day07-input", string)
  cmds := strings.split(input_file, "$ ")[1:]
  
  File :: struct {
    name: string,
    size: int,
  }
  Dir :: struct {
    name: string,
    subdirs: [dynamic]^Dir,
    files: [dynamic]^File,
    size: int,
  }
  get_dir :: proc(root: ^Dir, loc: []string) -> ^Dir {
    root := root
    if len(loc) == 0 { return root }
    if len(loc[0]) == 0 {return get_dir(root,loc[1:]) }
    for sub in root.subdirs {
      // println("Looking for:", loc,"testing:",sub.name)
      if sub.name == loc[0] {
        return get_dir(sub,loc[1:])
      }
    }
    return root
  }
  get_dir_size :: proc(dir: ^Dir) -> int {
    println("Attempting to find size")
    // dir := dir
    dir.size = 0
    for sub in dir.subdirs {
      dir.size += get_dir_size(sub)
    }
    for file in dir.files {
      dir.size += file.size
    }
    println(dir.name,dir.size)
    return dir.size
  }
  add_subdir :: proc(dir: ^Dir,name: string) {
    dir := dir
    newsub := new(Dir)
    newsub^ = Dir {
      name=name,
      subdirs=make([dynamic]^Dir,0,99),
      files=make([dynamic]^File,0,99),
      size=0,
    }
    // println("adding subdir:", name, "to", dir^)
    append(&dir.subdirs, newsub)
  }
  clean_dir :: proc(dir: ^Dir) {
    dir := dir
    for sdt in dir.subdirs {
      clean_dir(sdt)
    }
    files := dir.files
    subdirs := dir.subdirs
    clear(&files)
    clear(&subdirs)
  }
  root := new(Dir)
  root^ = Dir {
    name="",
    subdirs={},
    files={},
    size=0,
  }
  defer(clean_dir(root))
  
  dirchain := make([dynamic]string,0,30)
  defer(delete(dirchain))
  for cmd in cmds {
    tmp:[]string = strings.split(strings.trim_space(cmd),"\n")
    switch tmp[0][0:2] {
    case "cd":
      dir := tmp[0][3:]
      switch dir {
      case "/":
        // println("Move to root /")
        for len(dirchain) > 0 { pop(&dirchain) }
        append(&dirchain,"")
      case "..":
        // println("Move to parent dir ..")
        pop(&dirchain)
      case:
        append(&dirchain,dir)
        // println("Move into", dir, strings.join(dirchain[:],"/"))
      }
    case "ls":
      // println("List subdirs and files") // , tmp[1:]
      for l in tmp[1:] {
        test := strings.split(l," ")
        name := test[1]
        size_or_dir := test[0]
        // println("Attempting to get dir:",dirchain)
        curdir := get_dir(root,dirchain[1:])
        // println("Current Dir:",curdir)
        if size_or_dir == "dir" {
          add_subdir(curdir,name)
        } else {
          fsize, _ := parse_int(size_or_dir)
          newfile := new(File)
          newfile^ = File {name,fsize}
          // println("adding file:", name, test[0])
          append(&curdir.files, newfile)
        }
        // println("CurDir after:",curdir)
      }
    }
    // print("$",cmd)
  }
  println("Device total used space:", get_dir_size(root))
  free_space := 70000000 - root.size
  needed := 30000000 - free_space
  println("Free Space:", free_space, "Needed:", needed)
  total_dirs_x_size_or_less :: proc(dir: ^Dir, max: int) -> int {
    out := 0
    // println(dir.name,dir.size)
    if dir.size <= max {
      out += dir.size
    }
    for sub in dir.subdirs {
      out += total_dirs_x_size_or_less(sub,max)
    }
    return out
  }
  total := total_dirs_x_size_or_less(root,100000)
  println("Total of dirs <= 100000:", total)
  
  
  smallest_gte_min :: proc(dir: ^Dir, min: int) -> int {
    out := dir.size
    // println(dir.name,dir.size)
    if dir.size >= min {
      for sub in dir.subdirs {
        if (sub.size < dir.size) && (sub.size >= min) {
          test := smallest_gte_min(sub,min)
          if test < out {
            out = test
          }
        }
      }
    }
    return out
  }
  println("Dir to delete in size:", smallest_gte_min(root, needed))
}