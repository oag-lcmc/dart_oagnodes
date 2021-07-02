part of nodes;

typedef _SequenceFunction = Status Function(Sequence);

/// A [Sequence] evaluates its composite nodes sequentially expecting all of
/// them to return `Status.success`, in which case the [Selector] returns
/// `Status.success`.
///
/// If one of the children nodes returns `Status.failure`, the [Sequence]
/// returns `Status.failure`. If none of composite children [Node] instances
/// return `Status.success`, the [Sequence] will return `Status.failure`.
///
/// This behavior is similar to an AND statement where the children nodes
/// are the conditions of a boolean expression.
///
/// Example:
///
/// ```
/// void sequenceExample() {
///   var x = 0;
///   final incrementByOne = makeClosure(action: () => ++x);
///   final incrementByTwo = makeClosure(action: () => x += 2);
///   final incrementByThree = makeClosure(action: () => x += 3);
///   final reset = makeClosure(action: () => x = 0);
///
///   // evaluate nodes depending on the success of the
///   // previous node
///   final sequence = Sequence([
///     // increment by 1 and return Status.success
///     incrementByOne,
///     // increment by 2 and return Status.success
///     incrementByTwo,
///     // increment by 3 and return Status.success
///     incrementByThree,
///     makeClosure(action: () => print('value of x = $x')),
///     // reset x back to 0 at the end
///     reset
///   ], isPartial: true);
///
///   // partial sequence will require multiple calls
///   // to the update() method in order to go through
///   // composite children nodes
///   if (sequence.update() != Status.running) {
///     sequence.reset();
///   }
///   assert(x == 1);
///
///   if (sequence.update() != Status.running) {
///     sequence.reset();
///   }
///   assert(x == 3);
///
///   if (sequence.update() != Status.running) {
///     sequence.reset();
///   }
///   assert(x == 6);
///
///   // executes the last node which prints the value of x
///   if (sequence.update() != Status.running) {
///     sequence.reset();
///   }
/// }
/// ```
class Sequence extends Composite {
  final _SequenceFunction _updateImplementation;

  /// Constructs a [Sequence] instance.
  ///
  /// - `nodes` are the composite children nodes to be evaluated.
  /// - `isPartial` indicates whether the [Selector] instance should evaluate
  /// all of its composite children [Node] instances in one update cycle or
  /// sequentially with multiple calls to the `update()` method.
  ///   1. `true`: Evaluate one child node per update cycle.
  ///   2. `false`: Evaluate all children nodes in one update cycle.
  ///
  /// Note: Multiple calls to the `update()` method are required in either case
  /// if the currently evaluated child [Node] returns `Status.running`.
  Sequence(final List<Node> nodes, {required final bool isPartial})
      : _updateImplementation = isPartial ? Sequence._partial : Sequence._full,
        super(nodes);

  @override
  Status update() => _updateImplementation(this);

  /// The partial evaluation of a [Sequence] will update the [Node]
  /// corresponding to `_index` in the composite [List] and return a
  /// corresponding [Status].
  static final _SequenceFunction _partial = (final sequence) {
    // if the [Sequence] has evaluated all of its children nodes and none have
    // returned `Status.failure`, the [Selector] returns `Status.success`. In
    // order to have reached this point, every previous child [Node] instance
    // must have returned `Status.success`.
    if (sequence._index == sequence._nodes.length) {
      return Status.success;
    }

    final status = sequence._nodes[sequence._index].update();

    // the current child evaluates to `Status.failure`, the partial [Sequence]
    // returns `Status.failure` because it cannot satisfy the requirement that
    // all children [Node] instances must return `Status.success` (AND)
    if (status == Status.failure) {
      return Status.failure;
    }

    // the current child evaluates to `Status.success`, the partial [Sequence]
    // increments `_index`
    if (status == Status.success) {
      ++sequence._index;
    }

    // the partial [Sequence] returns `Status.running` if the current child
    // returns `Status.running` or `Status.success`; it must evaluate the
    // current and remaining children in the next update cycle
    return Status.running;
  };

  /// The full evaluation of a [Sequence] will update all of the children [Node]
  /// instances in the composite [List] and return a corresponding [Status].
  static final _SequenceFunction _full = (final sequence) {
    while (sequence._index != sequence._nodes.length) {
      final status = sequence._nodes[sequence._index].update();

      // the child returned `Status.failure`, the full [Sequence] returns
      // [Status.failure]; does not satisfy the logical AND requirement
      if (status == Status.failure) {
        return Status.failure;
      }

      // the child returned `Status.running`, the full [Sequence] returns
      // [Status.running] and waits for the next call to the `update()` method
      // to continue evaluating the current and remaining composite nodes
      if (status == Status.running) {
        return Status.running;
      }

      // the child returned `Status.success`, the full [Sequence] increments
      // `_index` and loops again to continue evaluating children nodes
      ++sequence._index;
    }

    // all children nodes were evaluated and none returned `Status.failure`, the
    // full [Selector] returns `Status.success` as it satisfies the logical AND
    // requirement
    return Status.success;
  };
}
