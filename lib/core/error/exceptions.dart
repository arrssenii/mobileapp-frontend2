class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({this.message = 'Server error', this.statusCode});
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);
}

class UnauthorizedException extends ServerException {
  UnauthorizedException()
      : super(message: 'Unauthorized', statusCode: 401);
}
