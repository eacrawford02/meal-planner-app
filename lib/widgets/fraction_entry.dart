import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner_app/utils.dart';

class FractionEntry extends StatefulWidget {
  final String entryName;
  final double amount;
  final bool focusNext;
  final Function(String) wholeCb;
  final Function(String) numeratorCb;
  final Function(String) denominatorCb;

  FractionEntry({
    this.entryName,
    this.amount,
    this.focusNext,
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

  @override
  void initState() {
    _whole.text = Utils.strWhole(widget.amount);
    _numerator.text = Utils.strNumerator(widget.amount);
    _denominator.text = Utils.strDenominator(widget.amount);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Expanded(
          child: Text(widget.entryName)
        )
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Focus(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _whole,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "--"
            ),
            onSubmitted: (String value) {
              widget.wholeCb(value);
              if (widget.focusNext) {
                Focus.of(context).nextFocus();
              }
            }
          )
        )
      ),
      Focus(
        child: TextField(
          keyboardType: TextInputType.number,
          controller: _numerator,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: "--"
          ),
          onSubmitted: (String value) {
            widget.numeratorCb(value);
            if (widget.focusNext) {
              Focus.of(context).nextFocus();
            }
          }
        )
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text("/")
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Focus(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _denominator,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[1-9]'))
            ],
            decoration: InputDecoration(
              hintText: "--"
            ),
            onSubmitted: (String value) {
              widget.denominatorCb(value);
              if (widget.focusNext) {
                Focus.of(context).nextFocus();
              }
            }
          )
        )
      )
    ]);
  }
}