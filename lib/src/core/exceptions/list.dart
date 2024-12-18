


extension RemoveNulls<T> on List<T?> {
  List<T> removeNulls() {
    return where((element) => element != null).cast<T>().toList();
  }
}