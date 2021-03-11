import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:rive/src/rive_core/shapes/shape.dart';

class Palette {
  static const PaletteEntry white = BasicPalette.white;
  static const PaletteEntry red = PaletteEntry(Color(0xFFFFff00));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF3000FF));
}

class Disc extends PositionComponent {
  Offset speed;
  bool held = false;
  var speedX = 1.0;
  bool flying = false;
  var life = 0.1;
  static const radius = 100.0;
  static Vector2 spawnPos = Vector2(200, 700);
  static Paint red = Palette.red.paint;
  static Paint blue = Palette.blue.paint;
  static Paint palette = red;
  Shape shape;
  Disc(Shape s) {
    shape = s;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    palette.style = PaintingStyle.stroke;
    //size = 100/life;
    // palette.color = palette.color.withOpacity(life);
    var s = size;
    // if (life > 1) {
    var r = max(5, radius - life * 10);
    s.x = r;
    s.y = r;
    // }
    palette.strokeWidth = max(2, 10 - 5 * life);
    //s.x=s.x.clamp(10,100);
    c.drawRect(s.toRect(), palette);
    if (!flying && held)
      c.drawRect(s.toRect(), Palette.white.withAlpha(100).paint);

    shape.x = position.x;
    shape.y = position.y - 300;
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += dt;
    // position.rotate(dt, center: Vector2(300, 700));
    if (flying) {
      if (position.y < 0 ||
          position.y > window.physicalSize.height / window.devicePixelRatio) {
        speed = Offset(speed.dx, -speed.dy);
        position.y += speed.dy;
      }
      if (position.x < 0 ||
          position.x > window.physicalSize.width / window.devicePixelRatio) {
        speed = Offset(-speed.dx, speed.dy);
        position.x += speed.dx;
      }
      position.x += speed.dx;
      position.y += speed.dy;
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
      position += spawnDist / (life * 10);
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
