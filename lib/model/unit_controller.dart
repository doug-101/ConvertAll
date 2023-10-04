// unit_controller.dart, the main unit model file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

// foundation.dart includes [ChangeNotifier].
import 'dart:math';
import 'package:eval_ex/expression.dart';
import 'package:flutter/foundation.dart';
import 'unit_data.dart';
import 'unit_group.dart';

enum ActiveEditor { fromEdit, toEdit }

/// The main model that stores unit data and conversion groups.
class UnitController extends ChangeNotifier {
  static final unitData = UnitData();
  final sortParam = UnitSortParam();
  final fromUnit = UnitGroup();
  final toUnit = UnitGroup();
  var canConvert = false;
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
    notifyListeners();
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

  /// Set [canConvert] based on whether the units are valid and compatible.
  void updateUnitCalc() {
    canConvert = false;
    statusString = '';
    if (fromUnit.isValid && toUnit.isValid) {
      if (fromUnit.isCategoryMatch(toUnit)) {
        canConvert = true;
        statusString = 'Converting...';
      } else {
        statusString = 'Units are not compatible (${fromUnit.reducedGroup} '
            'vs. ${toUnit.reducedGroup})';
      }
    }
    notifyListeners();
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
      if (decimalValue != null) {
        enteredValue = decimalValue.toDouble();
      } else {
        enteredValue = null;
      }
    } on ExpressionException {
      enteredValue = null;
    }
    notifyListeners();
  }

  /// Return the resulting converted value as a String.
  String convertedValue() {
    if (canConvert && enteredValue != null) {
      double value;
      if (fromValueEntered) {
        value = fromUnit.convert(enteredValue!, toUnit);
      } else {
        value = toUnit.convert(enteredValue!, fromUnit);
      }
      // Round to <16 significant figures to mask floating point errors,
      // then go back to a short string representation.
      return double.parse(value.toStringAsPrecision(15)).toString();
    }
    return '';
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
