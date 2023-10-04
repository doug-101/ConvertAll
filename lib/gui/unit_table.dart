// unit_table.dart, provides a data table for unit sselection.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/unit_controller.dart';
import '../model/unit_data.dart';
import '../model/unit_group.dart';

const headerHeight = 40.0;
const lineHeight = 30.0;

class UnitTable extends StatefulWidget {
  UnitTable({super.key});

  @override
  State<UnitTable> createState() => _UnitTableState();
}

class _UnitTableState extends State<UnitTable> {
  final _vertScrollCtrl = ScrollController();
  final _horziScrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<UnitController>(
      builder: (context, model, child) {
        final unitList = model.currentPartialMatches();
        if (_vertScrollCtrl.hasClients) {
          final viewHeight =
              _vertScrollCtrl.position.viewportDimension - headerHeight;
          model.tableRowHeight = (viewHeight / lineHeight).floor();
          final visibleUnit =
              model.highlightedTableUnit ?? model.currentUnit?.unitMatch;
          if (visibleUnit != null) {
            final pos = unitList.indexOf(visibleUnit) * lineHeight;
            if (pos >= 0 && pos < _vertScrollCtrl.offset) {
              // Need to scroll up.
              _vertScrollCtrl.jumpTo(pos);
            } else if (pos > _vertScrollCtrl.offset + viewHeight) {
              // Need to scroll down.
              _vertScrollCtrl.jumpTo(pos - viewHeight + lineHeight);
            }
          }
        }
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
                          final isActive = unit == model.highlightedTableUnit;
                          final textStyle = isSelected
                              ? TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : isActive
                                  ? TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
  double get maxExtent => headerHeight;

  @override
  double get minExtent => headerHeight;

  @override
  bool shouldRebuild(UnitTableHeader oldDelegate) => false;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final textStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSecondary);
    return Consumer<UnitController>(
      builder: (context, model, child) {
        return Container(
          color: Theme.of(context).colorScheme.secondary,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  model.handleHeaderTap(SortField.byName);
                },
                child: SizedBox(
                  width: 280.0,
                  height: headerHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      model.sortParam.headerTitle(SortField.byName),
                      style: textStyle,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  model.handleHeaderTap(SortField.byType);
                },
                child: SizedBox(
                  width: 150.0,
                  height: headerHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      model.sortParam.headerTitle(SortField.byType),
                      style: textStyle,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  model.handleHeaderTap(SortField.byComment);
                },
                child: SizedBox(
                  width: 280.0,
                  height: headerHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      model.sortParam.headerTitle(SortField.byComment),
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
