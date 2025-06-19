import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/kiss_repository_tests.dart';
import 'package:test/test.dart';

// ignore: public_member_api_docs
void runCrudTests({required Repository<ProductModel> Function() repositoryFactory}) {
  group('Basic CRUD Operations', () {
    test('should perform complete CRUD lifecycle', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'Sample Product', price: 9.99);

      // CREATE
      final createdObject = await repository.addAutoIdentified(
        productModel,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );
      expect(createdObject.id, isNotEmpty);
      expect(createdObject.name, equals('Sample Product'));

      // READ
      final retrievedObject = await repository.get(createdObject.id);
      expect(retrievedObject.id, equals(createdObject.id));
      expect(retrievedObject.name, equals('Sample Product'));

      // UPDATE
      final savedObject = await repository.update(
        createdObject.id,
        (current) => current.copyWith(name: 'Updated Item'),
      );
      expect(savedObject.name, equals('Updated Item'));
      expect(savedObject.id, equals(createdObject.id));

      // DELETE
      await repository.delete(savedObject.id);
      expect(() => repository.get(savedObject.id), throwsA(isA<RepositoryException>()));
    });

    test('should throw exception when getting non-existent record', () async {
      final repository = repositoryFactory();
      expect(() => repository.get('non_existent_id'), throwsA(isA<RepositoryException>()));
    });

    test('should throw exception when updating non-existent record', () async {
      final repository = repositoryFactory();
      expect(
        () => repository.update('non_existent_id', (current) => current.copyWith(name: 'Updated')),
        throwsA(isA<RepositoryException>()),
      );
    });

    test('should allow deleting non-existent record without error', () async {
      final repository = repositoryFactory();
      // Delete should succeed gracefully for non-existent records
      await repository.delete('non_existent_id');
    });

    test('should handle deleteAll with mix of existing and non-existent IDs', () async {
      final repository = repositoryFactory();

      // Create a test object
      final productModel = ProductModel.create(name: 'Sample Product', price: 9.99);
      final createdObject = await repository.addAutoIdentified(
        productModel,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );

      // Delete mix of existing and non-existing IDs - should succeed gracefully
      await repository.deleteAll([
        createdObject.id, // exists
        'non_existent_1', // doesn't exist
        'non_existent_2', // doesn't exist
      ]);

      // Verify the existing object was actually deleted
      expect(() => repository.get(createdObject.id), throwsA(isA<RepositoryException>()));
    });
  });
}
