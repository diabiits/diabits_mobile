/// Represents the data transfer object (DTO) for a Health Connect sync request.
/// This class is used to structure the health data before sending it to the backend.
class HealthConnectRequest {
  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> numerics;

  HealthConnectRequest({
    required this.workouts,
    required this.numerics,
  });

  /// Converts the [HealthConnectRequest] instance to a JSON map.
  /// This method is used to serialize the object before sending it as the request body.
  Map<String, dynamic> toJson() => {
    "workouts": workouts,
    "numerics": numerics,
  };
}
