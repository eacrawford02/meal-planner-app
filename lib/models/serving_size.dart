import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'food_item.dart';

enum Entry {A, B}

// Manages serving size entry models and provides access to their data to
// widgets.
class ServingSizeModel extends ChangeNotifier {
  _EntryModel _entryA;
  _EntryModel _entryB;
  List<String> _metricUnits = [FoodItem.grams, FoodItem.millilitres, null];
  List<String> _nonMetricUnits = [
    FoodItem.teaspoons, FoodItem.tablespoons, FoodItem.cup, FoodItem.cups, null
  ];

  ServingSizeModel([
    double amountA, String unitA, double amountB, String unitB
  ]) {
    _entryA = _EntryModel();
    _entryB = _EntryModel();
    // TODO: Reconfigure _EntryModel class to move following to constructor
    _convert(amountA, _entryA);
    _convert(amountB, _entryB);
    setUnit(Entry.A, unitA);
    setUnit(Entry.B, unitB);
  }

  void setSize(Entry entry, {int whole, int numerator, int denominator}) {
    var model = _entry(entry);
    model.whole = whole;
    model.numerator = numerator;
    model.denominator = denominator == 0 ? null : denominator;
  }

  double getSize(Entry entry) {
    var model = _entry(entry);
    if (model.whole != null && model.numerator != null && model.denominator !=
        null) {
      return model.whole + model.numerator / model.denominator;
    }
    else if (model.numerator != null && model.denominator != null) {
      return model.numerator / model.denominator;
    }
    else if (model.whole != null) {
      return model.whole.toDouble();
    }
    else {
      return null;
    }
  }

  void setUnit(Entry entry, String unit) {
    var model = _entry(entry);
    var otherModel = _entry(entry == Entry.A ? Entry.B : Entry.A);
    model.unit = unit;
    if (unit == null) {
      otherModel.availableUnits = _metricUnits + _nonMetricUnits;
    }
    else if (_metricUnits.contains(unit)) {
      otherModel.availableUnits = _nonMetricUnits;
    }
    else if (_nonMetricUnits.contains(unit)) {
      otherModel.availableUnits = _metricUnits;
    }
    else {
      throw Exception("Unknown unit provided to serving size model");
    }
    notifyListeners();
  }

  String getUnit(Entry entry) => _entry(entry).unit;

  List<String> getAvailableUnits(Entry entry) => _entry(entry).availableUnits;

  _EntryModel _entry(Entry entry) => entry == Entry.A ? _entryA : _entryB;

  void _convert(double amount, _EntryModel model) {
    Fraction fraction;
    if (amount != null) {
      fraction = amount.toFraction();
      if (fraction.isImproper) {
        MixedFraction mixedFraction = fraction.toMixedFraction();
        _entryA.whole = mixedFraction.whole;
        _entryA.numerator = mixedFraction.numerator;
        _entryA.denominator = mixedFraction.denominator;
      }
      else {
        _entryA.numerator = fraction.numerator;
        _entryA.denominator = fraction.denominator;
      }
    }
  }
}

class _EntryModel {
  int whole;
  int numerator;
  int denominator;
  String unit;
  List<String> availableUnits;
}