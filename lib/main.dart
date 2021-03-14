import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:rive/rive.dart';

import 'game.dart';

void set120Hz() async {
  var modes = await FlutterDisplayMode.supported;
  modes.forEach(print);
  try {
    await FlutterDisplayMode.setMode(modes.last);

    /// e.code =>
    /// noAPI - No API support. Only Marshmallow and above.
    /// noActivity -  Activity is not available. Probably app is in background
  } on PlatformException {
    return;
  }
  MyGame.frameRate = modes.last.refreshRate;
}

void main() {
  // final MyApp app = MyApp();
  runApp(MyApp());
  try {
    if (!kIsWeb && Platform.isAndroid) {
      set120Hz();
    }
  } catch (e) {}
}
// void main() {
//   final MyApp app = MyApp();
//   runApp(
//     GameWidget(
//       game: MyGame(null),
//       overlayBuilderMap: {
//         "PauseMenu": (ctx, a) {
//           return app.build(ctx);
//         },
//       },
//     ),
//   );
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gone fishing.',
      home: Scaffold(
        body: MyRiveAnimation(),
      ),
    );
  }
}

class MyRiveAnimation extends StatefulWidget {
  @override
  _MyRiveAnimationState createState() => _MyRiveAnimationState();
}

class _MyRiveAnimationState extends State<MyRiveAnimation> {
  final riveFileName = 'assets/pong.riv';
  Artboard _artboard;
  // WiperAnimation _wipersController;
  // Flag to turn wipers on and off

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile();

    if (file.import(bytes)) {
      setState(() => _artboard = file.mainArtboard
        ..addController(
          SimpleAnimation('Animation 1'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _artboard != null
            ? Rive(
                artboard: _artboard,
                fit: BoxFit.none,
                useArtboardSize: false,
              )
            : Container(),
        Opacity(
            opacity: 0.2,
            child: GameWidget(
              game: MyGame(_artboard),
            ))
      ],
    );
  }
}
