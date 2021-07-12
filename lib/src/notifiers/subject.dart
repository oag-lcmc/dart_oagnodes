part of nodes;

/// A [Subject] takes in a [Node] and notifies its [Observer] list when the
/// decorated [Node] updates to `Status.success`. Implementations of [Observer]
/// will handle notifications.
///
/// The [Subject] itself is passed covariantly to the [Observer] list so that
/// different concrete [Observer] types can handle different [Subject] type
/// subscriptions types as desired.
abstract class Subject extends Node {
  final Status _notifications;
  final Node _subject;
  final List<Observer> _observers;

  Subject(
    Node subject, {
    final List<Status> notifyStatus = const [Status.success],
  })  : _subject = subject,
        _notifications = notifyStatus.reduce((a, b) => Status._or(a, b)),
        _observers = List.empty(growable: true);

  /// Add an [Observer] to the notification list.
  void subscribe(Observer observer) {
    _observers.add(observer);
  }

  /// Remove an [Observer] from the notification list.
  void unsubscribe(Observer observer) {
    _observers.remove(observer);
  }

  /// Notifies the [Observer] list that the decorated [Node] has been modified.
  /// This method can be called before the `update()` method is called and/or
  /// before verifying that the decorated [Node] updates to `Status.success`.
  ///
  /// Note: it is usually not a good idea to call this manually and let the
  /// `update()` method call the `notify()` method when it determines that it
  /// should.
  void notify() {
    for (var i = 0; i != _observers.length; ++i) {
      _observers[i].receive(this);
    }
  }

  /// Reset the `_subject` [Node] of this instance.
  @override
  void reset() => _subject.reset();

  /// Updates the contained [Node] and notifies all subscribed observers if
  /// the resulting [Status] of the contained [Node] is `Status.success`. The
  /// resulting [Status] is returned by this method in all scenarios.
  @override
  Status update() {
    print('subject update');
    final status = _subject.update();

    if (_notifications._value & status._value > 0) {
      notify();
    }

    return status;
  }
}

/// A [DataSubject] has some `data` that can be passed along to [DataObserver]
/// types that are subscribed to the [DataSubject].
class DataSubject<T> extends Subject {
  T data;

  /// Construct a [DataSubject] with some `data`. The `data` is accessible
  /// because concrete this instance passes itself to a matching [DataObserver]
  /// whose `receive(subject)` method takes in a [DataSubject].
  DataSubject(
    DataNode<T> subject, {
    final List<Status> notifications = const [Status.success],
  })  : data = subject.data,
        super(subject, notifyStatus: notifications);
}
