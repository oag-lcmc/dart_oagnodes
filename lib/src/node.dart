part of nodes;

/// Abstract base class for all [Node] types.
abstract class Node {
  const Node();

  void reset() {}
  Status update();
}
