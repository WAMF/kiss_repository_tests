# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Dart testing framework package for validating KISS Repository implementations. It provides standardized test suites that ensure repository implementations meet behavioral contracts through a factory pattern.

## Development Commands

### Testing
```bash
dart test                    # Run all tests
dart test test/specific_test.dart  # Run specific test file
```

### Code Quality
```bash
dart fix                     # Auto-fix linting issues
dart analyse                 # Run static analysis
```

### Package Management
```bash
dart pub get                 # Install dependencies
dart pub upgrade             # Update dependencies
```

## Architecture

### Core Components

**Test Suite Runner** (`lib/src/repository_test_suite.dart`):
- `runRepositoryTests()` - Main entry point for running comprehensive test suites
- `RepositoryFactory<T>` - Abstract factory interface that implementations must provide
- Coordinates cleanup between test runs for isolation

**Test Modules** (`lib/src/`):
- `crud_tests.dart` - Basic CRUD operations testing
- `batch_tests.dart` - Bulk operations testing  
- `query_tests.dart` - Query system testing
- `streaming_tests.dart` - Real-time streaming functionality
- `auto_identify_tests.dart` - ID management and auto-generation

**Test Models** (`lib/src/test_models.dart`):
- `ProductModel` - Primary test entity with id, name, price, description, created fields
- `QueryByName` and `QueryByPriceRange` - Query implementations for testing

### Factory Pattern

Repository implementations must provide a factory that:
1. Creates fresh repository instances via `createRepository()`
2. Cleans up test data between tests via `cleanup()`
3. Disposes resources via `dispose()`

### Test Structure

Tests follow the pattern:
```dart
void main() {
  runRepositoryTests(
    implementationName: 'YourImplementation',
    factoryProvider: () => YourRepositoryFactory(),
    cleanup: () {},
    // Optional: configure which test suites to run
    config: const TestSuiteConfig.all(), // Default - runs all tests
  );
}
```

### Test Suite Configuration

Use `TestSuiteConfig` to control which test suites are executed:

**Predefined Configurations:**
- `TestSuiteConfig.all()` - All test suites (default)
- `TestSuiteConfig.basicOnly()` - Only CRUD tests
- `TestSuiteConfig.withoutStreaming()` - All tests except streaming
- `TestSuiteConfig.crudAndBatch()` - Only CRUD and batch operations

**Custom Configuration:**
```dart
const TestSuiteConfig(
  runCrudTests: true,      // Basic CRUD operations
  runBatchTests: true,     // Bulk operations (addAll, updateAll, deleteAll)
  runIdTests: true,        // ID management and auto-generation
  runQueryTests: true,     // Query system testing
  runStreamingTests: false, // Real-time streaming (disable if not supported)
)
```

**Common Usage Examples:**
```dart
// For repositories without streaming support
config: const TestSuiteConfig.withoutStreaming()

// For basic implementations
config: const TestSuiteConfig.basicOnly()

// Custom selection
config: const TestSuiteConfig(
  runCrudTests: true,
  runBatchTests: true,
  runIdTests: false,
  runQueryTests: false,
  runStreamingTests: false,
)
```

## Key Dependencies

- `kiss_repository: ^0.12.0` - Core repository interface
- `test: ^1.24.0` - Testing framework
- `very_good_analysis: ^6.0.0` - Linting rules

## Analysis Configuration

Uses `very_good_analysis` with specific overrides in `analysis_options.yaml`:
- Disables line length restrictions
- Allows print statements for debugging
- Disables API documentation requirements
- Disables pub dependency sorting enforcement