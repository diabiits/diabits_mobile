import 'package:diabits_mobile/data/health_connect/health_connect_constants.dart';
import 'package:diabits_mobile/data/network/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../network/api_client.dart';
import '../network/requests/health_connect_request.dart';
import '../network/responses/last_sync_response.dart';
import 'permission_handler.dart';

/// A class responsible for syncing Health Connect data with the backend.
///
/// This class fetches health data from the Health Connect platform, processes it,
/// and sends it to the backend. It handles determining the correct time range
/// to sync and converting the data into the required format.
class HealthConnectSync {
  final ApiClient _client;
  final PermissionHandler _permissionHandler;
  late final Health _health;

  HealthConnectSync({
    required ApiClient client,
    required PermissionHandler permissions,
  }) : _client = client,
       _permissionHandler = permissions;

  DateTime? _syncTime;

  /// Executes the entire sync process.
  ///
  /// Returns true if data was successfully sent or if there was nothing to sync.
  /// Returns false if the sync was aborted due to auth/server issues or failure to send.
  Future<bool> runSync() async {
    _health = await _permissionHandler.initHealthConnect();

    final range = await _getRangeToSync();
    if (range == null) return false;

    final data = await _getHealthConnectData(range);
    return await _sendToBackend(data);
  }

  /// Determines the time range for the sync based on the last successful sync time.
  Future<DateTimeRange?> _getRangeToSync() async {
    final result = await _client.get(Endpoints.lastSync);

    DateTime now = DateTime.now();
    DateTime start;

    if (result.success) {
      final lastSync = LastSyncResponse.fromJson(result.body).lastSyncAt;
      start = _startOfDay(lastSync);
    } else if (result.statusCode == 404) {
      // First time sync - default to a week ago
      final weekAgo = now.subtract(const Duration(days: 7));
      start = _startOfDay(weekAgo);
    } else {
      // ApiClient already broadcasted the specific AuthEvent
      return null;
    }

    // Sync up to the end of yesterday to ensure third-party apps have had time to write their data to Health Connect.
    final yesterday = now.subtract(const Duration(days: 1));
    final end = _endOfDay(yesterday);

    return DateTimeRange(start: start, end: end);
  }

  /// Fetches health data from Health Connect for the determined time range.
  Future<List<HealthDataPoint>> _getHealthConnectData(
    DateTimeRange range,
  ) async {
    _syncTime = range.end;

    final data = await _health.getHealthDataFromTypes(
      types: HealthConnectConstants.types,
      startTime: range.start,
      endTime: range.end,
    );

    return _health.removeDuplicates(data);
  }

  /// Sends the processed health data to the backend.
  Future<bool> _sendToBackend(List<HealthDataPoint> data) async {
    if (data.isEmpty) return true;

    final batch = _convertToRequest(data);
    var result = await _client.post(
      Endpoints.healthConnect,
      batch.toJson(),
      timeout: const Duration(minutes: 10),
    );

    return result.success;
  }

  /// Converts the list of [HealthDataPoint] into a [HealthConnectRequest].
  HealthConnectRequest _convertToRequest(List<HealthDataPoint> data) {
    final workouts = <Map<String, dynamic>>[];
    final numerics = <Map<String, dynamic>>[];

    for (final d in data) {
      final json = d.toJson();
      if (d.type == HealthDataType.WORKOUT) {
        workouts.add(json);
      } else {
        numerics.add(json);
      }
    }

    return HealthConnectRequest(
      clientSyncTime: _syncTime!.toIso8601String(),
      workouts: workouts,
      numerics: numerics,
    );
  }

  /// Returns the start of the given day (00:00:00).
  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 0, 0, 0);

  /// Returns the end of the given day (23:59:59).
  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);
}
