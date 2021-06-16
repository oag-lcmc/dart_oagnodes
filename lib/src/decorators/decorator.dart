part of nodes;

/// Abstract base class that decorates the behavior of a [Node] instance.
abstract class Decorator extends Node {
  final Node _node;

  const Decorator(final this._node);

  @override
  void reset() => _node.reset();
}
