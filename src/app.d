import std.stdio, std.algorithm, std.range, std.file, std.string;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

enum { Triangles, NumVAOs };
enum { ArrayBuffer, NumBuffers };
enum { vPosition = 0 };

GLuint VAOs[NumVAOs];
GLuint Buffers[NumBuffers];

const GLuint NumVertices = 6;

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

void init() {
  glGenVertexArrays(NumVAOs, VAOs.ptr);
  glBindVertexArray(VAOs[Triangles]);

  GLfloat vertices[NumVertices][2] = [
    [ -0.90, -0.90 ],
    [  0.85, -0.90 ],
    [ -0.90,  0.85 ],
    [  0.90, -0.85 ],
    [  0.90,  0.90 ],
    [ -0.85,  0.90 ]
  ];

  glGenBuffers(NumBuffers, Buffers.ptr);
  glBindBuffer(GL_ARRAY_BUFFER, Buffers[ArrayBuffer]);
  glBufferData(GL_ARRAY_BUFFER, vertices.sizeof, vertices.ptr, GL_STATIC_DRAW);

  ShaderInfo shaders[] = [
    { GL_VERTEX_SHADER, "triangles.vert" },
    { GL_FRAGMENT_SHADER, "triangles.frag" }
  ];

  GLuint program = LoadShaders(shaders);
  glUseProgram(program);
  glVertexAttribPointer(vPosition, 2, GL_FLOAT, GL_FALSE, 0, null);
  glEnableVertexAttribArray(vPosition);
}

int main() {
  DerelictGL3.load();
  DerelictGLFW3.load();

  glfwInit();

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  GLFWwindow* window = glfwCreateWindow(500, 500, "Example 01", null, null);
  glfwMakeContextCurrent(window);

  DerelictGL3.reload();

  init();

  glClearColor(1.0, 1.0, 1.0, 1.0);

  while (!glfwWindowShouldClose(window)) {
    glClear(GL_COLOR_BUFFER_BIT);
    glBindVertexArray(VAOs[Triangles]);
    glDrawArrays(GL_TRIANGLES, 0, NumVertices);

    glfwSwapBuffers(window);
    glfwPollEvents();
  }

  return 0;
}
