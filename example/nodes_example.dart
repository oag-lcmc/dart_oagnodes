import 'dart:math';
import 'package:oagnodes/oagnodes.dart';

void main() {
  //futureSubjectExample();
  // subjectObserverExample();
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
    print('increment by $step');
    data.value += step;
    return Status.success;
  }
}

/*
void futureSubjectExample() {
  final random = Random();
  final futureSubject = FutureSubject<IntReference>(
    // simulated ansynchronous operation returning data
    future: () async {
      await Future<void>.delayed(const Duration(seconds: 2));
      return IntReference(random.nextInt(3));
    },
  );

  // this observer will keep requesting new data from
  // its subscribed subject until it meets the > 10 criteria
  final observer = SingleDataObserver<IntReference>(
    data: IntReference(0),
    updater: (data, newData) {
      print('newData: ${newData.value}');
      data.value += newData.value;
      if (data.value < 10) {
        futureSubject.reset();
        futureSubject.update();
        print('data: ${data.value}');
      }
    },
  );

  futureSubject.subscribe(observer);
  futureSubject.update();
}
*/
/// Two state machine states
enum State { add, subtract }

class StateMachineSwitchObserver extends DataObserver<> {
  
}

void subjectDataObserverExample() {

}

/// Define a state machine that increments to a number
/// divisible by 7 and then subtracts until the number is
/// less than < -17. A [Subject] that updates the state
/// machine is returned.
Subject makeStateMachineSwitchSubject() {
  final machine = StateMachine(State.values);

  // the current state of the state machine
  var state = machine.current;

  final subject = Subject(
    Closure(() {
      // capture data and update it
      machine.update();

      // notifier checks if the state machine
      // has switched states
      if (machine.current != state) {
        state = machine.current;
        // returning Status.success from the notifier
        // will trigger a notification to observers
        return Status.success;
      } else {
        return Status.failure;
      }
    }),
  );

  final random = Random();
  final ref = IntReference(1);

  machine.define(
    State.add, // increment by 1, 2 or 3
    update: IncrementIntReference(random.nextInt(3) + 1, ref),
  );
  // subtract state modifies ref value by subtracting 2
  machine.define(
    State.subtract, // decrement by -2 or -1
    update: IncrementIntReference(-random.nextInt(2) - 1, ref),
  );

  // transition from add to subtract when
  // ref.value is divisible by 7
  machine.transition(
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
  machine.transition(
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

  return subject;
}

void subjectObserverExample() {
  final subject = makeStateMachineSwitchSubject();

  // print the name of the new state on notification
  final observer = Observer(
    handler: (Subject subject) {
      // print a message when a notification is received
      print('observed notification');
    },
  );

  // the observer subscribes to subject notifications
  subject.subscribe(observer);

  // update until the subject until it returns Status.success,
  // this will cause one notification to be sent out
  while (subject.update() != Status.success) {}
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
