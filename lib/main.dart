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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        FutureBuilder(
            future: rootBundle.loadString("README.md"),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Markdown(data: snapshot.data!);
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            }),
        Center(
          child: RiveAnimation.asset(
            'nerg.riv',
            stateMachines: ['State Machine 1'],
            artboard: "alla",
            fit: BoxFit.cover,
          ),
        )
      ]),
    );
  }
}
