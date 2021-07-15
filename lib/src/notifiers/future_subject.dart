part of nodes;

typedef FutureUpdate<T> = Future<T> Function();
/*
/// A [FutureSubject] takes a [Function] returning a [Future] of argument type
/// `T`. The [FutureSubject] will call the argument future and notify listeners
/// once the future is complete.
class FutureSubject<T> extends _SubjectBase {
  /// Placeholder function to run while awaiting the future.
  static Status _await() => Status.running;

  /// Future to be called by `_updater` before a result has been received.
  final FutureUpdate<T> _future;

  /// Operation to be called by the `update()` method.
  Status Function() _updater;

  /// Constructs a [FutureSubject] instance.
  ///
  /// - `data` is a placeholder default value to store before the `future` is
  /// finished.
  /// - `future` somehow obtains some data of type `T` and
  /// - `builder` builds a [DataNode] operation constructed from the return
  /// value of the `future`; the [DataNode] will be executed once `future`
  /// terminates.
  FutureSubject({
    required final Future<T> Function() future,
    final List<Status> notifications = const [Status.success],
  })  : _updater = FutureSubject._await,
        _future = future {
    _updater = _begin;
  }

  /// Switches `_updater` to always return `Status.running` until `_future` is
  /// complete. Once the callback of `_future` is executed, `_updater` is set
  /// to the parent [DataSubject] `update()` method which will call its
  /// [DataNode] `update()` method and compare the resulting [Status] to its
  /// monitored statuses in order to determine whether to trigger a notification
  /// to the subscribers of this [FutureSubject].
  Status _begin() {
    _updater = _await;

    _future().then((newData) {
      // switch to the parent update method
      _updater = super.update;
      // trigger an update in this class to evaluate the parent update
      update();
    });

    return Status.running;
  }

  /// Calls the future and once a result is available the contained data is
  /// updated and the [FutureSubject] is updated as if it were a
  /// [DataSubject].
  @override
  Status update() {
    return _updater();
  }
}

class FutureDataSubject<T> extends FutureSubject<T> {
  T? data;

  FutureDataSubject({required final FutureUpdate<T> future})
      : super(future: future);

  /// Indicates whether the [FutureDataSubject] is complete
  bool get hasResult => data != null;

  /// Resets the subject [Node] and the state of the [FutureSubject] so that
  /// it calls its future in the next call to the `update()` method.
  @override
  void reset() {
    _updater = _begin;
    super.reset();
  }

  /// Switches `_updater` to always return `Status.running` until `_future` is
  /// complete. Once the callback of `_future` is executed, `_updater` is set
  /// to the parent [DataSubject] `update()` method which will call its
  /// [DataNode] `update()` method and compare the resulting [Status] to its
  /// monitored statuses in order to determine whether to trigger a notification
  /// to the subscribers of this [FutureSubject].
  @override
  Status _begin() {
    _updater = _await;

    _future().then((newData) {
      data = newData;
      // switch to the parent update method
      _updater = super.update;
      // trigger an update in this class to evaluate the parent update
      update();
    });

    return Status.running;
  }
}
*/