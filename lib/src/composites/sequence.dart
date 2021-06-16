part of nodes;

typedef _SequenceFunction = Status Function(Sequence);

/// A [Sequence] instance evaluates its composite nodes sequentially.
///
/// A [Sequence] instance will evaluate every composite child [Node] instance
/// expecting all of them to return [Status.success], in which case the
/// [Sequence] instance returns [Status.success].
///
/// If any child [Node] instance returns [Status.failure], the [Sequence]
/// instance returns [Status.failure].
///
/// This behavior is similar to an AND statement where the children nodes
/// are the boolean expressions.
class Sequence extends Composite with CompositeMixin {
  final _SequenceFunction _updateImplementation;

  /// Creates a [Sequence] instance.
  ///
  /// - `nodes` are the composite children nodes to be evaluated.
  /// - `isPartial` indicates whether the [Selector] instance should evaluate all of
  /// its composite children [Node] instances in one update cycle or sequentially with
  /// multiple calls to the `update()` method.
  ///   1. `true`: Evaluate one child node per update cycle.
  ///   2. `false`: Evaluate all children nodes in one update cycle.
  Sequence(final List<Node> nodes, {required final bool isPartial})
      : _updateImplementation = isPartial ? Sequence._partial : Sequence._full,
        super(nodes);

  @override
  bool get isPartial => identical(_updateImplementation, Sequence._partial);

  @override
  Status update() => _updateImplementation(this);

  static final _SequenceFunction _partial = (final sequence) {
    if (sequence._index == sequence._nodes.length) {
      return Status.success;
    }

    final status = sequence._nodes[sequence._index].update();

    if (status == Status.failure) {
      return Status.failure;
    }

    if (status == Status.success) {
      ++sequence._index;
    }

    return Status.running;
  };

  static final _SequenceFunction _full = (final sequence) {
    while (sequence._index != sequence._nodes.length) {
      final status = sequence._nodes[sequence._index].update();

      if (status == Status.failure) {
        return Status.failure;
      }

      if (status == Status.running) {
        return Status.running;
      }

      ++sequence._index;
    }

    return Status.success;
  };
}
