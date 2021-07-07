part of nodes;

/// The [AutoDataObserver] is able to receive notifications from a [DataSubject]
/// and automatically calls its `update()` method when it receives a
/// notification and its `comparer` [Function] member evaluates to `true`.
class AutoDataObserver<T, U extends T> extends _DataObserverTemplate<T, U> {
  Status _status;

  /// Constructs an [AutoDataObserver] that it will automatically call the
  /// `update()` method when the `compare` [Function] detects a change from
  /// `initialData` and the data contained by the notifying [Subject].
  /// - `initialData` is the initial value of the [Observer] data that will be
  /// compared to the first [DataSubject] notification's data.
  /// - `comparer` determines whether two related data instances differ in a
  /// way that should trigger an update during a call to the `update()` method.
  /// - `assigner` updates the [Observer] data using the [Subject] data.
  /// - `updater` is the action taken on the data during a call to the
  /// `update()` method if the [DataObserver] determined to that a change
  /// occurred.
  AutoDataObserver({
    required T initialData,
    required bool Function(T, U) comparer,
    required void Function(T, U) assigner,
    required Status Function(T) updater,
  })  : _status = Status.failure,
        super(
          initialData: initialData,
          comparer: comparer,
          assigner: assigner,
          updater: updater,
        );

  /// Receives a notification from the argument [Subject] and if
  /// `compare(data, subject.data)` returns `true`, it calls
  /// `assigner(data, subject.data)` in order to update the [AutoDataObserver]
  /// `data`. The algorithm then calls `updater(data)` and caches the return
  /// [Status]; the [Status] value is continuously returned by calls to the
  /// `update()` method until the [AutoDataObserver] receives another
  /// notification or the `reset()` method is called.
  @override
  void receive(DataSubject<U> subject) {
    assert(!identical(data, subject.data));

    if (comparer(data, subject.data)) {
      assigner(data, subject.data);
      // can perform pre-update operations here
      _status = updater(data);
    }

    _status = Status.failure;
  }

  @override
  void reset() {
    _status = Status.failure;
  }

  @override
  Status update() {
    return _status;
  }
}
