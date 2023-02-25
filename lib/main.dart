import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final game = RiveExampleGame();
  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
    );
  }
}

class RiveExampleGame extends Forge2DGame with HasTappables {
  @override
  Color backgroundColor() {
    return Color.fromARGB(64, 128, 128, 128);
  }

  @override
  Future<void> onLoad() async {
    final skillsArtboard =
        await loadArtboard(RiveFile.asset('nerg.riv'), artboardName: 'alla');

    add(SkillsAnimationComponent(skillsArtboard, camera, size: size));
  }
}

class SkillsAnimationComponent extends RiveComponent with Tappable {
  final Camera camera;

  SkillsAnimationComponent(Artboard artboard, this.camera,
      {required Vector2 size})
      : super(artboard: artboard, size: Vector2(size.x, size.y));
  SMITrigger? triggerInput;
  @override
  void onLoad() {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    if (controller != null) {
      artboard.addController(controller);
      triggerInput = controller.findSMI("scale") as SMITrigger;
    }
  }

  @override
  bool onTapDown(TapDownInfo info) {
    camera.shake(duration: 0.5, intensity: 0.5);
    final p = info.eventPosition.game;
    print(p);
    print(size);
    if (max((p.y - size.y / 2).abs(), (p.x - size.x / 2).abs()) < 10) {
      triggerInput?.fire();
      print('tapped on the logo');
    } else {
      print('tapped outside');
    }
    return true;
  }
}
