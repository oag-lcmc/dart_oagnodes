part of nodes;

/// The [Observer] abstract base class provides an interface to receive
/// notifications from a [Subject] instance.
/// 
/// See examples at the [Subject] documentation.
abstract class Observer extends Node {
  const Observer();

  /// The `receive(subject)` method is called a [Subject] when it decides to
  /// notity a subscribed [Observer]. The [Subject] itself passes itself as the
  /// argument to this method.
  void receive(covariant Subject subject);
}

typedef _ObserverComparison<T, U extends T> = bool Function(T, U);
typedef _ObserverAssignation<T, U extends T> = void Function(T, U);
typedef _ObserverUpdate<T> = Status Function(T);

/// The [_DataObserverTemplate] class defines three template operations required
/// by all data observers.
abstract class _DataObserverTemplate<T, U extends T> extends Observer {
  /// The previous data to be compared to the new data from a notification.
  final T data;

  /// Determines whether the observed `data` has changed by comparing it to
  /// the `data` it receives from a [DataSubject] notification.
  final _ObserverComparison<T, U> comparer;

  /// Updates the local [Observer] data with a new value from the [Subject].
  final _ObserverAssignation<T, U> assigner;

  /// Performs some operation on the data of this [DataObserver] and returns a
  /// [Status] indicating the results of the operation.
  final _ObserverUpdate<T> updater;

  const _DataObserverTemplate({
    required T initialData,
    required this.comparer,
    required this.assigner,
    required this.updater,
  }) : data = initialData;
}
