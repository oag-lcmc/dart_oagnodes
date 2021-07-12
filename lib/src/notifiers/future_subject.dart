part of nodes;

class FutureDataSubject<T> extends DataSubject<T> {
  bool _isComplete;
  final Future<T> Function() _future;

  /// Constructs a [FutureDataSubject] instance.
  ///
  /// - `valueDefault` is a placeholder default value to store before the
  /// `future` is finished.
  /// - `future` somehow obtains some data of type `T` and
  /// - `builder` builds a [DataNode] operation constructed from the return
  /// value of the `future`; the [DataNode] will be executed once `future`
  /// terminates.
  FutureDataSubject({
    required DataNode<T> valueDefault,
    required final Future<T> Function() future,
    final List<Status> notifications = const [Status.success],
  })  : _isComplete = false,
        _future = future,
        super(valueDefault, notifications: notifications);

  /// Resets the subject [Node] and the state of the [FutureDataSubject] so that
  /// it calls its future in the next call to the `update()` method.
  @override
  void reset() {
    _isComplete = false;
    super.reset();
  }

  /// Calls the future and once a result is available the contained data is
  /// updated and the [FutureDataSubject] is updated as if it were a
  /// [DataSubject].
  @override
  Status update() {
    if (_isComplete) {
      _isComplete = false;
      return super.update();
    } else {
      print('calling future again');
      _future().then((value) {
        data = value;
        (_subject as DataNode<T>).data = value;
        _isComplete = true;
        update();
      });

      return Status.running;
    }
  }
}
