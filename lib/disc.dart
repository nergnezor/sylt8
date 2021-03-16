import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flingjammer/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:sensors/sensors.dart';

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFFff00));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF3000FF));
}

enum Dir { top, right, bottom, left }

class Disc extends PositionComponent {
  Offset speed = Offset.zero;
  bool held = false;
  var speedX = 1.0;
  bool flying = false;
  var life = 0.1;
  static Vector2 spawnPos = Vector2(200, 700);
  static Paint red = Palette.red.paint;
  static Paint blue = Palette.blue.paint;
  static Paint palette = Palette.white.paint;
  Shape shape;
  AccelerometerEvent acc;
  List vertices;
  final h = window.physicalSize.height / window.devicePixelRatio;
  final w = window.physicalSize.width / window.devicePixelRatio;
  double radius;
  Disc(Shape s) {
    shape = s;
    vertices = shape.paths.first.vertices;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      accelerometerEvents.listen((AccelerometerEvent event) {
        acc = event;
      });
  }
  @override
  void render(Canvas c) {
    super.render(c);
    palette.style = PaintingStyle.stroke;
    palette.strokeWidth = 3;
    Rect r = (size * 2).toRect();
    r = r.translate(-radius / 2, -radius / 2);
    // c.drawOval(r, Palette.blue.paint);
    if (!flying && held) c.drawOval(r, palette);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (acc != null && !held)
      speed = Offset(speed.dx - acc.x / MyGame.frameRate,
          speed.dy + acc.y / MyGame.frameRate);
    position.x += speed.dx;
    position.y += speed.dy;
    collision();
    shape.x = position.x - MyGame.screenSize.x / 2;
    shape.y = position.y - MyGame.screenSize.y / 2;
    speed *= 0.99;
  }

  void collision() {
    const forces = {4, 2};

    var left = vertices[Dir.left.index];
    var top = vertices[Dir.top.index];
    var bottom = vertices[Dir.bottom.index];
    var right = vertices[Dir.right.index];
    if (position.y < radius || position.y > h - radius) {
      speed = Offset(speed.dx, -speed.dy);
      bool topEdge = position.y < h / 2;
      top.y += speed.dy * (topEdge ? forces.first : forces.last);
      bottom.y += speed.dy * (topEdge ? forces.last : forces.first);
    }
    if (position.x < -left.x || position.x > w - right.x) {
      speed = Offset(-speed.dx, speed.dy);
      bool leftEdge = position.x < w / 2;
      left.x += speed.dx * (leftEdge ? forces.first : forces.last);
      right.x += speed.dx * (leftEdge ? forces.last : forces.first);
    }
    vertices.forEach((v) {
      v.inDistance += 1 * (Random().nextDouble() - 0.5);
      v.outDistance += 1 * (Random().nextDouble() - 0.5);
      v.inRotation += 0.01 * (Random().nextDouble() - 0.5);
      v.outRotation += 0.01 * (Random().nextDouble() - 0.5);
    });
    position.clamp(Vector2(left.x, top.y), MyGame.screenSize.xy);

//  grow
    {
      num d = 0.1;
      final v = RangeValues(50, 100);
      left.x = (left.x - d).clamp(-v.end, -v.start);
      top.y = (top.y - d).clamp(-v.end, -v.start);
      bottom.y = (bottom.y + d).clamp(v.start, v.end);
      right.x = (right.x + d).clamp(v.start, v.end);
    }
  }

  @override
  void onMount() {
    super.onMount();
    radius = shape.fillPath.getBounds().bottom;
    size = Vector2.all(radius);
    position = spawnPos;
    anchor = Anchor.center;
  }

  void changeSpeed(Offset o, double div) {
    speed = Offset(o.dx / div, o.dy / div);
    life += speed.distance / 10;
  }
}
