part of nodes;

/// Monitors whether the decorated node has returned the specified
/// parameter [Status] since the [DurationMonitor] instance was updated.
///
/// The [DurationMonitor] will return `Status.success` when the decorated
/// [Node] instance returns `Status.success` and the specified millisecond
/// interval of time has elapsed.
///
/// If the [DurationMonitor] instance millisecond interval expires before the
/// decorated [Node] instance returns the desired [Status], the monitor timer
/// is reset.
///
/// This is useful if you want to ensure that the child [Node] returns a
/// specific [Status] over time. The granularity of the checks if user decided
/// by calling the `update()` method as often as desired:
///   - Call it every frame
///   - Call it within a desired millisecond time frame
class DurationMonitor extends Decorator {
  final _MillisecondMonitor _monitor;
  final Status _desired;
  final Status _waiting;

  /// Creates a duration monitor for the specified argument [Node] instance.
  ///
  /// - `node` is the decorated [Node] instance that is monitored.
  /// - `interval` is the minimum amount of time in milliseconds that must elapse
  /// for the [DurationMonitor] will use to evaluate t.
  /// - `expecting` is the [Status] constant that the decorated [Node] must return
  /// during every `update()` cycle for the [DurationMonitor] instance.
  /// - `waiting` is the [Status] constant that the [DurationMonitor] instance
  /// returns before the [DurationMonitor] `interval` value is elapsed.
  DurationMonitor(
    final Node node, {
    required final int interval,
    required final Status expecting,
    final Status waiting = Status.running,
  })  : _monitor = _MillisecondMonitor(interval: interval),
        _desired = expecting,
        _waiting = waiting,
        super(node);

  /// Millisecond count since the last call to the `update()` method.
  int get elapsed => _monitor._elapsedMilliseconds;

  /// Resets the elapsed time of the [DurationMonitor] instance to 0.
  void refresh() => _monitor.reset();

  @override
  Status update() {
    final status = _node.update();

    if (status == _desired) {
      _monitor.update();

      if (_monitor.isElapsed) {
        _monitor.reset();

        return Status.success;
      }
    } else {
      _monitor.reset();
    }

    return _waiting;
  }
}

typedef _MillisecondMonitorFunction = void Function(_MillisecondMonitor);

class _MillisecondMonitor {
  final int _interval;
  _MillisecondMonitorFunction _onTick;
  int _previousMilliseconds;
  int _elapsedMilliseconds;

  _MillisecondMonitor({required final int interval})
      : assert(interval >= 0),
        _interval = interval,
        _onTick = _MillisecondMonitor.initializing,
        _previousMilliseconds = 0,
        _elapsedMilliseconds = 0;

  void reset() => _onTick = _MillisecondMonitor.initializing;

  void update() => _onTick(this);

  bool get isElapsed => _elapsedMilliseconds >= _interval;

  static final _MillisecondMonitorFunction initializing = (final monitor) {
    monitor._onTick = _MillisecondMonitor.updating;
    monitor._previousMilliseconds = DateTime.now().millisecondsSinceEpoch;
    monitor._elapsedMilliseconds = 0;
  };

  static final _MillisecondMonitorFunction updating = (final monitor) {
    monitor._elapsedMilliseconds =
        DateTime.now().millisecondsSinceEpoch - monitor._previousMilliseconds;
  };
}
