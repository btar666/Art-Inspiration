/// نتيجة قائمة مقسّمة من أمان ERP
class AmanPaginatedResult<T> {
  const AmanPaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.perPage = 50,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  bool get hasMore => currentPage < lastPage;
}
