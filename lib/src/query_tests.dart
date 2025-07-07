import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/src/test_models.dart';
import 'package:test/test.dart';

/// Shared, framework-agnostic test logic for basic query operations.
void runQueryTests({required Repository<ProductModel> Function() repositoryFactory}) {
  group('Basic Query Operations', () {
    test('should query all items with AllQuery (default)', () async {
      final repository = repositoryFactory();

      for (var i = 0; i < 3; i++) {
        final product = ProductModel.create(name: 'Product $i', price: 9.99);
        await repository.addAutoIdentified(product, updateObjectWithId: (object, id) => object.copyWith(id: id));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final allObjects = await repository.query();
      expect(allObjects.length, equals(3));

      // Check that all expected items are present (order not guaranteed)
      final names = allObjects.map((obj) => obj.name).toSet();
      expect(names.length, equals(3));
      expect(names, contains('Product 0'));
      expect(names, contains('Product 1'));
      expect(names, contains('Product 2'));
      print('✅ Queried all objects with default AllQuery');
    });

    test('should return empty list when querying empty collection', () async {
      final repository = repositoryFactory();

      final emptyResults = await repository.query();
      expect(emptyResults, isEmpty);
      print('✅ Handled empty collection query correctly');
    });

    test('should query by name prefix', () async {
      final repository = repositoryFactory();

      // Add test objects with various names
      final products = [
        ProductModel.create(name: 'Apple Item', price: 9.99),
        ProductModel.create(name: 'Banana Item', price: 19.99),
        ProductModel.create(name: 'Apple Product', price: 29.99),
        ProductModel.create(name: 'Cherry Item', price: 39.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(obj, updateObjectWithId: (object, id) => object.copyWith(id: id));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final appleObjects = await repository.query(query: QueryByName('Apple'));
      expect(appleObjects.length, equals(2));

      final names = appleObjects.map((obj) => obj.name).toList();
      expect(names, contains('Apple Item'));
      expect(names, contains('Apple Product'));
      print('✅ Queried objects by name prefix successfully');
    });

    test('should query by price greater than threshold', () async {
      final repository = repositoryFactory();
      final priceThreshold = 15.0;
      final products = [
        ProductModel.create(name: 'Cheap Product 1', price: 5.99),
        ProductModel.create(name: 'Cheap Product 2', price: 12.99),
        ProductModel.create(name: 'Expensive Product 1', price: 25.99),
        ProductModel.create(name: 'Expensive Product 2', price: 35.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(obj, updateObjectWithId: (object, id) => object.copyWith(id: id));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final expensiveObjects = await repository.query(query: QueryByPriceRange(minPrice: priceThreshold));
      expect(expensiveObjects.length, equals(2));

      final names = expensiveObjects.map((obj) => obj.name).toSet();
      expect(names, contains('Expensive Product 1'));
      expect(names, contains('Expensive Product 2'));

      for (final obj in expensiveObjects) {
        expect(obj.price > priceThreshold, isTrue);
      }
      print('✅ Queried objects by price greater than threshold successfully');
    });

    test('should query by price less than threshold', () async {
      final repository = repositoryFactory();
      final priceThreshold = 15.0;
      final products = [
        ProductModel.create(name: 'Cheap Product 1', price: 5.99),
        ProductModel.create(name: 'Cheap Product 2', price: 12.99),
        ProductModel.create(name: 'Expensive Product 1', price: 25.99),
        ProductModel.create(name: 'Expensive Product 2', price: 35.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(obj, updateObjectWithId: (object, id) => object.copyWith(id: id));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final cheapObjects = await repository.query(query: QueryByPriceRange(maxPrice: priceThreshold));
      expect(cheapObjects.length, equals(2));

      final names = cheapObjects.map((obj) => obj.name).toSet();
      expect(names, contains('Cheap Product 1'));
      expect(names, contains('Cheap Product 2'));

      for (final obj in cheapObjects) {
        expect(obj.price < priceThreshold, isTrue);
      }
      print('✅ Queried objects by price less than threshold successfully');
    });

    test('should query by price range (both min and max)', () async {
      final repository = repositoryFactory();
      final minPrice = 10.0;
      final maxPrice = 25.0;
      final products = [
        ProductModel.create(name: 'Too Cheap Product', price: 5.99),
        ProductModel.create(name: 'In Range Product 1', price: 15.99),
        ProductModel.create(name: 'In Range Product 2', price: 20.99),
        ProductModel.create(name: 'Too Expensive Product', price: 35.99),
      ];

      for (final obj in products) {
        await repository.addAutoIdentified(obj, updateObjectWithId: (object, id) => object.copyWith(id: id));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final rangeObjects = await repository.query(
        query: QueryByPriceRange(minPrice: minPrice, maxPrice: maxPrice),
      );
      expect(rangeObjects.length, equals(2));

      final names = rangeObjects.map((obj) => obj.name).toSet();
      expect(names, contains('In Range Product 1'));
      expect(names, contains('In Range Product 2'));

      for (final obj in rangeObjects) {
        expect(obj.price >= minPrice && obj.price <= maxPrice, isTrue);
      }
      print('✅ Queried objects by price range successfully');
    });

    test('should handle query with no results', () async {
      final repository = repositoryFactory();
      final products = [
        ProductModel.create(name: 'Sample Product', price: 9.99),
        ProductModel.create(name: 'Another Product', price: 19.99),
      ];
      for (final obj in products) {
        await repository.addAutoIdentified(obj, updateObjectWithId: (object, id) => object.copyWith(id: id));
      }
      final noResults = await repository.query(query: QueryByName('NonExistent'));
      expect(noResults, isEmpty);
      print('✅ Handled query with no results correctly');
    });
  });
}
