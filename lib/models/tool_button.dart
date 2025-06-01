import 'package:flutter/material.dart';

class ToolButtonModel extends ChangeNotifier {
  bool _isOn = false;
  bool get isOn => _isOn;

  void toggle() {
    _isOn = !_isOn;
    notifyListeners();
  }

  void setValue(bool newValue) {
    if (_isOn != newValue) {
      _isOn = newValue;
      notifyListeners();
    }
  }
}
