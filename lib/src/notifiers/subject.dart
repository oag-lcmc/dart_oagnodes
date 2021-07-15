part of nodes;

/// Abstract base class for all [_SubjectBase] types. The [_SubjectBase] passes
/// itself to each subscribed [_ObserverBase] in the `notify()` method so that
/// concrete [_ObserverBase] types can handle multiple subscriptions.
abstract class _SubjectBase extends Node {
  final List<_ObserverBase> _observers;

  /// Base constructor for [_SubjectBase] types.
  _SubjectBase() : _observers = List.empty(growable: true);

  /// Add an [_ObserverBase] to the notification list.
  void subscribe(_ObserverBase observer) {
    _observers.add(observer);
  }

  /// Remove an [_ObserverBase] from the notification list.
  void unsubscribe(_ObserverBase observer) {
    _observers.remove(observer);
  }

  /// Notifies each [_ObserverBase] by calling their respective `receive(subject)`
  /// method and passing `this` as the [_SubjectBase] of the notification.
  void notify() {
    for (var i = 0; i != _observers.length; ++i) {
      _observers[i].receive(this);
    }
  }
}

/// The [Subject] class has a [Status] list and a notifier [Node]. The
/// notification [Node] is updated and its [Status] is compared to the list of
/// notification status. If the notification status is part of the list of
/// status, the [Subject] will notify all subscribed [_ObserverBase].
class Subject extends _SubjectBase {
  final Node _notifier;
  final Status _notifications;

  Subject(
    this._notifier, {
    List<Status> notifications = const [Status.success],
  }) : _notifications = notifications.reduce((a, b) {
          return Status._or(a, b);
        });

  /// Resets the notification [Node].
  @override
  void reset() {
    _notifier.reset();
  }

  /// Updates the notification [Node] and if the [Status] it returns is part of
  /// the [Status] notification list, the [Subject] notifies all subscribed
  /// [_ObserverBase] instances.
  @override
  Status update() {
    final status = _notifier.update();

    if (status._value & _notifications._value > 0) {
      notify();
    }

    return status;
  }
}
