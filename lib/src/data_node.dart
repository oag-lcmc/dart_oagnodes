part of nodes;

/// Abstract base class for all [DataNode] types. It stores data of type
/// argument `T`. Concrete instances can be shared across multiple [DataNode] instances by reference in
/// order to compose operations that read/write from the same `data`.
abstract class DataNode<T> extends Node {
  /// The data contained by the [DataNode] instance.
  T data;

  /// Constructs a [DataNode] holding the specified argument `data`.
  ///
  /// - `data` is some data of argument type `T` stored by the [DataNode].
  DataNode(final this.data);
}
