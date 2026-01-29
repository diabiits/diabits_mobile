/// A utility class that contains all the API endpoint paths.
///
/// This class centralizes all the backend endpoints, making them easy to manage
/// and reference from the repositories and API client.
class Endpoints {
  // Health Data Endpoints
  /// Endpoint for submitting health data from Health Connect.
  static const healthConnect = "/HealthData/healthConnect";

  // User Endpoints
  /// Endpoint for getting the last sync timestamp for a user.
  static const lastSync = "/User/lastSync";

  // Authentication Endpoints
  /// Endpoint for validating the current access token.
  static const checkToken = "/Auth/checkToken";

  /// Endpoint for refreshing an expired access token.
  static const refreshToken = "/Auth/refreshToken";
}
