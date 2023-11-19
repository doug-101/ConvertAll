// unit_text_editor.dart, provides a text edit widget for units.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../model/unit_controller.dart';
import '../model/unit_group.dart';
import 'common_widgets.dart';

class UnitTextEditor extends StatefulWidget {
  final UnitGroup unitGroup;
  final bool isFrom;
  final FocusNode? focusNode;

  UnitTextEditor({
    super.key,
    required this.unitGroup,
    required this.isFrom,
    // External focusNode allows parent to explicitly set the focus widget.
    this.focusNode,
  });

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
    final model = Provider.of<UnitController>(context, listen: false);
    _editController.addListener(() {
      final newText = _editController.text;
      // Update cursor position if text hasn't changed.
      // User text changes are covered by the text field's onChanged callback.
      if (newText == widget.unitGroup.toString()) {
        checkCurrentUnit();
      }
    });
    _editorFocusNode = widget.focusNode ?? FocusNode();
    _editorFocusNode.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.tab:
            // Catch tab key to do a select-all in the next tab field.
            model.tabPressFlag = true;
            return KeyEventResult.ignored;
          case LogicalKeyboardKey.arrowDown:
            model.moveHighlightByOne(down: true);
          case LogicalKeyboardKey.arrowUp:
            model.moveHighlightByOne(down: false);
          case LogicalKeyboardKey.pageDown:
            model.moveHighlightByPage(down: true);
          case LogicalKeyboardKey.pageUp:
            model.moveHighlightByPage(down: false);
          case LogicalKeyboardKey.enter:
          case LogicalKeyboardKey.numpadEnter:
            if (model.highlightedTableUnit != null) {
              model.replaceCurrentUnit(model.highlightedTableUnit!);
            }
          default:
            return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    _editorFocusNode.addListener(() {
      if (_editorFocusNode.hasFocus) {
        if (model.tabPressFlag) {
          _editController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _editController.text.length,
          );
          model.tabPressFlag = false;
        }
        checkCurrentUnit();
      }
    });
  }

  @override
  void dispose() {
    _editController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
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
    // Use callback to prevent error from doing this update duraing a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<UnitController>(context, listen: false);
      model.updateCurrentUnit(
        startUnit,
        widget.isFrom ? ActiveEditor.fromEdit : ActiveEditor.toEdit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ConstrainedBox(
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
            // Select all text if a recent unit was loaded at strtup.
            if (_editorFocusNode.hasFocus && model.tabPressFlag) {
              _editController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _editController.text.length,
              );
              model.tabPressFlag = false;
            }
            return LabelledTextEditor(
              labelText: widget.isFrom ? 'From Unit' : 'To Unit',
              controller: _editController,
              focusNode: _editorFocusNode,
              autofocus: widget.isFrom,
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
              onSubmitted: (String newText) {
                if (model.highlightedTableUnit != null) {
                  model.replaceCurrentUnit(model.highlightedTableUnit!);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
