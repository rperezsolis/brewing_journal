import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum ShareStatus { idle, rendering, sharing, shared, unavailable, failure }

class ShareState extends Equatable {
  const ShareState({
    this.status = ShareStatus.idle,
    this.pngBytes,
    this.error,
  });

  final ShareStatus status;
  final Uint8List? pngBytes;
  final Object? error;

  ShareState copyWith({
    ShareStatus? status,
    Uint8List? pngBytes,
    Object? error,
    bool clearError = false,
  }) {
    return ShareState(
      status: status ?? this.status,
      pngBytes: pngBytes ?? this.pngBytes,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, pngBytes, error];
}
