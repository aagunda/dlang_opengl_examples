import std.stdio, std.algorithm, std.range;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

int main()
{
  DerelictGLFW3.load();
  DerelictGL3.load();

  glfwInit();

  GLFWwindow* window = glfwCreateWindow(500, 500, "test", null, null);
  while (!glfwWindowShouldClose(window)) {
    glfwPollEvents();
  }

  return 0;
}
