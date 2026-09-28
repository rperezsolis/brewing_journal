/// The last path segment of a pasted invite URL, or the bare token.
String inviteTokenFromInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;
  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.last;
  }
  final parts = trimmed.split('/').where((part) => part.isNotEmpty);
  return parts.isEmpty ? trimmed : parts.last;
}
