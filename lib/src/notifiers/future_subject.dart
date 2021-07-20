part of nodes;

/// A [FutureSubject] takes a [Function] returning a [Future] of argument type
/// `T`. The [FutureSubject] will call the argument future and use the result to
/// build a [DataNode] using the argument `builder` [Function]. The built
/// [DataNode] is then used as the `notifier` of the [FutureSubject].
///
/// Example:
///
/// ```
/// // A reference to an int
/// class IntReference {
///   int value;
///   IntReference(this.value);
/// }
///
/// /// Increments a [IntReference] by the `step` value.
/// class IncrementIntReference extends DataNode<IntReference> {
///   final int step;
///   IncrementIntReference(this.step, IntReference data) : super(data);
///
///   @override
///   Status update() {
///     print('increment by $step');
///     data.value += step;
///     return Status.success;
///   }
/// }
///
/// void futureSubjectExample() {
///   // keep a scopy reference for testing purposes
///   final intReference = IntReference(0);
///
///   final futureSubject = FutureSubject<IntReference>(
///     future: () async {
///       // simulate some future based operation
///       print('calling future');
///       await Future<void>.delayed(const Duration(seconds: 2));
///       // return a value from the future
///       return intReference;
///     },
///     // builds a DataNode using the result of the future
///     builder: (data) {
///       return IncrementIntReference(5, data);
///     },
///   );
///
///   final observer = Observer(handler: (subject) {
///     print('notified by future subject: ${intReference.value}');
///   });
///
///   futureSubject.subscribe(observer);
///
///   // calls the future function and notifies the
///   // observer using the built DataNode when the
///   // future completes
///   futureSubject.update();
/// }
/// ```
class FutureSubject<T> extends Subject {
  /// Future to be called by `_updater` before a result has been received.
  final Future<T> Function() _future;

  /// Builds a [DataNode] when the future completes using the value returned
  /// by the future.
  final DataNode<T> Function(T) _builder;

  static final Status Function() _updaterPlaceholder = () {
    return Status.failure;
  };

  Status Function() _updater;

  /// Constructs a [FutureSubject] instance.
  ///
  /// - `future` returns some data of type `T` to be used by the `builder`.
  /// - `builder` builds a [DataNode] operation constructed from the return
  /// value of the `future`; the [DataNode] becomes the `notifier` of the
  /// [FutureSubject] when built.
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
        _updater = _updaterPlaceholder,
        super(Identity.failure) {
    _updater = _await;
  }

  /// Schedules the future to be called and the `notifier` [DataNode] to be
  /// rebuilt using the result of the future.
  void rebuild() {
    _updater = _await;
  }

  /// Calls the future and once a result is available the contained data is
  /// updated and the [FutureSubject] is updated as if it were a
  /// [DataSubject].
  @override
  Status update() {
    return _updater();
  }

  /// Calls the future. Builds a [DataNode] using the result of the future and
  /// then uses the built [DataNode] as the `notifier` of this [FutureSubject]
  /// in a call to the `update()` method.
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
