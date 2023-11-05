// bases_view.dart, shows a converter between numbers with different bases.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'common_widgets.dart';

typedef void ValueBaseCallback(String entry, int base);

/// Used to store bit depth and two's complement parameters.
class _BaseParams {
  final int numBits;
  final bool useTwosComplement;

  _BaseParams({this.numBits = 32, this.useTwosComplement = false});

  String toString() {
    return "$numBits bits, ${useTwosComplement ? '' : 'no '}two's complement";
  }
}

/// Provides a view for base conversions.
class BasesView extends StatefulWidget {
  @override
  State<BasesView> createState() => _BasesViewState();
}

class _BasesViewState extends State<BasesView> {
  int? decValue;
  int? enteredBase;
  var baseParams = _BaseParams();
  var errorMsg = '';

  /// Callback to set decimal value and active base.
  void valueBaseChanged(String entry, int base) {
    entry = entry.replaceAll(' ', '');
    setState(() {
      decValue = _baseInt(entry, base, baseParams);
      enteredBase = base;
      errorMsg = '';
      if (decValue == null && entry.isNotEmpty && entry != '-') {
        errorMsg = 'invalid entry';
      }
      if (decValue != null && _baseIsOverflow(decValue!, baseParams)) {
        errorMsg = 'overflow';
        decValue = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base Conversions'),
        leading: IconButton(
          // Manually create button to avoid focus using tab key.
          icon: BackButtonIcon(),
          focusNode: FocusNode(skipTraversal: true),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 400.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextButton(
                  child: Text(baseParams.toString()),
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () async {
                    final params = await _baseParamDialog(
                      context: context,
                      initParams: baseParams,
                    );
                    if (params != null) {
                      setState(() {
                        enteredBase = null;
                        baseParams = params;
                        if (decValue != null &&
                            _baseIsOverflow(decValue!, baseParams)) {
                          decValue = null;
                        }
                      });
                    }
                  },
                ),
                BaseEditor(
                  base: 10,
                  label: 'Decimal',
                  regExpStr: r'[\d\-]',
                  isValueFixed: enteredBase == 10,
                  value: decValue,
                  baseParams: baseParams,
                  errorMsg: errorMsg,
                  callback: valueBaseChanged,
                ),
                BaseEditor(
                  base: 16,
                  label: 'Hex',
                  regExpStr: r'[\dA-Fa-f\-]',
                  isValueFixed: enteredBase == 16,
                  value: decValue,
                  baseParams: baseParams,
                  errorMsg: errorMsg,
                  callback: valueBaseChanged,
                ),
                BaseEditor(
                  base: 8,
                  label: 'Octal',
                  regExpStr: r'[0-7\-]',
                  isValueFixed: enteredBase == 8,
                  value: decValue,
                  baseParams: baseParams,
                  errorMsg: errorMsg,
                  callback: valueBaseChanged,
                ),
                BaseEditor(
                  base: 2,
                  label: 'Binary',
                  regExpStr: r'[01\-]',
                  isValueFixed: enteredBase == 2,
                  value: decValue,
                  baseParams: baseParams,
                  errorMsg: errorMsg,
                  callback: valueBaseChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Class for the entry editor for each base.
class BaseEditor extends StatefulWidget {
  final int base;
  final String label;
  final String regExpStr;
  final bool isValueFixed;
  final int? value;
  final _BaseParams baseParams;
  final String errorMsg;
  final ValueBaseCallback callback;

  BaseEditor({
    super.key,
    required this.base,
    required this.label,
    required this.regExpStr,
    required this.isValueFixed,
    required this.value,
    required this.baseParams,
    required this.errorMsg,
    required this.callback,
  });

  @override
  State<BaseEditor> createState() => _BaseEditorState();
}

class _BaseEditorState extends State<BaseEditor> {
  final _editController = TextEditingController();
  late final FocusNode _editorFocusNode;
  static bool tabPressFlag = false;

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          // Catch tab key to do a select all in the next tab field.
          _BaseEditorState.tabPressFlag = true;
        }
      }
      return KeyEventResult.ignored;
    });
    _editorFocusNode.addListener(() {
      if (_editorFocusNode.hasFocus) {
        if (_BaseEditorState.tabPressFlag) {
          _editController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _editController.text.length,
          );
          _BaseEditorState.tabPressFlag = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isValueFixed) {
      if (widget.value != null) {
        _editController.text =
            _baseStr(widget.value!, widget.base, widget.baseParams);
      } else {
        _editController.text = '';
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LabelledTextEditor(
        labelText: widget.label,
        errorText: widget.isValueFixed && widget.errorMsg.isNotEmpty
            ? widget.errorMsg
            : null,
        // helperText avoids movement when errorText is shown.
        helperText: ' ',
        controller: _editController,
        focusNode: _editorFocusNode,
        autofocus: true,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(widget.regExpStr),
          ),
        ],
        onChanged: (String newText) {
          widget.callback(newText, widget.base);
        },
      ),
    );
  }
}

/// Convert a string in the given base/radix to an integer.
///
/// Return null on invalid entry, but does not check for overflow.
int? _baseInt(String baseStr, int base, _BaseParams baseParams) {
  final numBits = baseParams.numBits;
  var result = int.tryParse(baseStr, radix: base);
  if (baseParams.useTwosComplement &&
      base != 10 &&
      result != null &&
      result > math.pow(2, numBits - 1) &&
      result < math.pow(2, numBits)) {
    result = result - math.pow(2, numBits).round();
  }
  return result;
}

/// Return true if the given value will overflow.
bool _baseIsOverflow(int value, _BaseParams baseParams) {
  final numBits = baseParams.numBits;
  if (baseParams.useTwosComplement) {
    return value >= math.pow(2, numBits - 1) ||
        value < math.pow(-2, numBits - 1);
  } else {
    return value.abs() >= math.pow(2, numBits);
  }
}

/// Return a string representing the value in the given base.
///
/// Does not check for overflow.
String _baseStr(int value, int base, _BaseParams baseParams) {
  if (value == 0) return '0';
  final numBits = baseParams.numBits;
  final allDigits = '0123456789abcdef'.split('');
  final resultDigits = <String>[];
  var sign = '';
  if (value < 0) {
    if (baseParams.useTwosComplement && base != 10) {
      value += math.pow(2, numBits).round();
    } else {
      value = value.abs();
      sign = '-';
    }
  }
  while (value > 0) {
    resultDigits.insert(0, allDigits[value % base]);
    value = value ~/ base;
  }
  return '$sign${resultDigits.join('')}';
}

Future<_BaseParams?> _baseParamDialog({
  required BuildContext context,
  required _BaseParams initParams,
}) async {
  var currentBits = initParams.numBits;
  var currentTwosComplement = initParams.useTwosComplement;
  return showDialog<_BaseParams>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Base Conversion\nParameters',
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: SpinBox(
                    min: 1.0,
                    max: 256.0,
                    pageStep: 16.0,
                    value: initParams.numBits.toDouble(),
                    onChanged: (double value) {
                      currentBits = value.round();
                    },
                    decoration: InputDecoration(
                      labelText: 'Number of bits',
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      currentTwosComplement = !currentTwosComplement;
                    });
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Use two\'s complement'),
                      ),
                      Switch(
                        value: currentTwosComplement,
                        onChanged: (bool value) {
                          setState(() {
                            currentTwosComplement = !currentTwosComplement;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(
                context,
                _BaseParams(
                  numBits: currentBits,
                  useTwosComplement: currentTwosComplement,
                ),
              );
            },
          ),
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context, null),
          ),
        ],
      );
    },
  );
}
