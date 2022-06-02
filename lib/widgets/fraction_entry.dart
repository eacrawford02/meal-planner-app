import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner_app/utils.dart';

class FractionEntry extends StatefulWidget {
  final String entryName;
  final double amount;
  final bool focusNext;
  final FocusNode initialFocus;
  final FocusNode nextFocus;
  final Function(String) wholeCb;
  final Function(String) numeratorCb;
  final Function(String) denominatorCb;

  // If `focusNext` is true, then both `initialFocus` and `nextFocus` should not
  // be null
  FractionEntry({
    this.entryName,
    this.amount,
    this.focusNext,
    this.initialFocus,
    this.nextFocus,
    this.wholeCb,
    this.numeratorCb,
    this.denominatorCb,
  });

  @override
  FractionEntryState createState() => FractionEntryState();
}

class FractionEntryState extends State<FractionEntry> {
  // Controllers for setting the fractional size of serving size amount
  TextEditingController _whole = TextEditingController();
  TextEditingController _numerator = TextEditingController();
  TextEditingController _denominator = TextEditingController();
  FocusNode _numFocus;
  FocusNode _dnmFocus;


  @override
  void initState() {
    _whole.text = Utils.strWhole(widget.amount);
    _numerator.text = Utils.strNumerator(widget.amount);
    _denominator.text = Utils.strDenominator(widget.amount);
    _numFocus = FocusNode();
    _dnmFocus = FocusNode();
    // TODO: add text selection

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(widget.entryName)
        )
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            focusNode: widget.initialFocus,
            keyboardType: TextInputType.number,
            controller: _whole,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "--"
            ),
            onChanged: (String value) {
              widget.wholeCb(value);
            },
            onSubmitted: (String value) {
              if (widget.focusNext) {
                _numFocus.requestFocus();
              }
            }
          )
        )
      ),
      Expanded(
        child: TextField(
          focusNode: _numFocus,
          keyboardType: TextInputType.number,
          controller: _numerator,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: "--"
          ),
          onChanged: (String value) {
            widget.numeratorCb(value);
          },
          onSubmitted: (String value) {
            if (widget.focusNext) {
              _dnmFocus.requestFocus();
            }
          }
        )
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text("/")
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            focusNode: _dnmFocus,
            keyboardType: TextInputType.number,
            controller: _denominator,
            inputFormatters: [
              // Prevent zeros from being entered
              FilteringTextInputFormatter.allow(RegExp(r'[1-9]'))
            ],
            decoration: InputDecoration(
              hintText: "--"
            ),
            onChanged: (String value) {
              widget.denominatorCb(value);
            },
            onSubmitted: (String value) {
              if (widget.focusNext) {
                widget.nextFocus.requestFocus();
              }
            }
          )
        )
      )
    ]);
  }

  @override
  void dispose() {
    _numFocus.dispose();
    _dnmFocus.dispose();

    super.dispose();
  }
}