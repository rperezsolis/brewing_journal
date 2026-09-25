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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

enum ExtractionMethod implements _isc.SerializableModel {
  v60,
  espresso,
  frenchPress,
  aeropress,
  chemex,
  coldBrew,
  matchaWhisk,
  other;

  static ExtractionMethod fromJson(String name) {
    switch (name) {
      case 'v60':
        return ExtractionMethod.v60;
      case 'espresso':
        return ExtractionMethod.espresso;
      case 'frenchPress':
        return ExtractionMethod.frenchPress;
      case 'aeropress':
        return ExtractionMethod.aeropress;
      case 'chemex':
        return ExtractionMethod.chemex;
      case 'coldBrew':
        return ExtractionMethod.coldBrew;
      case 'matchaWhisk':
        return ExtractionMethod.matchaWhisk;
      case 'other':
        return ExtractionMethod.other;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ExtractionMethod"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
