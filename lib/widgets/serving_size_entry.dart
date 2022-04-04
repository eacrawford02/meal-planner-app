import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/serving_size.dart';
import 'package:meal_planner_app/widgets/fraction_entry.dart';
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

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      FractionEntry(
        entryName: widget.entryName,
        amount: widget.amount,
        focusNext: widget.focusNext,
        wholeCb: (String value) {
          Provider.of<ServingSizeModel>(context, listen: false).setSize(
            widget.entryID, whole: int.parse(value)
          );
        },
        numeratorCb: (String value) {
          Provider.of<ServingSizeModel>(context, listen: false).setSize(
            widget.entryID, numerator: int.parse(value)
          );
        },
        denominatorCb: (String value) {
          Provider.of<ServingSizeModel>(context, listen: false).setSize(
            widget.entryID, denominator: int.parse(value)
          );
        },
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