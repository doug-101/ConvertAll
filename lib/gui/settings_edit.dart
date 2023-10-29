// settings_edit.dart, a view to edit the app's preferences.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart' show prefs, allowSaveWindowGeo, saveWindowGeo;
import '../model/unit_controller.dart';

/// A user settings view.
class SettingEdit extends StatefulWidget {
  SettingEdit({super.key});

  @override
  State<SettingEdit> createState() => _SettingEditState();
}

class _SettingEditState extends State<SettingEdit> {
  /// A flag showing that the view was forced to close.
  var _cancelFlag = false;

  final _formKey = GlobalKey<FormState>();

  Future<bool> updateOnPop() async {
    if (_cancelFlag) return true;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final model = Provider.of<UnitController>(context, listen: false);
      model.notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings - ConvertAll'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _cancelFlag = true;
              Navigator.pop(context, null);
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onWillPop: updateOnPop,
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
                    onChanged: (int? value) => null,
                    onSaved: (int? value) async {
                      if (value != null) {
                        await prefs.setInt('result_notation', value);
                      }
                    },
                  ),
                  TextFormField(
                    initialValue:
                        (prefs.getInt('num_dec_plcs') ?? 8).toString(),
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
                    initialValue:
                        (prefs.getInt('recent_unit_count') ?? 12).toString(),
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
                        final model =
                            Provider.of<UnitController>(context, listen: false);
                        if (model.recentUnits.length > intValue) {
                          model.recentUnits
                              .removeRange(intValue, model.recentUnits.length);
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
                    initialValue:
                        (prefs.getDouble('view_scale') ?? 1.0).toString(),
                    decoration: const InputDecoration(
                      labelText: 'App view scale ratio',
                    ),
                    validator: (String? value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Must be an number';
                        }
                        final scale = double.parse(value);
                        if (scale > 5.0 || scale < 0.2) {
                          return 'Valid range is 0.2 to 5.0';
                        }
                      }
                      return null;
                    },
                    onSaved: (String? value) async {
                      if (value != null && value.isNotEmpty) {
                        await prefs.setDouble(
                            'view_scale', double.parse(value));
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
  BoolFormField({
    bool? initialValue,
    String? heading,
    Key? key,
    FormFieldSetter<bool>? onSaved,
  }) : super(
          onSaved: onSaved,
          initialValue: initialValue,
          key: key,
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
                      Expanded(
                        child: Text(heading ?? 'Boolean Value'),
                      ),
                      Switch(
                        value: state.value!,
                        onChanged: (bool value) {
                          state.didChange(!state.value!);
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 3.0,
                  height: 6.0,
                ),
              ],
            );
          },
        );
}
