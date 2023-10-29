// main.dart, the main app entry point file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'gui/frame_view.dart';
import 'model/unit_controller.dart';

/// [prefs] is the global shared_preferences instance.
late final SharedPreferences prefs;

/// This is initially false to avoid saving window geometry during setup.
bool allowSaveWindowGeo = false;

Future<void> main() async {
  LicenseRegistry.addLicense(
    () => Stream<LicenseEntry>.value(
      const LicenseEntryWithLineBreaks(
        <String>['ConvertAll'],
        'ConvertAll, Copyright (C) 2023 by Douglas W. Bell\n\n'
        'This program is free software; you can redistribute it and/or modify '
        'it under the terms of the GNU General Public License as published by '
        'the Free Software Foundation; either version 2 of the License, or '
        '(at your option) any later version.\n\n'
        'This program is distributed in the hope that it will be useful, but '
        'WITHOUT ANY WARRANTY; without even the implied warranty of '
        'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU '
        'General Public License for more details.\n\n'
        'You should have received a copy of the GNU General Public License '
        'along with this program; if not, write to the Free Software '
        'Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  '
        '02110-1301, USA.',
      ),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  final stdWidth = 1200.0;
  final stdHeight = 1000.0;
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();
    var size = Size(stdWidth, stdHeight);
    double? offsetX, offsetY;
    if (prefs.getBool('save_window_geo') ?? true) {
      size = Size(
        prefs.getDouble('win_size_x') ?? stdWidth,
        prefs.getDouble('win_size_y') ?? stdHeight,
      );
      offsetX = prefs.getDouble('win_pos_x');
      offsetY = prefs.getDouble('win_pos_y');
    }
    // Setting the size twice (early and later) to work around linux problems.
    await windowManager.setSize(size);
    windowManager.waitUntilReadyToShow(null, () async {
      await windowManager.setTitle('ConvertAll');
      await windowManager.setMinimumSize(Size(270.0, 650.0));
      await windowManager.setSize(size);
      if (offsetX != null && offsetY != null) {
        await windowManager.setPosition(Offset(offsetX, offsetY));
      }
      await windowManager.show();
      allowSaveWindowGeo = prefs.getBool('save_window_geo') ?? true;
    });
  }
  if (kIsWeb) {
    final ratio = prefs.getDouble('calc_scale') ?? 1.0;
    runApp(
      FractionallySizedBox(
        widthFactor: 1 / ratio,
        heightFactor: 1 / ratio,
        child: Transform.scale(
          scale: ratio,
          child: Container(
            color: Color(0xFFa2b7bd),
            child: Center(
              child: SizedBox(
                width: stdWidth,
                height: stdHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: _RootApp(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } else {
    runApp(_RootApp());
  }
}

class _RootApp extends StatelessWidget {
  _RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ratio = prefs.getDouble('view_scale') ?? 1.0;
    return FractionallySizedBox(
      widthFactor: 1 / ratio,
      heightFactor: 1 / ratio,
      child: Transform.scale(
        scale: ratio,
        child: ChangeNotifierProvider<UnitController>(
          create: (context) => UnitController(),
          child: MaterialApp(
            title: 'ConvertAll',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.light,
                seedColor: Colors.red,
              ),
              useMaterial3: true,
            ),
            home: FrameView(),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

Future<void> saveWindowGeo() async {
  if (!allowSaveWindowGeo) return;
  final bounds = await windowManager.getBounds();
  await prefs.setDouble('win_size_x', bounds.size.width);
  await prefs.setDouble('win_size_y', bounds.size.height);
  await prefs.setDouble('win_pos_x', bounds.left);
  await prefs.setDouble('win_pos_y', bounds.top);
}
