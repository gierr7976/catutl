import 'dart:io';

import 'package:args/command_runner.dart';

import 'selmv.dart';

void main(List<String> args) async {
  final runner = CommandRunner<int>(
    'catutl',
    'Utility programs developed by @thecat7976',
  );
  runner.addCommand(SelmvCommand());
  final result = await runner.run(args);
  //exit(result ?? -1);
}
