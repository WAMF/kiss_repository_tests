import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/test.dart';

/// Shared, framework-agnostic test logic for basic query operations.
void runQueryTests({
  required Repository<ProductModel> Function() repositoryFactory,
  required TestFramework framework,
}) {
  framework.group('Basic Query Operations', () {
    framework.test('should query all items with AllQuery (default)', () async {
      final repository = repositoryFactory();

      for (int i = 0; i < 3; i++) {
        final product = ProductModel.create(name: 'Product $i', price: 9.99);
        await repository.addAutoIdentified(
          product,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
        await Future.delayed(Duration(milliseconds: 10));
      }

      final allObjects = await repository.query();
      framework.expect(allObjects.length, framework.equals(3));

      // Check that all expected items are present (order not guaranteed)
      final names = allObjects.map((obj) => obj.name).toSet();
      framework.expect(names.length, framework.equals(3));
      framework.expect(names, framework.contains('Product 0'));
      framework.expect(names, framework.contains('Product 1'));
      framework.expect(names, framework.contains('Product 2'));
      print('✅ Queried all objects with default AllQuery');
    });

    framework.test('should return empty list when querying empty collection', () async {
      final repository = repositoryFactory();

      final emptyResults = await repository.query();
      framework.expect(emptyResults, framework.isEmpty);
      print('✅ Handled empty collection query correctly');
    });

    framework.test('should query by name prefix', () async {
      final repository = repositoryFactory();

      // Add test objects with various names
      final products = [
        ProductModel.create(name: 'Apple Item', price: 9.99),
        ProductModel.create(name: 'Banana Item', price: 19.99),
        ProductModel.create(name: 'Apple Product', price: 29.99),
        ProductModel.create(name: 'Cherry Item', price: 39.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(
          obj,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
        await Future.delayed(Duration(milliseconds: 10));
      }

      final appleObjects = await repository.query(query: QueryByName('Apple'));
      framework.expect(appleObjects.length, framework.equals(2));

      final names = appleObjects.map((obj) => obj.name).toList();
      framework.expect(names, framework.contains('Apple Item'));
      framework.expect(names, framework.contains('Apple Product'));
      print('✅ Queried objects by name prefix successfully');
    });

    framework.test('should query by price greater than threshold', () async {
      final repository = repositoryFactory();
      final priceThreshold = 15.0;
      final products = [
        ProductModel.create(name: 'Cheap Product 1', price: 5.99),
        ProductModel.create(name: 'Cheap Product 2', price: 12.99),
        ProductModel.create(name: 'Expensive Product 1', price: 25.99),
        ProductModel.create(name: 'Expensive Product 2', price: 35.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(
          obj,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
        await Future.delayed(Duration(milliseconds: 10));
      }

      final expensiveObjects = await repository.query(query: QueryByPriceGreaterThan(priceThreshold));
      framework.expect(expensiveObjects.length, framework.equals(2));

      final names = expensiveObjects.map((obj) => obj.name).toSet();
      framework.expect(names, framework.contains('Expensive Product 1'));
      framework.expect(names, framework.contains('Expensive Product 2'));

      for (final obj in expensiveObjects) {
        framework.expect(obj.price > priceThreshold, framework.isTrue);
      }
      print('✅ Queried objects by price greater than threshold successfully');
    });

    framework.test('should query by price less than threshold', () async {
      final repository = repositoryFactory();
      final priceThreshold = 15.0;
      final products = [
        ProductModel.create(name: 'Cheap Product 1', price: 5.99),
        ProductModel.create(name: 'Cheap Product 2', price: 12.99),
        ProductModel.create(name: 'Expensive Product 1', price: 25.99),
        ProductModel.create(name: 'Expensive Product 2', price: 35.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(
          obj,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
        await Future.delayed(Duration(milliseconds: 10));
      }

      final cheapObjects = await repository.query(query: QueryByPriceLessThan(priceThreshold));
      framework.expect(cheapObjects.length, framework.equals(2));

      final names = cheapObjects.map((obj) => obj.name).toSet();
      framework.expect(names, framework.contains('Cheap Product 1'));
      framework.expect(names, framework.contains('Cheap Product 2'));

      for (final obj in cheapObjects) {
        framework.expect(obj.price < priceThreshold, framework.isTrue);
      }
      print('✅ Queried objects by price less than threshold successfully');
    });

    framework.test('should handle query with no results', () async {
      final repository = repositoryFactory();
      final products = [
        ProductModel.create(name: 'Sample Product', price: 9.99),
        ProductModel.create(name: 'Another Product', price: 19.99),
      ];
      for (final obj in products) {
        await repository.addAutoIdentified(
          obj,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
      }
      final noResults = await repository.query(query: QueryByName('NonExistent'));
      framework.expect(noResults, framework.isEmpty);
      print('✅ Handled query with no results correctly');
    });
  });
}
