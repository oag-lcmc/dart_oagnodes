part of nodes;

/// Determines the execution order of the transition condition.
enum TransitionGroup {
  /// The transition condition is checked before the state update.
  before,

  /// The transition condition is checked after the state update.
  after,

  /// The transition condition is checked before and after the state update.
  beforeAndAfter
}
