0.0.9

- [TransitionGroup] renamed to [EvaluationOrder].
- When defining a state, the `group` parameter is renamed to `order`.
- An additional parameter `shouldUpdateStateMachineOnTransition` is added to
defining a state, when true, if the state machine transitions to a new state,
it will automatically call the `update()` method.

0.0.8

- Removed assert to check that all states are defined on calls to `update()` of
a [StateMachine] so that a state can be defined during an update by the state
[Node] itself. This allows for dynamic state definitions.
- Added the [TransitionGroup] enum that represents the execution order of a
state transition.
- When defining a state transition, there is now the option to set the order of
evaluation for the transition condition. A transition condition can be evaluated
(before), (after) or (before and after) the state update node. This allows
transitions to occur at one or either point in order to transition during the
same call to the `update()` method of a state.

Example: A state transition condition checks a counter, the update node of the
state updates the counter. If the transition condition is only checked before
the state update, then a transition will not occur until the next call to the
`update()` method of the state, but it might be desireable to transition in the
same call to avoid having to call `update()` again.

0.0.7

- BREAKING CHANGE: new Subject, DataSubject, FutureSubject & Observer interfaces
and examples

0.0.6

- Added FutureSubject class to provide Future based notifications nodes; this
interface will most likely be changed
- Modified DataSubject interface to accomodate FutureSubject

0.0.5

- Removed empty class declaration

0.0.4

- Removed unused dart:ffi import
- Removed generic project example; more realistic examples later. See type
specific examples in documentation for usage
- Improved example of DataObserver; simplified interface, it is no longer a Node
 type, but can/might be wrapped into a type that does extend Node later
- BREAKING CHANGE: replaced named optional parameter 'action' to a
required positional parameter in the makeClosure() function

0.0.3

- Added the subject-observer types

0.0.2

- Additional documentation
- Fixed Evaluator reset method

0.0.1

- Initial version, created by Stagehand
