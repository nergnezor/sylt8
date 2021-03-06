import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import 'wiper_controller.dart';

void main() => runApp(MyApp());

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
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              print("tap");
              Shape shape = _artboard.children.firstWhere(
                  (element) => element.coreType == Shape().coreType);
              shape.scaleY += (details.delta.dy / 100);
            },
            onTap: () {
              doit();
            },
            child: _artboard != null
                ? Rive(
                    artboard: _artboard,
                    fit: BoxFit.cover,
                  )
                : Container(),
          ),
        ),
        SizedBox(
          height: 50,
          width: 200,
          child: SwitchListTile(
            title: const Text('Wipers'),
            value: _wipers,
            onChanged: _wipersChange,
          ),
        ),
      ],
    );
  }

  doit() {
    print("hej");
    // _artboard.path.transform(Transform.scale(scale: 0.9).);
  }
}
