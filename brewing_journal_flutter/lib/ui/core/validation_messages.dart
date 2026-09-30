/// Prefix for client-side validation stored on [BrewingException.message].
///
/// Server validation text does not use this prefix, so it is shown as sent.
const validationMessagePrefix = '@@';

/// A stable key the UI turns into a localized sentence.
///
/// [args] are interpolated in order and must not contain `:`.
String validationMessage(String key, [List<Object> args = const []]) {
  if (args.isEmpty) return '$validationMessagePrefix$key';
  return '$validationMessagePrefix$key:${args.join(':')}';
}

/// `1` or `0.1`, matching the numbers the wizard checks.
String formatLimit(num value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toString();
