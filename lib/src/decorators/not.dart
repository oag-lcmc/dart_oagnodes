part of nodes;

/// The [Not] decorator returns the opposite [Status] of its decorated [Node]
/// instance.
///
/// - On `Status.success`, the [Not] decorator instance returns
/// `Status.failure`.
/// - On `Status.failure`, the [Not] decorator instance returns
/// `Status.success`.
/// - On `Status.running`, the [Not] decorator instance returns
/// `Status.running`
///
/// This is the equivalent of a logical NOT on a boolean expression.
class Not extends Decorator {
  /// Construct a [Not] decorator for the specified argument [Node].
  /// The returned [Status] of the child [Node] will be inverted from
  /// [Status.success] to [Status.failure] or from [Status.failure] to
  /// [Status.success]. If the child [Node] returns [Status.running] the
  /// [Not] decorator returns [Status.running] as it does consider that
  /// status as an actual result.
  const Not(final Node node) : super(node);

  /// Updates the decorated [Node] and returns the opposite [Status]. It
  /// inverses `Status.success` into `Status.failure` and vice-versa. If the
  /// decorated [Node] returns `Status.running`, [Not] returns `Status.running`.
  @override
  Status update() {
    final status = _node.update();

    if (status == Status.running) {
      return Status.running;
    }
    // inverse Status.success into Status.failure and vice-versa
    return status == Status.success ? Status.failure : Status.success;
  }
}
