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

class MyRiveAnimation extends StatelessWidget {
  bool showText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        if (showText)
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
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

  SMITrigger? planetHit;

  void _onRiveInit(Artboard artboard) {
    // Get State Machine Controller for the state machine called "bumpy"
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1',
            onStateChange: (stateMachineName, stateName) => {
                  if (stateName == 'zoom') {showText = true, print('zoom')},
                  print(
                      'State machine $stateMachineName changed to state $stateName'),
                });
    artboard.addController(controller!);
    // Get a reference to the "bump" state machine input
    // planetHit = controller.findInput<bool>('planetHit') as SMITrigger;
    // React to the "bump" input being triggered
    // planetHit.planetHit!.addCallback((_) => print('planetHit triggered'));
  }
}
