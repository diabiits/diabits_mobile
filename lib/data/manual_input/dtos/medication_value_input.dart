/// Represents the medication details for a manual input record.
///
/// This class is nested within [ManualInputDto] when the record type is
/// 'MEDICATION'. It contains the name and amount of the medication.
class MedicationValueInput {
  /// The name of the medication.
  final String name;

  /// The amount of medication taken (e.g., in units or milligrams).
  final int amount;

  /// Creates a new instance of [MedicationValueInput].
  MedicationValueInput({
    required this.name,
    required this.amount,
  });

  /// Creates a [MedicationValueInput] instance from a JSON map.
  factory MedicationValueInput.fromJson(Map<String, dynamic> json) {
    return MedicationValueInput(
      name: json['name'],
      amount: json['amount'],
    );
  }

  /// Converts the [MedicationValueInput] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "name": name,
        "amount": amount,
      };
}
