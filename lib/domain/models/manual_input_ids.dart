//TODO Move to helper class?
/// A simple utility to generate unique temporary IDs for manual inputs during a single app session.
class ManualInputIds {
  static int _nextId = -1;

  /// Returns a unique negative integer.
  static int next() => _nextId--;
}