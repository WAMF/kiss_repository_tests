// ignore_for_file: cascade_invocations

import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/kiss_repository_tests.dart';
import 'package:test/test.dart';

/// Shared, framework-agnostic test logic for basic batch operations.
void runBatchTests({required Repository<ProductModel> Function() repositoryFactory}) {
  group('Basic Batch Operations', () {
    test('should add multiple items with addAll', () async {
      final repository = repositoryFactory();

      final products = [
        ProductModel.create(name: 'Batch Product 1', price: 9.99),
        ProductModel.create(name: 'Batch Product 2', price: 9.99),
        ProductModel.create(name: 'Batch Product 3', price: 9.99),
      ];

      final identifiedObjects = products
          .map((obj) => repository.autoIdentify(obj, updateObjectWithId: (object, id) => object.copyWith(id: id)))
          .toList();

      final addedObjects = await repository.addAll(identifiedObjects);
      final addedObjectsList = addedObjects.toList();

      expect(addedObjectsList.length, equals(3));
      for (int i = 0; i < products.length; i++) {
        expect(addedObjectsList[i].id, equals(identifiedObjects[i].id));
        expect(addedObjectsList[i].name, equals(products[i].name));

        final retrieved = await repository.get(identifiedObjects[i].id);
        expect(retrieved.id, equals(identifiedObjects[i].id));
        expect(retrieved.name, equals(products[i].name));
      }
    });

    test('should update multiple items with updateAll', () async {
      final repository = repositoryFactory();

      final products = [
        ProductModel.create(name: 'Update Product 1', price: 9.99),
        ProductModel.create(name: 'Update Product 2', price: 9.99),
        ProductModel.create(name: 'Update Product 3', price: 9.99),
      ];

      // First add the objects
      final createdObjects = <ProductModel>[];
      for (final obj in products) {
        final created = await repository.addAutoIdentified(
          obj,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
        createdObjects.add(created);
      }

      // Create updated versions
      final updatedObjectsList = createdObjects.map((obj) => obj.copyWith(name: '${obj.name} Updated')).toList();
      final identifiedUpdates = updatedObjectsList.map((obj) => IdentifiedObject(obj.id, obj)).toList();

      final updatedObjects = await repository.updateAll(identifiedUpdates);
      final updatedObjectsResult = updatedObjects.toList();

      expect(updatedObjectsResult.length, equals(3));
      for (int i = 0; i < createdObjects.length; i++) {
        expect(updatedObjectsResult[i].id, equals(createdObjects[i].id));
        expect(updatedObjectsResult[i].name, equals('${products[i].name} Updated'));

        final retrieved = await repository.get(createdObjects[i].id);
        expect(retrieved.name, equals('${products[i].name} Updated'));
      }
    });

    test('should delete multiple items with deleteAll', () async {
      final repository = repositoryFactory();

      final products = [
        ProductModel.create(name: 'Delete Product 1', price: 9.99),
        ProductModel.create(name: 'Delete Product 2', price: 9.99),
        ProductModel.create(name: 'Delete Product 3', price: 9.99),
      ];

      // First add the objects
      final createdObjects = <ProductModel>[];
      for (final obj in products) {
        final created = await repository.addAutoIdentified(
          obj,
          updateObjectWithId: (object, id) => object.copyWith(id: id),
        );
        createdObjects.add(created);
      }

      // Verify they exist first
      for (final obj in createdObjects) {
        final retrieved = await repository.get(obj.id);
        expect(retrieved.id, equals(obj.id));
      }

      final deleteIds = createdObjects.map((obj) => obj.id).toList();
      await repository.deleteAll(deleteIds);

      // Verify deletion
      for (final obj in createdObjects) {
        expect(() => repository.get(obj.id), throwsA(isA<RepositoryException>()));
      }
    });

    test('should handle empty batch operations', () async {
      final repository = repositoryFactory();

      final emptyAddResult = await repository.addAll(<IdentifiedObject<ProductModel>>[]);
      expect(emptyAddResult, isEmpty);

      final emptyUpdateResult = await repository.updateAll(<IdentifiedObject<ProductModel>>[]);
      expect(emptyUpdateResult, isEmpty);

      await repository.deleteAll(<String>[]);
    });

    test('should fail entire batch atomically when any item conflicts', () async {
      final repository = repositoryFactory();

      // First create an existing object
      final existingObject = ProductModel.create(name: 'Existing Object', price: 9.99);
      final createdExisting = await repository.addAutoIdentified(
        existingObject,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );

      // Try to add a batch that includes the existing ID
      final batchObjects = [
        ProductModel.create(name: 'New Product 1', price: 9.99),
        createdExisting, // This should cause a failure
        ProductModel.create(name: 'New Product 2', price: 9.99),
      ];

      final identifiedBatch = batchObjects.map((obj) => IdentifiedObject(obj.id, obj)).toList();

      expect(() => repository.addAll(identifiedBatch), throwsA(isA<RepositoryException>()));

      // Verify the original object is still there
      final retrieved = await repository.get(createdExisting.id);
      expect(retrieved.name, equals('Existing Object'));

      // Explicitly verify that none of the new items were added (atomic failure)
      for (final obj in batchObjects) {
        if (obj.id != createdExisting.id && obj.id.isNotEmpty) {
          expect(() => repository.get(obj.id), throwsA(isA<RepositoryException>()));
        }
      }
    });

    test('should fail updateAll when any item has non-existent ID', () async {
      final repository = repositoryFactory();

      // Create one existing object
      final existingObject = await repository.addAutoIdentified(
        ProductModel.create(name: 'Existing Object', price: 9.99),
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );

      // Try to update a batch that includes a non-existent ID
      final updateBatch = [
        IdentifiedObject(existingObject.id, existingObject.copyWith(name: 'Updated Existing')),
        IdentifiedObject('non_existent_id', ProductModel.create(name: 'Updated Non-Existent', price: 9.99)),
      ];

      expect(() => repository.updateAll(updateBatch), throwsA(isA<RepositoryException>()));

      // Verify the existing object was not modified (atomic failure)
      final retrieved = await repository.get(existingObject.id);
      expect(retrieved.name, equals('Existing Object'));
    });
  });
}
