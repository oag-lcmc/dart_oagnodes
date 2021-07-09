part of nodes;

/// A [Closure] takes a [Function] argument that returns a [Status]. The
/// function is executed by a call to the `update()` method of the [Closure].
///
/// The main use case of the [Closure] type is to avoid having to explicitly
/// write/subclass a [Node] type and/or to capture the surrounding scope at
/// declaration.
///
/// Example:
///
/// ```
/// void closureExample() {
///   var x = 0;
///
///   final closure = Closure(() {
///     // capture x from local scope and compute a Status
///     return ++x % 2 == 0 ? Status.success : Status.failure;
///   });
///
///   assert(closure.update() == Status.failure);
///   assert(closure.update() == Status.success);
///   assert(closure.update() == Status.failure);
/// }
/// ```
class Closure extends Node {
  final Status Function() _closure;

  /// Construct a [Closure] with the specified [Function] argument.
  const Closure(final this._closure);

  @override
  Status update() => _closure();
}

/// Creates a [Closure] instance for the specified [Function] argument returning
/// a predetermined [Status] value. The default predetermined [Status] is
/// `Status.success`.
///
/// This is a convenience function to construct [Closure] instances that do not
/// compute a [Status] to return.
///
/// Example:
///
/// ```
/// void main() {
///   var value = 42;
///
///   // use convenience function to create a Closure
///   final addToValue = makeClosure(() => ++value);
///
///   assert(addToValue.update() == Status.success);
///   assert(value == 43);
/// }
/// ```
Closure makeClosure(
  final void Function() action, {
  final Status returning = Status.success,
}) =>
    Closure(() {
      action();
      return returning;
    });
