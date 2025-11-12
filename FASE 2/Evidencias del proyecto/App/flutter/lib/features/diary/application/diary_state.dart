import '../data/models/diary_entry_model.dart';

sealed class DiaryState {
  const DiaryState();

  T map<T>({
    required T Function(DiaryInitial state) initial,
    required T Function(DiaryLoading state) loading,
    required T Function(DiaryLoaded state) loaded,
    required T Function(DiaryError state) error,
  }) {
    final self = this;
    if (self is DiaryInitial) return initial(self);
    if (self is DiaryLoading) return loading(self);
    if (self is DiaryLoaded) return loaded(self);
    if (self is DiaryError) return error(self);
    throw StateError('Estado de diario no soportado: $runtimeType');
  }
}

class DiaryInitial extends DiaryState {
  const DiaryInitial();
}

class DiaryLoading extends DiaryState {
  const DiaryLoading();
}

class DiaryLoaded extends DiaryState {
  const DiaryLoaded(this.entries);

  final List<DiaryEntryModel> entries;
}

class DiaryError extends DiaryState {
  const DiaryError(this.message);

  final String message;
}
