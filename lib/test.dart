// Testing utilities for KISS Repository implementations
// Import this to get access to all shared test logic and framework

// ignore_for_file: directives_ordering

// Runner components (factory and tester)
export 'package:kiss_repository_tests/test/runner/repository_factory.dart';
export 'package:kiss_repository_tests/test/runner/repository_tester.dart';

// Test framework
export 'package:kiss_repository_tests/test/framework/test_framework.dart';
export 'package:kiss_repository_tests/test/framework/dart_test_framework.dart';

// Shared test logic
export 'package:kiss_repository_tests/test/basic_crud_logic.dart';
export 'package:kiss_repository_tests/test/basic_batch_logic.dart';
export 'package:kiss_repository_tests/test/basic_id_logic.dart';
export 'package:kiss_repository_tests/test/basic_query_logic.dart';
export 'package:kiss_repository_tests/test/basic_streaming_logic.dart';

// Test data models
export 'package:kiss_repository_tests/test/data/product_model.dart';
export 'package:kiss_repository_tests/test/data/queries.dart';
