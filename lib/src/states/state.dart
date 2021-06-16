part of nodes;

class _StateData {
  final _Transitional _transitional;
  final Sequence _sequence;

  const _StateData(final this._transitional, final this._sequence);
}

class _State extends Node {
  static final _State _invalid = _State(_AnyStateMachine._invalid);

  final _StateData _data;

  _State(
    final _AnyStateMachine machine, {
    final Node? update,
    final Node? enter,
    final Node? exit,
  }) : _data = _makeStateData(machine, update, enter, exit);

  void add(final _Transition transition) => _data._transitional.add(transition);

  @override
  void reset() => _data._sequence.reset();

  @override
  Status update() => _data._sequence.update();
}

class _MachineTransition extends Node {
  final _AnyStateMachine _machine;

  _MachineTransition(final this._machine);

  @override
  Status update() {
    _machine._states[_machine._nextIndex].reset();
    _machine._index = _machine._nextIndex;

    return Status.success;
  }
}

_StateData _makeStateData(
  final _AnyStateMachine machine,
  final Node? update,
  final Node? enter,
  final Node? exit,
) {
  final transitional = _Transitional(machine, update ?? Identity.running);

  if (enter != null) {
    if (exit != null) {
      return _StateData(
          transitional,
          Sequence(
            [enter, transitional, exit, _MachineTransition(machine)],
            isPartial: true,
          ));
    } else {
      return _StateData(
          transitional,
          Sequence(
            [enter, transitional, _MachineTransition(machine)],
            isPartial: true,
          ));
    }
  } else if (exit != null) {
    return _StateData(
        transitional,
        Sequence(
          [transitional, exit, _MachineTransition(machine)],
          isPartial: true,
        ));
  } else {
    return _StateData(
        transitional,
        Sequence(
          [transitional, _MachineTransition(machine)],
          isPartial: true,
        ));
  }
}

class _Transition {
  final Node _condition;
  final int _key;

  const _Transition(final this._condition, final this._key);
}

class _Transitional extends Decorator {
  final _AnyStateMachine _machine;
  final List<_Transition> _transitions;

  _Transitional(this._machine, Node node)
      : _transitions = List.empty(growable: true),
        super(node);

  void add(final _Transition transition) => _transitions.add(transition);

  @override
  Status update() {
    for (var i = 0; i != _transitions.length; ++i) {
      final transition = _transitions[i];
      final status = transition._condition.update();

      if (status != Status.running) {
        transition._condition.reset();
      }

      if (status == Status.success) {
        _machine._nextIndex = transition._key;
        return Status.success;
      }
    }

    if (_node.update() != Status.running) {
      _node.reset();
    }

    return Status.running;
  }
}
