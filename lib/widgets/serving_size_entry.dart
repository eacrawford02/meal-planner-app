import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/serving_size.dart';
import 'package:meal_planner_app/widgets/fraction_entry.dart';
import 'package:provider/provider.dart';

class ServingSizeEntry extends StatefulWidget {
  final String entryName;
  final Entry entryID;
  final double amount;
  final bool focusNext;
  final FocusNode initialFocus;
  final FocusNode nextFocus;

  // If `focusNext` is true, then both `initialFocus` and `nextFocus` should not
  // be null
  ServingSizeEntry({
    this.entryName,
    this.entryID,
    this.amount,
    this.focusNext,
    this.initialFocus,
    this.nextFocus
  });

  @override
  ServingSizeEntryState createState() => ServingSizeEntryState();
}

class ServingSizeEntryState extends State<ServingSizeEntry> {
  FocusNode _unitFocus;

  @override
  void initState() {
    _unitFocus = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FractionEntry(
            entryName: widget.entryName,
            amount: widget.amount,
            focusNext: widget.focusNext,
            initialFocus: widget.initialFocus,
            nextFocus: _unitFocus,
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
          )
        )
      ),
      Consumer<ServingSizeModel>(
        builder: (context, model, child) => DropdownButton<String>(
          focusNode: _unitFocus,
          value: model.getUnit(widget.entryID),
          hint: Text("Select Unit"),
          underline: Container(
            height: 2,
            color: Theme.of(context).accentColor
          ),
          onChanged: (String newValue) {
            setState(() {
              if (newValue == "Select Unit") {
                newValue = null;
              }
              model.setUnit(widget.entryID, newValue);
            });
            if (widget.focusNext) {
              widget.nextFocus.requestFocus();
            }
          },
          items: model.getAvailableUnits(widget.entryID).map((String s) {
            return DropdownMenuItem(
              value: s == null ? "Select Unit" : s,
              child: s == null ? Text("Select Unit") : Text(s)
            );
          }).toList()
        )
      )
    ]);
  }

  @override
  void dispose() {
    _unitFocus.dispose();

    super.dispose();
  }
}