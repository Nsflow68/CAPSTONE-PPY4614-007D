sealed class RefugeFailure {
  const RefugeFailure();
}

class RefugeNetworkFailure extends RefugeFailure {
  final String message;
  const RefugeNetworkFailure(this.message);
}

class RefugeNotFoundFailure extends RefugeFailure {
  final String refugeId;
  const RefugeNotFoundFailure(this.refugeId);
}

class RefugeUnknownFailure extends RefugeFailure {
  final String message;
  const RefugeUnknownFailure(this.message);
}
