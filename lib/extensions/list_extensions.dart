extension ListExtensions<TItem> on List<TItem> {
  List<TItem> distinct<TId>({TId Function(TItem item)? predicate}) {
    final ids = <dynamic>{};
    final result = List<TItem>.from(this);
    result.retainWhere((element) => ids.add(predicate == null ? element : predicate(element)));

    return result;
  }
}