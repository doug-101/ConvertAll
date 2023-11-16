// common_widgets.dart, provides various customized widgets.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides a text editor with an upper-left label in a contrasting color.
class LabelledTextEditor extends StatelessWidget {
  final String labelText;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final autofocus;
  bool enabled;
  List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  LabelledTextEditor({
    super.key,
    required this.labelText,
    this.errorText,
    this.helperText,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            enabled: enabled,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            // Avoid losing focus when clicking on unit table or elsewhere.
            onTapOutside: (event) {},
            decoration: InputDecoration(
              errorText: errorText,
              helperText: helperText,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: enabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceVariant,
            ),
            style: TextStyle(
              color: enabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Positioned(
          left: 15,
          child: Container(
            height: 20,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: enabled
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.tertiaryContainer,
            ),
            child: Center(
              child: Text(
                labelText,
                style: TextStyle(
                  fontSize: 12,
                  color: enabled
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
