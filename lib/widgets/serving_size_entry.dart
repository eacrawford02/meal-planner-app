import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner_app/models/serving_size.dart';
import 'package:meal_planner_app/utils.dart';
import 'package:provider/provider.dart';

class ServingSizeEntry extends StatefulWidget {
  final String entryName;
  final Entry entryID;
  final double amount;
  final bool focusNext;

  ServingSizeEntry({
    this.entryName,
    this.entryID,
    this.amount,
    this.focusNext,
  });

  @override
  ServingSizeEntryState createState() => ServingSizeEntryState();
}

class ServingSizeEntryState extends State<ServingSizeEntry> {
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
    Row(children: [
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
              if (widget.focusNext) {
                Focus.of(context).nextFocus();
              }
            }
          )
        )
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Focus(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _numerator,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "--"
            ),
            onSubmitted: (String value) {
              if (widget.focusNext) {
                Focus.of(context).nextFocus();
              }
            }
          )
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
              if (widget.focusNext) {
                Focus.of(context).nextFocus();
              }
            }
          )
        )
      ),
      Focus(
        child: Consumer<ServingSizeModel>(
          builder: (context, model, child) => DropdownButton<String>(
            value: model.getUnit(widget.entryID),
            hint: Text("Select Unit"),
            underline: Container(
              height: 2,
              color: Theme.of(context).accentColor
            ),
            onChanged: (String newValue) {
              setState(() {
                model.setUnit(widget.entryID, newValue);
              });
              if (widget.focusNext) {
                Focus.of(context).nextFocus();
              }
            },
            items: model.getAvailableUnits(widget.entryID).map((String s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s)
              );
            }).toList()
          )
        )
      )
    ]);
  }
}