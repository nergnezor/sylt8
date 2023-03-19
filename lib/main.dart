import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rive/rive.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: MyRiveAnimation(),
    ));

class MyRiveAnimation extends StatefulWidget {
  MyRiveAnimation({super.key});

  @override
  State<MyRiveAnimation> createState() => _MyRiveAnimationState();
}

class _MyRiveAnimationState extends State<MyRiveAnimation> {
  bool showText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        if (showText)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: 200,
              child: FutureBuilder(
                  future: rootBundle.loadString("README.md"),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Markdown(data: snapshot.data!);
                    }

                    return Center();
                  }),
            ),
          ),
        Center(
          child: RiveAnimation.asset(
            'nerg.riv',
            stateMachines: ['State Machine 1'],
            artboard: "alla",
            fit: BoxFit.cover,
            onInit: _onRiveInit,
          ),
        )
      ]),
    );
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1',
            onStateChange: (stateMachineName, stateName) => setState(() {
                  print(stateName);
                  if (stateName == 'ExitState') {
                    return;
                  }
                  showText = stateName == 'zoom';
                }));
    artboard.addController(controller!);
  }
}
