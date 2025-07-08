import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/kiss_repository_tests.dart';

/// Query builder for InMemory implementation
class InMemoryProductQueryBuilder implements QueryBuilder<InMemoryFilterQuery<ProductModel>> {
  @override
  InMemoryFilterQuery<ProductModel> build(Query query) {
    if (query is QueryByName) {
      return InMemoryFilterQuery<ProductModel>(
        (product) => product.name.toLowerCase().contains(query.namePrefix.toLowerCase()),
      );
    }

    if (query is QueryByPriceRange) {
      return InMemoryFilterQuery<ProductModel>((product) {
        final minOk = query.minPrice == null || product.price >= query.minPrice!;
        final maxOk = query.maxPrice == null || product.price <= query.maxPrice!;
        return minOk && maxOk;
      });
    }

    // Default: return all products
    return InMemoryFilterQuery<ProductModel>((product) => true);
  }
}
