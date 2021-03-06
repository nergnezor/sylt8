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
  static const speed = 0.25;
  static const squareSize = 128.0;

  static Paint white = Palette.white.paint;
  static Paint red = Palette.red.paint;
  static Paint blue = Palette.blue.paint;

  @override
  void render(Canvas c) {
    super.render(c);
    white.style = PaintingStyle.stroke;
    white.strokeWidth = 2;
    c.drawOval(size.toRect(), white);
    // c.drawRect(const Rect.fromLTWH(0, 0, 3, 3), red);
    // c.drawRect(Rect.fromLTWH(width / 2, height / 2, 3, 3), blue);
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += speed * dt;
    angle %= 2 * math.pi;
  }

  @override
  void onMount() {
    super.onMount();
    size = Vector2.all(squareSize);
    anchor = Anchor.center;
  }
}

class MyGame extends BaseGame
    with DoubleTapDetector, TapDetector, VerticalDragDetector {
  bool running = true;

  MyGame() {
    add(Disc()
      ..x = 100
      ..y = 100);
  }
  bool isTouched(Offset pos) {
    final touchArea = Rect.fromCenter(
      center: pos,
      width: 20,
      height: 20,
    );

    final handled = components.any((c) {
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        remove(c);
        return true;
      }
    });
    return false;
  }

  @override
  void onVerticalDragUpdate(DragUpdateDetails details) {}
  @override
  void onTapUp(TapUpDetails details) {}
  @override
  void onTapDown(TapDownDetails details) {
    final handled = isTouched(details.localPosition);
    if (!handled) {
      add(Disc()
        ..x = details.localPosition.dx
        ..y = details.localPosition.dy);
    }
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
