import 'manual_input_dto.dart';

/// Represents the data transfer object for the response of a manual input query.
///
/// This class parses the backend response when fetching data for a specific day,
/// separating menstruation records from medication records.
class ManualInputResponse {
  final ManualInputDto? menstruation;
  final List<ManualInputDto> medications;

  ManualInputResponse({this.menstruation, required this.medications});

  /// Factory to deserialize the response body from the backend.
  factory ManualInputResponse.fromJson(Map<String, dynamic> json) {
    final menstruationJson = json['menstruation'];

    final List<dynamic> medicationsJson = json['medications'] ?? [];

    return ManualInputResponse(
      menstruation: menstruationJson != null ? ManualInputDto.fromJson(menstruationJson) : null,
      medications: medicationsJson.map((item) => ManualInputDto.fromJson(item)).toList(),
    );
  }
}
