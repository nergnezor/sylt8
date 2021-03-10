import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:rive/rive.dart';
// import 'dart:io' show Platform;

import 'game.dart';
import 'wiper_controller.dart';

// void main() => runApp(MyApp());
void set120Hz() async {
  var modes;
  try {
    modes = await FlutterDisplayMode.supported;
  } on MissingPluginException catch (e) {}
  modes.forEach(print);

  /// On OnePlus 7 Pro:
  /// #1 1080x2340 @ 60Hz
  /// #2 1080x2340 @ 90Hz
  /// #3 1440x3120 @ 90Hz
  /// #4 1440x3120 @ 60Hz

  /// On OnePlus 8 Pro:
  /// #1 1080x2376 @ 60Hz
  /// #2 1440x3168 @ 120Hz
  /// #3 1440x3168 @ 60Hz
  /// #4 1080x2376 @ 120Hz
  try {
    await FlutterDisplayMode.setMode(modes.last);

    /// e.code =>
    /// noAPI - No API support. Only Marshmallow and above.
    /// noActivity -  Activity is not available. Probably app is in background
  } on PlatformException catch (e) {}
}

void main() {
  MyGame.frameRate = 60;
  final MyApp app = MyApp();
  runApp(app);
  try {
    if (!kIsWeb && Platform.isAndroid) {
      set120Hz();
      MyGame.frameRate = 120;
    }
  } catch (e) {}
}

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

class TapboxA extends StatefulWidget {
  TapboxA({Key key}) : super(key: key);

  @override
  _TapboxAState createState() => _TapboxAState();
}

class _TapboxAState extends State<TapboxA> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _MyRiveAnimationState extends State<MyRiveAnimation> {
  final riveFileName = 'assets/pong.riv';
  Artboard _artboard;
  WiperAnimation _wipersController;
  // Flag to turn wipers on and off
  bool _wipers = false;

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

  void _wipersChange(bool wipersOn) {
    if (_wipersController == null) {
      _artboard.addController(
        _wipersController = WiperAnimation('windshield_wipers'),
      );
    }
    if (wipersOn) {
      _wipersController.start();
    } else {
      _wipersController.stop();
    }
    setState(() => _wipers = wipersOn);
  }

  // final bool active;
  // final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Column(
        // children: [
        Expanded(
          child: _artboard != null
              ? Rive(
                  artboard: _artboard,
                  fit: BoxFit.cover,
                )
              : Container(),
        ),

        // ),
        GameWidget(
          game: MyGame(),
        )
      ],
    );
    // ];
  }
}
