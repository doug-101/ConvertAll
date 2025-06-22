// unit_group.dart, combines units and exponents.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'dart:convert' show json;
import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:eval_ex/expression.dart';
import 'unit_controller.dart';
import 'unit_data.dart';

/// Parent class for UnitGroup and UnitAtom.
///
/// Allows them both to be part of a Unit Group (subgroups for parenthesis).
abstract class UnitItem {
  bool get isValid;
  bool get isLinear;
  bool get isFirstExpPositive;
}

/// Stores and manages a group of combined units.
class UnitGroup implements UnitItem {
  final unitItems = <UnitItem>[];
  UnitGroup? reducedGroup;
  double factor = 1.0;
  bool parenthClosed = true;

  void parse(String groupString, {clearFirst = true}) {
    if (clearFirst) {
      unitItems.clear();
      reducedGroup = null;
      factor = 1.0;
      parenthClosed = true;
    }
    var startPos = 0;
    var negativeExp = false;
    // Use non-greedy regex for multiple independent parenthesis,
    // greedy for nested parenthesis.
    var regExp = RegExp(r'\([^()]*\)').allMatches(groupString).length > 1
        ? RegExp(r'\(.*?\)|\(.*$|[\*/]')
        : RegExp(r'\(.*\)|\(.*$|[\*/]');
    final matches = List.of(regExp.allMatches(groupString));
    while (matches.isNotEmpty) {
      var match = matches.removeAt(0);
      var matchText = match[0]!;
      if (matchText.startsWith('(')) {
        final subgroup = UnitGroup();
        if (matchText.endsWith(')')) {
          matchText = matchText.substring(1, matchText.length - 1).trim();
        } else {
          matchText = matchText.substring(1).trim();
          subgroup.parenthClosed = false;
        }
        // Don't clear in order to preserve parenthesis flag.
        subgroup.parse(matchText, clearFirst: false);
        unitItems.add(subgroup);
        if (negativeExp) {
          for (var unit in subgroup._flatUnitList()) {
            unit.unitExp = -unit.unitExp;
          }
        }
        if (matches.isNotEmpty) {
          // Consume next operator after the parenthesis.
          match = matches.removeAt(0);
        }
      } else {
        unitItems.add(
          UnitAtom.parse(
            unitString: groupString.substring(startPos, match.start).trim(),
            negativeExp: negativeExp,
          ),
        );
      }
      startPos = match.end;
      negativeExp = matchText == '/';
    }
    if (unitItems.isEmpty || unitItems.last is UnitAtom) {
      unitItems.add(
        UnitAtom.parse(
          unitString: groupString.substring(startPos).trim(),
          negativeExp: negativeExp,
        ),
      );
    }
  }

  /// Remove current unit entries.
  void clearUnit() {
    unitItems.clear();
    reducedGroup = null;
    factor = 1.0;
    parenthClosed = true;
  }

  @override
  bool get isValid {
    return unitItems.isNotEmpty &&
        unitItems.every((unit) => unit.isValid) &&
        parenthClosed;
  }

  @override
  bool get isLinear {
    return isValid && unitItems.every((unit) => unit.isLinear);
  }

  /// True if the unit is valid linear or valid non-linear (no combinations).
  bool get isLinearOrLegal {
    if (isLinear) return true;
    final flatList = _flatUnitList();
    return isValid && flatList.length == 1 && flatList.first.unitExp == 1;
  }

  @override
  bool get isFirstExpPositive {
    final flatList = _flatUnitList();
    return flatList.isEmpty || flatList[0].unitExp >= 0;
  }

  /// Uses swapExp to flip signs if the group is after a division sign.
  @override
  String toString({bool swapExp = false}) {
    final strList = <String>[];
    for (var unit in unitItems) {
      if (strList.isNotEmpty) {
        var isMultiply = unit.isFirstExpPositive;
        if (swapExp) isMultiply = !isMultiply;
        strList.add(isMultiply ? '*' : '/');
      }
      if (unit is UnitAtom) {
        strList.add(unit.toString(absExp: strList.isNotEmpty || swapExp));
      } else if (unit is UnitGroup) {
        var isSwapped = swapExp;
        if (strList.isNotEmpty && !(unit.isFirstExpPositive)) {
          isSwapped = !isSwapped;
        }
        final groupText = unit.toString(swapExp: isSwapped);
        strList.add(unit.parenthClosed ? '($groupText)' : '($groupText');
      }
    }
    return strList.join(' ');
  }

  /// Return the unit closest to the given position in the string.
  UnitAtom? unitAtPosition(int pos) {
    if (unitItems.isEmpty) return null;
    final text = toString();
    final proceedingText = text.substring(
      0,
      pos < text.length ? pos : text.length,
    );
    final unitNum = RegExp(r'[\*/]').allMatches(proceedingText).length;
    final unitList = _flatUnitList();
    return unitList[unitNum < unitList.length ? unitNum : unitList.length - 1];
  }

