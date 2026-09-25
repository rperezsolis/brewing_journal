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

abstract class UploadTicket
    implements _is.SerializableModel, _is.ProtocolSerialization {
  UploadTicket._({
    required this.path,
    required this.description,
  });

  factory UploadTicket({
    required String path,
    required String description,
  }) = _UploadTicketImpl;

  factory UploadTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return UploadTicket(
      path: jsonSerialization['path'] as String,
      description: jsonSerialization['description'] as String,
    );
  }

  String path;

  String description;

  /// Returns a shallow copy of this [UploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UploadTicket copyWith({
    String? path,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UploadTicket',
      'path': path,
      'description': description,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UploadTicket',
      'path': path,
      'description': description,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UploadTicketImpl extends UploadTicket {
  _UploadTicketImpl({
    required String path,
    required String description,
  }) : super._(
         path: path,
         description: description,
       );

  /// Returns a shallow copy of this [UploadTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UploadTicket copyWith({
    String? path,
    String? description,
  }) {
    return UploadTicket(
      path: path ?? this.path,
      description: description ?? this.description,
    );
  }
}
