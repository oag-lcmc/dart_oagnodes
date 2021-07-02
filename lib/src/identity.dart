part of nodes;

/// An [Identity] exists solely to return the specified argument [Status] from
/// its `update()` method. An [Identity] compares equal to another [Identity] if
/// they are both constructed with the same [Status].
///
/// Example:
///
/// ```
/// void identityExample() {
///   final success = const Identity(Status.success);
///   // always returns the specified Status
///   assert(success.update() == Status.success);
///   assert(success.update() == Status.success);
///
///   final otherSuccess = Identity(Status.success);
///   // two instances with the same Status compare as equal
///   assert(success == otherSuccess);
///   assert(success.update() == otherSuccess.update());
/// }
/// ```
class Identity extends Node {
  /// An [Identity] instance that returns the `Status.success` [Status].
  static const Identity success = Identity(Status.success);

  /// An [Identity] instance that returns the `Status.failure` [Status].
  static const Identity failure = Identity(Status.failure);

  /// An [Identity] instance that returns the `Status.running` [Status].
  static const Identity running = Identity(Status.running);

  final Status _status;

  /// Constructs an [Identity] instance that always returns the specified
  /// [Status] argument when its `update()` method is called.
  const Identity(final this._status);

  @override
  Status update() => _status;

  @override
  bool operator ==(final Object rhs) =>
      rhs is Identity ? _status == rhs._status : false;

  @override
  int get hashCode => _status.hashCode;
}
