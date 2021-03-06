import std.stdio, std.algorithm, std.range, std.file, std.string, std.conv;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

import utils.shader;
import utils.model;

enum { Triangles, NumVAOs };
enum { ArrayBuffer, NumBuffers };
enum { vPosition = 0, vNormal, vColor };

GLuint VAOs[NumVAOs];
GLuint Buffers[NumBuffers];

Vertex vertices[];

void init() {
  glGenVertexArrays(NumVAOs, VAOs.ptr);
  glBindVertexArray(VAOs[Triangles]);

  vertices = loadModel("model.json");

  glGenBuffers(NumBuffers, Buffers.ptr);
  glBindBuffer(GL_ARRAY_BUFFER, Buffers[ArrayBuffer]);
  glBufferData(GL_ARRAY_BUFFER, vertices.length * Vertex.sizeof, vertices.ptr, GL_STATIC_DRAW);

  ShaderInfo shaders[] = [
    { GL_VERTEX_SHADER, "triangles.vert" },
    { GL_FRAGMENT_SHADER, "triangles.frag" }
  ];

  GLuint program = LoadShaders(shaders);
  glUseProgram(program);

  glEnableVertexAttribArray(vPosition);
  glEnableVertexAttribArray(vColor);

  glVertexAttribPointer(vPosition, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, null);
  auto offset = 6 * float.sizeof;
  glVertexAttribPointer(vColor, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(void*)offset);
}

struct WindowState {
  uint width = 500;
  uint height = 500;
};

WindowState state;

extern (C) nothrow {
  void resized(GLFWwindow* window, int width, int height) {
    state.width = width;
    state.height = height;
    glViewport(0, 0, width, height);
  }
}

struct S {
  void opDispatch(string s)() {
    writefln(s);
  }
}

int main() {
  DerelictGL3.load();
  DerelictGLFW3.load();

  glfwInit();

  glfwWindowHint(GLFW_SAMPLES, 16);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  GLFWwindow* window = glfwCreateWindow(state.width, state.height, "Example 01", null, null);
  glfwSetWindowSizeCallback(window, &resized);  
  glfwMakeContextCurrent(window);

  DerelictGL3.reload();

  init();
  
  auto s = S();
  s.foo();

  glClearColor(0.0, 0.0, 0.0, 1.0);
  //glClearDepth(-10.0);
  glEnable(GL_DEPTH_TEST);
  //glDepthRange(10.0, -10.0);
  //glDepthFunc(GL_GREATER);

  while (!glfwWindowShouldClose(window)) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBindVertexArray(VAOs[Triangles]);
    glDrawArrays(GL_TRIANGLES, 0, to!int(vertices.length));

    glfwSwapBuffers(window);
    glfwPollEvents();
  }

  return 0;
}
