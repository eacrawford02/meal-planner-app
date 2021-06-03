import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  @override
  RecipeCardState createState() => RecipeCardState();
}

class RecipeCardState extends State<RecipeCard> {
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
              child: Image.file(null) // TODO: get file from model
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
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          // TODO: get text from model - name
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        )
                      ),
                      Text(
                        "", // TODO: get text from model - time
                        textScaleFactor: 0.75,
                        style: TextStyle(
                          color: Colors.grey
                        )
                      ),
                      Text(
                        "", // TODO: get text from model - serving size & kcal
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