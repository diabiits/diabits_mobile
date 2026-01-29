import 'package:health/health.dart';

/// A utility class that defines constants related to Health Connect.
class HealthConnectConstants {
  /// The list of [HealthDataType] that the app requests access to.
  static const types = [
    HealthDataType.STEPS,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
  ];

  /// The list of [HealthDataAccess] permissions required for the specified data types.
  /// For this application, only read access is required.
  static final permissions = types.map((_) => HealthDataAccess.READ).toList();
}
