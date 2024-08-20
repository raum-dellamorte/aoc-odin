package aoc2022

// import "core:math/linalg" // temp for debugging
// import "core:os"
// import "core:slice"
// import "core:strings"

// import gl "vendor:OpenGL"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

MMI :: rl.MaterialMapIndex
SLI :: rlgl.ShaderLocationIndex
SADT :: rlgl.ShaderAttributeDataType
SUDT :: rlgl.ShaderUniformDataType

MAX_MATERIAL_MAPS :: 12

ZeroPtr :: rawptr(uintptr(0)) // this is the same as c.NULL

MaterialHelper :: struct {
  maps: [dynamic][11]rl.MaterialMap,
  mats: [dynamic]rl.Material,
  pointer: [^]rl.Material,
}

MatAssign :: struct {
  shader: int,
  texture: int,
  color: int,
  value: f32,
}

// For assignments, a zero value for shader, texture, or color in MatAssign leaves zero values
// in the resulting MaterialHelper whereas 1 is the first element of the provided matching array.
// Example: MatAssign {1, 3, 0, 1.4} assigns shaders[0], the first shader in shaders, as the
// shader for the nth, with respect to assignments[n], Material, along with the third Texture,
// texures[2], and does not assign a color, thus leaving it at a zero value. And, while I'm
// pedantically documenting, value is set directly.
gen_materials :: proc(assignments: []MatAssign, shaders: []rl.Shader, textures: []rl.Texture, colors: []rl.Color) -> MaterialHelper {
  sz := len(assignments)
  matmaps := make([dynamic][11]rl.MaterialMap,sz,sz)
  mats := make([dynamic]rl.Material,sz,sz)
  for a, i in assignments {
    matmaps[i] = [11]rl.MaterialMap {}
    mats[i].maps = raw_data(matmaps[i][:])
    if a.shader > 0 && a.shader <= len(shaders) {
      mats[i].shader = shaders[a.shader - 1]
    }
    if a.texture > 0 && a.texture <= len(textures) {
      mats[i].maps[0].texture = textures[a.texture - 1]
    }
    if a.color > 0 && a.color <= len(colors) {
      mats[i].maps[0].color = colors[a.color - 1]
    }
    mats[i].maps[0].value = a.value
  }
  return MaterialHelper{matmaps, mats, raw_data(mats[:])}
}
delete_mat_helper :: proc(mh: MaterialHelper) {
  delete(mh.maps)
  delete(mh.mats)
}

