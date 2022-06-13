class CustomNotifier<T> {
  List<void Function(T _value)> callBacks = [];
  bool _lockList = false;

  void addListener(void Function(T _value) func) {
    if (_lockList) {
      Future.delayed(const Duration(milliseconds: 1)).then((v) {
        addListener(func);
      });
      return;
    }
    _lockList = true;
    callBacks.add(func);
    _lockList = false;
  }

  bool get hasListeners => callBacks.isNotEmpty;

  void removeListener(void Function(T _value) func) {
    if (_lockList) {
      Future.delayed(const Duration(milliseconds: 1)).then((v) {
        removeListener(func);
      });
      return;
    }
    _lockList = true;
    callBacks.remove(func);
    _lockList = false;
  }

  void notifyListeners(T _value) {
    if (_lockList) {
      Future.delayed(const Duration(milliseconds: 1)).then((v) {
        notifyListeners(_value);
      });
      return;
    }
    _lockList = true;
    for (var element in callBacks) {
      element(_value);
    }
    _lockList = false;
  }

  dispose() {
    if (_lockList) {
      Future.delayed(const Duration(milliseconds: 1)).then((v) {
        dispose();
      });
      return;
    }
    _lockList = true;
    callBacks.clear();
    _lockList = false;
  }
}
