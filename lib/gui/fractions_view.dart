// fractions_view.dart, shows a converter for fractional numbers.
// ConvertAll, a versatile unit conversion program.
// Copyright (c) 2023, Douglas W. Bell.
// Free software, GPL v2 or later.

import 'package:eval_ex/expression.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common_widgets.dart';

const fullWidth = 440.0;
const columnWidth = 200.0;
const headerHeight = 40.0;
const lineHeight = 30.0;

/// Provides a view to do fraction conversions.
class FractionsView extends StatefulWidget {
  @override
  State<FractionsView> createState() => _FractionsViewState();
}

class _FractionsViewState extends State<FractionsView> {
  var usePowerOfTwo = false;
  final results = <Fraction>[];
  double? decimalValue;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraction Conversions'),
        leading: IconButton(
          // Manually create button to avoid focus using tab key.
          icon: BackButtonIcon(),
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
                  child: Text(
                    usePowerOfTwo
                        ? 'Limit denominators to powers of two'
                        : 'Do not limit denominators to powers of two',
                  ),
                  focusNode: FocusNode(skipTraversal: true),
                  onPressed: () {
                    setState(() {
                      usePowerOfTwo = !usePowerOfTwo;
                      if (decimalValue != null) {
                        results.clear();
                        results.addAll(fractionResults(
                          decimalValue!,
                          powerOfTwo: usePowerOfTwo,
                        ));
                      }
                    });
                  },
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
                      setState(() {
                        results.clear();
                        decimalValue = null;
                        errorText = null;
                        if (newText.isNotEmpty) {
                          try {
                            final decimal = Expression(newText).eval();
                            decimalValue = decimal?.toDouble();
                          } on ExpressionException {
                          } on FormatException {}
                          if (decimalValue != null) {
                            results.addAll(fractionResults(
                              decimalValue!,
                              powerOfTwo: usePowerOfTwo,
                            ));
                          } else {
                            errorText = 'Invalid value';
                          }
                        }
                      });
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
}

/// Provides a GUI scrolling table to display the fraction results.
class FractionTable extends StatefulWidget {
  final List<Fraction> results;

  FractionTable({super.key, required this.results});

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
                  (widget.results.length > 0 ? widget.results.length + 0.3 : 1),
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
                            constraints:
                                BoxConstraints.tightFor(height: lineHeight),
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

  String toString() => '$numerator/$denominator';

  String toDecimal() => (numerator / denominator).toString();
}

/// Return fractions that closely match the given decimal.
List<Fraction> fractionResults(double decimal, {var powerOfTwo = false}) {
  final results = <Fraction>[];
  if (decimal == 0.0) return results;
  final denomLimit = 1.0E+9;
  final minOffset = 1.0E-10;
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
      if (delta == 0.0) break;
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
