// help_view.dart, shows a Markdown output of the README file.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

const pathPrefix = 'assets/help/';

/// Provides a view with Markdown output of the README file.
class HelpView extends StatefulWidget {
  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  static final _pageHistory = <String>['contents.md'];
  static final _pageList = <String>[];
  String _currentContent = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() async {
    _currentContent =
        await rootBundle.loadString(pathPrefix + _pageHistory.last);
    // Initialize _pageList once with link addresses from contents page.
    if (_pageList.isEmpty) {
      for (var match in RegExp(r'\[.+\]\((.+)\)').allMatches(_currentContent)) {
        _pageList.add(match.group(1)!);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pagePos = _pageList.indexOf(_pageHistory.last);
    // Size placeholder for hidden icons, includes 8/side padding.
    final iconSize = (IconTheme.of(context).size ?? 24.0) + 16.0;
    return WillPopScope(
      onWillPop: () async {
        if (_pageHistory.length > 1) {
          _pageHistory.removeLast();
          _loadContent();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Help - ConvertAll'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          actions: <Widget>[
            if (pagePos > 0)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                tooltip: 'Previous',
                onPressed: () {
                  _pageHistory.add(_pageList[pagePos - 1]);
                  _loadContent();
                },
              ),
            if (pagePos >= 0 && pagePos < _pageList.length - 1) ...[
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                tooltip: 'Next',
                onPressed: () {
                  _pageHistory.add(_pageList[pagePos + 1]);
                  _loadContent();
                },
              ),
            ] else ...[
              SizedBox(
                width: iconSize,
                height: 1.0,
              ),
            ],
            if (_pageHistory.last != _pageHistory.first) ...[
              IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Home',
                onPressed: () {
                  _pageHistory.add(_pageHistory.first);
                  _loadContent();
                },
              ),
            ] else ...[
              SizedBox(
                width: iconSize,
                height: 1.0,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SelectionArea(
          child: Markdown(
            data: _currentContent,
            onTapLink: (String text, String? href, String title) async {
              if (href != null) {
                if (href.contains(':')) {
                  launchUrl(
                    Uri.parse(href),
                    mode: LaunchMode.externalApplication,
                  );
                } else if (href.endsWith('.md')) {
                  _pageHistory.add(href);
                  _loadContent();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
