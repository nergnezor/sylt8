// @dart=2.7
// Flutter web bootstrap script for package:flingjammer/main.dart.

import 'dart:async';

import 'package:flingjammer/main.dart' as entrypoint;

typedef _UnaryFunction = dynamic Function(List<String> args);
typedef _NullaryFunction = dynamic Function();
Future<void> main() async {
  if (entrypoint.main is _UnaryFunction) {
    return (entrypoint.main as _UnaryFunction)(<String>[]);
  }
  return (entrypoint.main)();
}
