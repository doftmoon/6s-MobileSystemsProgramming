import 'dart:async';

class StateBloc {
  static final StateBloc _instance = StateBloc._internal();

  factory StateBloc() {
    return _instance;
  }

  StateBloc._internal();

  int selectedIndex = 0;
  final _indexController = StreamController<int>();

  Stream<int> get indexStream => _indexController.stream;

  void setSelectedIndex(int index) {
    selectedIndex = index;
    _indexController.sink.add(selectedIndex);
  }

  void dispose() {
    _indexController.close();
  }
}
