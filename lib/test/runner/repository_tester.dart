// ignore_for_file: public_member_api_docs

import 'package:kiss_repository/kiss_repository.dart';
import 'package:kiss_repository_tests/test.dart';
import 'package:test/test.dart' as test_pkg;

class RepositoryTester {
  RepositoryTester(this.implementationName, this.factory, this.tearDown);

  final String implementationName;
  final RepositoryFactory factory;
  final void Function() tearDown;


  void run() {
    runRepositoryTests(
      implementationName: implementationName, 
      factoryProvider: () => factory, cleanup: tearDown,
      );
  }
}

void runRepositoryTests({
  required String implementationName,
  required RepositoryFactory Function() factoryProvider,
  required void Function() cleanup,
}) {
  test_pkg.group('$implementationName Repository Tests', () {
    late RepositoryFactory factory;
    late Repository<ProductModel> repository;
    final framework = DartTestFramework();

    test_pkg.setUpAll(() {
      factory = factoryProvider();
      repository = factory.createRepository();
    });

    test_pkg.setUp(() async {
      await factory.cleanup();
    });

    test_pkg.tearDown(() {
      cleanup();
    });

    runCrudTests(repositoryFactory: () => repository, framework: framework);

    runBatchTests(repositoryFactory: () => repository, framework: framework);

    runIdTests(repositoryFactory: () => repository, framework: framework);

    runQueryTests(repositoryFactory: () => repository, framework: framework);

    runStreamingTests(repositoryFactory: () => repository, framework: framework);
  });
}
