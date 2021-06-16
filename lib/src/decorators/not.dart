part of nodes;

/// The [Not] decorator returns the opposite [Status] of its decorated [Node]
/// instance.
///
/// - On `Status.success`, the [Not] decorator instance returns `Status.failure`.
/// - On `Status.failure`, the [Not] decorator instance returns `Status.success`.
/// - On `Status.running`, the [Not] decorator instance returns `Status.running`.
class Not extends Decorator {
  const Not(final Node node) : super(node);

  @override
  Status update() {
    final status = _node.update();

    if (status == Status.running) {
      return Status.running;
    }

    return status == Status.success ? Status.failure : Status.success;
  }
}
