import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeDialog extends StatefulWidget {
  final String _duration;

  TimeDialog(this._duration);

  @override
  TimeDialogState createState() => TimeDialogState();
}

class TimeDialogState extends State<TimeDialog> {
  FocusNode _focus;
  TextEditingController _hrText;
  TextEditingController _minText;
  double fontSize = 32;

  @override
  void initState() {
    super.initState();

    _focus = FocusNode();
    int i = widget._duration.indexOf(":");
    _hrText= TextEditingController.fromValue(TextEditingValue(
      text: widget._duration.substring(0, i),
      selection: TextSelection(
        baseOffset: 0,
        extentOffset: i
      )
    ));
    _minText = TextEditingController(
        text: widget._duration.substring(i + 1)
    );
    // Highlight minute text when that TextField receives focus
    _focus.addListener(() {
      _minText.selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget._duration.length - (i + 1)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Set Duration"),
      content: Row(
        children: [
          // Hours TextField
          Expanded(
            child: TextField(
              autofocus: true,
              maxLength: 2,
              keyboardType: TextInputType.number,
              controller: _hrText,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "hh",
                hintStyle: TextStyle(
                  fontSize: fontSize
                ),
                helperText: "Hours"
              ),
              style: TextStyle(
                fontSize: fontSize
              ),
              onSubmitted: (String s) {
                // Pass focus to minute TextField
                _focus.requestFocus();
              }
            )
          ),
          // TextField separator
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: fontSize,
              )
            )
          ),
          // Minutes TextField
          Expanded(
            child: TextField(
              focusNode: _focus,
              maxLength: 2,
              keyboardType: TextInputType.number,
              controller: _minText,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: "mm",
                hintStyle: TextStyle(
                  fontSize: fontSize
                ),
                helperText: "Minutes"
              ),
              style: TextStyle(
                fontSize: fontSize
              ),
              onSubmitted: (String s) {
                // Hide keyboard
                FocusScope.of(context).unfocus();
              },
            )
          )
        ]
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            // Note that TextFields only accept digits, so no need to check if
            // text is valid
            Navigator.of(context).pop(widget._duration);
          }
        ),
        TextButton(
          child: Text("Ok"),
          onPressed: () {
            // Note that TextFields only accept digits, so no need to check if
            // text is valid
            Navigator.of(context).pop("${_hrText.text}:${_minText.text}");
          }
        )
      ]
    );
  }

  @override
  void dispose() {
    _focus.dispose();

    super.dispose();
  }
}