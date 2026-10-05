/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class RateLimitException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  RateLimitException._({
    required this.message,
    required this.retryAfterSeconds,
  });

  factory RateLimitException({
    required String message,
    required int retryAfterSeconds,
  }) = _RateLimitExceptionImpl;

  factory RateLimitException.fromJson(Map<String, dynamic> jsonSerialization) {
    return RateLimitException(
      message: jsonSerialization['message'] as String,
      retryAfterSeconds: jsonSerialization['retryAfterSeconds'] as int,
    );
  }

  String message;

  int retryAfterSeconds;

  /// Returns a shallow copy of this [RateLimitException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RateLimitException copyWith({
    String? message,
    int? retryAfterSeconds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RateLimitException',
      'message': message,
      'retryAfterSeconds': retryAfterSeconds,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RateLimitException',
      'message': message,
      'retryAfterSeconds': retryAfterSeconds,
    };
  }

  @override
  String toString() {
    return 'RateLimitException(message: $message, retryAfterSeconds: $retryAfterSeconds)';
  }
}

class _RateLimitExceptionImpl extends RateLimitException {
  _RateLimitExceptionImpl({
    required String message,
    required int retryAfterSeconds,
  }) : super._(
         message: message,
         retryAfterSeconds: retryAfterSeconds,
       );

  /// Returns a shallow copy of this [RateLimitException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RateLimitException copyWith({
    String? message,
    int? retryAfterSeconds,
  }) {
    return RateLimitException(
      message: message ?? this.message,
      retryAfterSeconds: retryAfterSeconds ?? this.retryAfterSeconds,
    );
  }
}
