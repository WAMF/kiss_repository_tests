import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/kiss_repository_tests.dart';

/// Query builder for InMemory implementation
class InMemoryProductQueryBuilder implements QueryBuilder<InMemoryFilterQuery<ProductModel>> {
  @override
  InMemoryFilterQuery<ProductModel> build(Query query) {
    if (query is QueryByName) {
      return InMemoryFilterQuery<ProductModel>(
          (product) => product.name.toLowerCase().contains(query.namePrefix.toLowerCase()));
    }

    if (query is QueryByPriceGreaterThan) {
      return InMemoryFilterQuery<ProductModel>((product) => product.price > query.price);
    }

    if (query is QueryByPriceLessThan) {
      return InMemoryFilterQuery<ProductModel>((product) => product.price < query.price);
    }

    // Default: return all products
    return InMemoryFilterQuery<ProductModel>((product) => true);
  }
}
