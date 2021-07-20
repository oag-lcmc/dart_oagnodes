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
