import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/kiss_repository_tests.dart';
import 'package:test/test.dart';

/// Shared, framework-agnostic test logic for ID management functionality.
void runIdTests({required Repository<ProductModel> Function() repositoryFactory}) {
  group('ID Management & Auto-Generation', () {
    test('should auto-generate IDs with autoIdentify', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'Auto Product', price: 9.99);

      final autoIdentified = repository.autoIdentify(
        productModel,
        updateObjectWithId: (object, generatedId) => object.copyWith(id: generatedId),
      );

      expect(autoIdentified.id, isNotEmpty);
      expect(autoIdentified.object.name, equals('Auto Product'));
      expect(autoIdentified.object.id, equals(autoIdentified.id));
      print('✅ Auto-generated ID with autoIdentify');
    });

    test('should add items with auto-generated IDs using addAutoIdentified', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'Auto Added Product', price: 9.99);

      final addedObject = await repository.addAutoIdentified(
        productModel,
        updateObjectWithId: (object, generatedId) => object.copyWith(id: generatedId),
      );

      expect(addedObject.id, isNotEmpty);
      expect(addedObject.name, equals('Auto Added Product'));

      final retrieved = await repository.get(addedObject.id);
      expect(retrieved.id, equals(addedObject.id));
      expect(retrieved.name, equals('Auto Added Product'));
      print('✅ Added item with auto-generated ID using addAutoIdentified');
    });

    test('should handle multiple auto-generated IDs being unique', () async {
      final repository = repositoryFactory();
      final productModels = List.generate(5, (i) => ProductModel.create(name: 'Product $i', price: 9.99));

      final addedObjects = <ProductModel>[];
      for (final productModel in productModels) {
        final added = await repository.addAutoIdentified(
          productModel,
          updateObjectWithId: (object, generatedId) => object.copyWith(id: generatedId),
        );
        addedObjects.add(added);
      }

      // All IDs should be unique
      final ids = addedObjects.map((obj) => obj.id).toSet();
      expect(ids.length, equals(5));

      // All IDs should be non-empty
      for (final obj in addedObjects) {
        expect(obj.id, isNotEmpty);
      }

      // All objects should be retrievable
      for (final obj in addedObjects) {
        final retrieved = await repository.get(obj.id);
        expect(retrieved.id, equals(obj.id));
        expect(retrieved.name, equals(obj.name));
      }
      print('✅ Generated ${addedObjects.length} unique IDs');
    });

    test('should work with autoIdentify then manual add', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'Manual Add Product', price: 9.99);

      final autoIdentified = repository.autoIdentify(
        productModel,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );

      final addedObject = await repository.add(autoIdentified);

      expect(addedObject.id, isNotEmpty);
      expect(addedObject.name, equals('Manual Add Product'));

      final retrieved = await repository.get(addedObject.id);
      expect(retrieved.id, equals(addedObject.id));
      expect(retrieved.name, equals('Manual Add Product'));
      print('✅ AutoIdentify + manual add workflow worked');
    });

    test('should handle autoIdentify without updateObjectWithId (default behavior)', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'Default Product', price: 9.99).copyWith(id: 'original-id');

      final autoIdentified = repository.autoIdentify(productModel);

      expect(autoIdentified.id, isNotEmpty);
      expect(autoIdentified.id, isNot('original-id'));

      // Object should retain original ID since no updateObjectWithId was provided
      expect(autoIdentified.object.id, equals('original-id'));
      expect(autoIdentified.object.name, equals('Default Product'));
      print('✅ AutoIdentify default behavior handled correctly');
    });

    test('should handle autoIdentify in batch operations', () async {
      final repository = repositoryFactory();
      final productModels = [
        ProductModel.create(name: 'Batch Product 1', price: 9.99),
        ProductModel.create(name: 'Batch Product 2', price: 9.99),
      ];

      final identifiedObjects = productModels
          .map((obj) => repository.autoIdentify(obj, updateObjectWithId: (object, id) => object.copyWith(id: id)))
          .toList();

      final addedObjects = await repository.addAll(identifiedObjects);
      final addedObjectsList = addedObjects.toList();

      expect(addedObjectsList.length, equals(2));

      // Verify all IDs are unique and non-empty
      final ids = identifiedObjects.map((obj) => obj.id).toSet();
      expect(ids.length, equals(2));

      for (final identifiedObj in identifiedObjects) {
        expect(identifiedObj.id, isNotEmpty);
      }

      // Verify objects can be retrieved
      for (int i = 0; i < identifiedObjects.length; i++) {
        final retrieved = await repository.get(identifiedObjects[i].id);
        expect(retrieved.name, equals(productModels[i].name));
      }
      print('✅ AutoIdentify worked in batch operations');
    });
  });
}
