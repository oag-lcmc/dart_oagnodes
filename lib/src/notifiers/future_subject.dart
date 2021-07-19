part of nodes;

/// A [FutureSubject] takes a [Function] returning a [Future] of argument type
/// `T`. The [FutureSubject] will call the argument future and notify listeners
/// once the future is complete.
///
/// Example:
///
/// ```

/// ```
class FutureSubject<T> extends Subject {
  /// Future to be called by `_updater` before a result has been received.
  final Future<T> Function() _future;

  /// Builds a [DataNode] when the future completes using the value returned
  /// by the future.
  final DataNode<T> Function(T) _builder;

  static final Status Function() _ds = () {
    return Status.running;
  };

  Status Function() _updater;

  /// Constructs a [FutureSubject] instance.
  ///
  /// - `data` is a placeholder default value to store before the `future` is
  /// finished.
  /// - `future` somehow obtains some data of type `T` and
  /// - `builder` builds a [DataNode] operation constructed from the return
  /// value of the `future`; the [DataNode] will be executed once `future`
  /// terminates.
  ///
  /// Note: The `notifications` list only accepts `Status.success` and
  /// `Status.running`.
  FutureSubject({
    required final Future<T> Function() future,
    required final DataNode<T> Function(T) builder,
    final List<Status> notifications = const [Status.success],
  })  : assert(!notifications.contains(Status.failure)),
        _future = future,
        _builder = builder,
        _updater = _ds,
        super(Identity.failure) {
    _updater = _await;
  }

  @override
  void reset() {
    _updater = _await;
  }

  /// Calls the future and once a result is available the contained data is
  /// updated and the [FutureSubject] is updated as if it were a
  /// [DataSubject].
  @override
  Status update() {
    return _updater();
  }

  /// Calls the future. Builds a [DataNode] using the result of
  /// the future
  Status _await() {
    _future().then((T futureData) {
      notifier = _builder(futureData);
      _updater = _update;
      update();
    });

    return Status.failure;
  }

  Status _update() {
    final status = notifier.update();

    if (status._value & notifications._value > 0) {
      notify();
    }

    return status;
  }
}
