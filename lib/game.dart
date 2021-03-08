import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(
//     GameWidget(
//       game: MyGame(),
//     ),
//   );
// }

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFF0000));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF0000FF));
}

class Disc extends PositionComponent {
  Offset speed;
  var speedX = 1.0;
  bool flying = false;
  var life = 0.1;
  static const radius = 100.0;
  static Vector2 spawnPos = Vector2(200, 700);
  static Paint palette = Palette.white.paint;
  static Paint red = Palette.red.paint;
  static Paint blue = Palette.blue.paint;

  @override
  void render(Canvas c) {
    super.render(c);
    palette.style = PaintingStyle.stroke;
    palette.strokeWidth = life*10;
    //size = 100/life;
   // palette.color = palette.color.withOpacity(life);
    var s=size;
    
    //s.x -= speed.dy.abs();
    //s.x=s.x.clamp(10,100);
    c.drawOval(s.toRect(), palette);
    c.drawRect(const Rect.fromLTWH(0, 0, 3, 3), red);
    // c.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), blue);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (flying) {
      position.y += speed.dy;
      position.x += speed.dx;
      if (position.y < 0) {
        position.y = 0;
        speed = Offset(speed.dx, -speed.dy);
      }
      if (position.x < 0 || position.x > MyGame.screenSize.x) {
        //position.x = 0;
        speed = Offset(-speed.dx, speed.dy);
      }
      speed *= 0.97;
      life -= 0.01;
     
      if (life <= 0) {
        flying = false;
        position = spawnPos;
        //  remove();
        //   add(Disc());
      }
    } else if (life < 1) life += 0.01;
  }

  @override
  void onMount() {
    anchor = Anchor.center;
    super.onMount();
    size = Vector2.all(radius);
    position = spawnPos;
  }

  void changeSpeed(Offset o, int div) {
    speed = Offset(o.dx / div, o.dy / div);
    life += speed.distance/100;
  }
}

class MyGame extends BaseGame
    with DoubleTapDetector, TapDetector, VerticalDragDetector {
  bool running = true;
  var frameRate = 120;
  static Vector2 screenSize;
  Disc currentDisc;
  

  MyGame() {
    add(Disc()
      ..x = 200
      ..y = 100);
  }
  Component isTouched(Offset pos) {
    final touchArea = Rect.fromCenter(
      center: pos,
      width: 20,
      height: 20,
    );

    for (var c in components) {
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        return c;
      }
    }
    return null;
  }

  @override
  void onResize(Vector2 canvasSize) {
    screenSize = canvasSize;
    super.onResize(canvasSize);
  }

  @override
  void onVerticalDragEnd(DragEndDetails details) {
    currentDisc?.flying = true;
    currentDisc?.changeSpeed(details.velocity.pixelsPerSecond, frameRate);
    currentDisc=null;
  }

  @override
  void onVerticalDragUpdate(DragUpdateDetails details) {
    var disc = isTouched(details.localPosition);
    if (disc == null) return;
    currentDisc = (disc as Disc);
    currentDisc.position =
        Vector2(details.localPosition.dx, details.localPosition.dy);
        currentDisc.flying=false;
  }

  @override
  void onDoubleTap() {
    if (running) {
      pauseEngine();
    } else {
      resumeEngine();
    }

    running = !running;
  }
}
