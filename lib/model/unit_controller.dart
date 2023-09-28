// unit_controller.dart, the main unit model file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

// foundation.dart includes [ChangeNotifier].
import 'package:eval_ex/expression.dart';
import 'package:flutter/foundation.dart';
import 'unit_data.dart';
import 'unit_group.dart';

/// The main model that stores unit data and conversion groups.
class UnitController extends ChangeNotifier {
  static final unitData = UnitData();
  final fromUnit = UnitGroup();
  final toUnit = UnitGroup();
  var canConvert = false;
  UnitAtom? currentUnit;
  var fromEditorActive = true;
  double? enteredValue = 1.0;
  var fromValueEntered = true;
  var statusString = '';

  /// Async method to load data and update the GUI.
  Future<void> loadData() async {
    await unitData.loadData();
    notifyListeners();
  }

  /// Parse new unit text for the given unit and update current unit at cursor.
  void updateUnitText(UnitGroup unit, String newtext, int cursorPosFromEnd) {
    unit.parse(newtext);
    final cursorPos = unit.toString().length - cursorPosFromEnd;
    currentUnit = unit.unitAtPosition(cursorPos);
    updateUnitCalc();
  }

  /// Replace the current unit in the active unit group.
  void replaceCurrentUnit(UnitDatum newUnit) {
    if (newUnit != currentUnit?.unitMatch) {
      final currentGroup = fromEditorActive ? fromUnit : toUnit;
      currentUnit = currentGroup.replaceUnit(currentUnit, newUnit);
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
  void updateCurrentUnit(UnitAtom? unit, bool isFrom) {
    if (unit != currentUnit) {
      currentUnit = unit;
      fromEditorActive = isFrom;
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
  /// Return null if there is no current unit.
  List<UnitDatum>? currentPartialMatches() {
    if (currentUnit == null) return null;
    final searchText = currentUnit!.unitMatch?.name ?? currentUnit!.unitName!;
    return unitData.partialMatches(searchText);
  }
}
