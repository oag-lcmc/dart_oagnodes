part of nodes;

/// Error thrown when a [Status] contains an invalid value.
class StatusError extends Error {
  final String message;
  StatusError(this.message);
}

/// Status code returned by the `update()` method of all [Node] types.
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

  @override
  String toString() {
    switch (_value) {
      case 1 << 0:
        return 'Failure';
      case 1 << 1:
        return 'Success';
      case 1 << 2:
        return 'Running';
      default:
        throw StatusError('invalid status');
    }
  }
}
