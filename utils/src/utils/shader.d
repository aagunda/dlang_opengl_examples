module utils.shader;

import std.stdio, std.algorithm, std.range, std.file, std.string;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

struct ShaderInfo { GLenum type; string filename; GLuint handle; };

GLuint LoadShaders(ShaderInfo[] shaders) {
  auto program = glCreateProgram();
  GLint res;

  foreach (shader; shaders) {
    auto source = readText(shader.filename);

    shader.handle = glCreateShader(shader.type);
    auto tmp = source.toStringz;
    glShaderSource(shader.handle, 1, &tmp, null);
    glCompileShader(shader.handle);

    glGetShaderiv(shader.handle, GL_COMPILE_STATUS, &res);
    writeln(res);
    glAttachShader(program, shader.handle);
  }

  glLinkProgram(program);
  glGetProgramiv(program, GL_LINK_STATUS, &res);
  writeln(res);
  return program;
}

