import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base failure class for typed error handling.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({
    required String message,
    int? statusCode,
  }) = NetworkFailure;

  const factory Failure.server({
    required String message,
  }) = ServerFailure;

  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  const factory Failure.parse({
    required String message,
  }) = ParseFailure;

  const factory Failure.rateLimited({
    required String message,
  }) = RateLimitedFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}

/// Extension for user-friendly display.
extension FailureX on Failure {
  String get displayMessage => switch (this) {
        NetworkFailure(:final message) => message,
        ServerFailure(:final message) => message,
        CacheFailure(:final message) => message,
        ParseFailure(:final message) => message,
        RateLimitedFailure(:final message) => message,
        UnknownFailure(:final message) => message,
      };
}
