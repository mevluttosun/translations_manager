import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:translations_manager/src/export_unused_terms.dart';
import 'package:translations_manager/src/models/term.dart';
import 'package:translations_manager/src/translation_files.dart';
import 'package:translations_manager/src/unused_terms.dart';

/// Delete unused terms from the dart files
Future<void> deleteTerms(ArgResults? argResults) async {
  final bool exportTermsFlag = argResults?['export'] ?? true;
  final String? outputPath = argResults?['output-path'];

  final files = translationFiles();
  final terms = findUnusedTerms();

  if (terms.isNotEmpty && exportTermsFlag) {
    exportTerms(terms, outputPath);
  }
  await Future.wait(files.map((file) => _deleteTermsForFile(file, terms)));
  print('${terms.length} terms removed from ${files.length} files each 💪 🚀');
}

Future<void> _deleteTermsForFile(
    FileSystemEntity jsonFile, Set<Term> terms) async {
  final fileString = await File(jsonFile.path).readAsString();
  final Map<String, dynamic> fileJson = jsonDecode(fileString);
  for (var term in terms) {
    fileJson.remove(term.key);
  }
  // Indent is being used for proper formatting
  await File(jsonFile.path)
      .writeAsString(JsonEncoder.withIndent(' ' * 4).convert(fileJson));
}
