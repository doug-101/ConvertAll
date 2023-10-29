// unit_controller.dart, the main unit model file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

// foundation.dart includes [ChangeNotifier].
import 'dart:math';
import 'package:eval_ex/expression.dart';
import 'package:flutter/foundation.dart';
import '../main.dart' show prefs;
import 'unit_data.dart';
import 'unit_group.dart';

enum ActiveEditor { fromEdit, toEdit }

enum NumRepr { short, fixed, scientific, engineering }

/// The main model that stores unit data and conversion groups.
class UnitController extends ChangeNotifier {
  static final unitData = UnitData();
  final sortParam = UnitSortParam();
  final fromUnit = UnitGroup();
  final toUnit = UnitGroup();
  var canConvert = false;
  final recentUnits = <String>[];
  UnitAtom? currentUnit;
  UnitDatum? highlightedTableUnit;
  ActiveEditor? activeEditor;
  double? enteredValue = 1.0;
  var fromValueEntered = true;
  var statusString = '';
  var tabPressFlag = false;
  var tableRowHeight = 5;

  /// Async method to load data and update the GUI.
  Future<void> loadData() async {
    await unitData.loadData();
    sortParam.unitStableSort(unitData.unitList);
    recentUnits.addAll(prefs.getStringList('recents') ?? <String>[]);
    if ((prefs.getBool('load_recent') ?? false) && recentUnits.length >= 2) {
      fromUnit.parse(recentUnits[0]);
      toUnit.parse(recentUnits[1]);
      // Use tab flag to select first editor with filled-in unit.
      tabPressFlag = true;
      updateUnitCalc();
    } else {
      notifyListeners();
    }
  }

  /// Adjust sorting parameters based on a tap on a header.
  void handleHeaderTap(SortField field) {
    sortParam.chnageSortField(field);
    sortParam.unitStableSort(unitData.unitList);
    highlightedTableUnit = null;
    notifyListeners();
  }

  /// Parse new unit text for the given unit and update current unit at cursor.
  void updateUnitText(UnitGroup unit, String newtext, int cursorPosFromEnd) {
    unit.parse(newtext);
    final cursorPos = unit.toString().length - cursorPosFromEnd;
    currentUnit = unit.unitAtPosition(cursorPos);
    highlightedTableUnit = null;
    updateUnitCalc();
  }

  /// Replace the current unit in the active unit group.
  void replaceCurrentUnit(UnitDatum newUnit) {
    if (newUnit != currentUnit?.unitMatch) {
      final currentGroup =
          activeEditor == ActiveEditor.fromEdit ? fromUnit : toUnit;
      currentUnit = currentGroup.replaceUnit(currentUnit, newUnit);
      highlightedTableUnit = null;
      updateUnitCalc();
    }
  }

  /// Replace the current unit group with the provided text.
  void replaceCurrentGroup(String unitText) {
    final currentGroup =
        activeEditor == ActiveEditor.fromEdit ? fromUnit : toUnit;
    currentGroup.parse(unitText);
    highlightedTableUnit = null;
    updateUnitCalc();
  }

  /// Set [canConvert] based on whether the units are valid and compatible.
  void updateUnitCalc() {
    canConvert = false;
    statusString = '';
    if (fromUnit.isValid && toUnit.isValid) {
      if (fromUnit.isCategoryMatch(toUnit)) {
        canConvert = true;
        statusString = 'Converting...';
        addRecentUnits(toUnit.toString());
        addRecentUnits(fromUnit.toString());
      } else {
        statusString = 'Units are not compatible (${fromUnit.reducedGroup} '
            'vs. ${toUnit.reducedGroup})';
      }
    }
    notifyListeners();
  }

  void addRecentUnits(String unitText) async {
    recentUnits.remove(unitText);
    recentUnits.insert(0, unitText);
    final maxLength = prefs.getInt('recent_unit_count') ?? 10;
    if (recentUnits.length > maxLength) {
      recentUnits.removeRange(maxLength, recentUnits.length);
    }
    prefs.setStringList('recents', recentUnits);
  }

  /// Set the current unit under the cursor and update the GUI.
  void updateCurrentUnit(UnitAtom? unit, ActiveEditor? newActiveEditor) {
    if (unit != currentUnit || newActiveEditor != activeEditor) {
      currentUnit = unit;
      highlightedTableUnit = null;
      activeEditor = newActiveEditor;
      notifyListeners();
    }
  }

  /// Set the value to be converted and update the GUI.
  void updateEnteredValue(String valueStr, bool isFrom) {
    fromValueEntered = isFrom;
    try {
      final decimalValue = Expression(valueStr).eval();
      enteredValue = decimalValue?.toDouble();
    } on ExpressionException {
      enteredValue = null;
    } on FormatException {
      enteredValue = null;
    }
    notifyListeners();
  }

