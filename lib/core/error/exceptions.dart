abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
}

class ServerException extends AppException {
  const ServerException(String message, {String? code}) : super(message, code: code);
}

class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) : super(message, code: code);
}

class AuthException extends AppException {
  const AuthException(String message, {String? code}) : super(message, code: code);
}

class CacheException extends AppException {
  const CacheException(String message, {String? code}) : super(message, code: code);
}

