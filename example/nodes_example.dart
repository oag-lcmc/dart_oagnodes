import 'dart:math';
import 'package:oagnodes/oagnodes.dart';

void main() {
  final counter = Counter(1);
  final incrementer = RandomIncrementer(upperBound: 59);
  final sm = StateMachine(CounterState.values);

  final counterIncrementer = IncrementCounter(counter, incrementer);

  // the add state repeatedly calls `counterIncrementer`.
  sm.define(
    CounterState.add,
    update: Sequence(
      [
        counterIncrementer,
        makeClosure(action: () => print('counter.value = ${counter.value}'))
      ],
      isPartial: false,
    ),
    enter: makeClosure(
        action: () =>
            print('ENTER ${CounterState.add} @ counter = ${counter.value}')),
    exit: makeClosure(
        action: () =>
            print('EXIT ${CounterState.add} @ counter = ${counter.value}')),
  );

  // the subtract state repeatedly calls `counterIncrementer`.
  sm.define(
    CounterState.subtract,
    update: Sequence(
      [
        counterIncrementer,
        makeClosure(action: () => print('counter.value = ${counter.value}'))
      ],
      isPartial: false,
    ),
    enter: makeClosure(
        action: () => print(
            'ENTER ${CounterState.subtract} @ counter = ${counter.value}')),
    exit: makeClosure(
        action: () => print(
            'EXIT ${CounterState.subtract} @ counter = ${counter.value}')),
  );

  /// define a transition from the add state to the subtract state
  /// condition is `counter.value >= 512`
  sm.transition(
    from: CounterState.add,
    to: CounterState.subtract,
    on: Closure(() => counter.value > 512 ? Status.success : Status.failure),
  );

  const interval = 5;
  final intervalMonitor = DurationMonitor(
    counterIncrementer,
    interval: interval,
    expecting: Status.success,
    waiting: Status.failure,
  );

  /// define a transition from the subtract state to the add state
  /// condition is `counter.value <= 0 || `or the state machine has been in the add state
  /// for at least `interval` milliseconds.
  /// the subtract continually decrements the counter.value in every
  /// call to `update()`.
  sm.transition(
    from: CounterState.subtract,
    to: CounterState.add,
    on: Selector(
      [
        Sequence([intervalMonitor, Print('transitioned due to time')],
            isPartial: false),
        Closure(() => counter.value <= 0 ? Status.success : Status.failure),
      ],
      isPartial: true,
    ),
  );

  // set the current state machine state
  sm.set(to: CounterState.add);

  // get the current state of the state machine
  var previousState = sm.current;

  // update until state switch occurs
  while (sm.current == previousState) {
    sm.update();
  }

  previousState = sm.current;

  // update until state switch occurs
  while (sm.current == previousState) {
    sm.update();
  }
}

/// Two state machine states for [Counter] instances: adding and subtracting
enum CounterState { add, subtract }

/// Simple data structure to pass `value` around different nodes/states.
class Counter {
  int value;

  Counter(final this.value);
}

/// Base class/interface for a class that returns some integer value.
abstract class Incrementer {
  int getValue();
}

/// Concrete implementation of [Incrementer] that returns a random
/// positive or negative integer from the `getValue()` method up to
/// the argument `upperBound` (exclusive).
class RandomIncrementer implements Incrementer {
  final Random _random = Random();
  final int _upperBound;

  RandomIncrementer({required int upperBound}) : _upperBound = upperBound;

  @override
  int getValue() => _random.nextBool()
      ? _random.nextInt(_upperBound)
      : -_random.nextInt(_upperBound);
}

/// Concrete [DataNode] subclass that computes on an instance of the [Counter]
/// class using a dependency injected [Incrementer] instance.
///
/// A call to the `update()` method of this [Node] subtype will add to the
/// `value` data member of its [Counter] instance.
class IncrementCounter extends DataNode<Counter> {
  final Incrementer _incrementer;

  IncrementCounter(Counter data, this._incrementer) : super(data);

  @override
  Status update() {
    data.value += _incrementer.getValue();
    return Status.success;
  }
}
