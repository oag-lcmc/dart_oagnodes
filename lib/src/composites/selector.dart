part of nodes;

typedef _SelectorFunction = Status Function(Selector);

/// A [Selector] evaluates its composite nodes sequentially expecting one of
/// them to return `Status.success`, in which case the [Selector] returns
/// `Status.success`.
///
/// If one of the children nodes returns `Status.failure`, the [Selector]
/// evaluates the next child. If none of composite children [Node] instances
/// return `Status.success`, the [Selector] will return `Status.failure`.
///
/// This behavior is similar to an OR statement where the children nodes
/// are the conditions of a boolean expression.
///
/// Example:
///
/// ```
/// void selectorExample() {
///   // changing the value of this variable will
///   // change the behavior of the selector
///   var x = 1;
///
///   // checks if x is even:
///   // returns Status.success if it is,
///   // returns Status.failure if isn't
///   final isEven = Closure(() => x % 2 == 0
///     ? Status.success
///     : Status.failure);
///
///   // increments x by 1
///   final incrementByOne = makeClosure(action: () => ++x);
///
///   final selector = Selector(
///     [
///       // the first selector node is evaluated;
///       // it is a sequence node
///       Sequence([
///         // the first sequence node is evaluated:
///         // is x even?
///         isEven,
///         // if it is, the second sequence node
///         // is evaluated: print a statement
///         makeClosure(action: () => print('selector node 1: x == $x; even')),
///       ], isPartial: false),
///       // if x is not even, the second selector node
///       // is evaluated because the first one failed,
///       // this node simply increments x by one
///       // and then prints a statement
///       Sequence([
///         incrementByOne,
///         Print('selector node 2: x == $x; odd'),
///       ], isPartial: false),
///     ],
///     isPartial: false,
///   );
///
///   // on first iteration, x is odd, so the selector
///   // fails the first node
///   // on subsequent iterations, x is even,
///   // so only the second node executes
///   // this behavior is equivalent to:
///   // var x = 1;
///   // for (var i = 0; i != 4; ++i) {
///   //   if (x % 2 == 0) {
///   //     print('selector node 1: x == $x; even');
///   //   } else {
///   //     ++x;
///   //     print('selector node 2: x == $x; odd');
///   //   }
///   // }
///   for (var i = 0; i != 4; ++i) {
///     if (selector.update() != Status.running) {
///       // reset is necessary to re-evaluate
///       // selector nodes from the beginning
///       selector.reset();
///     }
///   }
/// }
/// ```
class Selector extends Composite {
  final _SelectorFunction _updateImplementation;

  /// Constructs a [Selector] instance.
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
  Selector(final List<Node> nodes, {required final bool isPartial})
      : _updateImplementation = isPartial ? Selector._partial : Selector._full,
        super(nodes);

  @override
  Status update() => _updateImplementation(this);

  /// The partial evaluation of a [Selector] will update the [Node]
  /// corresponding to `_index` in the composite [List] and return a
  /// corresponding [Status].
  static final _SelectorFunction _partial = (final selector) {
    // if the [Selector] has evaluated all of its children nodes and none have
    // returned `Status.success`, the [Selector] returns `Status.failure`
    if (selector._index == selector._nodes.length) {
      return Status.failure;
    }

    final status = selector._nodes[selector._index].update();

    // the current child evaluates to `Status.success`, the partial [Selector]
    // returns `Status.success` because at least one child [Node] succeeded (OR)
    if (status == Status.success) {
      return Status.success;
    }

    // the current child evaluates to `Status.failure`, the partial [Selector]
    // increments `_index`
    if (status == Status.failure) {
      ++selector._index;
    }

    // the partial [Selector] returns `Status.running` if the current child
    // returns `Status.running` or `Status.failure` because it must evaluate
    // the current and remaining children in the next update cycle
    return Status.running;
  };

  /// The full evaluation of a [Selector] will update all of the children [Node]
  /// instances in the composite [List] and return a corresponding [Status].
  static final _SelectorFunction _full = (final selector) {
    while (selector._index != selector._nodes.length) {
      final status = selector._nodes[selector._index].update();

      // the child returned `Status.success`, the full [Selector] returns
      // [Status.success]; satisfies the logical OR requirement
      if (status == Status.success) {
        return Status.success;
      }

      // the child returned `Status.running`, the full [Selector] returns
      // [Status.running] and waits for the next call to the `update()` method
      // to continue evaluating the current and remaining composite nodes
      if (status == Status.running) {
        return Status.running;
      }

      // the child returned `Status.failure`, the full [Selector] increments
      // `_index` and loops again to continue evaluating children nodes
      ++selector._index;
    }

    // all children nodes were evaluated and none returned `Status.success`, the
    // full [Selector] returns `Status.failure` as it does not satisfy the
    // logical OR requirement
    return Status.failure;
  };
}
