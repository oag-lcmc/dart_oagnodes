part of nodes;

/// Abstract base class for all [_ObserverBase] types. Provides an interface to
/// receive notifications from a [_SubjectBase] through the `receive(subject)`
/// method. The received [_SubjectBase] is covariant in order to handle
/// reception of different [_SubjectBase] types in concrete [_ObserverBase]
/// implementations.
abstract class _ObserverBase {
  const _ObserverBase();

  /// The `receive(subject)` method is called by a [_SubjectBase] when it
  /// decides to notity a subscribed [_ObserverBase]. The [_SubjectBase] itself
  /// passes itself as the argument to this method.
  void receive(covariant _SubjectBase subject);
}

typedef ObserverHandler<T> = void Function(T);

/// The [Observer] class can subscribe to one or more [Subject] instances. It
/// uses its argument `handler` [Function] in its `receive(subject)` method in
/// order to handle any notifications.
class Observer<T extends Subject> extends _ObserverBase {
  /// Handles [Subject] notifications.
  ObserverHandler<T> handler;

  /// Construct an [Observer] with a handler for any notifying [Subject].
  ///
  /// - `handler` is a [Function] called when a [Subject] notifies this
  /// [Observer]; the notifying [Subject] is passed as an argument.
  Observer({required final this.handler});

  /// Calls `handler` and passes the notifying [Subject].
  @override
  void receive(final T subject) {
    handler(subject);
  }
}
