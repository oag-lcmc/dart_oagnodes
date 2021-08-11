part of nodes;

/// Base class for an index-based state machine. Requires that all states be
/// defined before utilization. The list number of states cannot be modified,
/// but an existing list state can be assigned.
class _StateMachineBase extends Node {
  static final _invalid = _StateMachineBase._empty();

  final List<_State> _states;
  int _index;
  int _nextIndex;

  _StateMachineBase._empty()
      : _states = List.empty(growable: false),
        _index = -1,
        _nextIndex = -1;

  _StateMachineBase(final int capacity)
      : assert(capacity > 0),
        _states = List.filled(capacity, _State._invalid, growable: false),
        _index = 0,
        _nextIndex = 0;

  @override
  Status update() {
    // commented this assert out because we might want to define a state
    // inside another state
    // assert(_states.every((state) => !identical(state, _State._invalid)));
    return _states[_index].update();
  }
}