// Transcoded from rmodels.c in Raylib source
// Currently not working, but it compiles!
// ------------------------------------------
// Draw multiple mesh instances with material and different transforms
draw_mesh_instanced :: proc(mesh: rl.Mesh, material: rl.Material, transforms: []#row_major matrix[4,4]f32) {
  instances: int = len(transforms)
  if instances < 1 { return }

  // Bind shader program
  rlgl.EnableShader(material.shader.id)

  // Send required data to shader (matrices, values)
  //-----------------------------------------------------
  // Upload to shader material.colDiffuse
  if material.shader.locs[SLI.COLOR_DIFFUSE] != -1 {
    // println("COLOR_DIFFUSE set uniform")
    values: [4]f32 = {
      f32(material.maps[MMI.ALBEDO].color.r)/255.0,
      f32(material.maps[MMI.ALBEDO].color.g)/255.0,
      f32(material.maps[MMI.ALBEDO].color.b)/255.0,
      f32(material.maps[MMI.ALBEDO].color.a)/255.0,
    }
    rlgl.SetUniform(material.shader.locs[SLI.COLOR_DIFFUSE], raw_data(values[:]), i32(SUDT.VEC4), 1)
  }

  // Upload to shader material.colSpecular (if location available)
  if material.shader.locs[SLI.COLOR_SPECULAR] != -1 {
    // println("COLOR_SPECULAR set uniform")
    values: [4]f32 = {
      f32(material.maps[SLI.COLOR_SPECULAR].color.r)/255.0,
      f32(material.maps[SLI.COLOR_SPECULAR].color.g)/255.0,
      f32(material.maps[SLI.COLOR_SPECULAR].color.b)/255.0,
      f32(material.maps[SLI.COLOR_SPECULAR].color.a)/255.0,
    }
    rlgl.SetUniform(material.shader.locs[SLI.COLOR_SPECULAR], raw_data(values[:]), i32(SUDT.VEC4), 1)
  }

  // Get a copy of current matrices to work with,
  // just in case stereo render is required, and we need to modify them
  // NOTE: At this point the modelview matrix just contains the view matrix (camera)
  // That's because BeginMode3D() sets it and there is no model-drawing function
  // that modifies it, all use rlPushMatrix() and rlPopMatrix()
  matModel: rl.Matrix = rl.Matrix(1)
  matView: rl.Matrix = rlgl.GetMatrixModelview()
  matModelView: rl.Matrix = rl.Matrix(1) // This assignment is ignored and replaced with the result of rlgl.GetMatrixTransform() * matView
  matProjection: rl.Matrix = rlgl.GetMatrixProjection()

  // Upload view and projection matrices (if locations available)
  if material.shader.locs[SLI.MATRIX_VIEW] != -1 { rlgl.SetUniformMatrix(material.shader.locs[SLI.MATRIX_VIEW], matView) }
  if material.shader.locs[SLI.MATRIX_PROJECTION] != -1 { rlgl.SetUniformMatrix(material.shader.locs[SLI.MATRIX_PROJECTION], matProjection) }

  // Create instances buffer
  // instanceTransforms = (float16 *)RL_MALLOC(instances*sizeof(float16))
  instanceTransforms0 := make([dynamic][16]f16,instances,instances)
  instanceTransforms := make([dynamic][^]f16,instances,instances)
  defer delete(instanceTransforms0)
  defer delete(instanceTransforms)

  // Fill buffer with instances transformations as float16 arrays
  for i in 0..<instances {
    // t32 := rl.MatrixToFloatV(transforms[i])
    t := transforms[i]
    t16 := [16]f16{
      f16(t[0,0]), f16(t[0,1]), f16(t[0,2]), f16(t[0,3]),
      f16(t[1,0]), f16(t[1,1]), f16(t[1,2]), f16(t[1,3]),
      f16(t[2,0]), f16(t[2,1]), f16(t[2,2]), f16(t[2,3]),
      f16(t[3,0]), f16(t[3,1]), f16(t[3,2]), f16(t[3,3]),
    }
    // t16 := [16]f16{
    //   f16(t[0,0]), f16(t[1,0]), f16(t[2,0]), f16(t[3,0]),
    //   f16(t[0,1]), f16(t[1,1]), f16(t[2,1]), f16(t[3,1]),
    //   f16(t[0,2]), f16(t[1,2]), f16(t[2,2]), f16(t[3,2]),
    //   f16(t[0,3]), f16(t[1,3]), f16(t[2,3]), f16(t[3,3]),
    // }
    // for i in 0..<16 {
    //   t16[i] = f16(t32[i])
    // }
    instanceTransforms0[i] = t16
    instanceTransforms[i] = raw_data(instanceTransforms0[i][:])
  }

  // Enable mesh VAO to attach new buffer
  rlgl.EnableVertexArray(mesh.vaoId)

  // This could alternatively use a static VBO and either glMapBuffer() or glBufferSubData()
  // It isn't clear which would be reliably faster in all cases and on all platforms,
  // anecdotally glMapBuffer() seems very slow (syncs) while glBufferSubData() seems
  // no faster, since we're transferring all the transform matrices anyway
  // instancesVboId = rlLoadVertexBuffer(instanceTransforms, instances*sizeof(float16), false);
  // instancesVboId := rlgl.LoadVertexBuffer(raw_data(instanceTransforms0), i32(instances * size_of(f16)), false)
  // instancesVboId := rlgl.LoadVertexBuffer(raw_data(instanceTransforms), i32(size_of(instanceTransforms)), false)
  instancesVboId := rlgl.LoadVertexBuffer(raw_data(instanceTransforms0), i32(size_of(instanceTransforms0)), false)

  // Instances transformation matrices are send to shader attribute location: SLI.MATRIX_MODEL
  for i in  0..<i32(4) {
    rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.MATRIX_MODEL] + i))
    // I was using i * size_of(rl.Vector4) for the pointer
    rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.MATRIX_MODEL] + i), 4, rlgl.FLOAT, false, size_of(rl.Matrix), rawptr(uintptr(i * size_of(rl.Vector4))))
    rlgl.SetVertexAttributeDivisor(u32(material.shader.locs[SLI.MATRIX_MODEL] + i), 1)
  }

  rlgl.DisableVertexBuffer()
  rlgl.DisableVertexArray()

  // Accumulate internal matrix transform (push/pop) and view matrix
  // NOTE: In this case, model instance transformation must be computed in the shader
  matModelView = rlgl.GetMatrixTransform() * matView

  // Upload model normal matrix (if locations available)
  if material.shader.locs[SLI.MATRIX_NORMAL] != -1 {
    // println("Upload model normal matrix (if locations available)")
    rlgl.SetUniformMatrix(material.shader.locs[SLI.MATRIX_NORMAL], rl.MatrixTranspose(rl.MatrixInvert(matModel)))
  }
  //-----------------------------------------------------

  // Bind active texture maps (if available)
  for i in 0..<MAX_MATERIAL_MAPS {
    if (material.maps[i].texture.id > 0) {
      // Select current shader texture slot
      rlgl.ActiveTextureSlot(i32(i))
      // Enable texture for active slot
      #partial switch cast(MMI) i {
      case .IRRADIANCE, .PREFILTER, .CUBEMAP:
        rlgl.EnableTextureCubemap(material.maps[i].texture.id)
        // println("Enable Texture Cubemap", i)
      case:
        rlgl.EnableTexture(material.maps[i].texture.id)
        // println("Enable Texture", i)
      }
      value := [1]int{ i }
      // value := [1]i32{ i32(i) }
      // value := [1]u32{ u32(i) }
      // value := [1]uintptr{ uintptr(i) }
      // value := [1]rawptr{ rawptr(uintptr(i)) }
      rlgl.SetUniform(material.shader.locs[SLI.MAP_ALBEDO + SLI(i)], raw_data(value[:]), i32(SUDT.INT), 1)
      // rlgl.SetUniform(material.shader.locs[SLI.MAP_ALBEDO + SLI(i)], ZeroPtr, i32(SUDT.INT), 1) // Nope
      // rlgl.SetUniform(material.shader.locs[SLI.MAP_ALBEDO + SLI(i)], rawptr(uintptr(i)), i32(SUDT.INT), 1)
      // gl.Uniform1iv(material.shader.locs[SLI.MAP_ALBEDO + SLI(i)], 1, raw_data([]i32{ transmute(i32) int(i) }))
      // gl.Uniform1i(material.shader.locs[SLI.MAP_ALBEDO + SLI(i)], cast(i32) i )
      // println("Set Uniform for Texture", i, material.shader.locs[SLI.MAP_ALBEDO + SLI(i)])
    }
  }

  // Try binding vertex array objects (VAO)
  // or use VBOs if not possible
  if !rlgl.EnableVertexArray(mesh.vaoId) {
    println("!rlgl.EnableVertexArray(mesh.vaoId)")
    // Bind mesh VBO data: vertex position (shader-location = 0)
    rlgl.EnableVertexBuffer(mesh.vboId[0])
    rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.VERTEX_POSITION]), 3, rlgl.FLOAT, false, 0, ZeroPtr)
    rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_POSITION]))

    // Bind mesh VBO data: vertex texcoords (shader-location = 1)
    rlgl.EnableVertexBuffer(mesh.vboId[1])
    rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.VERTEX_TEXCOORD01]), 2, rlgl.FLOAT, false, 0, ZeroPtr)
    rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_TEXCOORD01]))

    if material.shader.locs[SLI.VERTEX_NORMAL] != -1 {
      // Bind mesh VBO data: vertex normals (shader-location = 2)
      rlgl.EnableVertexBuffer(mesh.vboId[2])
      rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.VERTEX_NORMAL]), 3, rlgl.FLOAT, false, 0, ZeroPtr)
      rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_NORMAL]))
    }

    // Bind mesh VBO data: vertex colors (shader-location = 3, if available)
    if (material.shader.locs[SLI.VERTEX_COLOR] != -1) {
      if (mesh.vboId[3] != 0) {
        rlgl.EnableVertexBuffer(mesh.vboId[3])
        rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.VERTEX_COLOR]), 4, rlgl.UNSIGNED_BYTE, true, 0, ZeroPtr)
        rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_COLOR]))
      } else {
        // Set default value for unused attribute
        // NOTE: Required when using default shader and no VAO support
        value: [4]f32 = { 1, 1, 1, 1 }
        rlgl.SetVertexAttributeDefault(material.shader.locs[SLI.VERTEX_COLOR], raw_data(value[:]), i32(SADT.VEC4), 4) // can try raw_data([]f32{ 1, 1, 1, 1 }) sometime
        rlgl.DisableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_COLOR]))
      }
    }

    // Bind mesh VBO data: vertex tangents (shader-location = 4, if available)
    if (material.shader.locs[SLI.VERTEX_TANGENT] != -1) {
      rlgl.EnableVertexBuffer(mesh.vboId[4])
      rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.VERTEX_TANGENT]), 4, rlgl.FLOAT, false, 0, ZeroPtr)
      rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_TANGENT]))
    }

    // Bind mesh VBO data: vertex texcoords2 (shader-location = 5, if available)
    if material.shader.locs[SLI.VERTEX_TEXCOORD02] != -1 {
      rlgl.EnableVertexBuffer(mesh.vboId[5])
      rlgl.SetVertexAttribute(u32(material.shader.locs[SLI.VERTEX_TEXCOORD02]), 2, rlgl.FLOAT, false, 0, ZeroPtr)
      rlgl.EnableVertexAttribute(u32(material.shader.locs[SLI.VERTEX_TEXCOORD02]))
    }

    if mesh.indices != ZeroPtr { rlgl.EnableVertexBufferElement(mesh.vboId[6]) }
  }

  eyeCount:i32 = 1
  if rlgl.IsStereoRenderEnabled() { eyeCount = 2 }

  for eye in 0..<eyeCount {
    // Calculate model-view-projection matrix (MVP)
    matModelViewProjection := rl.Matrix(1)
    if eyeCount == 1 {
      matModelViewProjection = matModelView * matProjection
      // println("matModelViewProjection", matModelViewProjection)
    } else {
      // Setup current eye viewport (half screen width)
      rlgl.Viewport(eye * rlgl.GetFramebufferWidth() / 2, 0, rlgl.GetFramebufferWidth() / 2, rlgl.GetFramebufferHeight())
      matModelViewProjection = (matModelView * rlgl.GetMatrixViewOffsetStereo(eye)) * rlgl.GetMatrixProjectionStereo(eye)
    }

    // Send combined model-view-projection matrix to shader
    rlgl.SetUniformMatrix(material.shader.locs[SLI.MATRIX_MVP], matModelViewProjection)

    // Draw mesh instanced
    if mesh.indices != ZeroPtr {
      rlgl.DrawVertexArrayElementsInstanced(0, mesh.triangleCount * 3, ZeroPtr, i32(instances))
    } else {
      rlgl.DrawVertexArrayInstanced(0, mesh.vertexCount, i32(instances))
    }
  }

  // Unbind all bound texture maps
  for i in 0..<MAX_MATERIAL_MAPS {
    if material.maps[i].texture.id > 0 {
      // Select current shader texture slot
      rlgl.ActiveTextureSlot( i32(i) )

      // Disable texture for active slot
      #partial switch cast(MMI) i {
      case .IRRADIANCE, .PREFILTER, .CUBEMAP:
        rlgl.DisableTextureCubemap()
      case:
        rlgl.DisableTexture()
      }
    }
  }

  // Disable all possible vertex array objects (or VBOs)
  rlgl.DisableVertexArray()
  rlgl.DisableVertexBuffer()
  rlgl.DisableVertexBufferElement()

  // Disable shader program
  rlgl.DisableShader()

  // Remove instance transforms buffer
  rlgl.UnloadVertexBuffer(instancesVboId)
}

// rlhSetUniform :: proc(locIndex: int, value: $T, uniformType: SUDT, count: int) {
//   switch uniformType {
//   case .FLOAT:     gl.Uniform1fv(locIndex, count, value)
//   case .VEC2:      gl.Uniform2fv(locIndex, count, value)
//   case .VEC3:      gl.Uniform3fv(locIndex, count, value)
//   case .VEC4:      gl.Uniform4fv(locIndex, count, value)
//   case .INT:       gl.Uniform1i(locIndex, value)
//   case .IVEC2:     gl.Uniform2iv(locIndex, count, value)
//   case .IVEC3:     gl.Uniform3iv(locIndex, count, value)
//   case .IVEC4:     gl.Uniform4iv(locIndex, count, value)
//   case .SAMPLER2D: gl.Uniform1iv(locIndex, count, value)
//   case: // TRACELOG(RL_LOG_WARNING, "SHADER: Failed to set uniform value, data type not recognized");
//   }
// }
