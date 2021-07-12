part of nodes;

/// The [Observer] abstract base class provides an interface to receive
/// notifications from a [Subject] instance.
///
/// See examples at the [Subject] documentation.
abstract class Observer {
  const Observer();

  /// The `receive(subject)` method is called a [Subject] when it decides to
  /// notity a subscribed [Observer]. The [Subject] itself passes itself as the
  /// argument to this method.
  void receive(covariant Subject subject);
}
