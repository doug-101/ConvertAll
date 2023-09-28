// unit_value_editor.dart, provides a number edit widget.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../model/unit_controller.dart';

class UnitValueEditor extends StatefulWidget {
  final bool isFrom;

  UnitValueEditor({super.key, required this.isFrom});

  @override
  State<UnitValueEditor> createState() => _UnitValueEditorState();
}

class _UnitValueEditorState extends State<UnitValueEditor> {
  final _editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
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
              TextField(
                controller: _editController,
                enabled: model.canConvert,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[\d\.eE\+\-\*/\(\) ]'),
                  ),
                ],
                onChanged: (String newText) {
                  model.updateEnteredValue(newText, widget.isFrom);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: widget.isFrom ? 'From Value' : 'To Value',
                ),
              ),
              Text(thisUnit.isValid ? thisUnit.toString() : '[no unit set]'),
            ],
          );
        },
      ),
    );
  }
}
