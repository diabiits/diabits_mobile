/// A utility class that contains all the API endpoint paths.
///
/// This class centralizes all the backend endpoints, making them easy to manage
/// and reference from the repositories and API client.
class Endpoints {
  // Health Data Endpoints
  /// Endpoint for submitting health data from Health Connect.
  static const healthConnect = "/HealthData/healthConnect";
  /// Endpoint for submitting and retrieving manual health data entries.
  static const manualInput = "/HealthData/manual";
  static const manualInputBatch = "/HealthData/manual/batch";

  // User Endpoints
  /// Endpoint for getting the last sync timestamp for a user.
  static const lastSync = "/User/lastSync";

  // Authentication Endpoints
  static const login = "/Auth/login";
  static const register = "/Auth/register";
  static const logout = "/Auth/logout";
  /// Endpoint for validating the current access token.
  static const checkToken = "/Auth/checkToken";
  /// Endpoint for refreshing an expired access token.
  static const refreshToken = "/Auth/refreshToken";
}
