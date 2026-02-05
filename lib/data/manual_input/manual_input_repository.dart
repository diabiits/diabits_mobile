import '../network/api_client.dart';
import '../network/endpoints.dart';
import 'dtos/manual_input_dto.dart';
import 'dtos/manual_input_request.dart';
import 'dtos/manual_input_response.dart';

/// A repository for handling manual input of health data.
///
/// This class provides methods for fetching, creating, updating, and deleting manual health data entries.
class ManualInputRepository {
  final ApiClient _client;

  ManualInputRepository({required ApiClient client}) : _client = client;

  /// Fetches the manual input data for a specific day.
  Future<ManualInputResponse?> getManualInputForDay(DateTime day) async {
    var result = await _client.get(Endpoints.manualInput, params: {"date": day.toIso8601String()});

    if (result.success && result.body != null) {
      return ManualInputResponse.fromJson(result.body);
    }
    return null;
  }

  /// Submits a new manual input entry.
  Future<bool> submitManualInput(ManualInputRequest req) async {
    var result = await _client.post(Endpoints.manualInput, req.toJson());
    return result.success;
  }

  /// Updates an existing manual input entry.
  Future<bool> updateManualInput(ManualInputDto dto) async {
    final result = await _client.put(Endpoints.manualInput, dto.toJson());
    return result.success;
  }

  /// Deletes a manual input entry by its ID.
  Future<bool> deleteManualInput(String id) async {
    var result = await _client.delete("${Endpoints.manualInput}/$id");
    return result.success;
  }
}
