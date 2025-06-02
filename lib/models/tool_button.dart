import 'package:flutter/material.dart';

class ToolButtonModel extends ChangeNotifier {
  static final ToolButtonModel _instance = ToolButtonModel._internal();
  factory ToolButtonModel() => _instance;
  ToolButtonModel._internal();

  bool _isOn = false;
  bool get isOn => _isOn;

  void toggle() {
    _isOn = !_isOn;
    print('Current status of tool button: $_isOn');
    notifyListeners();
  }

  void setValue(bool newValue) {
    if (_isOn != newValue) {
      _isOn = newValue;
      notifyListeners();
    }
  }
}
