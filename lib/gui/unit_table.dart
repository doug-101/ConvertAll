// unit_table.dart, provides a data table for unit sselection.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/unit_controller.dart';
import '../model/unit_group.dart';

class UnitTable extends StatefulWidget {
  UnitTable({super.key});

  @override
  State<UnitTable> createState() => _UnitTableState();
}

class _UnitTableState extends State<UnitTable> {
  final _vertScrollCtrl = ScrollController();
  final _horziScrollCtrl = ScrollController();
  var lineHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitController>(
      builder: (context, model, child) {
        final unitList =
            model.currentPartialMatches() ?? UnitController.unitData.unitList;
        return Scrollbar(
          controller: _horziScrollCtrl,
          thumbVisibility: true,
          trackVisibility: true,
          child: Scrollbar(
            controller: _vertScrollCtrl,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horziScrollCtrl,
              child: SizedBox(
                width: 750.0,
                child: CustomScrollView(
                  controller: _vertScrollCtrl,
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: UnitTableHeader(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: unitList.length,
                        (BuildContext context, int index) {
                          final unit = unitList[index];
                          final isSelected =
                              unit == model.currentUnit?.unitMatch;
                          final textStyle = isSelected
                              ? TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : null;
                          return GestureDetector(
                            onTap: () {
                              model.replaceCurrentUnit(unit);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              constraints:
                                  BoxConstraints.tightFor(height: lineHeight),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Theme.of(context).dividerColor),
                                ),
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    width: 280.0,
                                    child: Text(
                                      unit.nameWithUnabbrev,
                                      style: textStyle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150.0,
                                    child: Text(
                                      unit.type,
                                      style: textStyle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 280.0,
                                    child: Text(
                                      unit.comment,
                                      style: textStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UnitTableHeader extends SliverPersistentHeaderDelegate {
  final height = 40.0;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(UnitTableHeader oldDelegate) => false;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final textStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSecondary);
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 280.0,
            height: height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Unit Name', style: textStyle),
            ),
          ),
          SizedBox(
            width: 150.0,
            height: height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Unit Type', style: textStyle),
            ),
          ),
          SizedBox(
            width: 280.0,
            height: height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Comments', style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
