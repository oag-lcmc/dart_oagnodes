part of nodes;

/// A [Evaluator] instance updates its composite children nodes as an unordered sequence.
/// Composite child nodes will be updated until they return [Status.success], then
/// they are ignored in any future calls to the [Evaluator] instance `update()` method
/// until all other composite children node have returned [Status.success].
///
///
class Evaluator extends Composite with CompositeMixin {
  final List<int> _processing;
  final Status _accepted;

  /// Creates an [Evaluator] instance to process composite children [Node] instances
  /// at once with a list of accepted [Status] constants. Accepted statuses cause the
  /// [Evaluator] instance to mark a composite child [Node] as completed.
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
      super.reset();
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
