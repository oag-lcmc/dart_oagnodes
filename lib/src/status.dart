part of nodes;

/// Value returned by the `update()` method of all [Node] types.
///
/// 1. `failure` indicates that an operation was not successful.
/// 2. `success` indicates that the operation was successful.
/// 3. `running` indicates that the operation was not completed during
/// a call to the [Node] instance `update()` method.
class Status {
  final int _value;

  const Status._(this._value);

  /// Indicates an unsuccessful operation.
  static const Status failure = Status._(1 << 0);

  /// Indicates a successful operation.
  static const Status success = Status._(1 << 1);

  /// Indicates an incomplete or currently executing operation.
  static const Status running = Status._(1 << 2);

  static Status _or(final Status lhs, final Status rhs) =>
      Status._(lhs._value | rhs._value);
}
