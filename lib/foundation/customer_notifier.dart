
class CustomNotifier<T>{

  List<void Function(T _value)> callBacks = [];

  void addListener(void Function(T _value) func){
    callBacks.add(func);
  }
  bool get hasListeners{
    return callBacks.length > 0;
  }
  void removeListener(void Function(T _value) func){
    callBacks.remove(func);
  }

  void notifyListeners(T _value){
    callBacks.forEach((element) {
      element(_value);
    });
  }

  dispose(){
    callBacks.clear();
  }
}