  /// Swap the oldAtom with the newUnit and reset cached reduced units.
  ///
  /// Return the new [Unitatom] if succesful.
  UnitAtom? replaceUnit(UnitAtom? oldAtom, UnitDatum newUnit) {
    final newAtom = UnitAtom(
      unitMatch: newUnit,
      unitExp: oldAtom?.unitExp ?? 1,
      partialExp: oldAtom?.partialExp,
      isExpValid: oldAtom?.isExpValid ?? true,
    );
    if (oldAtom == null) {
      if (unitItems.isEmpty) {
        unitItems.add(newAtom);
        reducedGroup = null;
        factor = 1.0;
        return newAtom;
      }
    } else {
      final unitNum = unitItems.indexOf(oldAtom);
      if (unitNum >= 0) {
        unitItems[unitNum] = newAtom;
        reducedGroup = null;
        factor = 1.0;
        return newAtom;
      } else {
        for (var unit in unitItems) {
          if (unit is UnitGroup) {
            final subAtom = unit.replaceUnit(oldAtom, newUnit);
            if (subAtom != null) {
              return subAtom;
            }
          }
        }
      }
    }
    return null;
  }

  /// Change the given unit's exponent and reset and cached reduced units.
  void replaceExponent(UnitAtom unitAtom, num newExp, [bool keepSign = true]) {
    if (keepSign) {
      unitAtom.unitExp = unitAtom.unitExp >= 0 ? newExp.abs() : -(newExp.abs());
    } else {
      unitAtom.unitExp = newExp;
    }
    unitAtom.partialExp = null;
    unitAtom.isExpValid = true;
    reducedGroup = null;
    factor = 1.0;
  }

  /// Return a single list of all of the UnitAtoms.
  List<UnitAtom> _flatUnitList() {
    final result = <UnitAtom>[];
    for (var unit in unitItems) {
      if (unit is UnitGroup) {
        result.addAll(unit._flatUnitList());
      } else if (unit is UnitAtom) {
        result.add(unit);
      }
    }
    return result;
  }

  /// Calculate the reduced equivalent unit and the factor for valid units.
  void _reduceGroup() {
    if (!isValid) return;
    final rawReducedList = <UnitAtom>[];
    var count = 0;
    var expandedList = _flatUnitList();
    while (expandedList.isNotEmpty) {
      count += 1;
      if (count > 5000) {
        throw UnitDataException('Circular unit definition');
      }
      final unit = expandedList.removeAt(0);
      if (unit.unitMatch!.equiv.startsWith('!')) {
        rawReducedList.add(unit.duplicate());
      } else {
        final newGroup = UnitGroup();
        newGroup.parse(unit.unitMatch!.equiv);
        final newList = newGroup._flatUnitList();
        for (var newUnit in newList) {
          newUnit.unitExp *= unit.unitExp;
        }
        expandedList.addAll(newList);
        factor *= math.pow(unit.unitMatch!.factor, unit.unitExp);
      }
    }
    rawReducedList.sort(
      (a, b) => a.unitMatch!.name.toLowerCase().compareTo(
        b.unitMatch!.name.toLowerCase(),
      ),
    );
    final reducedList = <UnitAtom>[];
    for (var unit in rawReducedList) {
      if (reducedList.isNotEmpty &&
          unit.unitMatch == reducedList.last.unitMatch) {
        reducedList.last.unitExp += unit.unitExp;
      } else {
        reducedList.add(unit);
      }
    }
    reducedList.removeWhere(
      (unit) =>
          unit.unitMatch!.equiv == '!!' ||
          unit.unitMatch!.name == 'unit' ||
          unit.unitExp == 0,
    );
    reducedGroup = UnitGroup();
    reducedGroup!.unitItems.addAll(reducedList);
  }

  /// Return true if this unit's reduced units match the other.
  bool isCategoryMatch(UnitGroup otherGroup) {
    if (!isLinearOrLegal || !otherGroup.isLinearOrLegal) return false;
    if (reducedGroup == null) _reduceGroup();
    if (otherGroup.reducedGroup == null) otherGroup._reduceGroup();
    if (reducedGroup.toString() == otherGroup.reducedGroup.toString()) {
      return true;
    }
    return false;
  }

  /// Return a converted value.
  ///
  /// Assumes that [isCategoryMatch] was already checked.
  double convert(double value, UnitGroup toGroup) {
    if (isLinear) {
      value *= factor;
    } else {
      value = _nonLinearCalc(value, true) * factor;
    }
    if (toGroup.isLinear) {
      value /= toGroup.factor;
    } else {
      value = toGroup._nonLinearCalc(value / toGroup.factor, false);
    }
    return value;
  }

