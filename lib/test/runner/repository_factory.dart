// ignore_for_file: public_member_api_docs

import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/test.dart';

/// Factory interface that each repository implementation must provide
/// to run the shared integration tests.
abstract class RepositoryFactory {
  Repository<ProductModel> createRepository();

  Future<void> cleanup();

  void dispose();
}
