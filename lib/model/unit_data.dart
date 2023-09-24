// unit_data.dart, reads and stores unit data.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'dart:convert' show json;
import 'package:eval_ex/expression.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Handles the stored database of unit data.
class UnitData {
  // The list allows the list to be sorted based on user criteria.
  final unitList = <UnitDatum>[];

  // The map uses lower-case unit names with no spaces as keys.
  final unitMap = <String, UnitDatum>{};

  Future<void> loadData() async {
    final List<dynamic> dataList =
        json.decode(await rootBundle.loadString('assets/units.json'));
    for (var item in dataList) {
      final unit = UnitDatum(item);
      unitList.add(unit);
      unitMap[unit.name.toLowerCase().replaceAll(' ', '')] = unit;
    }
  }

  /// Return an exact match for the given unit name.
  UnitDatum? unitMatch(String searchTerm) {
    return unitMap[searchTerm.toLowerCase().replaceAll(' ', '')];
  }

  /// Return all units with words staring with the given words.
  List<UnitDatum> partialMatches(String searchTerm) {
    final wordList = searchTerm.toLowerCase().split(' ');
    return List.of(unitList.where((unit) => unit.isPartialMatch(wordList)));
  }
}

/// Stores database info for a particular unit.
class UnitDatum {
  final String name;
  final String type;
  String equiv;
  double factor = 1.0;
  final String fromEqn;
  final String toEqn;
  final String unabbrev;
  final String comment;
  final searchTerms = <String>[];

  UnitDatum(dynamic dataList)
      : name = dataList['name'],
        type = dataList['type'],
        equiv = dataList['equiv'],
        fromEqn = dataList['fromeqn'] ?? '',
        toEqn = dataList['toeqn'] ?? '',
        unabbrev = dataList['unabbrev'] ?? '',
        comment = dataList['comment'] ?? '' {
    if (fromEqn.isEmpty) {
      final parts = equiv.split(' ');
      if (parts.length > 1) {
        try {
          final value = Expression(parts.removeAt(0)).eval();
          if (value != null) {
            factor = value.toDouble();
            equiv = parts.join(' ');
          }
        } on ExpressionException {}
      }
    }
    if (equiv.isEmpty) throw UnitDataException('Invalid equivalent for $name');
    searchTerms.addAll(name.toLowerCase().split(' '));
  }

  String get nameWithUnabbrev => unabbrev.isEmpty ? name : '$name ($unabbrev)';

  /// Return true if this unit's words match words from the wordlist.
  bool isPartialMatch(List<String> wordList) {
    for (var word in wordList) {
      for (var key in searchTerms) {
        if (key.startsWith(word)) return true;
      }
    }
    return false;
  }
}

/// General exception for unit data issues.
class UnitDataException extends FormatException {
  final String? msg;

  UnitDataException([this.msg]);

  @override
  String toString() => msg ?? 'UnitDataException';
}
