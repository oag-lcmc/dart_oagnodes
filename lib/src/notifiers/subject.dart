part of nodes;

/// A [Subject] takes in a [Node] and notifies its [Observer] list when the
/// decorated [Node] updates to `Status.success`. Implementations of [Observer]
/// will handle notifications.
///
/// The [Subject] itself is passed covariantly to the [Observer] list so that
/// different concrete [Observer] types can handle different concrete [Subject]
/// types as desired.
///
/// Example:
///
/// ```
/// // reference to an int
/// class IntRef {
///   int value;
///   IntRef(this.value);
/// }
///
// increments contained IntRef value by 1
/// class AddToIntRef extends DataNode<IntRef> {
///   AddToIntRef(IntRef data) : super(data);
///
///   @override
///   Status update() {
///     ++data.value;
///     return Status.success;
///   }
/// }
///
/// void subjectObserverExample() {
///   // data to be observed
///   final ref = IntRef(0);
///
///   // the operation that triggers a subject notification
///   final addToIntRef = AddToIntRef(ref);
///
///   // emit notifications when adding to data
///   final subject = DataSubject(addToIntRef);
///
///   final observer = AutoDataObserver<IntRef, IntRef>(
///     // initialData must refer to a different instance
///     // than the subject data instance
///     initialData: IntRef(-1),
///     // comparison mechanics: two IntRef instances are
///     // equal if their value is equal, emit notifications
///     // when their values are different
///     comparer: (a, b) => a.value != b.value,
///     // assign mechanics: update the contained data
///     // with the subject data
///     assigner: (a, b) => a.value = b.value,
///     // update mechanics: if the value is assigned, print it out
///     updater: (data) {
///       print('data value is ${data.value}');
///       return Status.success;
///     },
///   );
///
///   subject.subscribe(observer); // observe changes of subject
///
///   assert(ref.value != observer.data.value);
///
///   // calls addToIntRef.update() and emits notification
///   // to observers
///   subject.update();
///
///   assert(ref.value == observer.data.value);
/// }
/// ```
abstract class Subject extends Node {
  final Node _subject;
  final List<Observer> _observers;

  Subject(this._subject) : _observers = List.empty(growable: true);

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

  @override
  void reset() => _subject.reset();

  @override
  Status update() {
    final status = _subject.update();

    if (status == Status.success) {
      notify();
    }

    return status;
  }
}

/// A [DataSubject] has some `data`.
class DataSubject<T> extends Subject {
  final T data;

  /// Construct a [DataSubject] with some `data`. The `data` is accessible
  /// because concrete this instance passes itself to a matching [DataObserver]
  /// whose `receive(subject)` method takes in a [DataSubject].
  DataSubject(DataNode<T> subject)
      : data = subject.data,
        super(subject);
}
