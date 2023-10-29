// frame_view.dart, the main view's frame and controls.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import '../main.dart' show prefs, saveWindowGeo;
import '../model/unit_controller.dart';
import 'bases_view.dart';
import 'fractions_view.dart';
import 'help_view.dart';
import 'settings_edit.dart';
import 'unit_table.dart';
import 'unit_text_editor.dart';
import 'unit_value_editor.dart';

class FrameView extends StatefulWidget {
  FrameView({super.key});

  @override
  State<FrameView> createState() => _FrameViewState();
}

class _FrameViewState extends State<FrameView> with WindowListener {
  // Key is used to avoid focusing open drawer icon.
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      windowManager.addListener(this);
    }
    final model = Provider.of<UnitController>(context, listen: false);
    model.loadData();
    if (prefs.getBool('show_tips') ?? true) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        startupTipDialog(context: context);
      });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  /// Call main function to save window geometry after a resize.
  @override
  void onWindowResize() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await saveWindowGeo();
    }
  }

  /// Call main function to save window geometry after a move.
  @override
  void onWindowMove() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await saveWindowGeo();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Size placeholder for hidden icons, includes 8/side padding.
    final iconSize = (IconTheme.of(context).size ?? 24.0) + 16.0;
    return Consumer<UnitController>(
      builder: (context, model, child) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    'ConvertAll',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 36,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingEdit(),
                      ),
                    );
                  },
                ),
                Divider(),
                ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('Bases'),
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BasesView(),
                        ),
                      );
                    }),
                ListTile(
                    leading: const Icon(Icons.pie_chart),
                    title: const Text('Fractions'),
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FractionsView(),
                        ),
                      );
                    }),
                Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help View'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HelpView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About ConvertAll'),
                  onTap: () async {
                    Navigator.pop(context);
                    final packageInfo = await PackageInfo.fromPlatform();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AboutDialog(
                          applicationName: 'ConvertAll',
                          applicationVersion: 'Version ${packageInfo.version}',
                          applicationLegalese: '©2023 by Douglas W. Bell',
                          applicationIcon: Image.asset(
                            'assets/images/convertall_icon_48.png',
                          ),
                        );
                      },
                    );
                  },
                ),
                if (defaultTargetPlatform == TargetPlatform.linux ||
                    defaultTargetPlatform == TargetPlatform.macOS) ...[
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.highlight_off_outlined),
                    title: const Text('Quit'),
                    onTap: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ],
            ),
          ),
          appBar: AppBar(
            title: const Text('ConvertAll'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            // Manually create button to avoid focus using tab key.
            leading: IconButton(
              icon: Icon(Icons.menu_rounded),
              focusNode: FocusNode(skipTraversal: true),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
            ),
            actions: <Widget>[
              if (!model.isFilteringUnitData) ...[
                Focus(
                  // Avoid tab giving focus to this menu.
                  descendantsAreFocusable: false,
                  canRequestFocus: false,
                  descendantsAreTraversable: false,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.filter_alt),
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
                  icon: Icon(Icons.filter_alt_off),
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
                    icon: Icon(Icons.watch_later),
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
