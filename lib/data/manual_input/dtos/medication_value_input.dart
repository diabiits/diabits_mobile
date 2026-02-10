/// Represents the medication details for a manual input record.
///
/// This class is nested within [ManualInputDto] when the record type is
/// 'MEDICATION'. It contains the name, quantity and strength of the medication.
class MedicationValueInput {
  final String name;
  final double quantity;

  /// Dose per unit. Example: 500 mg per tablet
  final double strengthValue;
  final String strengthUnit;

  /// Creates a new instance of [MedicationValueInput].
  MedicationValueInput({
    required this.name,
    required this.quantity,
    required this.strengthValue,
    required this.strengthUnit,
  });

  /// Creates a [MedicationValueInput] instance from a JSON map.
  factory MedicationValueInput.fromJson(Map<String, dynamic> json) {
    return MedicationValueInput(
      name: json['name'],
      quantity: (json['quantity'] as num).toDouble(),
      strengthValue: (json['strengthValue'] as num).toDouble(),
      strengthUnit: json['strengthUnit'],
    );
  }

  /// Converts the [MedicationValueInput] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        "name": name,
        "quantity": quantity,
        "strengthValue": strengthValue,
        "strengthUnit": strengthUnit,
      };
}
