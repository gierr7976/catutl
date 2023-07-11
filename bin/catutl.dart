import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'selmv.dart';

final Map<String, CatutlCommand> commands = {
  'selmv': SelmvCommand(),
};

void main(List<String> args) async {
  final ArgParser parser = ArgParser();
  for(final cmd in commands.entries) {
    final cmdParser = await cmd.value.build();
    parser.addCommand(cmd.key, cmdParser);
  }

  final input = parser.parse(args);
  final cmdName = input.command?.name;
  if(cmdName is! String) {
    print('No command');
    exit(10);
  }

  final cmd = commands[cmdName];
  if(cmd is! CatutlCommand) {
    print('Unknown command: $cmdName');
    exit(10);
  }

  await cmd.run();
}

abstract interface class CatutlCommand {
  FutureOr<ArgParser> build();

  FutureOr<void> run();
}