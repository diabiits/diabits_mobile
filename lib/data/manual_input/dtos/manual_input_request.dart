import 'manual_input_dto.dart';

/// Represents the data transfer object (DTO) for a bulk manual input request.
///
/// This class is used to batch and send multiple new medication and menstruation
/// records to the backend in a single request.
class ManualInputRequest {
  /// A list of new medication records to be created.
  final List<ManualInputDto> medications;

  /// A list of new menstruation records to be created.
  final List<ManualInputDto> menstruations;

  /// Creates a new instance of [ManualInputRequest].
  ManualInputRequest({required this.medications, required this.menstruations});

  /// Converts the [ManualInputRequest] instance to a JSON map.
  ///
  /// This method is used to serialize the object before sending it as the
  /// request body.
  Map<String, dynamic> toJson() => {
    "medications": medications.map((m) => m.toJson()).toList(),
    "menstruations": menstruations.map((m) => m.toJson()).toList(),
  };
}
