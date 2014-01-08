module utils.model;

import std.stdio, std.algorithm, std.range, std.file, std.string, std.json, std.conv, std.math;

alias float[3] Vec3;

struct Vertex {
  Vec3 position;
  Vec3 normal;
  Vec3 color;
};

alias Vertex[3] Triangle;

struct Mesh {
  Triangle triangles[];
};

struct Material {
  Vec3 color;

  this(JSONValue def) {
    auto hex = def["color"].str;

    auto stripped = hex[2..$];
    for (auto i = 0; i < 3; ++i) {
      auto sub = stripped[0 + (2 * i) .. 2 + (2 * i)];
      color[i] = parse!int(sub, 16) / 256.0;
    }
  }
};

struct Square {
  Vec3 geometry[2][3] = [
    [
      [-1.0, -1.0,  0.0],
      [-1.0,  1.0,  0.0],
      [ 1.0,  1.0,  0.0]
    ],
    [
      [ 1.0,  1.0,  0.0],
      [ 1.0, -1.0,  0.0],
      [-1.0, -1.0,  0.0]
    ]
  ]; 

  this(JSONValue def) {
    
  }
};

struct Circle {
  Vec3 geometry[];

  this(JSONValue def) {
    Vec3 center = [0.0, 0.0, 0.0];
    Vec3 last = [1.0, 0.0, 0.0];

    for (auto idx = 1; idx <= 100; ++idx) {
      auto rads = 2 * PI * idx / 100;
      Vec3 next = [cos(rads), sin(rads), 0];
      geometry ~= [last, center, next];
      last = next;
    }
  }
};

Vertex[] loadModel(string filename) {
  auto model = parseJSON(readText(filename));

  auto materials = model["materials"].object;
  foreach (name, def; materials)
    auto m = Material(def);

  Circle c;

  auto objects = model["objects"].object;
  foreach (name, def; objects) {
    auto type = def["type"].str;
    switch (type) {
      case "square": {
        auto obj = Square(def);
        break;
      }
      case "circle": {
        auto obj = Circle(def);
        c = obj;
        break;
      }
      default: {
        writeln("Unknown object type");
      }
    }
  }

  Vertex verts[];
  foreach (pos; c.geometry)
    verts ~= Vertex(pos, [0.0, 0.0, 1.0], [1.0, 0.0f, 1.0f]);

  writeln(verts);

  return verts;
}
