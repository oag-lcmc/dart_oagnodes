part of nodes;

/// Prints a message by calling the Dart `print(message)` function where `message` is
/// the specified argument [String] when the `update()` method of the [Print] instance
/// is called.
class Print extends Node {
  final String _message;

  const Print(final this._message);

  @override
  Status update() {
    print(_message);
    return Status.success;
  }
}
