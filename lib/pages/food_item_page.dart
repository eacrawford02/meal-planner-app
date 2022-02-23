import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:meal_planner_app/models/food_item.dart';
import 'package:meal_planner_app/utils.dart';

class FoodItemPage extends StatefulWidget {

  final String _name;

  FoodItemPage([this._name]);

  @override
  FoodItemPageState createState() => FoodItemPageState();
}

class FoodItemPageState extends State<FoodItemPage> {

  FoodItem _data;
  bool _isNew;
  List<String> _categories;
  TextEditingController _nameText = TextEditingController();
  // Controllers for setting the fractional size of serving size amount
  TextEditingController _wholeA = TextEditingController();
  TextEditingController _numA = TextEditingController();
  TextEditingController _dnmA = TextEditingController();
  TextEditingController _wholeB = TextEditingController();
  TextEditingController _numB = TextEditingController();
  TextEditingController _dnmB = TextEditingController();
  String _unitA;
  String _unitB;

  @override
  void initState() {
    // Get categories asynchronously and then rebuild widget once acquired
    Future(() async {
      _categories = await Categories.getCategories();
    }).then((value) => this.setState(() {}));
    if (widget._name != null) {
      _isNew = false;
      _data = FoodItem(name: widget._name);
      // Load data asynchronously and then rebuild widget once loading is done
      Future(() async {
        _data.loadData();
      }).then((value) => this.setState(() {
        _nameText.text = _data.name;
        double amountA = _data.getServingSize(false);
        _wholeA.text = Utils.strWhole(amountA);
        _numA.text = Utils.strNumerator(amountA);
        _dnmA.text = Utils.strDenominator(amountA);
        double amountB = _data.getServingSize(true);
        _wholeB.text = Utils.strWhole(amountB);
        _numB.text = Utils.strNumerator(amountB);
        _dnmB.text = Utils.strDenominator(amountB);
      }));
    }
    else {
      _isNew = true;
      _data = FoodItem();
      _nameText.text = _data.name;
      _nameText.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _data.name.length
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            // TODO: close page
          }
        ),
        title: Text(_isNew ? "Add New Food Item" : "Edit Food Item"),
        actions: [TextButton(
          child: Text("Save"),
          onPressed: () {
            _data.save();
            // TODO: close page
          },
        )]
      ),
      body: Column(children: [
        // Name
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text("Name:")
            ),
            Expanded(
              child: Focus(
                autofocus: _isNew,
                child: TextField(
                  controller: _nameText,
                  onSubmitted: (String value) {
                    if (_nameText.text != "") {
                      _data.name = value;
                    }
                    if (_isNew) {
                      Focus.of(context).nextFocus();
                    }
                  }
                )
              )
            )
          ])
        ),
        // Category
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(children: [
            Expanded(
              child: Text("Category:")
            ),
            Focus(
              child: DropdownButton<String>(
                value: _isNew ? null : _data.category,
                hint: Text("Select Category"),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).accentColor
                ),
                onChanged: (String newValue) {
                  setState(() {
                    _data.category = newValue;
                  });
                  if (_isNew) {
                    Focus.of(context).nextFocus();
                  }
                },
                items: _categories.map<DropdownMenuItem<String>>((String s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s)
                  );
                }).toList()
              )
            )
          ])
        ),
        Divider(),
        // Serving size
        _servingSizeData(
          "Serving Size:",
          _wholeA,
          _numA,
          _dnmA,
          false,
          _unitA,
          _unitB
        ),
        _servingSizeData(
          "Equivalent Serving Size:",
          _wholeB,
          _numB,
          _dnmB,
          true,
          _unitB,
          _unitA
        ),
        Divider(),
        // Nutrition info
      ])
    );
  }

  // TODO: move to separate file
  Widget _servingSizeData(
      String fieldName,
      TextEditingController whole,
      TextEditingController numerator,
      TextEditingController denominator,
      bool metric,
      String thisUnit,
      String otherUnit) {
    List<String> availableUnits = [
      FoodItem.teaspoons,
      FoodItem.tablespoons,
      FoodItem.cup,
      FoodItem.cups,
      FoodItem.grams,
      FoodItem.millilitres
    ];
    if (otherUnit == FoodItem.grams || otherUnit == FoodItem.millilitres) {
      availableUnits.remove(FoodItem.grams);
      availableUnits.remove(FoodItem.millilitres);
    }
    else if (otherUnit != null) {
      availableUnits.remove(FoodItem.teaspoons);
      availableUnits.remove(FoodItem.tablespoons);
      availableUnits.remove(FoodItem.cup);
      availableUnits.remove(FoodItem.cups);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Expanded(
            child: Text(fieldName)
          )
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Focus(
            child: TextField(
              keyboardType: TextInputType.number,
              controller: whole,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "--"
              ),
              onSubmitted: (String value) {
                if (_isNew) {
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
              controller: numerator,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "--"
              ),
              onSubmitted: (String value) {
                if (_isNew) {
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
              controller: denominator,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[1-9]'))
              ],
              decoration: InputDecoration(
                hintText: "--"
              ),
              onSubmitted: (String value) {
                if (_isNew) {
                  Focus.of(context).nextFocus();
                }
              }
            )
          )
        ),
        Focus(
          child: DropdownButton<String>(
            value: _data.getServingUnit(metric),
            hint: Text("Select Unit"),
            underline: Container(
              height: 2,
              color: Theme.of(context).accentColor
            ),
            onChanged: (String newValue) {
              setState(() {
                thisUnit = newValue;
              });
              if (_isNew) {
                Focus.of(context).nextFocus();
              }
            },
            items: availableUnits.map((String s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s)
              );
            }).toList()
          )
        )
      ])
    );
  }
}