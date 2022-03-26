import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner_app/models/food_item.dart';
import 'package:meal_planner_app/models/serving_size.dart';
import 'package:meal_planner_app/utils.dart';
import 'package:meal_planner_app/widgets/nutrient_entry.dart';
import 'package:meal_planner_app/widgets/serving_size_entry.dart';
import 'package:provider/provider.dart';

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
  ServingSizeModel _servingSizeModel;
  double amountA;
  String unitA;
  double amountB;
  String unitB;

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
        amountA = _data.getServingSize(false);
        unitA = _data.getServingUnit(false);
        amountB = _data.getServingSize(true);
        unitB = _data.getServingUnit(true);
        _servingSizeModel = ServingSizeModel(amountA, unitA, amountB, unitB);
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
      _servingSizeModel = ServingSizeModel();
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ChangeNotifierProvider.value(
            value: _servingSizeModel,
            child: ServingSizeEntry(
              entryName: "Serving Size:",
              entryID: Entry.A,
              amount: amountA,
              focusNext: _isNew
            )
          )
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: ChangeNotifierProvider.value(
                value: _servingSizeModel,
                child: ServingSizeEntry(
                    entryName: "Equivalent Serving Size:",
                    entryID: Entry.B,
                    amount: amountB,
                    focusNext: _isNew
                )
            )
        ),
        Divider(),
        // Nutrition info
        Column(children: _nutrientEntries())
      ])
    );
  }

  List<Widget> _nutrientEntries() {
    List<Widget> widgets = [];
    List<String> nutrients = Nutrient.nutrients().keys.toList();
    for (var nutrient in nutrients) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: NutrientEntry(nutrient, _data, _isNew)
        )
      );
    }
    return widgets;
  }
}