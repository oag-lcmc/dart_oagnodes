part of nodes;

/// Abstract base class for a node composed of multiple nodes. The `update()`
/// method uses the composite [Node] instances.
abstract class Composite extends Node {
  final List<Node> _nodes;
  int _index;

  /// Construct a [Composite] made up of the specified argument nodes.
  Composite(final List<Node> nodes)
      : assert(nodes.isNotEmpty),
        _nodes = List.from(nodes, growable: false),
        _index = 0;

  /// Count of the number of [Node] instances in the [Composite].
  int get length => _nodes.length;

  /// Index of the current [Node] of the [Composite]. The value should represent
  /// the index of the child [Node] that is in execution. The index is not
  /// guaranteed to be inside the bounds of the [List] that holds the children
  /// [Node] instances of the [Composite].
  int get index => _index;

  /// Indexes into the [List] of children [Node] instances.
  Node operator [](final int index) {
    assert(index >= 0);
    assert(index < _nodes.length);

    return _nodes[index];
  }

  @override
  void reset() {
    /// situations may occur (depending on subclass implementation) where
    /// _index will update to node n, however by having _index be the
    /// excluded upper bound of the loop, the composite would only reset up to
    /// node n - 1, breaking the internal requirement that all updated nodes
    /// must be reset by the composite reset method
    final last = _index < _nodes.length ? _index + 1 : _index;

    for (var i = 0; i != last; ++i) {
      _nodes[i].reset();
    }

    _index = 0;
  }
}
