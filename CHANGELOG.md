## 0.3.1

- Update kiss_repository dependency to ^0.14.0

## 0.3.0

- **New Feature**: Add selective test suite execution with `TestSuiteConfig`
- Add predefined configurations: `all()`, `basicOnly()`, `withoutStreaming()`, `crudAndBatch()`
- Support custom test suite selection (CRUD, batch, ID management, query, streaming)
- Maintain backward compatibility - existing code continues to work unchanged
- Update documentation with configuration examples for repositories without streaming support

## 0.2.1

- Fix all analyzer warnings (23 issues resolved)
- Update tests for kiss_repository v0.12.0 interface change: delete now throws exception for non-existent records
- Add analysis_options.yaml rules to ignore print statements and documentation requirements for test package

## 0.2.0 (Breaking)

- Add delays between streaming test operations to ensure distinct processing
- Reduce streaming test timeout from 15s to 2s for faster test execution
- Replace QueryByPriceGreaterThan and QueryByPriceLessThan with unified QueryByPriceRange
- Add new range query test case supporting both min and max price constraints

## 0.1.0

- Initial version.
