/// Represents the data transfer object (DTO) for a Health Connect sync request.
/// This class is used to structure the health data before sending it to the backend.
class HealthConnectRequest {
  final String clientSyncTime;
  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> numerics;

  HealthConnectRequest({
    required this.clientSyncTime,
    required this.workouts,
    required this.numerics,
  });

  /// Converts the [HealthConnectRequest] instance to a JSON map.
  /// This method is used to serialize the object before sending it as the request body.
  Map<String, dynamic> toJson() => {
    "clientSyncTime": clientSyncTime,
    "workouts": workouts,
    "numerics": numerics,
  };
}
