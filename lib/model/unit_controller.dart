// unit_controller.dart, the main unit model file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

// foundation.dart includes [ChangeNotifier].
import 'package:flutter/foundation.dart';
import 'unit_data.dart';
import 'unit_group.dart';

/// The main model that stores unit data and conversion groups.
class UnitController extends ChangeNotifier {
  static final unitData = UnitData();
  final fromUnit = UnitGroup();
  final toUnit = UnitGroup();
  UnitAtom? currentUnit;
  var fromEditorActive = true;

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

  /// Set the current unit under the cursor and update the GUI.
  void updateCurrentUnit(UnitAtom? unit, bool isFrom) {
    if (unit != currentUnit) {
      currentUnit = unit;
      fromEditorActive = isFrom;
      notifyListeners();
    }
  }

  /// Check that units are valid and compatible before doing value calculation.
  void updateUnitCalc() {
    if (fromUnit.isValid && toUnit.isValid) {
      if (fromUnit.isCategoryMatch(toUnit)) {
        updateValueCalc();
        return;
      }
      print('${fromUnit.reducedGroup} is not compatible with '
          '${toUnit.reducedGroup}');
    }
    notifyListeners();
  }

  /// Assume that the units are unchanged and do value calculation.
  void updateValueCalc() {
    print('2 from units = ${fromUnit.convert(2.0, toUnit)} to units');
    notifyListeners();
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
