part of nodes;

/// The [Print] node forwards its [String] argument to a call to the Dart
/// `print()` function when the [Print] instance calls its `update()` method.
class Print extends Node {
  final String _message;

  /// Constructs a [Print] node with the specified argument [String].
  const Print(final this._message);

  @override
  Status update() {
    print(_message);
    return Status.success;
  }
}
