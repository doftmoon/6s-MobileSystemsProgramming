import 'package:flutter/cupertino.dart';

class GlobalAppState extends ChangeNotifier {
  static final GlobalAppState _instance = GlobalAppState._internal();

  factory GlobalAppState() {
    return _instance;
  }

  GlobalAppState._internal();

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
