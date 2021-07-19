part of nodes;

/// A [DataSubject] is a [Subject] whose `notifier` is a [DataNode]. It provides
/// access to the [DataNode] `data` through a getter. A [DataSubject] observer
/// can therefore receive data through a notification.
///
/// Example:
///
///```
/// // A reference to an int
/// class IntReference {
///   int value;
///   IntReference(this.value);
/// }
///
/// /// Increments a [IntReference] by the `step` value.
/// class IncrementIntReference extends DataNode<IntReference> {
///   final int step;
///   IncrementIntReference(this.step, IntReference data) : super(data);
///
///   @override
///   Status update() {
///     print('increment by $step');
///     data.value += step;
///     return Status.success;
///   }
/// }
///
/// void dataSubjectObserverExample() {
///   // subject data is an int reference
///   final subjectData = IntReference(0);
///
///   // subject notifier simply increments its int reference
///   // and returns Status.success
///   final incrementer = IncrementIntReference(2, subjectData);
///
///   // the notifier will succeed on every attempt because it
///   // always returns Status.success
///   final dataSubject = DataSubject(incrementer);
///
///   // the observer knows it will subscribe to a data subject;
///   // its handler will therefore use a DataSubject parameter
///   final observer = Observer(handler: (DataSubject<IntReference> subject) {
///     print('received notification with data: ${subject.data.value}');
///   });
///
///   dataSubject.subscribe(observer);
///
///   // update the data subject, the observer receives notification
///   dataSubject.update();
/// }
/// ```
class DataSubject<T> extends Subject {
  /// Constructs a [DataSubject] instance.
  ///
  /// `notifier` is a [DataNode] used as the base [Subject] notifier.
  DataSubject(DataNode<T> notifier) : super(notifier);

  /// Access the data contained by the notifier [DataNode].
  T get data {
    print('get data: ${notifier.runtimeType}');
    return (notifier as DataNode<T>).data;
  }
}
