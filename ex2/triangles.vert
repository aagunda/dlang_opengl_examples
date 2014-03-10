#version 410 core

layout(location = 0) 
in vec4 vPosition;

layout(location = 1)
in vec4 vNormal;

layout(location = 2)
in vec4 vColor;

out vec4 fColor;

void main()
{
  gl_Position = vPosition;
  fColor = vColor;
}
