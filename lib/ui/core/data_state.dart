sealed class DataState<T> {
  const DataState();
}

final class DataLoading<T> extends DataState<T> {
  const DataLoading();
}

final class DataLoaded<T> extends DataState<T> {
  const DataLoaded(this.value);

  final T value;
}

final class DataError<T> extends DataState<T> {
  const DataError(this.message);

  final String message;
}
