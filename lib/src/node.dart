part of nodes;

/// Abstract base class for all [Node] types. The `reset()` method is defined as
/// no-op and does not require implementation.
abstract class Node {
  const Node();

  void reset() {}
  Status update();
}
