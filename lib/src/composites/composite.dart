part of nodes;

/// Abstract base class for a node composed of multiple nodes. The `update()`
/// method uses the composite [Node] instances to evaluate to a [Status] constant.
abstract class Composite extends Node {
  final List<Node> _nodes;
  int _index;

  Composite(final List<Node> nodes)
      : assert(nodes.isNotEmpty),
        _nodes = List.from(nodes, growable: false),
        _index = 0;

  int get length => _nodes.length;
  int get index => _index;

  Node operator [](final int index) {
    assert(index >= 0);
    assert(index < _nodes.length);

    return _nodes[index];
  }

  @override
  void reset() {
    /// there are specific instances where `_index` will update to node `n`,
    /// however by having `_index` be the excluded upper bound of the loop,
    /// the composite would only reset up to node `n - 1`, breaking the requirement
    /// that all updated nodes must be reset by the composite reset function
    final last = _index < _nodes.length ? _index + 1 : _index;

    for (var i = 0; i != last; ++i) {
      _nodes[i].reset();
    }

    _index = 0;
  }
}

mixin CompositeMixin on Composite {
  bool get isPartial => false;
}
