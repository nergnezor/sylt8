import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flingjammer/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rive/src/rive_core/shapes/shape.dart';
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
  static Paint palette = red;
  Shape shape;
  AccelerometerEvent acc;
  Disc(Shape s) {
    shape = s;
    if (!kIsWeb && Platform.isAndroid || Platform.isIOS)
      accelerometerEvents.listen((AccelerometerEvent event) {
        // print(event);
        acc = event;
        // shape.x -= event.x;
        // shape.y += event.y;
      });
  }
  @override
  void render(Canvas c) {
    return;
    super.render(c);
    palette.style = PaintingStyle.stroke;
    //size = 100/life;
    // palette.color = palette.color.withOpacity(life);
    var s = size;
    // if (life > 1) {
    double r = max(20, radius - life * 10);
    s.x = r;
    s.y = r;
    // }
    palette.strokeWidth = max(4, 10 - 5 * life);
    //s.x=s.x.clamp(10,100);
    c.drawOval(s.toRect(), palette);
    if (!flying && held)
      c.drawOval(s.toRect(), Palette.white.withAlpha(100).paint);
    r /= 100;
    // shape?.scaleX = r;
    // shape?.scaleY = r;
    //   -300;
  }

  @override
  void update(double dt) {
    super.update(dt);
    shape?.x = position.x - spawnPos.x;
    // MyGame.artboard.x = 0;
    shape?.y = position.y - spawnPos.y / 1.7;
    angle += dt;
    if (shape?.scaleY < 1) shape.scaleY += 0.01 / pow(shape.scaleY, 2);
    // if (shape?.scaleY > 1) shape?.scaleY -= 0.1;
    // position.rotate(dt, center: Vector2(300, 700));
    // speed.dx -= acc?.x;
    // position.y += acc?.y;
    if (flying) {
      if (acc != null)
        speed = Offset(speed.dx - acc?.x / 120, speed.dy + acc?.y / 120);
      final height = window.physicalSize.height / window.devicePixelRatio;
      if (position.y < 0 || position.y > height) {
        speed = Offset(speed.dx, -speed.dy);
        position.y += speed.dy;
        shape?.scaleY =
            max(0.1, shape.scaleY - speed.dy.abs() / MyGame.frameRate);
      }
      if (position.x < 0 || position.x > height) {
        speed = Offset(-speed.dx, speed.dy);
        position.x += speed.dx;
      }
      // if (speed != null) {
      position.x += speed.dx;
      position.y += speed.dy;
      // }
      speed *= 0.99;
      life -= 0.01;

      if (life < 0) {
        flying = false;
        // position = spawnPos;
        //  remove();
        //   add(Disc());
      }
    } else if (life < 1) {
      life += 0.01;
    }
    if (flying) {
      var spawnDist = spawnPos - position;
      // position += spawnDist / (life * 10);
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