  /// Return the resulting converted value as a String.
  String convertedValue() {
    var result = '';
    if (canConvert && enteredValue != null) {
      double value;
      if (fromValueEntered) {
        value = fromUnit.convert(enteredValue!, toUnit);
      } else {
        value = toUnit.convert(enteredValue!, fromUnit);
      }
      // Round to <16 significant figures to mask floating point errors.
      value = double.parse(value.toStringAsPrecision(15));
      final decPlcs = prefs.getInt('num_dec_plcs') ?? 8;
      switch (NumRepr.values[prefs.getInt('result_notation') ?? 0]) {
        case NumRepr.short:
          if (value.abs() >= 1e+7 || value.abs() <= 1e-7) {
            result = value.toStringAsExponential(decPlcs);
            result = result.replaceFirst(RegExp(r'0+e'), 'e');
          } else {
            result = value.toStringAsFixed(decPlcs);
            result = result.replaceFirst(RegExp(r'0+$'), '');
          }
        case NumRepr.fixed:
          result = value.toStringAsFixed(decPlcs);
        case NumRepr.scientific:
          result = value.toStringAsExponential(decPlcs);
        case NumRepr.engineering:
          var exp = 0;
          // log of zero is undefined.
          if (value != 0.0) {
            exp = (log(value.abs()) / ln10 / 3).floor() * 3;
          }
          value /= pow(10.0, exp);
          // Round the number to see if rounding should bump the exponent.
          value =
              (value * pow(10.0, decPlcs)).roundToDouble() / pow(10.0, decPlcs);
          if (value.abs() >= 1000.0) {
            value /= 1000.0;
            exp += 3;
          }
          result = exp >= 0
              ? '${value.toStringAsFixed(decPlcs)}e+$exp'
              : '${value.toStringAsFixed(decPlcs)}e$exp';
      }
    }
    return result;
  }

  /// Return a list of partial matches for the [currentUnit].
  ///
  /// Return full or filtered unit list if there is no current unit.
  /// Set [highlightedTableUnit] to first one if it is not already set.
  List<UnitDatum> currentPartialMatches() {
    if (currentUnit == null) {
      if (highlightedTableUnit == null &&
          UnitController.unitData.unitList.isNotEmpty) {
        highlightedTableUnit =
            UnitController.unitData.filteredOrFullUnits.first;
      }
      return UnitController.unitData.filteredOrFullUnits;
    }
    final searchText = currentUnit!.unitMatch?.name ?? currentUnit!.unitName!;
    final results = unitData.partialMatches(searchText, canFilter: true);
    if (currentUnit!.unitMatch == null &&
        highlightedTableUnit == null &&
        results.isNotEmpty) {
      highlightedTableUnit = results.first;
    }
    return results;
  }

  /// Move [highlightedTableUnit] up or down by one space in table results.
  void moveHighlightByOne({bool down = true}) {
    final unitList = currentPartialMatches();
    final oldUnit = highlightedTableUnit ?? currentUnit?.unitMatch;
    if (unitList.length > 1 && oldUnit != null) {
      final pos = unitList.indexOf(oldUnit);
      if (down && pos >= 0 && pos < unitList.length - 1) {
        highlightedTableUnit = unitList[pos + 1];
        notifyListeners();
      } else if (!down && pos >= 1) {
        highlightedTableUnit = unitList[pos - 1];
        notifyListeners();
      }
    }
  }

  /// Move [highlightedTableUnit] up or down by one page in table results.
  void moveHighlightByPage({bool down = true}) {
    final unitList = currentPartialMatches();
    final oldUnit = highlightedTableUnit ?? currentUnit?.unitMatch;
    if (unitList.length > 1 && oldUnit != null) {
      var pos = unitList.indexOf(oldUnit);
      if (down && pos >= 0 && pos < unitList.length - 1) {
        highlightedTableUnit =
            unitList[min(pos + tableRowHeight, unitList.length - 1)];
        notifyListeners();
      } else if (!down && pos >= 1) {
        highlightedTableUnit = unitList[max(pos - tableRowHeight, 0)];
        notifyListeners();
      }
    }
  }

  bool get isFilteringUnitData => UnitController.unitData.isFiltering;

  /// start filtering for given type name.
  void filterUnitData(String typeName) {
    UnitController.unitData.filterUnits(typeName);
    notifyListeners();
  }

  /// Stop filering by unit type.
  void endFilterUnitData() {
    UnitController.unitData.endFilter();
    notifyListeners();
  }
}
