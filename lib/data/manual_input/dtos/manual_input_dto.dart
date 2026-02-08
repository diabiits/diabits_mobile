import 'medication_value_input.dart';

/// Represents a single manual input data transfer object (DTO).
///
/// This class is used for serializing and deserializing manual input data when
/// communicating with the backend. It can represent different types of manual
/// data, such as medication or menstruation.
class ManualInputDto {
  final String? id;
  final String type;
  final DateTime dateFrom;
  final MedicationValueInput? medication;
  final String? flow;

  ManualInputDto({this.id, required this.type, required this.dateFrom, this.medication, this.flow});

  factory ManualInputDto.fromJson(Map<String, dynamic> json) {
    final String type = json['type'];

    return ManualInputDto(
      id: json['id']?.toString(),
      type: type,
      dateFrom: DateTime.parse(json['startTime']),
      medication: type == 'MEDICATION'
          ? MedicationValueInput.fromJson(json)
          : null,
      flow: json['flow'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'type': type,
    'dateFrom': dateFrom.toIso8601String(),
    if (medication != null) 'medication': medication!.toJson(),
    if (flow != null) 'flow': flow,
  };
}
