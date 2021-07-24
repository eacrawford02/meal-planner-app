import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/recipe_model.dart';

class RecipeCard extends StatefulWidget {
  final RecipeModel data;

  RecipeCard(this.data, ValueKey key) : super(key: key);

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(4)), // TODO: make const, should equal card corner radius
        onTap: () {
          // TODO: implement
        },
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: widget.data.getImage()
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 2,
                    bottom: 2
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        widget.data.getDurationS(),
                        textScaleFactor: 0.75,
                        style: TextStyle(
                          color: Colors.grey
                        )
                      ),
                      Text(
                        "${widget.data.nutrition["kcal"]} kcal \u{00B7} serves "
                            "${widget.data.servings}",
                        textScaleFactor: 0.75,
                        style: TextStyle(
                          color: Colors.grey
                        )
                      )
                    ]
                  )
                )
              )
            )
          ]
        )
      )
    );
  }
}