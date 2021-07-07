part of nodes;
/*
class Notifier extends Node {
  final HashSet<Subject> _subjects;

  Notifier(final List<Subject> subjects)
      : _subjects = HashSet.of(subjects);

  void notify(final Subject subject) {
    assert(_subjects.contains(subject));

    for (var i = 0; i != subject._observers.length; ++i) {
      final observer = subject._observers[i];

      if (observer.hasChanged) {
        observer.update();
      }
    }
  }

  @override
  Status update() {
    for (final subject in _subjects) {
      notify(subject);
    }

    return Status.success;
  }
}
*/