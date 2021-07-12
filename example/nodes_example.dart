import 'dart:math';
import 'package:oagnodes/oagnodes.dart';

void main() {
  subjectDataObserverExample1();
  // subjectDataObserverExample2();
  // evaluatorExample();
  // dataNodeExample();
  // closureExample();
  // identityExample();
  // selectorExample();
  // sequenceExample();
}

// A reference to an int
class IntReference {
  int value;
  IntReference(this.value);
}

/// Increments a [IntReference] by the `step` value.
class IncrementIntReference extends DataNode<IntReference> {
  final int step;
  IncrementIntReference(this.step, IntReference data) : super(data);

  @override
  Status update() {
    data.value += step;
    return Status.success;
  }
}

/// Two state machine states
enum State { add, subtract }

/// Define a state machine that increments to a number
/// divisible by 7 and then subtracts until the number is
/// less than < -17
StateMachine<State> makeIncrementStateMachine() {
  final random = Random();

  final ref = IntReference(1);

  final stateMachine = StateMachine(State.values);
  stateMachine.define(
    State.add, // increment by 1, 2 or 3
    update: IncrementIntReference(random.nextInt(3) + 1, ref),
  );
  // subtract state modifies ref value by subtracting 2
  stateMachine.define(
    State.subtract, // decrement by -2 or -1
    update: IncrementIntReference(-random.nextInt(2) - 1, ref),
  );

  // transition from add to subtract when
  // ref.value is divisible by 7
  stateMachine.transition(
    from: State.add,
    to: State.subtract,
    on: Closure(() {
      if (ref.value % 7 == 0) {
        print('add -> subtract @ value = ${ref.value}');
        return Status.success;
      } else {
        return Status.failure;
      }
    }),
  );

  // transition from subtract to add when
  // ref.value is less than -17; ref.value < -17
  stateMachine.transition(
    from: State.subtract,
    to: State.add,
    on: Closure(() {
      if (ref.value < -17) {
        print('subtract -> add @ value = ${ref.value}');
        return Status.success;
      } else {
        return Status.failure;
      }
    }),
  );

  return stateMachine;
}

class UpdateStateMachine<TEnum> extends DataNode<StateMachine<TEnum>> {
  UpdateStateMachine(StateMachine<TEnum> data) : super(data);

  @override
  Status update() => data.update();
}

void subjectDataObserverExample1() {
  final machine = makeIncrementStateMachine();

  // the subject notifies its observer every time the state
  // machine is updated
  final subject = DataSubject(
    UpdateStateMachine(machine),
    // notify observers when the state machine returns
    // Status.success or Status.running
    notifications: [Status.success, Status.running],
  );

  // increments its data any time it receives a notification
  // from the observed subject.
  final countObserver = DataObserver<IntReference, StateMachine<State>>(
    data: IntReference(0),
    updater: (data, otherData) {
      print('counter: ${++data.value} @ ${otherData.current.toString()}');
    },
  );

  // any time this observer is notified, it updates its
  // notifying subject if its state has not changed;
  // this is similar to a white loop
  final observer = SingleDataObserver<StateMachine<State>>(
    data: machine,
    // will only request a subject update if the state
    // is not the subtract state
    comparer: (machine, _) => machine.current != State.subtract,
    updater: (data, otherData) => subject.update(),
  );

  // the count observer subscribes first
  subject.subscribe(countObserver);

  // the subject updating observer subscribes second because
  // it calls the subject's update method until it switches
  // states; by calling that update method every time, only the
  // first observer is updated, so this is placed last in order
  // to ensure that all observers are first notified before the
  // subject is updated again
  subject.subscribe(observer);

  subject.update();
}

void subjectDataObserverExample2() {
  // data to be observed; int reference starting at 0
  final ref = IntReference(0);

  // add 1 to the value of the IntReference
  final addOneToIntRef = IncrementIntReference(1, ref);

  // subject.update() will call addToIntRef.update() and notify its
  // subscribed observers if addToIntRef.update() returns Status.success
  final subject = DataSubject(addOneToIntRef);

  // observe changes to an IntRef and compare and assign from an IntRef
  final observer = SingleDataObserver<IntReference>(
    // the observer's initial data is another instance of the
    // the subject's data type IntReference
    data: IntReference(-1),
    // comparison mechanics:
    // trigger assignment when a.value != b.value
    // a.value is the the observer's local data
    // b.value is the subject's local data
    comparer: (data, subjectData) => data.value != subjectData.value,
    // assignment mechanics:
    // copy the value of b.value into a.value
    // print out the value of the observer's value
    updater: (data, subjectData) {
      data.value = subjectData.value;
      print('data value is ${data.value}');
    },
  );

  // observer subscribes to notifications of subject
  subject.subscribe(observer);

  assert(observer.data.value != subject.data.value);

  // emits notification to observers if the contained node
  // returns Status.success
  subject.update();

  // the comparer verified that ref.value != observer.data.value
  // and then assigned the subject's data to the observer's data
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
  final incrementByOne = makeClosure(() => ++x);

  final selector = Selector(
    [
      // the first selector node is evaluated; it is a sequence node
      Sequence([
        // the first sequence node is evaluated: is x even?
        isEven,
        // if it is, the second sequence node is evaluated: print a statement
        makeClosure(() => print('selector node 1: x == $x; even')),
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
  var incrementByOne = makeClosure(() => ++x);
  var incrementByTwo = makeClosure(() => x += 2);
  var incrementByThree = makeClosure(() => x += 3);
  var reset = makeClosure(() => x = 0);

  // evaluate nodes depending on the success of the
  // previous node
  final sequence = Sequence([
    // increment by 1 and return Status.success
    incrementByOne,
    // increment by 2 and return Status.success
    incrementByTwo,
    // increment by 3 and return Status.success
    incrementByThree,
    makeClosure(() => print('value of x = $x')),
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

  final increment = IncrementIntReference(1, intRef);
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
