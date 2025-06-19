// ignore_for_file: public_member_api_docs

import 'package:kiss_repository/kiss_repository.dart';
import 'package:test/test.dart';

import 'package:kiss_repository_tests/src/auto_identify_tests.dart';
import 'package:kiss_repository_tests/src/batch_tests.dart';
import 'package:kiss_repository_tests/src/crud_tests.dart';
import 'package:kiss_repository_tests/src/data/product_model.dart';
import 'package:kiss_repository_tests/src/query_tests.dart';
import 'package:kiss_repository_tests/src/streaming_tests.dart';

// Factory interface that each repository implementation must provide
abstract class RepositoryFactory {
  Repository<ProductModel> createRepository();
  Future<void> cleanup();
  void dispose();
}

/// Generic test suite that can test any Repository implementation
/// Following the same pattern as kiss_queue_tests
void runRepositoryTests({
  required String implementationName,
  required RepositoryFactory Function() factoryProvider,
  required void Function() cleanup,
}) {
  group('$implementationName Repository Tests', () {
    late RepositoryFactory factory;
    late Repository<ProductModel> repository;

    setUpAll(() {
      factory = factoryProvider();
      repository = factory.createRepository();
    });

    setUp(() async {
      await factory.cleanup();
    });

    tearDown(() {
      cleanup();
    });

    // Call individual test modules
    runCrudTests(repositoryFactory: () => repository);
    runBatchTests(repositoryFactory: () => repository);
    runIdTests(repositoryFactory: () => repository);
    runQueryTests(repositoryFactory: () => repository);
    runStreamingTests(repositoryFactory: () => repository);
  });
}
