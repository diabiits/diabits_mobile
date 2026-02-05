/// A utility class that provides static methods for form field validation.
class FieldValidators {
  /// A validator that checks if a field is empty.
  /// Returns an error message if the value is null or empty, otherwise returns null.
  static String? requiredValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  /// A validator for password fields.
  /// Checks for a minimum length and the presence of lowercase, uppercase,
  /// numeric, and special characters.
  static String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (value.length < 6) return 'Must be at least 6 characters';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Missing lowercase';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Missing uppercase';
    if (!value.contains(RegExp(r'\d'))) return 'Missing digit';
    if (!value.contains(RegExp(r'[^A-Za-z0-9]')))
      return 'Missing special character';
    return null;
  }

  /// A validator for integer fields.
  /// Checks if the value is a valid whole number.
  static String? integerValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (int.tryParse(value) == null) return 'Must be a whole number';
    return null;
  }
}
