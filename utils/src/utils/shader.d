module utils.shader;

import std.stdio, std.algorithm, std.range, std.file, std.string;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

class Shader {
  GLuint handle;
  GLenum type;

  this(GLenum type, string filename) {
    this.type = type;

    handle = glCreateShader(type);
    auto source = readText(filename);
    auto tmp = source.toStringz;

    glShaderSource(handle, 1, &tmp, null);
    glCompileShader(handle);

    GLint res;
    glGetShaderiv(handle, GL_COMPILE_STATUS, &res);
    if (!res)
      writeln("Failed to compile shader: ", filename);
  }
};

class Program {
  GLuint handle;
  Shader shaders[];

  this(Shader shaders[]) {
    this.shaders = shaders;

    handle = glCreateProgram();

    foreach (shader; shaders)
      glAttachShader(handle, shader.handle);
    glLinkProgram(handle);

    GLint res;
    glGetProgramiv(handle, GL_LINK_STATUS, &res);
    if (!res)
      writeln("Failed to link shader program");
  }
};

struct ShaderInfo { GLenum type; string filename; GLuint handle; };

GLuint LoadShaders(ShaderInfo[] shaderInfo) {
  Shader shaders[];

  foreach (info; shaderInfo)
    shaders ~= new Shader(info.type, info.filename);
  auto program = new Program(shaders);

  return program.handle;
}

