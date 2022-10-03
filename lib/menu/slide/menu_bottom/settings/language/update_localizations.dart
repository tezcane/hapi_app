import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

/// commandline dart app that generates the localization.g.dart file.
void main() async {
  //the document id for your google sheet
  const String documentId = '17UktLwAEDS01i_XYqIULRvj6UMDsA6mY0mOcXTYTXYA';
  //the sheetId of your google sheet
  const String sheetId = '0';

  const String url =
      'https://docs.google.com/spreadsheets/d/$documentId/export?format=csv&id=$documentId&gid=$sheetId';

  stdout.writeln('');
  stdout.writeln('---------------------------------------');
  stdout.writeln('Downloading Google sheet url "$url" ...');
  stdout.writeln('---------------------------------------');

  String phraseKey = '';
  List<Locale> localizations = [];

  try {
    var response = await http.get(
      Uri.parse(url),
      headers: {'accept': 'text/csv;charset=UTF-8'},
    );
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
            if (element.lang == key) {
              element.phrases.add(Phrase(phraseKey, value));
              languageAdded = true;
            }
          }
          if (languageAdded == false) {
            localizations.add(
              Locale(
                lang: key,
                phrases: [Phrase(phraseKey, value)],
              ),
            );
          }
        }
      });
    }

    // updateLocalizationFile(localizations); // obsolete, uses too much memory

    await _updateMainTranslationFiles(localizations, ['t.', 'r.']);
    await _updateArabicOnlyFile(localizations);
    await _updateBigTranslationFiles(localizations, 't.', 't/');
    await _updateBigTranslationFiles(localizations, 'r.', 'r/');
  } catch (e) {
    //output error
    stderr.writeln('error: networking error');
    stderr.writeln(e.toString());
  }
}

/// Creates multiple json files with all translations per language. It saves all
/// translations except those specified in the keysToFilterOut list. Those need
/// to be written out using _updateBigTranslationFiles().  Note, it does write
/// the "a.<key>" files because these are the local language translations needed
/// to show the arabic words in the user's native language (if non-arabic). The
/// keys for "a." keys is the Arabic transliteration as well, so this is used as
/// a stepping stone to learn arabic script and the Arabic word.
Future _updateMainTranslationFiles(
  List<Locale> localizations,
  List<String> keysToFilterOut,
) async {
  int count = 0;
  for (var localization in localizations) {
    count++;
    String text = '{';
    for (var phrase in localization.phrases) {
      if (phrase.key.startsWith('dummy.')) continue;

      bool keyToFilterOutFound = false;
      for (String keyToFilterOut in keysToFilterOut) {
        if (phrase.key.startsWith(keyToFilterOut)) keyToFilterOutFound = true;
      }
      if (keyToFilterOutFound) continue;

      String key = phrase.key
          .replaceAll(r'"', '\\"') // escape quotes for json syntax
          .replaceAll('\n', '\\n'); // escape new lines for json syntax

      String value = phrase.value
          .replaceAll(r'"', '\\"') // escape quotes for json syntax
          .replaceAll('\n', '\\n'); // escape new lines for json syntax
      String currentPhraseTextCode = '\n"$key": "$value",';
      text += currentPhraseTextCode;
    }
    text = text.substring(0, text.length - 1); // Remove last comma
    text += '\n}\n';

    String filename = '../../../../../../assets/i18n/${localization.lang}.json';
    stdout.writeln('Saving $filename');
    final file = File(filename);
    await file.writeAsString(text);
  }
  stdout.writeln('Done writing $count json files');
}

/// Creates a single a.json file with all arabic translations in it. These are
/// the key to teaching the user Arabic.  They are always loaded in memory.
Future _updateArabicOnlyFile(List<Locale> localizations) async {
  int count = 0;
  for (var localization in localizations) {
    if (localization.lang != 'ar') continue;

    count++;
    String text = '{';
    for (var phrase in localization.phrases) {
      if (!phrase.key.startsWith('a.')) continue;
//    if (phrase.key.startsWith('dummy.')) continue;

      String key = phrase.key
          .replaceFirst('a.', '') // remove key tag from out file
          .replaceAll(r'"', '\\"') // escape quotes for json syntax
          .replaceAll('\n', '\\n'); // escape new lines for json syntax

      String value = phrase.value
          .replaceAll(r'"', '\\"') // escape quotes for json syntax
          .replaceAll('\n', '\\n'); // escape new lines for json syntax
      String currentPhraseTextCode = '\n"$key": "$value",';
      text += currentPhraseTextCode;
    }
    text = text.substring(0, text.length - 1); // Remove last comma
    text += '\n}\n';

    String filename = '../../../../../../assets/i18n/a/a.json';
    stdout.writeln('Saving $filename');
    final file = File(filename);
    await file.writeAsString(text);
  }
  stdout.writeln('Done writing $count json files');
}

/// Filters "t.<key>" / "r.<key>" tarikh, relic, etc. big text descriptions into
/// their own folder path.  These are to save memory and not always have this
/// data loaded.
Future _updateBigTranslationFiles(
  List<Locale> localizations,
  String keyToFilterFor,
  String outFolder,
) async {
  int count = 0;
  for (var localization in localizations) {
    count++;
    String text = '{';
    for (var phrase in localization.phrases) {
      if (!phrase.key.startsWith(keyToFilterFor)) continue;
//    if (phrase.key.startsWith('dummy.')) continue;

      String key = phrase.key
          .replaceFirst(keyToFilterFor, '') // remove key tag from out file
          .replaceAll(r'"', '\\"') // escape quotes for json syntax
          .replaceAll('\n', '\\n'); // escape new lines for json syntax

      String value = phrase.value
          .replaceAll(r'"', '\\"') // escape quotes for json syntax
          .replaceAll('\n', '\\n'); // escape new lines for json syntax
      String currentPhraseTextCode = '\n"$key": "$value",';
      text += currentPhraseTextCode;
    }
    text = text.substring(0, text.length - 1); // Remove last comma
    text += '\n}\n';

    String filename =
        '../../../../../../assets/i18n/$outFolder${localization.lang}.json';
    stdout.writeln('Saving $filename');
    final file = File(filename);
    await file.writeAsString(text);
  }
  stdout.writeln('Done writing $count json files');
}

String _uniformizeKey(String key) {
  key = key.trim().replaceAll('\n', '').toLowerCase();
  return key;
}

//Localization Model
class Locale {
  Locale({
    required this.lang,
    required this.phrases,
  });
  final String lang;
  final List<Phrase> phrases;

  factory Locale.fromMap(Map data) => Locale(
        lang: data['lang'],
        phrases:
            (data['phrases'] as List).map((v) => Phrase.fromMap(v)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'phrases': List<dynamic>.from(phrases.map((x) => x.toJson())),
      };
}

class Phrase {
  Phrase(this.key, this.value);
  final String key;
  final String value;

  factory Phrase.fromMap(Map data) => Phrase(data['key'], data['phrase']);

  Map<String, dynamic> toJson() => {'key': key, 'phrase': value};
}
