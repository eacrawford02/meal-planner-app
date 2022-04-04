import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/food_item.dart';
import 'package:meal_planner_app/models/recipe_model.dart';
import 'package:meal_planner_app/widgets/fraction_entry.dart';

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
  List<String> _units = [
    FoodItem.grams,
    FoodItem.millilitres,
    FoodItem.teaspoons,
    FoodItem.tablespoons,
    FoodItem.cup,
    FoodItem.cups,
    null
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Ingredient"),
      content: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FractionEntry(
            entryName: widget._ingredient.name,
            amount: widget._ingredient.amount,
            focusNext: widget._focusNext,
            wholeCb: (String value) {
              _whole = int.parse(value);
            },
            numeratorCb: (String value) {
              _numerator = int.parse(value);
            },
            denominatorCb: (String value) {
              _denominator = int.parse(value) == 0 ? null : int.parse(value);
            }
          )
        ),
        Focus(
          child: DropdownButton<String>(
            value: widget._ingredient.units,
            hint: Text("Select Unit"),
            underline: Container(
              height: 2,
              color: Theme.of(context).accentColor
            ),
            onChanged: (String newValue) {
              widget._ingredient.units = newValue;
            },
            items: _units.map((String s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s)
              );
            }).toList()
          )
        )
      ]),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed:() => Navigator.of(context).pop()
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
            Navigator.of(context).pop();
          },
        )
      ]
    );
  }
}