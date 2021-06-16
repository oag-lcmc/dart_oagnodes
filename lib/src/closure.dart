part of nodes;

/// Takes in a [Function] argument that returns a [Status] value.
///
/// The return value of the call to `update()` is the returned [Status] value of
/// the argument function.
class Closure extends Node {
  final Status Function() _closure;

  const Closure(final this._closure);

  @override
  Status update() => _closure();
}

/// Creates a [Closure] instance for the specified [Function] argument that returns
/// the specified argument [Status] at every call.
Closure makeClosure({
  final Status returning = Status.success,
  required final void Function() action,
}) =>
    Closure(() {
      action();
      return returning;
    });
