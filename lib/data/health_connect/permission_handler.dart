import 'package:health/health.dart';
import 'health_connect_constants.dart';

/// A handler for initializing the Health Connect SDK and managing permissions.
///
/// This class abstracts the logic for interacting with the `health` package to
/// ensure the Health Connect SDK is available, installed if necessary, and that
/// all required permissions are granted by the user.
class PermissionHandler {
  final _health = Health();

  /// Requests all necessary Health Connect permissions.
  ///
  /// This method should be called from the foreground. It first ensures that
  /// the Health Connect SDK is initialized. Then, it requests authorization for
  /// the required data types, as well as for historical data and background
  /// data access.
  ///
  /// Returns `true` if all permissions are successfully granted, `false` otherwise.
  Future<bool> requestPermissions() async {
    try {
      await initHealthConnect();
    } catch (e) {
      return false;
    }
    bool healthPermissionsGranted = await _health.hasPermissions(HealthConnectConstants.types) ?? false;

    if (!healthPermissionsGranted) {
      healthPermissionsGranted = await _health.requestAuthorization(HealthConnectConstants.types);
    }

    final backgroundPermissionsGranted = await _health.requestHealthDataInBackgroundAuthorization();

    return healthPermissionsGranted && backgroundPermissionsGranted;
  }

  /// Initializes the Health Connect SDK and ensures it is available.
  ///
  /// This method configures the health factory and checks if the Health Connect
  /// SDK is installed and available on the device. If not, it will prompt the
  /// user to install it and throw an exception to indicate that the process
  /// is not yet complete.
  ///
  /// Returns the initialized [Health] instance.
  Future<Health> initHealthConnect() async {
    await _health.configure();

    final status = await _health.getHealthConnectSdkStatus();
    if (status?.name != "sdkAvailable") {
      await _health.installHealthConnect();

      final newStatus = await _health.getHealthConnectSdkStatus();
      if (newStatus?.name != "sdkAvailable") {
        throw Exception("Health Connect not installed");
      }
    }
    return _health;
  }
}
