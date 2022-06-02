import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:meal_planner_app/models/food_item.dart';
import 'package:meal_planner_app/models/recipe_model.dart';
import 'package:meal_planner_app/widgets/fraction_entry.dart';

/// Takes an Ingredient object and mutates its state based on the dialog
/// options. Returns true if edit is successful, and false otherwise.
class IngredientDialog extends StatefulWidget {
  final Ingredient _ingredient;
  final bool _focusNext;

  IngredientDialog(this._ingredient, this._focusNext);

  @override
  IngredientDialogState createState() => IngredientDialogState();
}

class IngredientDialogState extends State<IngredientDialog> {
  int _whole;
  int _numerator;
  int _denominator;
  String _unit;
  List<String> _units = [
    FoodItem.grams,
    FoodItem.millilitres,
    FoodItem.teaspoons,
    FoodItem.tablespoons,
    FoodItem.cup,
    FoodItem.cups,
    null
  ];
  FocusNode _entryFocus;
  FocusNode _unitFocus;

  @override
  void initState() {
    if (widget._ingredient.amount != null) {
      Fraction fraction = Fraction.fromDouble(widget._ingredient.amount);
      if (fraction.isImproper) {
        MixedFraction mixed = fraction.toMixedFraction();
        _whole = mixed.whole;
        _numerator = mixed.numerator;
        _denominator = mixed.denominator;
      }
      else {
        _numerator = fraction.numerator;
        _denominator = fraction.denominator;
      }
    }
    _entryFocus = FocusNode();
    _unitFocus = FocusNode();
    _entryFocus.requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Ingredient"),
      content: Row(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FractionEntry(
              entryName: widget._ingredient.name,
              amount: widget._ingredient.amount,
              initialFocus: _entryFocus,
              focusNext: widget._focusNext,
              nextFocus: _unitFocus,
              wholeCb: (String value) {
                _whole = value != "" ? int.parse(value) : null;
              },
              numeratorCb: (String value) {
                _numerator = value != "" ? int.parse(value) : null;
              },
              denominatorCb: (String value) {
                if (value != "") {
                  _denominator =
                      int.parse(value) == 0 ? null : int.parse(value);
                }
                else {
                  _denominator = null;
                }
              }
            )
          )
        ),
        DropdownButton<String>(
          focusNode: _unitFocus,
          value: widget._ingredient.units,
          hint: Text("Select Unit"),
          underline: Container(
            height: 2,
            color: Theme.of(context).accentColor
          ),
          onChanged: (String newValue) {
            _unit = newValue;
          },
          items: _units.map((String s) {
            return DropdownMenuItem(
              value: s == null ? "Select Unit" : s,
              child: s == null ? Text("Select Unit") : Text(s)
            );
          }).toList()
        )
      ]),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed:() => Navigator.of(context).pop<bool>(false)
        ),
        TextButton(
          child: Text("Save"),
          onPressed: () {
            if (_whole != null && _numerator != null && _denominator != null) {
              widget._ingredient.amount = _whole + _numerator / _denominator;
            }
            else if (_numerator != null && _denominator != null) {
              widget._ingredient.amount = _numerator / _denominator;
            }
            else if (_whole != null) {
              widget._ingredient.amount = _whole.toDouble();
            }
            else {
              widget._ingredient.amount = null;
            }
            widget._ingredient.units = _unit;
            Navigator.of(context).pop<bool>(true);
          },
        )
      ]
    );
  }

  @override
  void dispose() {
    _entryFocus.dispose();
    _unitFocus.dispose();

    super.dispose();
  }
}