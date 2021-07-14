part of nodes;

/// Abstract base class for all [_SubjectBase] types. The [_SubjectBase] passes itself
/// to each subscribed [Observer] in the `notify()` method so that concrete
/// [Observer] types can handle multiple subscriptions.
abstract class _SubjectBase extends Node {
  final List<Observer> _observers;

  /// Base constructor for [_SubjectBase] types.
  _SubjectBase() : _observers = List.empty(growable: true);

  /// Add an [Observer] to the notification list.
  void subscribe(Observer observer) {
    _observers.add(observer);
  }

  /// Remove an [Observer] from the notification list.
  void unsubscribe(Observer observer) {
    _observers.remove(observer);
  }

  /// Notifies each [Observer] by calling their respective `receive(subject)`
  /// method and passing `this` as the [_SubjectBase] of the notification.
  void notify() {
    for (var i = 0; i != _observers.length; ++i) {
      _observers[i].receive(this);
    }
  }
}

/// The [Subject] class has a [Status] list and a [Node]. A call to the
/// `update()` method will
class Subject extends _SubjectBase {
  final Node _node;

  Subject(this._node);

  /// Updates the
  @override
  Status update() {
    final status = _node.update();

    if (status == Status.success) {
      notify();
    }

    return status;
  }
}
