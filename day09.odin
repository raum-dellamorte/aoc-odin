package aoc2022


import "core:math/linalg" // temp for debugging
import "core:os"
import "core:slice"
import "core:strings"

import rl "vendor:raylib"

day09 :: proc() {
  // {
  //   println("Day 09: Rope Bridge\n")
  //   input_file := #load("day09-input", string)
  //   movements := strings.split(strings.trim_space(input_file), "\n")
  //   num_mov := len(movements)
  //   visited := make([dynamic]Loc, 0, num_mov)
  //   defer delete(visited)
  //   append(&visited, Loc{0, 0})
  //   visited2 := make([dynamic]Loc, 0, num_mov)
  //   defer delete(visited2)
  //   append(&visited2, Loc{0, 0})
  //   mov := Moves.ErrDir
  //   dist := 0
  //   rope: [10]RopeLink = {}
  //   // for i in 0..<10 { // Everything is initialized as 0 so this isn't needed.
  //   //   rope[i] = RopeLink {}
  //   // }
  //   rope[1].visited = &visited
  //   rope[9].visited = &visited2
  //   for mov_line in movements {
  //     // using Moves
  //     mov, dist = get_mov(mov_line)
  //     #partial switch mov {
  //     case .ErrDir:
  //       println("Error parsing direction:", mov)
  //     case .ErrDist:
  //       println("Error parsing distance:", mov)
  //     }
  //     move_rope(&rope, mov, dist)
  //   }
  //   println("Rope Link 1 visited", len(visited), "locations.")
  //   println("Rope Link 9 visited", len(visited2), "locations.")
  // }
  {
    WIN: rl.Vector2 = {1280, 720}
    // RLNK : rl.Vector2 = { 50, 50 }
    RLNK: rl.Vector3 = {1, 1, 1}
    SPEED: f32 = 40
    ROPE_SPEED: f32 = 10
    // Init Window BEFORE other Raylib operations like importing models and shaders
    rl.InitWindow(i32(WIN.x), i32(WIN.y), "Day 09: Rope Bridge")
    
    rlnk: rl.Vector3 = {0, 0, 0}
    // offset : rl.Vector2 = { 0, 0 }
    // win_offset : rl.Vector2 = WIN / 2.0
    dist_player: f32 = 0
    
    // HEAD: = "🐙"
    // LINK: = "🐠"
    // LNK1: = "🦑"
    // LNK9: = "🦑"
    // VIS1: = "🖤"
    // VIS9: = "💦"
    
    input_file := #load("day09-input", string)
    movements := strings.split(strings.trim_space(input_file), "\n")
    num_mov := len(movements)
    
    visited := make([dynamic]Loc, 0, num_mov)
    defer delete(visited)
    append(&visited, Loc{0, 0})
    
    visited2 := make([dynamic]Loc, 0, num_mov)
    defer delete(visited2)
    append(&visited2, Loc{0, 0})
    
    DrawMe :: enum {
      None,
      First,
      Last,
      Both,
    }
    DrawMeSOA :: struct {
      loc: Loc,
      draw_me: DrawMe,
      pos: rl.Vector3,
    }
    visited_draw : #soa[dynamic]DrawMeSOA
    visited_draw = make_soa(#soa[dynamic]DrawMeSOA, 0, num_mov * num_mov)
    defer delete_soa(visited_draw)
    visited_mat4 := make([dynamic] #row_major matrix[4, 4]f32, 0, num_mov * num_mov)
    defer delete(visited_mat4)
    
    mov := Moves.ErrDir
    dist := 0
    rope: [10]RopeLink = {}
    rope_anim: #soa[10]RopeAnimSOA = {}
    for i in 0 ..< 10 {
      rope[i] = RopeLink{Loc{0, 0}, false, nil}
      rope_anim[i].link = &rope[i]
    }
    rope[1].visited = &visited
    rope[9].visited = &visited2
    
    // Shaders
    rope_trail_shader := rl.LoadShader("res/shaders/rope_trail_instanced.vs", "res/shaders/rope_trail_instanced.fs")
    // defer rl.UnloadShader(rope_trail_shader) // This Segfaults. Turns out it's automatic.
    rope_trail_shader.locs[rl.ShaderLocationIndex.MATRIX_MVP] = i32(rl.GetShaderLocation(rope_trail_shader, "mvp"));
    rope_trail_shader.locs[rl.ShaderLocationIndex.MATRIX_MODEL] = i32(rl.GetShaderLocationAttrib(rope_trail_shader, "instance"));
    rope_trail_shader.locs[rl.ShaderLocationIndex.MATRIX_VIEW] = i32(rl.GetShaderLocation(rope_trail_shader, "view"));
    rope_trail_shader.locs[rl.ShaderLocationIndex.MATRIX_PROJECTION] = i32(rl.GetShaderLocation(rope_trail_shader, "projection"));
    
    // Meshes and Textures
    cube := rl.LoadModel("cube-1x1x1.obj")
    cube.materials[0].shader = rope_trail_shader
    // textures := []
    // player_tex := rl.LoadTexture("CubeTex.png")
    // red_tex := rl.LoadTextureFromImage(rl.GenImageColor(256, 256, rl.RED))
    // orange_tex := rl.LoadTextureFromImage(rl.GenImageColor(256,256,rl.ORANGE))
    // gold_tex := rl.LoadTextureFromImage(rl.GenImageColor(256,256,rl.GOLD))
    // green_tex := rl.LoadTextureFromImage(rl.GenImageColor(256,256,rl.GREEN))
    // darkblue_tex := rl.LoadTextureFromImage(rl.GenImageColor(256,256,rl.DARKBLUE))
    // purple_tex := rl.LoadTextureFromImage(rl.GenImageColor(256,256,rl.PURPLE))
    // materials : [7]rl.Material = {}
    // cube.materials = raw_data(materials[:])
    // cube.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = player_tex
    // cube.materials[1].maps[rl.MaterialMapIndex.ALBEDO].texture = red_tex
    // cube.materials[2].maps[rl.MaterialMapIndex.ALBEDO].texture = orange_tex
    // cube.materials[3].maps[rl.MaterialMapIndex.ALBEDO].texture = gold_tex
    // cube.materials[4].maps[rl.MaterialMapIndex.ALBEDO].texture = green_tex
    // cube.materials[5].maps[rl.MaterialMapIndex.ALBEDO].texture = darkblue_tex
    // cube.materials[6].maps[rl.MaterialMapIndex.ALBEDO].texture = purple_tex
    
    // Camera
    camera := rl.Camera3D {
      position   = [3]f32{0, 0, 16},
      target     = [3]f32{0, 0, 0},
      up         = [3]f32{0, 1, 0},
      fovy       = 90.0,
      projection = rl.CameraProjection.PERSPECTIVE,
    }
    move_cam :: proc(camera: ^rl.Camera3D, target: ^[3]f32) {
      camera.position.x = target^.x
      camera.position.y = target^.y
      camera.target.x = target^.x
      camera.target.y = target^.y
    }
    
    inst_num := 0
    loop_state := 0
    dist_current := 0
    mov_line := movements[0]
    
    // printf("{}",)
    
    frametime: f32 = f32(1.0 / 60.0)
    for !rl.WindowShouldClose() {
      frametime = rl.GetFrameTime()
      dist_player = frametime * SPEED
      
      if loop_state == 0 {
        // initialize rope movement
        mov, dist = get_mov(mov_line)
        #partial switch mov {
        case .ErrDir:
          println("Error parsing direction:", mov)
        case .ErrDist:
          println("Error parsing distance:", mov)
        }
        move_rope(&rope, mov, dist)
        dist_current = dist
        loop_state += 1
      }
      
      // Move "Player"
      if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {rlnk.y += dist_player}
      if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {rlnk.y -= dist_player}
      if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {rlnk.x -= dist_player}
      if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {rlnk.x += dist_player}
      // offset = (WIN / 2.0) - (RLNK / 2.0) + rlnk
      move_cam(&camera, &rlnk)
      
      rl.BeginDrawing()
      rl.ClearBackground(rl.BLUE)
      rl.BeginMode3D(camera)
      rl.rlPushMatrix()  // I don't yet understand this, just trying it
      
      view_mat := rl.GetCameraMatrix(camera)
      
      if loop_state == 1 {
        // animate rope pieces moving
        
        // Screen bounds
        boundL := camera.position.x - (WIN.x / 2.0) - 2.0
        boundR := boundL + WIN.x + 4.0
        boundD := camera.position.y - (WIN.y / 2.0) - 2.0
        boundU := boundD + WIN.y + 4.0
        
        clear_soa(&visited_draw)
        clear(&visited_mat4)
        for pnt in rope[1].visited {
          x := f32(pnt.x)
          y := f32(pnt.y)
          if !(x < boundL || x > boundR || y > boundU || y < boundD) {
            append_soa(&visited_draw, DrawMeSOA { pnt, DrawMe.First, rl.Vector3{x,y,0} })
          }
        }
        for pnt in rope[9].visited {
          x := f32(pnt.x)
          y := f32(pnt.y)
          if !(x < boundL || x > boundR || y > boundU || y < boundD) {
            found := false
            for &visd in visited_draw {
              if visd.loc != pnt { continue }
              visd.draw_me = DrawMe.Both
              found = true
              break
            }
            if !found { append_soa(&visited_draw, DrawMeSOA { pnt, DrawMe.Last, rl.Vector3{x,y,0} }) }
          }
        }
        for &visd in visited_draw {
          append(&visited_mat4, rl.MatrixTranslate(visd.pos.x,visd.pos.y,visd.pos.z))
        }
        // After including the shader in the material, it now renders correctly!
        rl.BeginShaderMode(rope_trail_shader)
        rl.DrawMeshInstanced(cube.meshes[0], cube.materials[0], raw_data(visited_mat4), i32(len(visited_mat4)))
        rl.EndShaderMode()
        
        for i := 9; i >= 0; i -= 1 {
          r_to := loc_vec(rope_anim[i].link.loc)
          tdist := linalg.distance(rope_anim[i].anim, r_to)
          // println(tdist)
          if tdist <= 0.00001 {
            rope_anim[i].step = f32(0)
            rope_anim[i].anim = r_to
            rope_anim[i].prev = r_to
          } else {
            rope_anim[i].step += (f32(ROPE_SPEED) / f32(dist_current)) * frametime
            rope_anim[i].anim = linalg.lerp(
              rope_anim[i].prev,
              r_to,
              linalg.smootherstep(f32(0), f32(1), rope_anim[i].step),
            )
            // println("rspd[i]:",rspd[i])
          }
          // println(rprv[i], r_to, rpos[i], rspd[i])
          // pos := (rpos[i] * 50.0) // + win_offset
          // rl.DrawCircleV(pos, 20.0, rl.GREEN)
          pick_color :: proc(i: int) -> rl.Color {
            switch i {
            case 0:
              return rl.ORANGE
            case 1, 9:
              return rl.PURPLE
            case:
              return rl.GREEN
            }
          }
          rl.DrawCubeV(rope_anim[i].anim, {f32(1), f32(1), f32(1)}, pick_color(i))
        }
        rope_moved := true
        for i := 9; i >= 0; i -= 1 {
          rope_moved = rope_moved && (rope_anim[i].prev == loc_vec(rope[i].loc))
          if !rope_moved {break}
        }
        if rope_moved {
          loop_state += 1
        }
      }
      if loop_state == 2 {
        // animation finished
        // reset the loop state
        loop_state = 0
        inst_num += 1
        if inst_num < len(movements) {
          mov_line = movements[inst_num]
        } else {
          loop_state = 3
        }
      }
      // rl.DrawCubeV(rlnk, RLNK, rl.RED)
      rl.DrawMesh(cube.meshes[0], cube.materials[0], rl.Matrix(linalg.MATRIX4F32_IDENTITY))
      rl.rlPopMatrix() // Pushing after Begin and Popping before End, makes sense? Must read docs ... which are for C, slight differences...
      rl.EndMode3D()
      rl.EndDrawing()
    }
    
    rl.CloseWindow()
  }
}

Moves :: enum {
  Up,
  Dn,
  Lt,
  Rt,
  ErrDir,
  ErrDist,
}

get_mov :: proc(mov: string) -> (Moves, int) {
  using Moves
  tmp := strings.split(mov, " ")
  if len(tmp) == 2 {
    dist, ok := parse_int(tmp[1])
    if ok {
      mov: Moves = .ErrDir
      switch tmp[0] {
      case "U":
        mov = .Up
      case "D":
        mov = .Dn
      case "L":
        mov = .Lt
      case "R":
        mov = .Rt
      }
      return mov, dist
    }
  }
  return .ErrDist, 0
}

Loc :: struct {
  x: int,
  y: int,
}

loc_vec :: proc(loc: Loc) -> rl.Vector3 {
  return {f32(loc.x), f32(loc.y), f32(0)}
}

RopeLink :: struct {
  loc:     Loc,
  moved:   bool,
  visited: ^[dynamic]Loc, // Leave this null to not keep track of this link
}

RopeAnimSOA :: struct {
  link: ^RopeLink,
  prev: rl.Vector3,
  anim: rl.Vector3,
  step: f32,
}

move_rope :: proc(rope: ^[10]RopeLink, mov: Moves, dist: int) {
  dist := dist
  head := &rope[0]

  using Moves
  switch mov {
  case .ErrDir, .ErrDist:
    println("Move instruction passed to move_rope is invalid:", mov)
  case .Up, .Dn, .Lt, .Rt:
    dist -= 1
    #partial switch mov {
    case .Up:
      head.loc.y += 1
    case .Dn:
      head.loc.y -= 1
    case .Lt:
      head.loc.x -= 1
    case .Rt:
      head.loc.x += 1
    }
  }
  for i in 1 ..< len(rope) {
    move_tail(&rope[i - 1], &rope[i])
  }
  if dist > 0 {
    move_rope(rope, mov, dist)
  }
}

move_tail :: proc(head: ^RopeLink, tail: ^RopeLink) {
  xda := abs(head.loc.x - tail.loc.x)
  yda := abs(head.loc.y - tail.loc.y)
  if (xda < 2) && (yda < 2) {
    return
  }
  xda = xda > 0 ? 1 : 0
  yda = yda > 0 ? 1 : 0
  move_link(
    tail,
    xda * (head.loc.x < tail.loc.x ? -1 : 1),
    yda * (head.loc.y < tail.loc.y ? -1 : 1),
  )
}

move_link :: proc(link: ^RopeLink, xd: int, yd: int) {
  link^.moved = (xd != 0) || (yd != 0)
  link^.loc.x += xd
  link^.loc.y += yd
  if link^.moved && (link^.visited != nil) && !slice.contains(link^.visited[:], link^.loc) {
    append(link^.visited, link^.loc)
  }
}
