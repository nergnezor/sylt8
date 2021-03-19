import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart' show PositionComponent;
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:rive/rive.dart';
import 'disc.dart';
import 'package:flutter/material.dart';
import 'package:rive/src/rive_core/shapes/paint/trim_path.dart';

class Wall extends PositionComponent {}

class MyGame extends BaseGame
    with MultiTouchTapDetector, MultiTouchDragDetector {
  bool running = true;
  static double frameRate = 60;
  static Vector2 screenSize;
  Disc currentDisc;
  Shape shape;
  static Shape ice;
  TrimPath iceHiglight;
  static Artboard artboard;
  static final Paint paint = Palette.white.paint;
  final pauseOverlayIdentifier = "PauseMenu";
  static Wall wall = Wall();

  MyGame(Artboard a) {
    if (a == null) return;
    shape = a.children.firstWhere((element) => element.name == 'Ball');
    shape.scaleX = shape.scaleY = 0.7;
    ice = a.children.firstWhere((element) => element.name == 'Ice');
    // ice.scaleX = 0.4;
    // ice.scaleY = 0.5;
    iceHiglight = ice.strokes.last.children.last;
    a.children.forEach((element) {
      print({element, element.name});
    });
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
  void update(double dt) {
    super.update(dt);
    iceHiglight.offset += 0.001;
    iceHiglight.start = 0.01;
    iceHiglight.end = 0.02;
    iceHiglight.stroke.thickness += sin(dt * 1000) / 10;
    var verts = ice.paths.single.vertices;
    verts.forEach((v) {
      if (v.x.abs() * ice.scaleX > canvasSize.x / 2) {
        ice.scaleX *= 0.99;
      }
      if (v.y.abs() * ice.scaleY > canvasSize.y / 2) {
        ice.scaleY *= 0.99;
      }
    });
    // ic
    // ice.strokes.last.
    for (var i = 0; i < verts.length; i++) {
      final step = 0.1;
      var j = (i + 1) % verts.length;
      Offset o = Offset(verts[j].x - verts[i].x, verts[j].y - verts[i].y);
      for (num k = 0; k < 1; k += 0.1) {
        // print(verts[i].x + k * o.dx);
        // print(verts[i].y + k * o.dy);
      }
    }
  }

  @override
  void render(Canvas c) {
    super.render(c);
    // c.drawPath(shape.paths.first.uiPath, paint);
    // artboard.draw(c);
    // artboard.draw(c);
    var verts = ice.paths.single.vertices;
    for (var i = 0; i < verts.length; i++) {
      var j = (i + 1) % verts.length;
      Vector2 o = Vector2((verts[j].x - verts[i].x) * ice.scaleX,
          (verts[j].y - verts[i].y) * ice.scaleY);
      for (double k = 0; k < 1; k += 0.1) {
        var start = Vector2(canvasSize.x / 2 + verts[i].x * ice.scaleX,
            canvasSize.y / 2 + verts[i].y * ice.scaleY);
        Vector2 wallPoint = start + o * k;
        shape.paths.single.vertices.forEach((v) {
          if (wallPoint.distanceTo(Vector2(
                  shape.x + v.x * shape.scaleX + canvasSize.x / 2,
                  shape.y + v.y * shape.scaleY + canvasSize.y / 2)) <
              100) {
            c.drawCircle(wallPoint.toOffset(), 50, paint);
          }
        });
        //   print(verts[i].x);
      }
      //   // print(verts[i].y + k * o.dy);
      // });
    }
  }

  @override
  Future<void> onLoad() async {
    if (ice == null) return;
    if (shape != null) add(Disc(shape));
    // ice?.x = ice.localBounds.topLeft.values.first / 2;
    // ice?.x = -size.x * (1 - ice.scaleX);
    print(canvasSize);
  }

  @override
  void onResize(Vector2 canvasSize) {
    ice?.scaleX = ice?.scaleY = 10;
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
