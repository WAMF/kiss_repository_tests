# KISS Repository Tests

A comprehensive testing framework for KISS Repository implementations. This package provides a standardized test suite and factory pattern that ensures all repository implementations meet the same behavioral contracts.

## Overview

The KISS Repository Tests package provides:

- **🏭 Factory Pattern**: Standardized way to create and test repository implementations
- **📋 Comprehensive Test Suite**: 28+ tests covering CRUD, batch operations, queries, streaming, and ID management
- **🧹 Automatic Cleanup**: Built-in cleanup between tests to ensure test isolation
- **🔧 Extensible Framework**: Easy to add new test scenarios and implementations

## Features

- ✅ **Basic CRUD Operations** - Create, Read, Update, Delete functionality
- ✅ **Batch Operations** - Bulk add, update, and delete operations
- ✅ **Query System** - Complex querying with filters and conditions
- ✅ **Real-time Streaming** - Live data updates and change notifications
- ✅ **ID Management** - Auto-generation and validation of unique identifiers
- ✅ **Error Handling** - Proper exception handling for edge cases
- ✅ **Test Isolation** - Clean state between tests with automatic cleanup

## Architecture

### Factory Pattern

Each repository implementation provides a factory that implements the `RepositoryFactory` interface:

```dart
abstract class RepositoryFactory {
  Repository<ProductModel> createRepository();
  Future<void> cleanup();
  void dispose();
}
```

### Test Framework

The testing framework provides:

- **`RepositoryTester`**: Main test runner that executes all test suites
- **`TestFramework`**: Abstraction for different test frameworks (currently supports Dart's `test` package)
- **Test Logic Modules**: Separate modules for different aspects (CRUD, batch, query, streaming, ID management)

## Getting Started

### 1. Add Dependency

Add `kiss_repository_tests` to your `pubspec.yaml`:

```yaml
dev_dependencies:
  kiss_repository_tests:
    path: ../kiss_repository_tests  # or your path
  test: ^1.24.0
```

### 2. Create a Factory

Implement the `RepositoryFactory` interface for your repository:

```dart
import 'package:kiss_repository_tests/test.dart';

class MyRepositoryFactory implements RepositoryFactory {
  Repository<ProductModel>? _repository;
  
  static Future<void> initialize() async {
    // Setup your repository (database connections, etc.)
  }

  @override
  Repository<ProductModel> createRepository() {
    _repository = MyRepository<ProductModel>(
      // your repository configuration
    );
    return _repository!;
  }

  @override
  Future<void> cleanup() async {
    // Clean up test data between tests
    final allItems = await _repository!.query();
    if (allItems.isNotEmpty) {
      final ids = allItems.map((item) => item.id).toList();
      await _repository!.deleteAll(ids);
    }
  }

  @override
  void dispose() {
    _repository?.dispose();
    _repository = null;
  }
}
```

### 3. Create Test File

Create your test file following the standard pattern:

```dart
import 'package:kiss_repository_tests/test.dart';
import 'package:test/test.dart';

import 'factories/my_repository_factory.dart';

void main() {
  setUpAll(() async {
    await MyRepositoryFactory.initialize();
  });

  final factory = MyRepositoryFactory();
  final tester = RepositoryTester('MyRepository', factory, () {});

  tester.run();
}
```

### 4. Run Tests

```bash
dart test test/integration/all_integration_tests.dart
```

## Usage

This testing framework can be used with any repository implementation that follows the KISS Repository interface contract.

## Contributing

When adding new test scenarios:

1. Add the test logic to the appropriate module in `lib/test/`
2. Update the `RepositoryTester` to include the new test
3. Ensure all existing implementations still pass
4. Document any new requirements for factory implementations

## Integration

To integrate this testing framework with your repository implementation:

1. Implement the `RepositoryFactory` interface
2. Create your test files following the recommended structure
3. Run the comprehensive test suite to validate your implementation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
