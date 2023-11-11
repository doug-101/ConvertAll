// unit_value_editor.dart, provides a number edit widget.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../model/unit_controller.dart';
import 'common_widgets.dart';

class UnitValueEditor extends StatefulWidget {
  final bool isFrom;

  UnitValueEditor({super.key, required this.isFrom});

  @override
  State<UnitValueEditor> createState() => _UnitValueEditorState();
}

class _UnitValueEditorState extends State<UnitValueEditor> {
  final _editController = TextEditingController();
  late final FocusNode _editorFocusNode;

  @override
  void initState() {
    super.initState();
    final model = Provider.of<UnitController>(context, listen: false);
    _editorFocusNode = FocusNode(onKeyEvent: (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          // Catch tab key to do a select all in the next tab field.
          model.tabPressFlag = true;
        }
      }
      return KeyEventResult.ignored;
    });
    _editorFocusNode.addListener(() {
      if (_editorFocusNode.hasFocus) {
        if (model.tabPressFlag) {
          _editController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _editController.text.length,
          );
          model.tabPressFlag = false;
        }
        // Disable active editor and active unit in model when this gets focus.
        model.updateCurrentUnit(null, null);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 50, maxWidth: 280),
        child: Consumer<UnitController>(
          builder: (context, model, child) {
            final thisUnit = widget.isFrom ? model.fromUnit : model.toUnit;
            if (model.canConvert) {
              if (widget.isFrom != model.fromValueEntered) {
                _editController.text = model.convertedValue();
              } else if (_editController.text.isEmpty &&
                  model.enteredValue != null) {
                _editController.text = model.enteredValue.toString();
              }
            }
            return Column(
              children: <Widget>[
                LabelledTextEditor(
                  labelText: widget.isFrom ? 'From Value' : 'To Value',
                  controller: _editController,
                  focusNode: _editorFocusNode,
                  enabled: model.canConvert,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[\d\.eE\+\-\*/\(\) ]'),
                    ),
                  ],
                  onChanged: (String newText) {
                    model.updateEnteredValue(newText, widget.isFrom);
                  },
                ),
                Text(thisUnit.isValid ? thisUnit.toString() : '[no unit set]'),
              ],
            );
          },
        ),
      ),
    );
  }
}
