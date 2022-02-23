import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:fraction/fraction.dart';
import 'package:meal_planner_app/models/food_item.dart';
import 'package:meal_planner_app/models/recipe_model.dart';

class IngredientsPage extends StatefulWidget {

  final Ingredient _ingredient;

  IngredientsPage(this._ingredient);

  @override
  IngredientsPageState createState() => IngredientsPageState();
}

class IngredientsPageState extends State<IngredientsPage> {
  @override
  Widget build(BuildContext context) {

  }
}

class FoodItemSearch extends SearchDelegate<String> {

  Future<List<String>> _foodItems;

  FoodItemSearch() {
    // TODO: load past queries from database
    _foodItems = FoodItem.getAll();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: add clear text button
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: add back button
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _foodItems,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          // Search for similar results using current query value
          List<ExtractedResult<String>> results = extractAllSorted(
            query: query,
            cutoff: 10,
            choices: snapshot.data
          );
          return SearchResults(results);
        }
        else {
          return Column();
        }
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: build suggestions based on past queries
    return Text("No suggestions currently available");
  }
}

// Making the search results list its own stateful widget allows for the widget
// to reflect any changes made to the list's state (such as removing a food
// item) using setState()
class SearchResults extends StatefulWidget {

  final List<ExtractedResult<String>> _results;

  SearchResults(this._results);

  @override
  SearchResultsState createState() => SearchResultsState();
}

class SearchResultsState extends State<SearchResults> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // # of results + 1 in item count to allow for add new item button
      itemCount: widget._results.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == widget._results.length) {
          // Return 'add new item' list tile
          return ListTile(
            leading: Icon(Icons.add),
            onTap: () {
              // TODO: Open food item editor with empty item data
            }
          );
        }
        String itemName = widget._results[index].choice;
        return ListTile(
          title: Text(itemName),
          onTap: () {
            // TODO: Open ingredient editor dialog
          },
          onLongPress: () {
            // TODO: open food item editor
          },
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                // Delete food item from storage and remove it from search
                // results list
                FoodItem.delete(itemName);
                widget._results.removeAt(index);
              });
            }
          )
        );
      }
    );
  }
}