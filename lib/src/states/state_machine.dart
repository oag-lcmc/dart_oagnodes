part of nodes;

/// A [StateMachine] handles the update of a state and transitions between
/// a state and other defined states.
class StateMachine<TEnum> extends _StateMachineBase {
  final List<TEnum> _enum;

  /// Constructs a [StateMachine] instance with the specified list of states.
  ///
  /// The parameter [TEnum] list should correspond to a valid
  /// `enum` declaration or interface with the same members as a `enum`
  /// declaration with compile-time constants. The enumuration entries must
  /// be 0-indexed and incremented by 1 for every subsequent enumeration
  /// entry that follow the first entry.
  StateMachine(final this._enum)
      : assert(_enum.isNotEmpty),
        assert(_isIndexedFromZeroIncrementally(_enum)),
        super(_enum.length);

  /// Gives the [TEnum] value representing the current state of this
  /// [StateMachine] instance.
  TEnum get current => _enum[_index];

  /// Defines the behavior of a state through [Node] instances.
  ///
  /// - `state` is the state being defined.
  /// - `update` is a [Node] instance that is updated every time the state
  /// machine is updated.
  /// - `enter` is a [Node] instance that is updated once when the state is
  /// first entered.
  /// - `exit` is a [Node] instance that is updated once when the state is first
  /// exited.
  /// - `isPartial` determines whether the state is evaluated partially, or not,
  /// as described in the documentation of [Sequence].
  ///
  /// A state will execute its `enter` [Node] on every `update()` call
  /// to the [StateMachine] instance until `Status.success` is returned
  /// by the `enter` [Node] or a transition is triggered manually or by
  /// a transition condition of the state itself.
  ///
  /// A state will continually execute its `update` [Node] until the
  /// machine transitions to a state either through a manual transition
  /// or one of the transitions of the current [State].
  ///
  /// A state will execute its `exit` [Node] if a state transition is triggered
  /// by the state or by a call to the `set(state)` method of the [StateMachine]
  /// instance. In exit mode, every `update()` call to the [StateMachine]
  /// instance until `Status.success` is returned by the `exit` [Node] or a
  /// transition is triggered manually.
  void define(
    final TEnum state, {
    final Node? enter,
    final Node? update,
    final Node? exit,
    final bool isPartial = false,
  }) {
    _states[_enumAsInt(state)] = _State(this,
        update: update, enter: enter, exit: exit, isPartial: isPartial);
  }

  /// Defines a transition from a state to another state based on a
  /// condition [Node] instance.
  ///
  /// - `from` is the state that evaluates the `on` [Node] condition.
  /// - `to` is the state that will be transitioned to if the condition is
  /// fulfilled.
  /// - `on` is the condition [Node] that determines whether to switch states; a
  /// condition is fulfilled if the `on` [Node] returns [Status.success] from
  /// its `update()` method.
  ///
  /// Transitions are evaluated before state updates.
  void transition({
    required final TEnum from,
    required final TEnum to,
    required final Node on,
  }) {
    _states[_enumAsInt(from)].add(_Transition(on, _enumAsInt(to)));
  }

  /// Change the current state of [StateMachine] instance to the
  /// specified [TEnum] state.
  ///
  /// The state of a [StateMachine] instance is the first entry
  /// (`TEnum.entry.index == 0`) in the [TEnum] enumeration.
  void set({required final TEnum to}) {
    _index = _enumAsInt(to);
    _states[_index].reset();
  }
}

int _enumAsInt<TEnum>(final TEnum entry) => (entry as dynamic).index as int;

/// Verifies that every value in `values` has an `index` property that is
/// and that the [List] contains is zero-indexed and increments by one for each
/// subsequent value.
bool _isIndexedFromZeroIncrementally<TEnum>(final List<TEnum> values) {
  for (var i = 0; i != values.length; ++i) {
    try {
      _enumAsInt(values[i]) == i;
    } on NoSuchMethodError {
      return false;
    } on Exception {
      return false;
    } catch (e) {
      return false;
    }
  }

  return true;
}
