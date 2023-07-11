import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart';

import 'catutl.dart';

class SelmvCommand extends Command<int> {

  @override
  String get name => 'selmv';


  @override
  String get description => 'Moves files matching a regular expression pattern';

  SelmvCommand() {
    argParser.addOption(
      'input',
      abbr: 'i',
      defaultsTo: Directory.current.path,
      help: 'Folder to copy from',
      callback: (i) => _params.input = i is String ? Directory(i) : Directory.current,
    );
    argParser.addOption(
      'output',
      abbr: 'o',
      mandatory: true,
      help: 'Folder to copy to',
      callback: (o) => _params.output = Directory(o!),
    );
    argParser.addOption(
      'pattern',
      abbr: 'p',
      defaultsTo: '\.mp3\$',
      help: 'Regular expression to select files',
      callback: (p) => _params.pattern = p is String ? RegExp(p) : RegExp(r'\.mp3$'),
    );
  }

  final SelmvParams _params = SelmvParams();

  @override
  FutureOr<int> run() async {
    await _params.validate();

    final entities = await _params.input
        .list()
        .where((f) => _params.pattern.hasMatch(f.path))
        .toList();

    if(entities.isEmpty) {
      print('No matches detected');
      exit(1);
    }

    print('Moving ${entities.length} files to ${_params.output}:\n');

    for (FileSystemEntity entity in entities) {
      if (entity is! File) continue;

      final String filename = basename(entity.path);
      final String newPath = join(_params.output.path, filename);
      if(!await _removeExisting(newPath)) continue;

      await entity.rename(newPath);

      print('\t$filename');
    }

    return 0;
  }

  Future<bool> _removeExisting(String newPath) async {
    try {
      final File file = File(newPath);
      if (await file.exists())
        await file.delete();
    } catch (_) {
      print('Невозможно перезаписать файл: $newPath');
      return false;
    }

    return true;
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
