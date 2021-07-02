part of nodes;

/// Represents the [_State] of a state machine with associated transitions to
/// other [_State] instances within the same state machine. A [_State] also has
/// an update node. The update [Node] is only executed if no transitions occur
/// during a call to the `update()` method of the [_State].
class _State extends Node {
  /// Placeholder for uninitialized [Sequence] of a [_State]. This could be
  /// replaced by a conditional expression chain in a constructor initializer
  /// list.
  static final _placeholderSequence =
      Sequence([Identity.running], isPartial: false);

  /// Placeholder [_State] to initialize a [List] of [_State].
  static final _invalid = _State(_AnyStateMachine._invalid);

  final _Transitional _transitional;
  Sequence _sequence;

  /// Constructs a [_State] dependant on the whether the specified argument
  /// nodes are null or not.
  _State(
    final _AnyStateMachine machine, {
    final Node? update,
    final Node? enter,
    final Node? exit,
  })  :
        // the update part of the state will check for transitions, if no
        // transition is triggered or exists, the update method is called for
        // the state, if no update node is specified, a Status.running identity
        // node is used as a placeholder
        _transitional = _Transitional(machine, update ?? Identity.running),
        _sequence = _State._placeholderSequence {
    /* equivalent conditional expression
    enter != null
        ? exit != null
            ? Sequence(
                [enter, _transitional, exit, _MachineTransition(machine)],
                isPartial: true,
              )
            : Sequence(
                [enter, _transitional, _MachineTransition(machine)],
                isPartial: true,
              )
        : exit != null
            ? _sequence = Sequence(
                [_transitional, exit, _MachineTransition(machine)],
                isPartial: true,
              )
            : Sequence(
                [_transitional, _MachineTransition(machine)],
                isPartial: true,
              );
    */
    if (enter != null) {
      // there is an enter node
      if (exit != null) {
        // and an exit node
        _sequence = Sequence(
          [enter, _transitional, exit, _MachineTransition(machine)],
          isPartial: true,
        );
      } else {
        // but no exit node
        _sequence = Sequence(
          [enter, _transitional, _MachineTransition(machine)],
          isPartial: true,
        );
      }
    } else if (exit != null) {
      // there's no enter node, but there is an exit node
      _sequence = Sequence(
        [_transitional, exit, _MachineTransition(machine)],
        isPartial: true,
      );
    } else {
      // there is no enter or exit node
      _sequence = Sequence(
        [_transitional, _MachineTransition(machine)],
        isPartial: true,
      );
    }
  }

  void add(final _Transition transition) => _transitional.add(transition);

  @override
  void reset() => _sequence.reset();

  @override
  Status update() => _sequence.update();
}

/// A [_Transition] is defined by a condition [Node] and an associated `_key`
/// that corresponds to an index in the [StateMachine] instance [State] list.
/// The condition [Node] must evaluate to `Status.success` for the transition to
/// occur. See [_Transitional] and [_MachineTransition] for details.
class _Transition {
  final Node _condition;
  final int _key;

  const _Transition(final this._condition, final this._key);
}

/// A [_Transitional] node decorates a [Node] with a [List] of [_Transition]
/// instances that are checked on every `update()` method call. The transition
/// list is evaluated in order. Therefore, transitions that are added first are
/// evaluated first.
///
/// A [_Transitional] has two outcomes for a call to its `update()` method:
///
/// 1. One of the [_Transition] nodes returns [Status.success], the associated
/// [_AnyStateMachine] will have its `_nextIndex` set to the `_key` of the
/// [_Transition] and the `update()` method will return `Status.success`, which
/// in turn allows the internal [Sequence] of the [_AnyStateMachine] to go to
/// the exit node (if any). The decorated [Node] is not evaluated at all.
/// 2. None of the [_Transition] nodes return [Status.success]. The decorated
/// [Node] is fully evaluated by a call to `update()` and a call to `reset()` if
/// the decorated [Node] returns a [Status] different from `Status.running`.
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
      // check if the current transition condition node succeeds
      final transition = _transitions[i];
      final status = transition._condition.update();

      // reset the transition node if it succeeded or failed
      if (status != Status.running) {
        transition._condition.reset();
      }

      // the transition node succeeds, update the state machine key and
      // return Status.success so that the state machine's sequence advances
      if (status == Status.success) {
        _machine._nextIndex = transition._key;
        return Status.success;
      }
    }

    // evaluate the decorated node; this is the node evaluated when no
    // transitions occur
    if (_node.update() != Status.running) {
      _node.reset();
    }

    // return Status.running so that the state machine sequence keeps updating
    // this node
    return Status.running;
  }
}

/// A [_MachineTransition] is always found at the end of a [StateMachine<T>]
/// [Sequence]. It should only be called after a [_Transition] evaluates to
/// `Status.success`. It represents the switch from the current state to the
/// next state.
class _MachineTransition extends Node {
  final _AnyStateMachine _machine;

  _MachineTransition(final this._machine);

  @override
  Status update() {
    // reset the state the state machine is switching to because it might have
    // been left in a updated state by a previous transition
    _machine._states[_machine._nextIndex].reset();

    // set the state machine's current index to the transitioned state
    _machine._index = _machine._nextIndex;

    return Status.success;
  }
}
