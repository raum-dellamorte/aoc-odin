package aoc2022

import "core:math/linalg" // temp for debugging
import "core:os"
import "core:slice"
import "core:strings"

import rl "vendor:raylib"

gen_materials :: proc(textures: []rl.Texture, shaders: []rl.Shader) -> ([dynamic][11]rl.MaterialMap, [dynamic]rl.Material) {
  sz := len(textures)
  matmaps := make([dynamic][11]rl.MaterialMap,sz,sz)
  mats := make([dynamic]rl.Material,sz,sz)
  for i in 0..<sz {
    matmaps[i] = [11]rl.MaterialMap {}
    mats[i].maps = raw_data(matmaps[i][:])
    mats[i].maps[0].texture = textures[i]
    mats[i].maps[0].color = rl.Color {255,255,255,255}
    mats[i].shader = shaders[i]
    println("mats:",mats)
  }
  return matmaps, mats
}