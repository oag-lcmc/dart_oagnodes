part of nodes;

/// An [Evaluator] instance updates its children nodes as an unordered sequence.
/// Composite child nodes will be updated until they return [Status.success],
/// then they are ignored in any future calls `update()` method of the
/// [Evaluator] until all other children nodes have returned [Status.success].
///
/// The [Evaluator] will only call `reset()` on children [Node] instances that
/// have not yet evaluated to one of the accepted [Status] values. By default,
/// only children nodes that return `Status.success` are considered as
/// evaluated.
///
/// Example:
///
/// ```
/// void evaluatorExample() {
///   final random = Random();
///
///   final randomSuccess0 = Closure(() {
///     if (random.nextDouble() > 0.95) {
///       print('rs0');
///       return Status.success;
///     }
///     return Status.failure;
///   });
///
///   final randomSuccess1 = Closure(() {
///     if (random.nextDouble() > 0.95) {
///       print('rs1');
///       return Status.success;
///     }
///     return Status.failure;
///   });
///
///   final evaluator = Sequence([
///     Evaluator([
///       Identity.success,
///       randomSuccess0,
///       randomSuccess1
///     ]),
///     Print('evaluator finished'),
///   ], isPartial: false);
///
///   while (evaluator.update() != Status.success) {}
///   // sometimes prints rs0, then rs1
///   // sometimes prints rs1, then rs0
/// }
/// ```
class Evaluator extends Composite {
  final List<int> _processing;
  final Status _accepted;

  /// Constructs an [Evaluator] instance.
  ///
  /// - `nodes` are the composite children nodes to be evaluated.
  /// - `accepted` indicates which [Status] the children nodes should evaluate
  /// to in order to be considered as evaluated (thus skipped) on future calls
  /// to the `update()` method.
  ///
  /// Note: The [Evaluator] `update()` method only returns [Status.success] once
  /// all children nodes have returned one of the specfied accepted [Status]
  /// values.
  Evaluator(
    List<Node> nodes, {
    List<Status> accepted = const <Status>[Status.success],
  })  : assert(accepted.isNotEmpty),
        _processing = List.generate(nodes.length, (i) => i, growable: true),
        _accepted = accepted.reduce((a, b) => Status._or(a, b)),
        super(nodes);

  @override
  void reset() {
    if (_processing.isEmpty) {
      // add indices back and reset all nodes
      for (var i = 0; i < _nodes.length; ++i) {
        _processing.add(i);
        _nodes[i].reset();
      }

      _index = 0;
    } else {
      for (var i = 0; i < _processing.length; ++i) {
        _nodes[i].reset();
      }
    }
  }

  @override
  Status update() {
    if (_processing.isEmpty) {
      return Status.success;
    }

    for (var i = 0; i != _processing.length; ++i) {
      final index = _processing[i];
      final status = _nodes[index].update();

      if (_accepted._value & status._value > 0) {
        _index = index;
        _processing.removeAt(i);

        return Status.running;
      }
    }

    return Status.running;
  }
}
