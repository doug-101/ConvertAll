// settings_edit.dart, a view to edit the app's preferences.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2025, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../main.dart'
    show prefs, minWidth, minHeight, allowSaveWindowGeo, saveWindowGeo;
import '../model/theme_model.dart';
import '../model/unit_controller.dart';

/// A user settings view.
class SettingEdit extends StatefulWidget {
  const SettingEdit({super.key});

  @override
  State<SettingEdit> createState() => _SettingEditState();
}

class _SettingEditState extends State<SettingEdit> {
  /// A flag showing that the view was forced to close.
  var _cancelFlag = false;

  final _formKey = GlobalKey<FormState>();
  final origViewScale = prefs.getDouble('view_scale') ?? 1.0;

  /// Prepare to close by validating and updating.
  ///
  /// Returns true if it's ok to close.
  Future<bool> _handleClose() async {
    if (_cancelFlag) return true;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final viewScale = prefs.getDouble('view_scale') ?? 1.0;
      if (viewScale != origViewScale &&
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        final currentSize = await windowManager.getSize();
        var currentWidth = currentSize.width;
        var currentHeight = currentSize.height;
        if (currentWidth < minWidth * viewScale) {
          currentWidth = minWidth * viewScale;
        }
        if (currentHeight < minHeight * viewScale) {
          currentHeight = minHeight * viewScale;
        }
        if (currentWidth != currentSize.width ||
            currentHeight != currentSize.height) {
          await windowManager.setSize(Size(currentWidth, currentHeight));
        }
        await windowManager.setMinimumSize(
          Size(minWidth * viewScale, minHeight * viewScale),
        );
      }
      if (!mounted) return true;
      final model = Provider.of<UnitController>(context, listen: false);
      model.generalUpdate();
      final themeModel = Provider.of<ThemeModel>(context, listen: false);
      themeModel.updateTheme();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings - ConvertAll'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close without saving',
            onPressed: () {
              _cancelFlag = true;
              Navigator.pop(context, null);
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          if (await _handleClose() && context.mounted) {
            // Pop manually (bypass canPop) if update is complete.
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 400.0,
              child: ListView(
                children: <Widget>[
                  DropdownButtonFormField<int>(
                    items: [
                      for (var item in NumRepr.values)
                        DropdownMenuItem<int>(
                          value: item.index,
                          child: Text(
                            '${item.name.substring(0, 1).toUpperCase()}'
                            '${item.name.substring(1)}',
                          ),
                        ),
                    ],
                    value: prefs.getInt('result_notation') ?? 0,
                    decoration: const InputDecoration(
                      labelText: 'Result Notation Type',
                    ),
                    onChanged: (int? value) {},
                    onSaved: (int? value) async {
                      if (value != null) {
                        await prefs.setInt('result_notation', value);
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: (prefs.getInt('num_dec_plcs') ?? 8)
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Number of Decimal Places',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        var places = int.tryParse(value);
                        if (places == null) {
                          return 'Must be an integer';
                        }
                        if (places < 0 || places > 9) {
                          return 'Must be between 0 and 9';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        await prefs.setInt('num_dec_plcs', int.parse(value));
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: (prefs.getInt('recent_unit_count') ?? 12)
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Number of saved recent units',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        var count = int.tryParse(value);
                        if (count == null) {
                          return 'Must be an integer';
                        }
                        if (count < 0) {
                          return 'Must be greater than or equal to zero';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        var intValue = int.parse(value);
                        await prefs.setInt('recent_unit_count', intValue);
                        if (!context.mounted) return;
                        final model = Provider.of<UnitController>(
                          context,
                          listen: false,
                        );
                        if (model.recentUnits.length > intValue) {
                          model.recentUnits.removeRange(
                            intValue,
                            model.recentUnits.length,
                          );
                        }
                      }
                    },
                  ),
                  BoolFormField(
                    initialValue: prefs.getBool('load_recent') ?? false,
                    heading: 'Load most recent units at startup',
                    onSaved: (bool? value) async {
                      if (value != null) {
                        await prefs.setBool('load_recent', value);
                      }
                    },
                  ),
                  BoolFormField(
                    initialValue: prefs.getBool('show_tips') ?? true,
                    heading: 'Show tips at startup',
                    onSaved: (bool? value) async {
                      if (value != null) {
                        await prefs.setBool('show_tips', value);
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: (prefs.getDouble('view_scale') ?? 1.0)
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'App view scale ratio',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        final scale = double.tryParse(value);
                        if (scale == null) {
                          return 'Must be an number';
                        }
                        if (scale > 4.0 || scale < 0.25) {
                          return 'Valid range is 0.25 to 4.0';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        await prefs.setDouble(
                          'view_scale',
                          double.parse(value),
                        );
                      }
                    },
                  ),
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.macOS))
                    BoolFormField(
                      initialValue: prefs.getBool('save_window_geo') ?? true,
                      heading: 'Remember Window Position and Size',
                      onSaved: (bool? value) async {
                        if (value != null) {
                          await prefs.setBool('save_window_geo', value);
                          allowSaveWindowGeo = value;
                          if (allowSaveWindowGeo) saveWindowGeo();
                        }
                      },
                    ),
                  if (!kIsWeb &&
                      (defaultTargetPlatform == TargetPlatform.linux ||
                          defaultTargetPlatform == TargetPlatform.windows ||
                          defaultTargetPlatform == TargetPlatform.macOS))
                    BoolFormField(
                      initialValue: prefs.getBool('show_title_bar') ?? true,
                      heading: 'Show the Window Title Bar',
                      onSaved: (bool? value) async {
                        if (value != null) {
                          await prefs.setBool('show_title_bar', value);
                          await windowManager.setTitleBarStyle(
                            value ? TitleBarStyle.normal : TitleBarStyle.hidden,
                          );
                        }
                      },
                    ),
                  BoolFormField(
                    initialValue: prefs.getBool('dark_theme') ?? false,
                    heading: 'Use dark color theme',
                    onSaved: (bool? value) async {
                      if (value != null) {
                        await prefs.setBool('dark_theme', value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [FormField] widget for boolean settings.
class BoolFormField extends FormField<bool> {
  BoolFormField({String? heading, super.initialValue, super.key, super.onSaved})
    : super(
        builder: (FormFieldState<bool> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InkWell(
                onTap: () {
                  state.didChange(!state.value!);
                },
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(heading ?? 'Boolean Value')),
                    Switch(
                      value: state.value!,
                      onChanged: (bool value) {
                        state.didChange(!state.value!);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 3.0, height: 6.0),
            ],
          );
        },
      );
}
