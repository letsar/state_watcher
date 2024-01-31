class PaginatedData<T> {
  const PaginatedData({
    required List<T> this.data,
    required this.cursor,
  });

  const PaginatedData.empty()
      : data = null,
        cursor = null;

  final List<T>? data;
  final String? cursor;

  PaginatedData<T> merge(PaginatedData<T> other) {
    if (data != null && cursor == null) {
      // We have all the data, cannot add more.
      return this;
    }

    final mergedData = [...?data, ...?other.data];
    return PaginatedData(
      data: mergedData,
      cursor: other.cursor,
    );
  }
}
