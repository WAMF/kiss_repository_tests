import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/kiss_repository_tests.dart';

import 'inmemory_query_builder.dart';

class InMemoryRepositoryFactory implements RepositoryFactory<ProductModel> {
  Repository<ProductModel>? _repository;

  @override
  Future<Repository<ProductModel>> createRepository() async {
    _repository = InMemoryRepository<ProductModel>(
      queryBuilder: InMemoryProductQueryBuilder(),
      path: 'products',
    );
    return _repository!;
  }

  @override
  Future<void> cleanup() async {
    if (_repository == null) {
      print('🧹 Cleanup: No repository to clean');
      return;
    }

    try {
      final allItems = await _repository!.query();
      print('🧹 Cleanup: Found ${allItems.length} items to delete');

      if (allItems.isNotEmpty) {
        // Extract IDs from items - assuming ProductModel has an id field
        final ids = allItems.map((item) => item.id).toList();
        await _repository!.deleteAll(ids);
        print('🧹 Cleanup: Deleted ${ids.length} items successfully');
      } else {
        print('🧹 Cleanup: Repository already empty');
      }
    } on Exception catch (e) {
      print('❌ Cleanup failed: $e');
    }
  }

  @override
  void dispose() {
    _repository?.dispose();
    _repository = null;
  }
}
