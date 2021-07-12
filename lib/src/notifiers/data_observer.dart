part of nodes;

typedef ObserverComparison<T, U> = bool Function(T, U);
typedef ObserverUpdate<T, U> = void Function(T, U);

/// The [DataObserver] class is can subscribe to a [Subject] in order to be
/// notified by that [Subject] when its `update()` method is called. The
/// [DataObserver] will receive a notification along with a reference to the
/// [Subject] that initiated the notification.
///
/// /// The [DataObserver] is able to receive notifications from a [DataSubject]. It
/// must call the `update()` method itself or through a proxy in order to call
/// the `updater` [Function] member.
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
///     data.value += step;
///     return Status.success;
///   }
/// }
///
/// /// Two state machine states
/// enum State { add, subtract }
///
/// /// Define a state machine that increments to a number
/// /// divisible by 7 and then subtracts until the number is
/// /// less than < -17
/// StateMachine<State> makeIncrementStateMachine() {
///   final random = Random();
///
///   final ref = IntReference(1);
///
///   final stateMachine = StateMachine(State.values);
///   stateMachine.define(
///     State.add, // increment by 1, 2 or 3
///     update: IncrementIntReference(random.nextInt(3) + 1, ref),
///   );
///   // subtract state modifies ref value by subtracting 2
///   stateMachine.define(
///     State.subtract, // decrement by -2 or -1
///     update: IncrementIntReference(-random.nextInt(2) - 1, ref),
///   );
///
///   // transition from add to subtract when
///   // ref.value is divisible by 7
///   stateMachine.transition(
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
///   stateMachine.transition(
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
///   return stateMachine;
/// }
///
/// class UpdateStateMachine<TEnum> extends DataNode<StateMachine<TEnum>> {
///   UpdateStateMachine(StateMachine<TEnum> data) : super(data);
///
///   @override
///   Status update() => data.update();
/// }
///
/// void subjectDataObserverExample() {
///   final machine = makeIncrementStateMachine();
///
///   // the subject notifies its observer every time the state
///   // machine is updated
///   final subject = DataSubject(
///     UpdateStateMachine(machine),
///     // notify observers when the state machine returns
///     // Status.success or Status.running
///     notifications: [Status.success, Status.running],
///   );
///
///   // increments its data any time it receives a notification
///   // from the observed subject.
///   final countObserver = DataObserver<IntReference, StateMachine<State>>(
///     data: IntReference(0),
///     updater: (data, otherData) {
///       print('counter: ${++data.value} @ ${otherData.current.toString()}');
///     },
///   );
///
///   // any time this observer is notified, it updates its
///   // notifying subject if its state has not changed;
///   // this is similar to a white loop
///   final observer = SingleDataObserver<StateMachine<State>>(
///     data: machine,
///     // will only request a subject update if the state
///     // is not the subtract state
///     comparer: (machine, _) => machine.current != State.subtract,
///     updater: (data, otherData) => subject.update(),
///   );
///
///   // the count observer subscribes first
///   subject.subscribe(countObserver);
///
///   // the subject updating observer subscribes second because
///   // it calls the subject's update method until it switches
///   // states; by calling that update method every time, only the
///   // first observer is updated, so this is placed last in order
///   // to ensure that all observers are first notified before the
///   // subject is updated again
///   subject.subscribe(observer);
///
///   subject.update();
/// }
/// ```
class DataObserver<T, U> extends Observer {
  /// The previous data to be compared to the new data from a notification.
  final T data;

  /// Performs some operation on the data of this [DataObserver] and returns a
  /// [Status] indicating the results of the operation.
  final ObserverUpdate<T, U> updater;

  /// Determines whether the observed `data` has changed by comparing it to
  /// the `data` it receives from a [DataSubject] notification.
  final ObserverComparison<T, U> comparer;

  /// Constructs a [DataObserver] that can subscribe to some [Subject].
  ///
  /// Arguments:
  /// - `data` is the initial value of the [Observer] data that will be
  /// compared to the first [DataSubject] notification's data. It can be
  /// assigned to; be sure that the `comparer` [Function] properly accounts for
  /// same reference instances.
  /// - `updater` takes the `data` members of the [DataObserver] and the
  /// notifying [Subject] to respond to the notification.
  /// - `comparer` is a [Function] that returns a `bool` by comparing the
  /// `data` members of the [DataObserver] and [DataSubject] notification in
  /// order to determine whether to call the `updater` [Function].
  DataObserver({
    required final this.data,
    required final this.updater,
    final ObserverComparison<T, U>? comparer,
  }) : comparer = comparer ?? ((_, __) => true);

  /// Receives a notification from the argument [Subject] and if the `comparer`
  /// [Function] returns `true`, the [DataUpdater] forwards `data` and the
  /// `data` of the notifying [Subject] into a call to its `updater` [Function].
  @override
  void receive(DataSubject<U> subject) {
    if (comparer(data, subject.data)) {
      updater(data, subject.data);
    }
  }
}

/// Convenience alias for a [DataObserver] that operates and receives the same
/// data type.
typedef SingleDataObserver<T> = DataObserver<T, T>;
