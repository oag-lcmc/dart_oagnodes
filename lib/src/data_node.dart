part of nodes;

/// Abstract base class for [Node] instances that hold some `data`. The `data` instance
/// can be shared across multiple [DataNode] instances such as a [Sequence] instance
/// containing [DataNode] instances in order to perform computations on `data`.
abstract class DataNode<T> extends Node {
  /// The data contained by the [DataNode] instance.
  T data;

  DataNode(final this.data);
}
