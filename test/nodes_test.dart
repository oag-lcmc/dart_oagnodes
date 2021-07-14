import 'dart:io';
import 'dart:math';
import 'package:oagnodes/oagnodes.dart';
import 'package:test/test.dart';

final random = Random();

void main() {
  group('Basic node test', () {
    const success = Identity(Status.success);

    test('Identity test', () {
      expect(success == Identity.success, isTrue);
      expect(success.hashCode == Identity.success.hashCode, isTrue);
      expect(success.update() == Status.success, isTrue);
    });

    final closure = Closure(() => Status.success);

    test('Closure test', () {
      expect(closure.update() == Status.success, isTrue);
      expect(
          Closure(() => closure.update() == Status.success
                  ? Status.running
                  : Status.failure).update() ==
              Status.running,
          isTrue);
    });
  });

  group('Decorator node test', () {
    final durationMonitor = DurationMonitor(
      Identity.success,
      interval: 150,
      expecting: Status.success,
    );

    test('Duration monitor test', () {
      expect(durationMonitor.elapsed == 0, isTrue);
      expect(durationMonitor.update() == Status.running, isTrue);

      sleep(Duration(milliseconds: 140));
      expect(durationMonitor.update() == Status.running, isTrue);
      expect(durationMonitor.elapsed != 0, isTrue);

      sleep(Duration(milliseconds: 25));
      expect(durationMonitor.update() == Status.success, isTrue);
      expect(durationMonitor.elapsed != 0, isTrue);

      durationMonitor.refresh();
      expect(durationMonitor.update() == Status.running, isTrue);
      expect(durationMonitor.elapsed == 0, isTrue);

      sleep(Duration(milliseconds: 150));
      expect(durationMonitor.update() == Status.success, isTrue);
      expect(durationMonitor.elapsed >= 150, isTrue);
    });

    test('Not test', () {
      expect(Not(Identity.failure).update() == Status.success, isTrue);
      expect(Not(Identity.success).update() == Status.failure, isTrue);
      expect(Not(Identity.running).update() == Status.running, isTrue);
    });
  });

  group('Composite node test', () {
    final partialSuccessSequence = Sequence(
      [Identity.success, Identity.success, Identity.success],
      isPartial: true,
    );

    test('Partial sequence success test', () {
      expect(partialSuccessSequence.update() == Status.running, isTrue);
      expect(partialSuccessSequence.update() == Status.running, isTrue);
      expect(partialSuccessSequence.update() == Status.running, isTrue);
      expect(partialSuccessSequence.index == partialSuccessSequence.length,
          isTrue);
      expect(partialSuccessSequence.update() == Status.success, isTrue);
      expect(partialSuccessSequence.update() == Status.success, isTrue);

      partialSuccessSequence.reset();

      expect(partialSuccessSequence.index == 0, isTrue);
      expect(partialSuccessSequence.update() == Status.running, isTrue);
      partialSuccessSequence.update();
      expect(partialSuccessSequence.index == 2, isTrue);
      partialSuccessSequence.update();
      expect(partialSuccessSequence.index == partialSuccessSequence.length,
          isTrue);
      expect(partialSuccessSequence.update() == Status.success, isTrue);
      expect(partialSuccessSequence.index == 3, isTrue);
      expect(partialSuccessSequence.update() == Status.success, isTrue);
      expect(partialSuccessSequence.index == 3, isTrue);
    });

    final fullSuccessSequence = Sequence(
      [Identity.success, Identity.success],
      isPartial: false,
    );

    test('Full sequence success test', () {
      expect(fullSuccessSequence.index != fullSuccessSequence.length, isTrue);
      expect(fullSuccessSequence.index == 0, isTrue);
      expect(fullSuccessSequence.update() == Status.success, isTrue);
      expect(fullSuccessSequence.update() == Status.success, isTrue);
      expect(fullSuccessSequence.index == 2, isTrue);
      expect(fullSuccessSequence.index == fullSuccessSequence.length, isTrue);

      fullSuccessSequence.reset();

      expect(fullSuccessSequence.index != fullSuccessSequence.length, isTrue);
      expect(fullSuccessSequence.index == 0, isTrue);
      expect(fullSuccessSequence.update() == Status.success, isTrue);
      expect(fullSuccessSequence.index == 2, isTrue);
      expect(fullSuccessSequence.index == fullSuccessSequence.length, isTrue);
    });

    final partialFailureSequence = Sequence(
      [Identity.success, Identity.failure, Identity.success],
      isPartial: true,
    );

    test('Partial sequence failure test', () {
      expect(partialFailureSequence.update() == Status.running, isTrue);
      expect(partialFailureSequence.index == 1, isTrue);
      expect(partialFailureSequence.update() == Status.failure, isTrue);
      partialFailureSequence.update();
      partialFailureSequence.update();
      expect(partialFailureSequence.index == 1, isTrue);

      partialFailureSequence.reset();

      expect(partialFailureSequence.index == 0, isTrue);
      expect(partialFailureSequence.update() == Status.running, isTrue);
      expect(partialFailureSequence.index == 1, isTrue);
      expect(partialFailureSequence.update() == Status.failure, isTrue);
    });

    final fullFailureSequence = Sequence(
      [Identity.success, Identity.success, Identity.failure],
      isPartial: false,
    );

    test('Full sequence failure test', () {
      expect(fullFailureSequence.index == 0, isTrue);
      expect(fullFailureSequence.update() == Status.failure, isTrue);
      fullFailureSequence.update();
      fullFailureSequence.update();
      expect(fullFailureSequence.index == 2, isTrue);
      expect(fullFailureSequence.index != fullFailureSequence.length, isTrue);

      fullFailureSequence.reset();
      expect(fullFailureSequence.update() == Status.failure, isTrue);
    });

    final partialSuccessSelector = Selector(
      [Identity.failure, Identity.failure, Identity.success],
      isPartial: true,
    );

    test('Partial selector success test', () {
      expect(partialSuccessSelector.index == 0, isTrue);
      expect(partialSuccessSelector.update() == Status.running, isTrue);
      expect(partialSuccessSelector.index == 1, isTrue);
      expect(partialSuccessSelector.update() == Status.running, isTrue);
      expect(partialSuccessSelector.index == 2, isTrue);
      expect(partialSuccessSelector.update() == Status.success, isTrue);
      expect(partialSuccessSelector.update() == Status.success, isTrue);
      expect(partialSuccessSelector.index == 2, isTrue);
      partialSuccessSelector.reset();
    });

    final fullSuccessSelector = Selector(
      [Identity.failure, Identity.success, Identity.failure],
      isPartial: false,
    );

    test('Full selector success test', () {
      expect(fullSuccessSelector.update() == Status.success, isTrue);
      expect(fullSuccessSelector.index == 1, isTrue);
      expect(fullSuccessSelector.index != fullSuccessSelector.length, isTrue);

      fullSuccessSelector.reset();

      expect(fullSuccessSelector.index == 0, isTrue);
    });

    final partialFailureSelector = Selector(
      [Identity.failure, Identity.failure, Identity.failure],
      isPartial: true,
    );

    test('Partial selector failure test', () {
      expect(partialFailureSelector.index == 0, isTrue);
      expect(partialFailureSelector.update() == Status.running, isTrue);
      expect(partialFailureSelector.index == 1, isTrue);
      expect(partialFailureSelector.update() == Status.running, isTrue);
      expect(partialFailureSelector.index == 2, isTrue);
      expect(partialFailureSelector.update() == Status.running, isTrue);
      expect(partialFailureSelector.update() == Status.failure, isTrue);
      expect(partialFailureSelector.index == partialFailureSelector.length,
          isTrue);
      partialFailureSelector.reset();
    });

    final fullFailureSelector = Selector(
      [Identity.failure, Identity.failure, Identity.failure],
      isPartial: false,
    );

    test('Full selector failure test', () {
      expect(fullFailureSelector.index == 0, isTrue);
      expect(fullFailureSelector.update() == Status.failure, isTrue);
      expect(fullFailureSelector.index == fullFailureSelector.length, isTrue);

      fullFailureSelector.reset();

      expect(fullFailureSelector.index == 0, isTrue);
      expect(fullFailureSelector.update() == Status.failure, isTrue);
      expect(fullFailureSelector.index == fullFailureSelector.length, isTrue);
    });

    final successEvaluator = Evaluator([
      Identity.success,
      Identity.success,
      Identity.success,
      Identity.success,
    ]);

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

    final evaluator = Sequence(
      [
        Evaluator([Identity.success, randomSuccess0, randomSuccess1]),
        Print('evaluator finished'),
      ],
      isPartial: false,
    );

    test('Evaluator test', () {
      while (successEvaluator.update() != Status.success) {}

      expect(successEvaluator.update() == Status.success, isTrue);
      expect(successEvaluator.index == successEvaluator.length - 1, isTrue);
      successEvaluator.reset();
      expect(successEvaluator.index == 0, isTrue);

      var evaluatorCounter = 0;
      for (var i = 0; i != 3; ++i) {
        while (evaluator.update() != Status.success) {
          ++evaluatorCounter;
        }

        evaluator.reset();
      }

      expect(evaluatorCounter >= 3, isTrue);
    });
  });

  group('Notifier node test', () {
    final counter = Counter(0);
    final incrementer = RandomIncrementer(upperBound: 3);
    final subject = DataSubject<Counter>(
      counter,
      builder: (data) => IncrementCounter(data, incrementer),
    );

    final observerA = SingleDataObserver<Counter>(
      data: Counter(0),
      comparer: (counter, otherCounter) {
        print('previous counter.value = ${counter.value}');
        print('notifier counter.value = ${otherCounter.value}');
        return counter.value != otherCounter.value;
      },
      updater: (lhs, rhs) {
        lhs.value = rhs.value;
        print('updated ${counter.runtimeType}: ${counter.value}');
      },
    );

    subject.subscribe(observerA);

    test('Subject tests', () {
      expect(identical(counter, observerA.data), isFalse);
      expect(counter.value == observerA.data.value, isTrue);
      subject.update();
      expect(identical(counter, observerA.data), isFalse);
      expect(counter.value == observerA.data.value, isTrue);
    });
  });

  group('State machine test', () {
    final counter = Counter(1);
    final incrementer = RandomIncrementer(upperBound: 13);
    final sm = StateMachine(CounterState.values);

    sm.define(
      CounterState.add,
      update: IncrementCounter(counter, incrementer),
      enter: makeClosure(() =>
          print('ENTER ${CounterState.add} @ counter = ${counter.value}')),
      exit: makeClosure(
          () => print('EXIT ${CounterState.add} @ counter = ${counter.value}')),
      isPartial: true,
    );

    sm.define(
      CounterState.subtract,
      update: IncrementCounter(counter, incrementer),
      enter: makeClosure(() =>
          print('ENTER ${CounterState.subtract} @ counter = ${counter.value}')),
      exit: makeClosure(() =>
          print('EXIT ${CounterState.subtract} @ counter = ${counter.value}')),
      isPartial: true,
    );

    sm.transition(
      from: CounterState.add,
      to: CounterState.subtract,
      on: Closure(() => counter.value > 16 ? Status.success : Status.failure),
    );

    sm.transition(
      from: CounterState.subtract,
      to: CounterState.add,
      on: Closure(() => counter.value <= 0 ? Status.success : Status.failure),
    );

    sm.set(to: CounterState.add);

    test('State machine transition tests', () {
      expect(sm.current == CounterState.add, isTrue);

      var previous = sm.current;

      while (sm.current == previous) {
        expect(sm.update() == Status.running, isTrue);
      }

      expect(sm.current != previous, isTrue);
      expect(sm.current == CounterState.subtract, isTrue);

      previous = sm.current;

      while (sm.current == previous) {
        expect(sm.update() == Status.running, isTrue);
      }

      expect(sm.current != previous, isTrue);
      expect(sm.current == CounterState.add, isTrue);

      for (var i = 0; i != 2; i++) {
        previous = sm.current;

        while (sm.current == previous) {
          expect(sm.update() == Status.running, isTrue);
        }

        expect(sm.current != previous, isTrue);
      }
    });
  });
}

enum CounterState { add, subtract }

class Counter {
  int value;

  Counter(final this.value);
}

abstract class Incrementer {
  int getValue();
}

class RandomIncrementer implements Incrementer {
  final Random _random = Random();
  final int _upperBound;

  RandomIncrementer({required int upperBound}) : _upperBound = upperBound;

  @override
  int getValue() => _random.nextBool()
      ? _random.nextInt(_upperBound)
      : -_random.nextInt(_upperBound);
}

class IncrementCounter extends DataNode<Counter> {
  final Incrementer _incrementer;

  IncrementCounter(Counter data, this._incrementer) : super(data);

  @override
  Status update() {
    data.value += _incrementer.getValue();
    return Status.success;
  }
}
