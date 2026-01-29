/// Represents the data transfer object (DTO) for a Health Connect sync request.
///
/// This class is used to structure the health data before sending it to the
/// backend. It includes the client-side timestamp of the sync, as well as
/// lists of workout and numeric data points.
class HealthConnectRequest {
  /// The ISO 8601 formatted timestamp of when the sync was initiated on the client.
  final String clientSyncTime;

  /// A list of workout data points, represented as JSON maps.
  final List<Map<String, dynamic>> workouts;

  /// A list of numeric health data points (e.g., steps, heart rate), represented
  /// as JSON maps.
  final List<Map<String, dynamic>> numerics;

  /// Creates a new instance of [HealthConnectRequest].
  HealthConnectRequest({
    required this.clientSyncTime,
    required this.workouts,
    required this.numerics,
  });

  /// Converts the [HealthConnectRequest] instance to a JSON map.
  ///
  /// This method is used to serialize the object before sending it as the
  /// request body.
  Map<String, dynamic> toJson() => {
    "clientSyncTime": clientSyncTime,
    "workouts": workouts,
    "numerics": numerics,
  };
}
