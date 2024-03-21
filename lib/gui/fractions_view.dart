// fractions_view.dart, shows a converter for fractional numbers.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2024, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:async/async.dart';
import 'package:eval_ex/expression.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_widgets.dart';

const fullWidth = 460.0;
const columnWidth = 220.0;
const headerHeight = 40.0;
const lineHeight = 30.0;

/// Provides a view to do fraction conversions.
class FractionsView extends StatefulWidget {
  const FractionsView({super.key});

  @override
  State<FractionsView> createState() => _FractionsViewState();
}

class _FractionsViewState extends State<FractionsView> {
  var usePowerOfTwo = false;
  final results = <Fraction>[];
  double? decimalValue;
  String? errorText;
  CancelableOperation? _calcOper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraction Conversions'),
        leading: IconButton(
          // Manually create button to avoid focus using tab key.
          icon: const BackButtonIcon(),
          focusNode: FocusNode(skipTraversal: true),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: fullWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextButton(
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    usePowerOfTwo = !usePowerOfTwo;
                    asyncResults();
                  },
                  child: Text(
                    usePowerOfTwo
                        ? 'Limiting denominators to powers of two'
                        : 'Not limiing denominators to powers of two',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: LabelledTextEditor(
                    labelText: 'Expression',
                    errorText: errorText,
                    // helperText avoids movement when errorText is shown.
                    helperText: ' ',
                    autofocus: true,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\d\.eE\+\-\*/\(\) ]'),
                      ),
                    ],
                    onChanged: (String newText) {
                      if (_calcOper != null) {
                        _calcOper!.cancel();
                      }
                      decimalValue = null;
                      errorText = null;
                      if (newText.isNotEmpty) {
                        try {
                          final decimal = Expression(newText).eval();
                          decimalValue = decimal?.toDouble();
                        } on ExpressionException {
                          // Ignore errors, since will check for null value.
                        } on FormatException {
                          // Ignore errors, since will check for null value.
                        }
                        if (decimalValue == null) {
                          errorText = 'Invalid value';
                        }
                      }
                      asyncResults();
                    },
                  ),
                ),
                Expanded(
                  child: FractionTable(results: results),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate fractions and update as an async cancellable operation.
  void asyncResults() {
    results.clear();
    setState(() {});
    if (decimalValue != null) {
      // Start post-frame to allow editor to update first.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _calcOper = CancelableOperation.fromFuture(
          fractionResults(
            decimalValue!,
            powerOfTwo: usePowerOfTwo,
          ),
        ).then((calcResults) {
          results.addAll(calcResults);
          setState(() {});
        });
      });
    }
  }
}

/// Provides a GUI scrolling table to display the fraction results.
class FractionTable extends StatefulWidget {
  final List<Fraction> results;

  const FractionTable({super.key, required this.results});

  @override
  State<FractionTable> createState() => _FractionTableState();
}

class _FractionTableState extends State<FractionTable> {
  final _vertScrollCtrl = ScrollController();
  final _horziScrollCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: headerHeight + lineHeight,
          maxHeight: headerHeight +
              lineHeight *
                  (widget.results.isNotEmpty ? widget.results.length + 0.3 : 1),
        ),
        child: Scrollbar(
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
                width: fullWidth,
                child: CustomScrollView(
                  controller: _vertScrollCtrl,
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      floating: false,
                      delegate: _FractionTableHeader(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: widget.results.length,
                        (BuildContext context, int index) {
                          return Container(
                            alignment: Alignment.center,
                            constraints: const BoxConstraints.tightFor(
                              height: lineHeight,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context).dividerColor),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: columnWidth,
                                  child: Text(
                                    widget.results[index].toString(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: columnWidth,
                                  child: Text(
                                    widget.results[index].toDecimal(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

/// Provides the result table header.
class _FractionTableHeader extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => headerHeight;

  @override
  double get minExtent => headerHeight;

  @override
  bool shouldRebuild(_FractionTableHeader oldDelegate) => false;

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
            width: columnWidth,
            height: headerHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Fraction', style: textStyle),
            ),
          ),
          SizedBox(
            width: columnWidth,
            height: headerHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Decimal', style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}

/// storage for fraction results.
class Fraction {
  final int numerator;
  final int denominator;

  Fraction(this.numerator, this.denominator);

  @override
  String toString() => '$numerator/$denominator';

  String toDecimal() => (numerator / denominator).toString();
}

/// Return fractions that closely match the given decimal.
Future<List<Fraction>> fractionResults(
  double decimal, {
  var powerOfTwo = false,
}) async {
  final results = <Fraction>[];
  if (decimal == 0.0) return results;
  const denomLimit = 1.0E+9;
  const minOffset = 1.0E-15;
  var denom = 2;
  var numer = (decimal * denom).round();
  var delta = (decimal - numer / denom).abs();
  var minDelta = denomLimit;
  while (denom < denomLimit) {
    final nextDenom = powerOfTwo ? denom * 2 : denom + 1;
    final nextNumer = (decimal * nextDenom).round();
    final nextDelta = (decimal - nextNumer / nextDenom).abs();
    if (numer != 0 &&
        (delta == 0.0 ||
            (delta < minDelta - minOffset && delta <= nextDelta))) {
      results.add(Fraction(numer, denom));
      if (delta < 5.0E-16) break;
      minDelta = delta;
    }
    numer = nextNumer;
    denom = nextDenom;
    delta = nextDelta;
  }
  // Handle case when first result is a whole number (2/2, 4/2, etc.).
  if (results.isNotEmpty) {
    numer = results[0].numerator;
    denom = results[0].denominator;
    if (denom == 2 && numer / denom == (numer / denom).round()) {
      results[0] = Fraction((numer / denom).round(), 1);
    }
  }
  return results;
}
