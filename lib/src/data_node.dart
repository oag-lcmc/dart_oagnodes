part of nodes;

/// Abstract base class for [Node] instances that hold some `data`. The `data`
/// instance can be shared across multiple [DataNode] instances by reference in
/// order to compose operations that read/write from the same `data`.
///
/// Example:
///
/// ```
/// // A class to be used as a reference to an int
/// class IntReference {
///   int value;
///   IntReference(this.value);
/// }
///
/// // An increment-by-one operation DataNode on an IntReference data instance
/// class IncrementByOne extends DataNode<IntReference> {
///   IncrementByOne(IntReference data) : super(data);
///
///   @override
///   Status update() {
///     // increment the int value stored by the IntReference instance by one.
///     ++data.value;
///     return Status.success;
///   }
/// }
///
/// // A multiply operation DataNode on an IntReference data instance
/// class Multiply extends DataNode<IntReference> {
///   final int multiplier;
///   Multiply(this.multiplier, IntReference data) : super(data);
///
///   @override
///   Status update() {
///     // multiply the int value stored by the IntReference instance by the
///     // specified multiplier argument
///     data.value *= multiplier;
///     return Status.success;
///   }
/// }
///
/// void dataNodeExample() {
///   final intRef = IntReference(0);
///   assert(intRef.value == 0);
///
///   final increment = IncrementByOne(intRef);
///   increment.update();
///   increment.update();
///   assert(intRef.value == 2);
///
///   final multiply = Multiply(2, intRef);
///   multiply.update();
///   assert(intRef.value == 4);
/// }
/// ```
abstract class DataNode<T> extends Node {
  /// The data contained by the [DataNode] instance.
  T data;

  /// Constructs a [DataNode] holding the specified argument data.
  DataNode(final this.data);
}
