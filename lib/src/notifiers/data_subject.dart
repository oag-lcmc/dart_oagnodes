part of nodes;

/// Abstract base class for all [DataSubject] types. It stores data of type
/// argument `T`. Concrete [_ObserverBase] instances can be passed a [DataSubject] in
/// order to observe, modify and make requests to the [DataSubject] and its
/// `data`.
abstract class DataSubject<T> extends Subject {
  /// The data contained by the [DataSubject] instance.
  T data;

  /// Constructs a [DataSubject] holding the specified argument `data`.
  ///
  /// - `data` is some data of argument type `T` stored by the [DataSubject].
  DataSubject(final this.data, final Node node) : super(node);
}
