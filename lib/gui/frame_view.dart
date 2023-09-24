// frame_view.dart, the main view's frame and controls.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/unit_controller.dart';
import 'unit_table.dart';
import 'unit_text_editor.dart';

class FrameView extends StatefulWidget {
  FrameView({super.key});

  @override
  State<FrameView> createState() => _FrameViewState();
}

class _FrameViewState extends State<FrameView> {
  @override
  void initState() {
    super.initState();
    final model = Provider.of<UnitController>(context, listen: false);
    model.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<UnitController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ConvertAll',
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  runSpacing: 20,
                  children: <Widget>[
                    UnitTextEditor(
                      unitGroup: model.fromUnit,
                      isFrom: true,
                    ),
                    UnitTextEditor(
                      unitGroup: model.toUnit,
                      isFrom: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: UnitTable(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
