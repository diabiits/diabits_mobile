import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../network/requests/manual_input_request.dart';
import '../network/responses/manual_input_response.dart';

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
  Future<bool> submitManualInputs(ManualInputRequest req) async {
    var result = await _client.post(Endpoints.manualInputBatch, req.toJson());
    return result.success;
  }

  Future<bool> updateManualInputs(ManualInputRequest req) async {
    final result = await _client.put(Endpoints.manualInputBatch, req.toJson());
    return result.success;
  }

  Future<bool> deleteManualInputs(ManualInputDeleteRequest req) async {
    var result = await _client.delete(Endpoints.manualInputBatch, body: req.toJson());
    return result.success;
  }
}
