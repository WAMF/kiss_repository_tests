// ignore_for_file: public_member_api_docs

import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/src/auto_identify_tests.dart';
import 'package:kiss_repository_tests/src/batch_tests.dart';
import 'package:kiss_repository_tests/src/crud_tests.dart';
import 'package:kiss_repository_tests/src/query_tests.dart';
import 'package:kiss_repository_tests/src/streaming_tests.dart';
import 'package:kiss_repository_tests/src/test_models.dart';
import 'package:test/test.dart';

// Factory interface that each repository implementation must provide
abstract class RepositoryFactory<T> {
  Future<Repository<T>> createRepository();

  Future<void> cleanup();

  void dispose();
}

/// Configuration for selecting which test suites to run
class TestSuiteConfig {
  const TestSuiteConfig({
    this.runCrudTests = true,
    this.runBatchTests = true,
    this.runIdTests = true,
    this.runQueryTests = true,
    this.runStreamingTests = true,
  });

  /// Creates a configuration with all tests enabled (default behavior)
  const TestSuiteConfig.all()
      : runCrudTests = true,
        runBatchTests = true,
        runIdTests = true,
        runQueryTests = true,
        runStreamingTests = true;

  /// Creates a configuration with only basic CRUD tests
  const TestSuiteConfig.basicOnly()
      : runCrudTests = true,
        runBatchTests = false,
        runIdTests = false,
        runQueryTests = false,
        runStreamingTests = false;

  /// Creates a configuration without streaming tests (useful for repositories that don't support real-time features)
  const TestSuiteConfig.withoutStreaming()
      : runCrudTests = true,
        runBatchTests = true,
        runIdTests = true,
        runQueryTests = true,
        runStreamingTests = false;

  /// Creates a configuration with only CRUD and batch operations
  const TestSuiteConfig.crudAndBatch()
      : runCrudTests = true,
        runBatchTests = true,
        runIdTests = false,
        runQueryTests = false,
        runStreamingTests = false;

  final bool runCrudTests;
  final bool runBatchTests;
  final bool runIdTests;
  final bool runQueryTests;
  final bool runStreamingTests;
}

/// Generic test suite that can test any Repository implementation
/// Following the same pattern as kiss_queue_tests
void runRepositoryTests({
  required String implementationName,
  required RepositoryFactory<ProductModel> Function() factoryProvider,
  required void Function() cleanup,
  TestSuiteConfig config = const TestSuiteConfig.all(),
}) {
  group('$implementationName Repository Tests', () {
    late RepositoryFactory<ProductModel> factory;
    late Repository<ProductModel> repository;

    setUpAll(() async {
      factory = factoryProvider();
      repository = await factory.createRepository();
    });

    setUp(() async {
      await factory.cleanup();
    });

    tearDown(() {
      cleanup();
    });

    // Call individual test modules based on configuration
    if (config.runCrudTests) {
      runCrudTests(repositoryFactory: () => repository);
    }
    
    if (config.runBatchTests) {
      runBatchTests(repositoryFactory: () => repository);
    }
    
    if (config.runIdTests) {
      runIdTests(repositoryFactory: () => repository);
    }
    
    if (config.runQueryTests) {
      runQueryTests(repositoryFactory: () => repository);
    }
    
    if (config.runStreamingTests) {
      runStreamingTests(repositoryFactory: () => repository);
    }
  });
}
