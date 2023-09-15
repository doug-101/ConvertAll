// unit_controller.dart, the main unit model file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'unit_data.dart';
import 'unit_group.dart';

/// The main model that stores unit data and conversion groups.
class UnitController {
  final unitData = UnitData();
  final fromUnit = UnitGroup();
  final toUnit = UnitGroup();

  /// Async method to load data and initialize groups.
  Future<void> loadData() async {
    await unitData.loadData();

    fromUnit.parse('ft / (lbm * s)');
    toUnit.parse('ft / (kg * s)');
    print('From unit: $fromUnit, To unit: $toUnit');
    print('Units compatible: ${fromUnit.isCategoryMatch(toUnit)}');
    print('From equiv: ${fromUnit.reducedGroup}, '
        'To equiv: ${toUnit.reducedGroup}');
    print('2 from units = ${fromUnit.convert(2.0, toUnit)} to units');
  }
}
