module utils.model;

import utils.shader;

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

alias Vec3[3] TriangleVerts;
alias TriangleVerts[] Geometry;

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
  Geometry geometry = [
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
  Geometry geometry;

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

interface Drawable {
  void draw();
};

class Node : Drawable {
  Drawable children[];

  void draw() {
    foreach (child; children)
      child.draw();
  }

  void addChild(Drawable child) {
    children ~= child;
  }
};

class ShaderNode : Node {
  Program program;

  this() {

  }
  
  this(Program program) {
    this.program = program;
  }

  override void draw() {
    writeln("Set shader program");
    Node.draw();
  }
};

Vertex[] verts;

class MeshNode : Node {
  Mesh mesh;

  this(Mesh mesh) {
    this.mesh = mesh;
  }

  override void draw() {
    writeln("Draw mesh");
    foreach (tri; mesh.triangles)
      verts ~= tri;
    Node.draw();
  }
};

Node processScene(JSONValue curr, Material[string] materials, Geometry[string] objects) {
  auto node = new Node();

  foreach (name, def; curr.object) {
    auto obj = objects[def["object"].str];
    auto mat = materials[def["material"].str];

    Mesh mesh;
    foreach (tri; obj) {
      mesh.triangles ~= [
        Vertex(tri[0], [0, 0, 1], mat.color),
        Vertex(tri[1], [0, 0, 1], mat.color),
        Vertex(tri[2], [0, 0, 1], mat.color)
      ];
    }

    auto m = new MeshNode(mesh);

    /*
    auto children = def.object.get("children", def);
    if (def != children) {
      writeln("okay");
      foreach (child; children.array) {
        m.addChild(processScene(child, materials, objects));
      }
    }
    */

    node.addChild(m);
  }
  return node;
}

Vertex[] loadModel(string filename) {
  auto model = parseJSON(readText(filename));

  Material[string] materials;
  Geometry[string] objects;

  auto material_set = model["materials"].object;
  foreach (name, def; material_set)
    materials[name] = Material(def);

  auto object_set = model["objects"].object;
  foreach (name, def; object_set) {
    auto type = def["type"].str;

    switch (type) {
      case "square": {
        auto obj = Square(def);
        break;
      }
      case "circle": {
        auto obj = Circle(def);
        objects[name] = obj.geometry;
        break;
      }
      default: {
        writeln("Unknown object type");
      }
    }
  }

  auto scene = processScene(model["scene"], materials, objects);
  scene.draw();

  //Vertex verts[];
  return verts;
}
