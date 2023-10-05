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
import 'unit_value_editor.dart';

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
    // Size placeholder for hidden icons, includes 8/side padding.
    final iconSize = (IconTheme.of(context).size ?? 24.0) + 16.0;
    return Consumer<UnitController>(
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'ConvertAll',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            actions: <Widget>[
              if (!model.isFilteringUnitData) ...[
                Focus(
                  // Avoid tab giving focus to this menu.
                  descendantsAreFocusable: false,
                  canRequestFocus: false,
                  descendantsAreTraversable: false,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.filter_alt,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    tooltip: 'Filter units by type',
                    onSelected: (result) {
                      model.filterUnitData(result);
                    },
                    itemBuilder: (context) => [
                      for (var type in UnitController.unitData.typeList)
                        PopupMenuItem<String>(
                          child: Text(type),
                          value: type,
                        ),
                    ],
                  ),
                ),
              ] else ...[
                IconButton(
                  icon: Icon(
                    Icons.filter_alt_off,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  tooltip: 'Stop filtering',
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    model.endFilterUnitData();
                  },
                ),
              ],
              if (model.recentUnits.isNotEmpty &&
                  model.activeEditor != null) ...[
                Focus(
                  // Avoid tab giving focus to this menu.
                  descendantsAreFocusable: false,
                  canRequestFocus: false,
                  descendantsAreTraversable: false,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.watch_later,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    tooltip: 'Recently used units',
                    onSelected: (result) {
                      model.replaceCurrentGroup(result);
                    },
                    itemBuilder: (context) => [
                      for (var unitText in model.recentUnits)
                        PopupMenuItem<String>(
                          child: Text(unitText),
                          value: unitText,
                        )
                    ],
                  ),
                ),
              ] else ...[
                // Reserve space for hidden recent icon if not present.
                SizedBox(
                  width: iconSize,
                  height: 1.0,
                ),
              ],
            ],
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
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      runSpacing: 20,
                      children: <Widget>[
                        UnitValueEditor(
                          isFrom: true,
                        ),
                        UnitValueEditor(
                          isFrom: false,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(model.statusString),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
