part of nodes;

class Identity extends Node {
  static const Identity success = Identity(Status.success);
  static const Identity failure = Identity(Status.failure);
  static const Identity running = Identity(Status.running);

  final Status _status;

  const Identity(final this._status);

  @override
  Status update() => _status;

  @override
  bool operator ==(final Object rhs) =>
      rhs is Identity ? _status == rhs._status : false;

  @override
  int get hashCode => _status.hashCode;
}
