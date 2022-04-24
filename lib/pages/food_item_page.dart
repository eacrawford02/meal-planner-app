import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner_app/models/food_item.dart';
import 'package:meal_planner_app/models/serving_size.dart';
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
  FocusNode _entryAFocus;
  FocusNode _entryBFocus;
  List<FocusNode> _nutrientFocus;
  List<String> _categories;
  TextEditingController _nameText = TextEditingController();
  ServingSizeModel _servingSizeModel;
  double amountA;
  String unitA;
  double amountB;
  String unitB;

  @override
  void initState() {
    _entryAFocus = FocusNode();
    _entryBFocus = FocusNode();
    _nutrientFocus = List.generate(
      Nutrient.nutrients().length, (index) => FocusNode()
    );
    // Get categories asynchronously and then rebuild widget once acquired
    _categories = [];
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
            Navigator.pop<String>(context, null);
          }
        ),
        title: Text(_isNew ? "Add New Food Item" : "Edit Food Item"),
        actions: [TextButton(
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.onPrimary
          ),
          child: Text("Save"),
          onPressed: () {
            _data.setServingSize(
              _servingSizeModel.getSize(Entry.A),
              _servingSizeModel.getUnit(Entry.A),
              _servingSizeModel.getSize(Entry.B),
              _servingSizeModel.getUnit(Entry.B)
            );
            _data.save();
            Navigator.pop<String>(context, _data.name);
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
        Divider(),
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
              focusNext: _isNew,
              initialFocus: _entryAFocus,
              nextFocus: _entryBFocus,
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
              focusNext: _isNew,
              initialFocus: _entryBFocus,
              nextFocus: _nutrientFocus[0],
            )
          )
        ),
        Divider(),
        // Nutrition info
        Column(children: _nutrientEntries())
      ])
    );
  }

  @override
  void dispose() {
    _entryAFocus.dispose();
    _entryBFocus.dispose();
    _nutrientFocus.forEach((element) => element.dispose());

    super.dispose();
  }

  List<Widget> _nutrientEntries() {
    List<Widget> widgets = [];
    List<String> nutrients = Nutrient.nutrients().keys.toList();
    for (int i = 0; i < nutrients.length; i++) {
      bool focusNext = false;
      FocusNode nextFocus;
      // Ensure that the last entry doesn't try to shift focus to the next node
      if (i < nutrients.length - 1) {
        focusNext = _isNew;
        nextFocus = _nutrientFocus[i + 1];
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: NutrientEntry(
            nutrients[i],
            _data,
            focusNext,
            _nutrientFocus[i],
            nextFocus
          )
        )
      );
    }
    return widgets;
  }
}