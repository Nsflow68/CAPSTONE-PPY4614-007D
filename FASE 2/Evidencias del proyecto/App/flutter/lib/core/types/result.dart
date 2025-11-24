/// Resultado genérico para operaciones (éxito o fallo tipado).
sealed class Result<T, E> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(E error) failure,
  }) {
    final self = this;
    if (self is Success<T, E>) return success(self.data);
    if (self is Failure<T, E>) return failure(self.error);
    throw StateError('Tipo de Result no soportado: $runtimeType');
  }

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;
}

class Success<T, E> extends Result<T, E> {
  const Success(this.data);
  final T data;
}

class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;
}
