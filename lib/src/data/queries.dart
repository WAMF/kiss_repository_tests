// ignore_for_file: public_member_api_docs

import 'package:kiss_repository/kiss_repository.dart';

/// Query classes for ProductModel

class QueryByName extends Query {
  const QueryByName(this.namePrefix);
  final String namePrefix;
}

class QueryByCreatedAfter extends Query {
  const QueryByCreatedAfter(this.date);
  final DateTime date;
}

class QueryByCreatedBefore extends Query {
  const QueryByCreatedBefore(this.date);
  final DateTime date;
}

class QueryByPriceGreaterThan extends Query {
  const QueryByPriceGreaterThan(this.price);
  final double price;
}

class QueryByPriceLessThan extends Query {
  const QueryByPriceLessThan(this.price);
  final double price;
}
