import 'dart:ui';

import 'package:flame/components.dart' show PositionComponent;
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:rive/rive.dart';
import 'disc.dart';
import 'package:flutter/material.dart';

class MyGame extends BaseGame
    with MultiTouchTapDetector, MultiTouchDragDetector {
  bool running = true;
  static double frameRate = 60;
  static Vector2 screenSize;
  Disc currentDisc;
  Shape shape;
  static Artboard artboard;
  static final Paint paint = Palette.white.paint;
  final pauseOverlayIdentifier = "PauseMenu";

  MyGame(Artboard a) {
    shape = a?.children?.firstWhere((element) => element.name == 'Ball');
    overlays.add(pauseOverlayIdentifier); // marks "PauseMenu" to be rendered.
    artboard = a;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10;
  }

  PositionComponent isTouched(Offset pos) {
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
  void render(Canvas c) {
    super.render(c);
  }

  @override
  Future<void> onLoad() async {
    if (shape != null) add(Disc(shape));
  }

  @override
  void onResize(Vector2 canvasSize) {
    screenSize = canvasSize;
    Disc.spawnPos.x = screenSize.x / 2;
    Disc.spawnPos.y = 5 * screenSize.y / 6;
    super.onResize(canvasSize);
  }

  @override
  void onDragEnd(int, DragEndDetails details) {
    if (currentDisc == null) return;
    currentDisc.flying = true;
    currentDisc.changeSpeed(details.velocity.pixelsPerSecond, frameRate);
    currentDisc.held = false;
    currentDisc = null;
  }

  @override
  void onDragUpdate(int, DragUpdateDetails details) {
    // shape?.x += details.delta.dx;
    // shape?.y += details.delta.dy;
    var disc = isTouched(details.localPosition);
    if (disc == null) return;
    currentDisc = (disc as Disc);
    currentDisc.held = true;
    currentDisc.position =
        Vector2(details.localPosition.dx, details.localPosition.dy);
    currentDisc.flying = false;
  }

  // @override
  // void onTap(int) {
  //   if (running) {
  //     pauseEngine();
  //   } else {
  //     resumeEngine();
  //   }

  //   running = !running;
  // }
}
