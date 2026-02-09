/// Represents the data transfer object (DTO) for the last sync timestamp response.
///
/// This class is used to parse the JSON response from the backend when fetching
/// the timestamp of the last successful Health Connect sync.
class LastSyncResponse {
  /// The timestamp of the last successful sync.
  final DateTime lastSyncAt;

  /// Creates a new instance of [LastSyncResponse].
  LastSyncResponse({required this.lastSyncAt});

  /// Creates a [LastSyncResponse] instance from a JSON map.
  ///
  /// This factory is used to deserialize the response body from the backend.
  factory LastSyncResponse.fromJson(Map<String, dynamic> json) {
    return LastSyncResponse(lastSyncAt: DateTime.parse(json['lastSyncAt']));
  }
}
