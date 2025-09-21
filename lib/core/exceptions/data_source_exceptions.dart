class DataSourceException implements Exception {
  final String message;
  final dynamic originalError;

  const DataSourceException(this.message, {this.originalError});

  @override
  String toString() => 'DataSourceException: $message';
}

class DataLoadException extends DataSourceException {
  const DataLoadException(super.message, {super.originalError});
}

class DataParseException extends DataSourceException {
  const DataParseException(super.message, {super.originalError});
}

class EntityNotFoundException extends DataSourceException {
  const EntityNotFoundException(super.message, {super.originalError});
}