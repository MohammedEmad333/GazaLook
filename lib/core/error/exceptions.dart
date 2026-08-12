/// Low-level exceptions thrown by data sources.
///
/// Repositories catch these and convert them into typed [Failure]s, keeping
/// the throwing/catching boundary inside the data layer.
library;

/// Thrown by remote data sources on a backend/network error.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
}

/// Thrown by local data sources on a cache read/write error.
class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);
  final String message;
}

/// Thrown when a submitted OTP code is incorrect or expired.
class InvalidOtpException implements Exception {
  const InvalidOtpException([this.message = 'رمز التحقق غير صحيح']);
  final String message;
}
