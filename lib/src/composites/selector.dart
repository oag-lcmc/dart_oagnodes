part of nodes;

typedef _SelectorFunction = Status Function(Selector);

/// A [Selector] instance evaluates its composite nodes sequentially.
///
/// A [Selector] instance will evaluate every composite child [Node] instance
/// expecting one of them to return [Status.success], in which case the
/// [Selector] instance returns [Status.success].
///
/// If one of the children nodes returns [Status.failure], the [Selector] instance
/// evaluates the next child. If none of composite children [Node] instances
/// return [Status.success], the [Selector] instance will return [Status.failure].
///
/// This behavior is similar to an OR statement where the children nodes
/// are the boolean expressions.
class Selector extends Composite with CompositeMixin {
  final _SelectorFunction _updateImplementation;

  /// Creates a [Selector] instance.
  ///
  /// - `nodes` are the composite children nodes to be evaluated.
  /// - `isPartial` indicates whether the [Selector] instance should evaluate all of
  /// its composite children [Node] instances in one update cycle or sequentially with
  /// multiple calls to the `update()` method.
  ///   1. `true`: Evaluate one child node per update cycle.
  ///   2. `false`: Evaluate all children nodes in one update cycle.
  Selector(final List<Node> nodes, {required final bool isPartial})
      : _updateImplementation = isPartial ? Selector._partial : Selector._full,
        super(nodes);

  @override
  bool get isPartial => identical(_updateImplementation, Selector._partial);

  @override
  Status update() => _updateImplementation(this);

  static final _SelectorFunction _partial = (final selector) {
    if (selector._index == selector._nodes.length) {
      return Status.failure;
    }

    final status = selector._nodes[selector._index].update();

    if (status == Status.success) {
      return Status.success;
    }

    if (status == Status.failure) {
      ++selector._index;
    }

    return Status.running;
  };

  static final _SelectorFunction _full = (final selector) {
    while (selector._index != selector._nodes.length) {
      final status = selector._nodes[selector._index].update();

      if (status == Status.success) {
        return Status.success;
      }

      if (status == Status.running) {
        return Status.running;
      }

      ++selector._index;
    }

    return Status.failure;
  };
}
