import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'catutl.dart';

class SelmvCommand implements CatutlCommand {

  final SelmvParams args = SelmvParams();

  @override
  FutureOr<ArgParser> build() {
    final parser = ArgParser();

    parser.addOption(
      'input',
      abbr: 'i',
      defaultsTo: Directory.current.path,
      help: 'Folder to copy from',
      callback: (i) => args.input = i is String ? Directory(i) : Directory.current,
    );
    parser.addOption(
      'output',
      abbr: 'o',
      mandatory: true,
      help: 'Folder to copy to',
      callback: (o) => args.output = Directory(o!),
    );
    parser.addOption(
      'pattern',
      abbr: 'p',
      defaultsTo: '\.mp3\$',
      help: 'Regular expression to select files',
      callback: (p) => args.pattern = p is String ? RegExp(p) : RegExp(r'\.mp3$'),
    );

    return parser;
  }

  @override
  FutureOr<void> run() async {
    await args.validate();

    final entities = await args.input
        .list()
        .where((f) => args.pattern.hasMatch(f.path))
        .toList();

    if(entities.isEmpty) {
      print('No matches detected');
      exit(1);
    }

    print('Moving ${entities.length} files to ${args.output}:\n');

    for (FileSystemEntity entity in entities) {
      if (entity is! File) return;

      final String filename = basename(entity.path);
      final String newPath = join(args.output.path, filename);

      await entity.rename(newPath);

      print('\t$filename');
    }

    exit(0);
  }

}

class SelmvParams {
  late Directory input;

  late Directory output;

  late RegExp pattern;

  Future<void> validate() async {
    if (!await input.exists()) // fmt
      throw ArgumentError('Input directory is invalid');

    if (!await output.exists()) // fmt
      throw ArgumentError('Input directory is invalid');
  }
}
