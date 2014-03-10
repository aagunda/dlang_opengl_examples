#version 410 core

in vec4 gl_FragCoord;
out vec4 fColor;

void main()
{
  //if (gl_FragCoord.x < 200 || gl_FragCoord.y < 200)
  //  discard;

  fColor = vec4(0.0, 0.0, 1.0, 1.0);
}
