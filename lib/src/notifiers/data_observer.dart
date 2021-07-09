part of nodes;

/// The [DataObserver] is able to receive notifications from a [DataSubject]. It
/// must call the `update()` method itself or through a proxy in order to call
/// the `updater` [Function] member.
///
/// Example:
///
/// ```
/// /// A reference to an int
/// class IntReference {
///   int value;
///   IntReference(this.value);
/// }
///
/// /// Increments a [IntReference] by some value.
/// class IncrementIntReference extends DataNode<IntReference> {
///   final int step;
///
///   IncrementIntReference(this.step, IntReference data) : super(data);
///
///   @override
///   Status update() {
///     // increment the int value stored by the IntReference
///     // instance by one.
///     data.value += step;
///     return Status.success;
///   }
/// }
///
/// void subjectDataObserverExample() {
///   // data to be observed; int reference starting at 0
///   final ref = IntReference(0);
///
///   // add 1 to the value of the IntReference
///   final addOneToIntRef = IncrementIntReference(1, ref);
///
///   // subject.update() will call addToIntRef.update() and
///   // notify its subscribed observers if addToIntRef.update()
///   // returns Status.success
///   final subject = DataSubject(addOneToIntRef);
///
///   // observe changes to an IntRef and compare and
///   // assign from an IntRef
///   final observer = DataObserver<IntReference, IntReference>(
///     // the observer's initial data is another instance of the
///     // the subject's data type IntReference
///     initialData: IntReference(-1),
///     // comparison mechanics:
///     // trigger assignment when a.value != b.value
///     // a.value is the the observer's local data
///     // b.value is the subject's local data
///     comparer: (a, b) => a.value != b.value,
///     // assignment mechanics:
///     // copy the value of b.value into a.value
///     assigner: (a, b) {
///       print('a.value = ${a.value}, b.value = ${b.value}');
///       a.value = b.value;
///     },
///     // updating mechanics:
///     // print out the value of the observer's value
///     updater: (data) {
///       print('data value is ${data.value}');
///       return Status.success;
///     },
///   );
///
///   // observer subscribes to notifications of subject
///   subject.subscribe(observer);
///
///   // observer has not changed because it has not received
///   // a notification from the subject is subscibed to
///   assert(!observer.hasChanged);
///
///   // will not do anything because observer.hasChanged == false
///   assert(observer.update() == Status.failure);
///   assert(observer.data.value != subject.data.value);
///
///   // emits notification to observers if the contained node
///   // returns Status.success
///   subject.update();
///
///   // the comparer verified that ref.value != observer.data.value
///   // and then assigned the subject's data to the observer's data
///   assert(ref.value == observer.data.value);
///
///   // the subject emitted an a notification, the observer is now
///   // marked as changed because the comparer returned true
///   // it has also been assigned the newly updated value
///   assert(observer.hasChanged);
///
///   // the call to its update() method will perform an update
///   // on the assigned value; this observer simply prints the value
///   assert(observer.update() == Status.success);
/// }
/// ```
class DataObserver<T, U> extends _DataObserverTemplate<T, U> {
  static final bool Function(Object?, Object?) compareTrue = _compareTrue;
  static final void Function(Object?, Object?) assignNone = _assignNone;

  bool _hasChanged;

  /// Construct a [DataObserver] with the following parameters:
  /// - `initialData` is the initial value of the [Observer] data that will be
  /// compared to the first [DataSubject] notification's data.
  /// - `comparer` determines whether two related data instances differ in a
  /// way that should trigger an update during a call to the `update()` method.
  /// - `assigner` updates the [Observer] data using the [Subject] data.
  /// - `updater` is the action taken on the data during a call to the
  /// `update()` method if the [DataObserver] determined to that a significant
  /// change occurred.
  DataObserver({
    required T data,
    required _ObserverUpdate<T> updater,
    _ObserverComparison<T, U>? comparer,
    _ObserverAssignation<T, U>? assigner,
  })  : _hasChanged = false,
        super(
          data: data,
          updater: updater,
          comparer: comparer ?? DataObserver.compareTrue,
          assigner: assigner ?? DataObserver.assignNone,
        );

  /// Indicates whether there was a relevant change in data as determined by
  /// the `comparer` [Function] instance when this [DataObserver] last
  /// received a notification.
  bool get hasChanged => _hasChanged;

  /// Receives a notification from the argument [Subject] and if the `compare`
  /// [Function] returns `true`, it sets an internal flag marking the
  /// [DataObserver] as changed. When a [DataObserver] is marked as changed, a
  /// subsequent call to the `update()` method will execute `updater(data)` and
  /// return its [Status].
  @override
  void receive(DataSubject<U> subject) {
    if (_hasChanged = comparer(data, subject.data)) {
      assigner(data, subject.data);
    }
  }

  /// Marks the [DataObserver] as unchanged.
  @override
  void reset() {
    _hasChanged = false;
  }

  /// Checks if the [DataObserver] is marked as changed and updates it using
  /// the specified `updater` with the `data` received from the latest
  /// notification.
  @override
  Status update() {
    if (_hasChanged) {
      _hasChanged = false;
      return updater(data);
    }

    return Status.failure;
  }
}

/// Convenience alias for a [DataObserver] that operates and receives the same
/// data type.
typedef SingleDataObserver<T> = DataObserver<T, T>;

bool _compareTrue<T, U>(T _, U __) => true;
void _assignNone<T, U>(T _, U __) {}
