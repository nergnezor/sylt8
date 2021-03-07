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
  var speed = 1.0;
  var speedX = 1.0;
  bool flying = false;
  var life = 1.0;
  static const radius = 100.0;

  static Paint white = Palette.white.paint;
  static Paint red = Palette.red.paint;
  static Paint blue = Palette.blue.paint;

  @override
  void render(Canvas c) {
    super.render(c);
    white.style = PaintingStyle.stroke;
    white.strokeWidth = math.pow(life, 4) * 20;
    white.color = white.color.withOpacity(life);
    c.drawOval(size.toRect(), white);
    // c.drawRect(const Rect.fromLTWH(0, 0, 3, 3), red);
    // c.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), blue);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed;
    if (flying) {
      speed *= 0.97;
      life -= 0.001;
      if (life <= 0) {
        remove();
      }
    }
  }

  @override
  void onMount() {
     anchor = Anchor.center;
 super.onMount();
    size = Vector2.all(radius);
position = Vector2(200,600);
  
  }

  void changeSpeed(double s) {
    if (s.abs() > speed.abs()) speed = s / 100;
    print(s);
  }
}

class MyGame extends BaseGame
    with DoubleTapDetector, TapDetector, VerticalDragDetector {
  bool running = true;
  Disc currentDisc;
  FPSCounter fpsCounter;
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

    // final handled = components.firstWhere((c) {
    for (var c in components) {
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        return c;
      }
      // remove(c);
      // return true;
    }
    // });
    return null;
  }

  @override
  void onVerticalDragDown(DragDownDetails details) {}
  @override
  void onVerticalDragStart(DragStartDetails details) {
    var disc = isTouched(details.localPosition);
    
  }

  @override
  void onVerticalDragEnd(DragEndDetails details) {
    currentDisc?.flying = true;
    // currentDisc.speed = details.velocity.pixelsPerSecond.dy;
    currentDisc?.changeSpeed(details.velocity.pixelsPerSecond.dy);
 
      add(Disc());
    }

  @override
  void onVerticalDragUpdate(DragUpdateDetails details) {
    var disc = isTouched(details.localPosition);
    if (disc == null) return;
    currentDisc = (disc as Disc);
    currentDisc.position =
        Vector2(details.localPosition.dx, details.localPosition.dy);
    // (disc as Disc)?.changeSpeed(details.delta.dy);
    // print(details.localPosition);
  }

  @override
  void onTapUp(TapUpDetails details) {
    print(details);
  }

  @override
  void onTapDown(TapDownDetails details) {
    print("Tap down");
    final c = isTouched(details.localPosition);
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
