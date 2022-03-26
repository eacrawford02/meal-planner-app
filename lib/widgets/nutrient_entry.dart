import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner_app/models/food_item.dart';

class NutrientEntry extends StatefulWidget {
  final String nutrient;
  final FoodItem foodItem;
  final bool focusNext;

  NutrientEntry(this.nutrient, this.foodItem, this.focusNext);

  @override
  NutrientEntryState createState() => NutrientEntryState();
}

class NutrientEntryState extends State<NutrientEntry> {
  TextEditingController amountText = TextEditingController();

  @override
  void initState() {
    int amount = widget.foodItem.getAmount(widget.nutrient);
    if (amount != 0) {
      amountText.text = "$amount";
      amountText.selection = TextSelection(
        baseOffset: 0,
        extentOffset: amountText.text.length
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(widget.nutrient),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Focus(
          child: TextField(
            keyboardType: TextInputType.number,
            controller: amountText,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "--"
            ),
            onSubmitted: (String value) {
              widget.foodItem.setAmount(widget.nutrient, int.parse(value));
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