part of nodes;

/// Abstract base class for all [Observer] types. Provides an interface to
/// receive notifications from a [_SubjectBase] through the `receive(subject)`
/// method. The received [_SubjectBase] is covariant in order to handle reception of
/// different [_SubjectBase] types in concrete [Observer] implementations.
abstract class Observer {
  const Observer();

  /// The `receive(subject)` method is called by a [_SubjectBase] when it decides to
  /// notity a subscribed [Observer]. The [_SubjectBase] itself passes itself as the
  /// argument to this method.
  void receive(covariant _SubjectBase subject);
}
