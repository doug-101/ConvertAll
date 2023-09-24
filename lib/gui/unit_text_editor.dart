// unit_text_editor.dart, provides a text edit widget to units.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/unit_controller.dart';
import '../model/unit_group.dart';

class UnitTextEditor extends StatefulWidget {
  final UnitGroup unitGroup;
  final bool isFrom;

  UnitTextEditor({super.key, required this.unitGroup, required this.isFrom});

  @override
  State<UnitTextEditor> createState() => _UnitTextEditorState();
}

class _UnitTextEditorState extends State<UnitTextEditor> {
  final _editController = TextEditingController();
  late final FocusNode _editorFocusNode;

  /// Setup the edit controller and focus listeners.
  @override
  void initState() {
    super.initState();
    _editController.addListener(() {
      final newText = _editController.text;
      // Update cursor position if text hasn't changed.
      // User text changes are covered by the text field's onChanged callback.
      if (newText == widget.unitGroup.toString()) {
        checkCurrentUnit();
      }
    });
    _editorFocusNode = FocusNode();
    _editorFocusNode.addListener(() {
      if (_editorFocusNode.hasFocus) {
        checkCurrentUnit();
      }
    });
  }

  /// Find unit at cursor after cursor or focus change.
  void checkCurrentUnit() {
    final startPos = _editController.selection.start;
    final endPos = _editController.selection.end;
    var startUnit = widget.unitGroup.unitAtPosition(startPos);
    if (startPos != endPos) {
      final endUnit = widget.unitGroup.unitAtPosition(endPos);
      if (startUnit != endUnit) {
        startUnit = null;
      }
    }
    final model = Provider.of<UnitController>(context, listen: false);
    model.updateCurrentUnit(startUnit, widget.isFrom);
  }

  @override
  void dispose() {
    _editController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 50, maxWidth: 280),
      child: Consumer<UnitController>(
        builder: (context, model, child) {
          final newText = widget.unitGroup.toString();
          if (newText != _editController.text) {
            final lengthDelta = newText.length - _editController.text.length;
            // Maintain cursor position from the end of the text.
            var selectPos = _editController.selection.end + lengthDelta;
            if (selectPos < 0) selectPos = 0;
            _editController.value = _editController.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: selectPos),
              composing: TextRange.empty,
            );
          }
          return TextField(
            controller: _editController,
            focusNode: _editorFocusNode,
            onChanged: (String newText) {
              // Compare with spaces removed to allow backspace to remove
              // extra space.
              if (newText.replaceAll(' ', '') !=
                  widget.unitGroup.toString().replaceAll(' ', '')) {
                final cursorPosFromEnd =
                    newText.length - _editController.selection.end;
                model.updateUnitText(
                  widget.unitGroup,
                  newText,
                  cursorPosFromEnd,
                );
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: widget.isFrom ? 'From Unit' : 'To Unit',
            ),
          );
        },
      ),
    );
  }
}
