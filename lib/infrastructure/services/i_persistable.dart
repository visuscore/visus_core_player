abstract class IPersistable {
  Future<void> commit();
  Future<void> rollback();
}