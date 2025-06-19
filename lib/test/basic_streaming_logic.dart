import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/test.dart';
import 'package:test/test.dart';

void runStreamingTests({required Repository<ProductModel> Function() repositoryFactory}) {
  group('Basic Streaming Operations', () {
    test('should stream single document changes', () async {
      final repository = repositoryFactory();

      // Create an object first
      final productModel = ProductModel.create(name: 'Initial Name', price: 9.99);

      final createdObject = await repository.addAutoIdentified(
        productModel,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );

      final stream = repository.stream(createdObject.id);
      final streamFuture = stream.take(3).toList();

      // Give time for the subscription to be fully established
      await Future.delayed(Duration(milliseconds: 500));

      // Make updates with delays to ensure they are processed separately
      await repository.update(createdObject.id, (current) => current.copyWith(name: 'Updated Name 1'));

      await Future.delayed(Duration(milliseconds: 200));

      await repository.update(createdObject.id, (current) => current.copyWith(name: 'Updated Name 2'));

      final emissions = await streamFuture.timeout(Duration(seconds: 15));

      expect(emissions.length, equals(3));
      expect(emissions[0].name, equals('Initial Name'));
      expect(emissions[1].name, equals('Updated Name 1'));
      expect(emissions[2].name, equals('Updated Name 2'));
      print('✅ Streamed single document changes successfully');
    });

    test('should stream query results changes', () async {
      final repository = repositoryFactory();

      final stream = repository.streamQuery();
      final streamFuture = stream.take(4).toList();

      await Future.delayed(Duration(milliseconds: 200));

      // Add first object
      final object1 = ProductModel.create(name: 'Product 1', price: 9.99);
      final createdObject1 = await repository.addAutoIdentified(
        object1,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );

      // Add second object
      final object2 = ProductModel.create(name: 'Product 2', price: 9.99);
      await repository.addAutoIdentified(object2, updateObjectWithId: (object, id) => object.copyWith(id: id));

      // Update first object
      await repository.update(createdObject1.id, (current) => current.copyWith(name: 'Updated Product 1'));

      final emissions = await streamFuture.timeout(Duration(seconds: 15));

      expect(emissions.length, equals(4));
      expect(emissions[0].length, equals(0));
      expect(emissions[1].length, equals(1));
      expect(emissions[1][0].name, equals('Product 1'));
      expect(emissions[2].length, equals(2));
      expect(emissions[3].length, equals(2));
      expect(emissions[3].firstWhere((obj) => obj.id == createdObject1.id).name, equals('Updated Product 1'));
      print('✅ Streamed query results changes successfully');
    });

    test('should emit error for non-existent document', () async {
      final repository = repositoryFactory();

      // Generate a properly formatted ID using the repository's interface, but don't add it
      final autoIdentified = repository.autoIdentify(
        ProductModel.create(name: 'Dummy', price: 9.99),
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );
      final nonExistentId = autoIdentified.id;

      final stream = repository.stream(nonExistentId);

      // Should emit error immediately for non-existent document (consistent with get() behavior)
      expect(() => stream.first, throwsA(isA<RepositoryException>()));

      print('✅ Emitted error for non-existent document');
    });

    test('should stop emitting when document is deleted', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'To Be Deleted', price: 9.99);
      final createdObject = await repository.addAutoIdentified(
        productModel,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );
      final stream = repository.stream(createdObject.id);
      final emissions = <ProductModel>[];
      final subscription = stream.listen((obj) => emissions.add(obj));
      await Future.delayed(Duration(milliseconds: 500));
      await repository.delete(createdObject.id);
      await Future.delayed(Duration(milliseconds: 500));
      await subscription.cancel();

      expect(emissions.length, equals(1));
      expect(emissions[0].name, equals('To Be Deleted'));
      print('✅ Stopped emitting when document was deleted');
    });

    test('should emit initial data immediately on stream subscription', () async {
      final repository = repositoryFactory();
      final productModel = ProductModel.create(name: 'Immediate Object', price: 9.99);
      final createdObject = await repository.addAutoIdentified(
        productModel,
        updateObjectWithId: (object, id) => object.copyWith(id: id),
      );
      final stream = repository.stream(createdObject.id);
      final firstEmission = await stream.first.timeout(Duration(seconds: 10));

      expect(firstEmission.name, equals('Immediate Object'));
      expect(firstEmission.id, equals(createdObject.id));
      print('✅ Emitted initial data immediately on subscription');
    });
  });
}
