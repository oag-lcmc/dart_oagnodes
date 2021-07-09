part of nodes;

class DataNodeObserver<T, U> extends Observer {
  final Node comparer;

  DataNodeObserver(this.comparer);

  @override
  void receive(DataSubject<U> subject) {
    if (comparer.update() == Status.success) {}
  }

  @override
  Status update() {
    return Status.success;
  }
}
