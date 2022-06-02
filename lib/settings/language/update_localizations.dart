import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

/// commandline dart app that generates the localization.g.dart file.
void main() async {
  //the document id for your google sheet
  const String documentId = '17UktLwAEDS01i_XYqIULRvj6UMDsA6mY0mOcXTYTXYA';
//the sheetid of your google sheet
  const String sheetId = '0';

  const String url =
      'https://docs.google.com/spreadsheets/d/$documentId/export?format=csv&id=$documentId&gid=$sheetId';

  stdout.writeln('');
  stdout.writeln('---------------------------------------');
  stdout.writeln('Downloading Google sheet url "$url" ...');
  stdout.writeln('---------------------------------------');

  String phraseKey = '';
  List<LocalizationModel> localizations = [];

  try {
    var response = await http
        .get(Uri.parse(url), headers: {'accept': 'text/csv;charset=UTF-8'});

    // print('Google sheet csv:\n ${response.body}');

    final bytes = response.bodyBytes.toList();
    final csv = Stream<List<int>>.fromIterable([bytes]);

    final fields = await csv
        .transform(utf8.decoder)
        .transform(
          const CsvToListConverter(
            shouldParseNumbers: false,
          ),
        )
        .toList();

    final index = fields[0]
        .cast<String>()
        .map(_uniformizeKey)
        .takeWhile((x) => x.isNotEmpty)
        .toList();

    for (var r = 1; r < fields.length; r++) {
      final rowValues = fields[r];

      /// Creating a map
      final row = Map<String, String>.fromEntries(
        rowValues
            .asMap()
            .entries
            .where(
              (e) => e.key < index.length,
            )
            .map(
              (e) => MapEntry(index[e.key], e.value),
            ),
      );

      row.forEach((key, value) {
        if (key == 'key') {
          phraseKey = value;
        } else {
          bool languageAdded = false;
          for (var element in localizations) {
            if (element.language == key) {
              element.phrases.add(PhraseModel(key: phraseKey, phrase: value));
              languageAdded = true;
            }
          }
          if (languageAdded == false) {
            localizations.add(
              LocalizationModel(
                language: key,
                phrases: [PhraseModel(key: phraseKey, phrase: value)],
              ),
            );
          }
        }
      });
    }

    updateLocalizationFile(localizations); // obsolete, uses too much memory
    //updateLocalizationFiles(localizations);
  } catch (e) {
    //output error
    stderr.writeln('error: networking error');
    stderr.writeln(e.toString());
  }
}

/// Creates multiple json files with all translations. App must load each one
/// when the language preference updates.
Future updateLocalizationFiles(List<LocalizationModel> localizations) async {
  int count = 0;
  for (var localization in localizations) {
    count++;
    String text = '{';
    for (var phrase in localization.phrases) {
      String phraseKey =
          phrase.key.replaceAll(r'"', '\\"').replaceAll('\n', '\\n');
      String phrasePhrase =
          phrase.phrase.replaceAll(r'"', '\\"').replaceAll('\n', '\\n');
      String currentPhraseTextCode = '\n"$phraseKey": "$phrasePhrase",';
      text += currentPhraseTextCode;
    }
    // Remove last comma
    text = text.substring(0, text.length - 1);
    text += '\n}\n';

    String filename = '../../../assets/i18n/${localization.language}.json';
    stdout.writeln('Saving $filename');
    final file = File(filename);
    await file.writeAsString(text);
  }
  stdout.writeln('Done writing $count json files');
}

/// Creates a single dart file with all translations, ok if your app is small
/// but if you have lots of translation it takes up too much memory.
Future updateLocalizationFile(List<LocalizationModel> localizations) async {
  String localizationFile = """import 'package:get/get.dart';

class Localization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    """;

  for (var localization in localizations) {
    String language = localization.language;
    localizationFile += "'$language': {\n";
    for (var phrase in localization.phrases) {
      String phraseKey =
          phrase.key.replaceAll(r"'", "\\'").replaceAll('\n', '\\n');
      String phrasePhrase =
          phrase.phrase.replaceAll(r"'", "\\'").replaceAll('\n', '\\n');
      String currentPhraseTextCode = "'$phraseKey': '$phrasePhrase',\n";
      localizationFile += currentPhraseTextCode;
    }
    localizationFile += '},\n';
  }
  localizationFile += '''
  };
}
''';

  stdout.writeln('');
  stdout.writeln('---------------------------------------');
  stdout.writeln('Saving localization.g.dart');
  stdout.writeln('---------------------------------------');
  final file = File('localization.g.dart');
  await file.writeAsString(localizationFile);
  stdout.writeln('Done...');
}

String _uniformizeKey(String key) {
  key = key.trim().replaceAll('\n', '').toLowerCase();
  return key;
}

//Localization Model
class LocalizationModel {
  final String language;
  final List<PhraseModel> phrases;

  LocalizationModel({
    required this.language,
    required this.phrases,
  });

  factory LocalizationModel.fromMap(Map data) {
    return LocalizationModel(
      language: data['language'],
      phrases:
          (data['phrases'] as List).map((v) => PhraseModel.fromMap(v)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'phrases': List<dynamic>.from(phrases.map((x) => x.toJson())),
      };
}

class PhraseModel {
  String key;
  String phrase;

  PhraseModel({required this.key, required this.phrase});

  factory PhraseModel.fromMap(Map data) {
    return PhraseModel(
      key: data['key'],
      phrase: data['phrase'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'phrase': phrase,
      };
}
