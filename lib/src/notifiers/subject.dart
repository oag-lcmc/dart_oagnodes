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

/// The [Subject] class has `notifier` [Node] and a `notifications` [List]. The
/// `notifier` is updated and if its [Status] is part of `notifications`, the
/// [Subject] notifies any subscribed [Observer].
///
/// Example:
///
/// ```
/// /// Two state machine states
/// enum State { add, subtract }
///
/// /// Define a state machine that increments to a number
/// /// divisible by 7 and then subtracts until the number is
/// /// less than < -17. A [Subject] that updates the state
/// /// machine is returned.
/// Subject makeStateMachineSwitchSubject() {
///   final machine = StateMachine(State.values);
///
///   // the current state of the state machine
///   var state = machine.current;
///
///   final subject = Subject(
///     Closure(() {
///       // capture data and update it
///       machine.update();
///
///       // notifier checks if the state machine
///       // has switched states
///       if (machine.current != state) {
///         state = machine.current;
///         // returning Status.success from the notifier
///         // will trigger a notification to observers
///         return Status.success;
///       } else {
///         return Status.failure;
///       }
///     }),
///   );
///
///   final random = Random();
///   final ref = IntReference(1);
///
///   machine.define(
///     State.add, // increment by 1, 2 or 3
///     update: IncrementIntReference(random.nextInt(3) + 1, ref),
///   );
///   // subtract state modifies ref value by subtracting 2
///   machine.define(
///     State.subtract, // decrement by -2 or -1
///     update: IncrementIntReference(-random.nextInt(2) - 1, ref),
///   );
///
///   // transition from add to subtract when
///   // ref.value is divisible by 7
///   machine.transition(
///     from: State.add,
///     to: State.subtract,
///     on: Closure(() {
///       if (ref.value % 7 == 0) {
///         print('add -> subtract @ value = ${ref.value}');
///         return Status.success;
///       } else {
///         return Status.failure;
///       }
///     }),
///   );
///
///   // transition from subtract to add when
///   // ref.value is less than -17; ref.value < -17
///   machine.transition(
///     from: State.subtract,
///     to: State.add,
///     on: Closure(() {
///       if (ref.value < -17) {
///         print('subtract -> add @ value = ${ref.value}');
///         return Status.success;
///       } else {
///         return Status.failure;
///       }
///     }),
///   );
///
///   return subject;
/// }
///
/// void subjectObserverExample() {
///   final subject = makeStateMachineSwitchSubject();
///
///   final observer = Observer(
///     handler: (Subject subject) {
///       // print a message when a notification is received
///       print('observed notification');
///     },
///   );
///
///   // the observer subscribes to subject notifications
///   subject.subscribe(observer);
///
///   // update until the subject until it returns Status.success,
///   // this will cause one notification to be sent out
///   while (subject.update() != Status.success) {}
/// }
/// ```
class Subject extends _SubjectBase {
  final Node notifier;
  final Status notifications;

  Subject(
    this.notifier, {
    List<Status> notifications = const [Status.success],
  }) : notifications = notifications.reduce((a, b) {
          return Status._or(a, b);
        });

  /// Resets the notification [Node].
  @override
  void reset() {
    notifier.reset();
  }

  /// Updates the notification [Node] and if the [Status] it returns is part of
  /// the [Status] notification list, the [Subject] notifies all subscribed
  /// [_ObserverBase] instances.
  @override
  Status update() {
    final status = notifier.update();

    if (status._value & notifications._value > 0) {
      notify();
    }

    return status;
  }
}
