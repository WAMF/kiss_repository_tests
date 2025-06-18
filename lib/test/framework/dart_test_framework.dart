// ignore_for_file: public_member_api_docs

import 'package:kiss_repository_tests/test.dart';
import 'package:test/test.dart' as test_pkg;

class DartTestFramework implements TestFramework {
  @override
  void group(String description, GroupFunction body) {
    return test_pkg.group(description, body);
  }

  @override
  void test(String description, TestFunction body) {
    return test_pkg.test(description, body);
  }

  @override
  void setUp(TestFunction body) {
    return test_pkg.setUp(body);
  }

  @override
  void tearDown(TestFunction body) {
    return test_pkg.tearDown(body);
  }

  @override
  void expect(dynamic actual, dynamic matcher) {
    return test_pkg.expect(actual, matcher);
  }

  // Matchers
  @override
  dynamic get isNotEmpty => test_pkg.isNotEmpty;

  @override
  dynamic get isEmpty => test_pkg.isEmpty;

  @override
  dynamic equals(dynamic expected) => test_pkg.equals(expected);

  @override
  dynamic contains(dynamic value) => test_pkg.contains(value);

  @override
  dynamic throwsA(dynamic matcher) => test_pkg.throwsA(matcher);

  @override
  dynamic isA<T>() => test_pkg.isA<T>();

  @override
  dynamic get isTrue => test_pkg.isTrue;

  @override
  dynamic isNot(dynamic matcher) => test_pkg.isNot(matcher);
}