  /// Do a calculation for a non-linear unit (equation or interpolation).
  double _nonLinearCalc(double value, bool isFrom) {
    final unit = _flatUnitList()[0].unitMatch!;
    double? result;
    if (unit.toEqn.isNotEmpty) {
      // For regular equations.
      try {
        if (isFrom) {
          final expr = Expression(unit.fromEqn);
          expr.setDecimalVariable('x', Decimal.parse(value.toString()));
          result = expr.eval()?.toDouble();
        } else {
          final expr = Expression(unit.toEqn);
          expr.setDecimalVariable('x', Decimal.parse(value.toString()));
          result = expr.eval()?.toDouble();
        }
      } on ExpressionException {
        // Ignore exception, caught be null result.
      }
    } else {
      final List<dynamic> dataList = json.decode(unit.fromEqn);
      if (!isFrom) {
        for (var pair in dataList) {
          final tmp = pair[0];
          pair[0] = pair[1];
          pair[1] = tmp;
        }
      }
      dataList.sort((a, b) => a[0].compareTo(b[0]));
      var pos = dataList.indexWhere((pair) => value <= pair[0]);
      if (pos == 0) pos = 1;
      result =
          (value - dataList[pos - 1][0]) /
              (dataList[pos][0] - dataList[pos - 1][0]) *
              (dataList[pos][1] - dataList[pos - 1][1]) +
          dataList[pos - 1][1];
    }
    if (result == null) {
      throw UnitDataException('Invalid equation for ${unit.name}');
    }
    return result;
  }
}

/// Stores a unit's data with an exponent.
class UnitAtom implements UnitItem {
  String? unitName;
  UnitDatum? unitMatch;
  num unitExp = 1;
  String? partialExp;
  bool isExpValid = true;

  UnitAtom({
    this.unitName,
    this.unitMatch,
    required this.unitExp,
    this.partialExp,
    required this.isExpValid,
  });

  UnitAtom.parse({required String unitString, negativeExp = false}) {
    final parts = unitString.split('^');
    if (parts.length > 1) {
      if (parts.length > 2) {
        parts[1] = parts.sublist(1).join();
      }
      final expText = parts[1].trim();
      try {
        unitExp = int.parse(expText);
        if (unitExp.abs() == 1) {
          // Keep partial exponent for the start of typing '1.5' or '-1.5'.
          partialExp = '^$expText';
        } else if (expText == '-0') {
          // Keep partial exponent for the start of typing '-0.5',
          partialExp = '^-0';
        }
      } on FormatException {
        try {
          unitExp = double.parse(expText);
          if (expText.endsWith('.')) {
            // Keep partial exponent for the start of typing a fractional exp.
            partialExp = '^$expText';
          }
        } on FormatException {
          partialExp = switch (expText) {
            '.' => '^0.',
            '-.' => '^-0.',
            _ when expText.startsWith('-') => '^-',
            _ => '^',
          };
          isExpValid = false;
        }
      }
    }
    final unitText = parts[0].trim();
    final unitData = UnitController.unitData;
    unitMatch = unitData.unitMatch(unitText);
    if (unitMatch == null) {
      if (unitText.endsWith('2') || unitText.endsWith('3')) {
        final tmpMatch = unitData.unitMatch(
          unitText.substring(0, unitText.length - 1),
        );
        if (tmpMatch != null && unitExp == 1 && partialExp == null) {
          unitMatch = tmpMatch;
          unitExp = unitText.endsWith('2') ? 2 : 3;
        }
      } else if ((unitText.endsWith('s') || unitText.endsWith('S')) &&
          unitData.partialMatches(unitText).isEmpty) {
        unitMatch = unitData.unitMatch(
          unitText.substring(0, unitText.length - 1),
        );
      }
    }
    if (negativeExp) {
      unitExp = -unitExp;
      if (isExpValid && partialExp != null) {
        partialExp = partialExp!.replaceFirst('^-', '^');
      }
    }
    if (unitMatch == null) {
      unitName = unitText;
    }
  }

  @override
  bool get isValid => unitMatch != null && isExpValid;

  @override
  bool get isLinear => isValid && unitMatch!.fromEqn.isEmpty;

  @override
  bool get isFirstExpPositive => unitExp >= 0;

  @override
  String toString({bool absExp = false}) {
    final name = unitMatch?.name ?? unitName ?? '';
    if (partialExp != null) {
      return '$name$partialExp';
    }
    final tmpExp = absExp ? unitExp.abs() : unitExp;
    if (tmpExp != 1) {
      return '$name^$tmpExp';
    }
    return name;
  }

  UnitAtom duplicate() {
    return UnitAtom(
      unitName: unitName,
      unitMatch: unitMatch,
      unitExp: unitExp,
      partialExp: partialExp,
      isExpValid: isExpValid,
    );
  }
}
