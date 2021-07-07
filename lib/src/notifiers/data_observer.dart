part of nodes;

/// The [DataObserver] is able to receive notifications from a [DataSubject]. It
/// must call the `update()` method itself or through a proxy in order to call
/// the `updater` [Function] member.
class DataObserver<T, U extends T> extends _DataObserverTemplate<T, U> {
  bool _hasChanged;

  /// Construct a [DataObserver] with the following parameters:
  /// - `initialData` is the initial value of the [Observer] data that will be
  /// compared to the first [DataSubject] notification's data.
  /// - `comparer` determines whether two related data instances differ in a
  /// way that should trigger an update during a call to the `update()` method.
  /// - `assigner` updates the [Observer] data using the [Subject] data.
  /// - `updater` is the action taken on the data during a call to the
  /// `update()` method if the [DataObserver] determined to that a significant
  /// change occurred.
  DataObserver({
    required T initialData,
    required _ObserverComparison<T, U> comparer,
    required _ObserverAssignation<T, U> assigner,
    required _ObserverUpdate<T> updater,
  })  : _hasChanged = false,
        super(
          initialData: initialData,
          comparer: comparer,
          assigner: assigner,
          updater: updater,
        );

  /// Indicates whether there was a relevant change in data as determined by
  /// the `comparer` [Function] instance when this [DataObserver] last
  /// received a notification.
  bool get hasChanged => _hasChanged;

  /// Receives a notification from the argument [Subject] and if the `compare`
  /// [Function] returns `true`, it sets an internal flag marking the
  /// [DataObserver] as changed. When a [DataObserver] is marked as changed, a
  /// subsequent call to the `update()` method will execute `updater(data)` and
  /// return its [Status].
  @override
  void receive(DataSubject<U> subject) {
    assert(!identical(data, subject.data));

    if (comparer(data, subject.data)) {
      assigner(data, subject.data);
      _hasChanged = true;
      // can perform pre-update operations here
    }
  }

  @override
  void reset() {
    _hasChanged = false;
  }

  @override
  Status update() {
    if (_hasChanged) {
      _hasChanged = false;
      return updater(data);
    }

    return Status.failure;
  }
}
