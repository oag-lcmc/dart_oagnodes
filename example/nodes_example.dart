import 'dart:math';
import 'package:oagnodes/oagnodes.dart';

void main() {
  subjectObserverExample();
  evaluatorExample();
  dataNodeExample();
  closureExample();
  identityExample();
  selectorExample();
  sequenceExample();
}

// reference to an int
class IntRef {
  int value;
  IntRef(this.value);
}

// increments contained IntRef value by 1
class AddToIntRef extends DataNode<IntRef> {
  AddToIntRef(IntRef data) : super(data);

  @override
  Status update() {
    ++data.value;
    return Status.success;
  }
}

void subjectObserverExample() {
  // data to be observed
  final ref = IntRef(0);

  // the operation that triggers a subject notification
  final addToIntRef = AddToIntRef(ref);

  // emit notifications when adding to data
  final subject = DataSubject(addToIntRef);

  final observer = AutoDataObserver<IntRef, IntRef>(
    // initialData must refer to a different instance than the subject
    // data instance
    initialData: IntRef(-1),
    // comparison mechanics: two IntRef instances are equal if their
    // value is equal
    comparer: (a, b) => a.value != b.value,
    // assign mechanics: update the contained data with the subject data
    assigner: (a, b) => a.value = b.value,
    // update mechanics: if the value is assigned, print it out
    updater: (data) {
      print('data value is ${data.value}');
      return Status.success;
    }, // print value when updated
  );

  subject.subscribe(observer); // observe changes of subject

  assert(ref.value != observer.data.value);

  // calls addToIntRef.update() and emits notification to observers
  subject.update();

  assert(ref.value == observer.data.value);
}

void evaluatorExample() {
  final random = Random();

  final randomSuccess0 = Closure(() {
    if (random.nextDouble() > 0.95) {
      print('rs0');
      return Status.success;
    }
    return Status.failure;
  });

  final randomSuccess1 = Closure(() {
    if (random.nextDouble() > 0.95) {
      print('rs1');
      return Status.success;
    }
    return Status.failure;
  });

  final evaluator = Sequence([
    Evaluator([
      Identity.success,
      randomSuccess0,
      randomSuccess1,
    ]),
    Print('evaluator finished'),
  ], isPartial: false);

  while (evaluator.update() != Status.success) {}
}

void selectorExample() {
  // changing the value of this variable will change the behavior of the
  // selector
  var x = 1;

  // checks if x is even; returns Status.success if it is, Status.failure if not
  final isEven = Closure(() => x % 2 == 0 ? Status.success : Status.failure);

  // increments x by 1
  final incrementByOne = makeClosure(action: () => ++x);

  final selector = Selector(
    [
      // the first selector node is evaluated; it is a sequence node
      Sequence([
        // the first sequence node is evaluated: is x even?
        isEven,
        // if it is, the second sequence node is evaluated: print a statement
        makeClosure(action: () => print('selector node 1: x == $x; even')),
      ], isPartial: false),
      // if x is not even, the second selector node is evaluated because
      // the first one failed, this node simply increments x by one
      Sequence([
        incrementByOne,
        Print('selector node 2: x == $x; odd'),
      ], isPartial: false),
    ],
    isPartial: false,
  );

  // on first iteration, x is odd, so the selector fails the first node
  // on subsequent iterations, x is even, so only the second node executes
  // this behavior is equivalent to:
  // var x = 1;
  // for (var i = 0; i != 4; ++i) {
  //   if (x % 2 == 0) {
  //     print('selector node 1: x == $x; even');
  //   } else {
  //     ++x;
  //     print('selector node 2: x == $x; odd');
  //   }
  // }
  for (var i = 0; i != 4; ++i) {
    if (selector.update() != Status.running) {
      // reset is necessary to re-evaluate the selector nodes from the beginning
      selector.reset();
    }
  }
}

void sequenceExample() {
  var x = 0;
  var incrementByOne = makeClosure(action: () => ++x);
  var incrementByTwo = makeClosure(action: () => x += 2);
  var incrementByThree = makeClosure(action: () => x += 3);
  var reset = makeClosure(action: () => x = 0);

  // evaluate nodes depending on the success of the
  // previous node
  final sequence = Sequence([
    // increment by 1 and return Status.success
    incrementByOne,
    // increment by 2 and return Status.success
    incrementByTwo,
    // increment by 3 and return Status.success
    incrementByThree,
    makeClosure(action: () => print('value of x = $x')),
    // reset x back to 0 at the end
    reset
  ], isPartial: true);

  // partial sequence will require multiple calls
  // to the update() method in order to go through
  // composite children nodes
  if (sequence.update() != Status.running) {
    sequence.reset();
  }
  assert(x == 1);

  if (sequence.update() != Status.running) {
    sequence.reset();
  }
  assert(x == 3);

  if (sequence.update() != Status.running) {
    sequence.reset();
  }
  assert(x == 6);

  if (sequence.update() != Status.running) {
    sequence.reset();
  }
}

// A class to be used as a reference to an int
class IntReference {
  int value;
  IntReference(this.value);
}

class IncrementByOne extends DataNode<IntReference> {
  IncrementByOne(IntReference data) : super(data);

  @override
  Status update() {
    // increment the int value stored by the IntReference instance by one.
    ++data.value;
    return Status.success;
  }
}

class Multiply extends DataNode<IntReference> {
  final int multiplier;
  Multiply(this.multiplier, IntReference data) : super(data);

  @override
  Status update() {
    // multiply the int value stored by the IntReference instance by the
    // specified multiplier argument
    data.value *= multiplier;
    return Status.success;
  }
}

void dataNodeExample() {
  final intRef = IntReference(0);
  assert(intRef.value == 0);

  final increment = IncrementByOne(intRef);
  increment.update();
  increment.update();
  assert(intRef.value == 2);

  final multiply = Multiply(2, intRef);
  multiply.update();
  assert(intRef.value == 4);
}

void closureExample() {
  var x = 0;

  final closure = Closure(() {
    // captured from local scope
    return ++x % 2 == 0 ? Status.success : Status.failure;
  });

  assert(closure.update() == Status.failure);
  assert(closure.update() == Status.success);
  assert(closure.update() == Status.failure);
}

void identityExample() {
  final success = const Identity(Status.success);
  // always returns the specified Status
  assert(success.update() == Status.success);
  assert(success.update() == Status.success);

  final otherSuccess = Identity(Status.success);
  // two instances with the same Status compare as equal
  assert(success == otherSuccess);
  assert(success.update() == otherSuccess.update());
}

/*
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
*/
