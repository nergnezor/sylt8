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
// import 'package:rive/src/rive_core/shapes/shape.dart';
import 'package:sensors/sensors.dart';

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFFff00));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF3000FF));
}

class Disc extends PositionComponent {
  Offset speed = Offset.zero;
  bool held = false;
  var speedX = 1.0;
  bool flying = false;
  var life = 0.1;
  static const radius = 200.0;
  static Vector2 spawnPos = Vector2(200, 700);
  static Paint red = Palette.red.paint;
  static Paint blue = Palette.blue.paint;
  static Paint palette = Palette.white.paint;
  Shape shape;
  AccelerometerEvent acc;
  Disc(Shape s) {
    shape = s;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      accelerometerEvents.listen((AccelerometerEvent event) {
        acc = event;
      });
  }
  @override
  void render(Canvas c) {
    // return;
    super.render(c);
    palette.style = PaintingStyle.stroke;
    palette.strokeWidth = 3;
    // c.drawOval(size.toRect(), palette);
    if (!flying && held) c.drawOval(size.toRect(), palette);
  }

  @override
  void update(double dt) {
    if (acc != null)
      speed = Offset(speed.dx - acc.x / MyGame.frameRate,
          speed.dy + acc.y / MyGame.frameRate);
    position.x += speed.dx;
    position.y += speed.dy;
    angle += dt;

    if (shape.scaleY < 1) {
      shape.scaleY += 1 / (MyGame.frameRate * pow(shape.scaleY, 1));
      shape.scaleY = min(1, shape.scaleY);
    }
    if (shape.scaleX < 1) {
      shape.scaleX += 1 / (MyGame.frameRate * pow(shape.scaleX, 1));
      shape.scaleX = min(1, shape.scaleX);
    }
    collision();
    shape.x = position.x - MyGame.screenSize.x / 2;
    shape.y = position.y - MyGame.screenSize.y / 2;
    speed *= 0.99;
    if (flying) {
      life -= 0.01;
      if (life < 0) flying = false;
    } else if (life < 1) life += 0.01;

    super.update(dt);
  }

  void collision() {
    final h = window.physicalSize.height / window.devicePixelRatio;
    final w = window.physicalSize.width / window.devicePixelRatio;
    Rect size = shape.fillPath.getBounds();
    int r = size.bottom.toInt();
    if (position.y < r || position.y > h - r) {
      speed = Offset(speed.dx, -speed.dy);
      shape?.scaleY = max(0.1, shape.scaleY - speed.dy.abs() / 20);
      position.y += speed.dy;
    }
    if (position.x < r || position.x > w - r) {
      speed = Offset(-speed.dx, speed.dy);
      shape?.scaleX = max(0.1, shape.scaleX - speed.dx.abs() / 40);
      position.x += speed.dx;
    }
  }

  @override
  void onMount() {
    super.onMount();
    size = Vector2.all(radius);
    position = spawnPos;
    anchor = Anchor.center;
  }

  void changeSpeed(Offset o, double div) {
    speed = Offset(o.dx / div, o.dy / div);
    life += speed.distance / 10;
  }
}
