import 'dart:convert';

import 'package:diabits_mobile/data/health_connect/health_connect_constants.dart';
import 'package:diabits_mobile/data/network/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../network/api_client.dart';
import 'dtos/health_connect_request.dart';
import 'dtos/last_sync_response.dart';
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

  /// Creates a new instance of [HealthConnectSync].
  ///
  /// It requires an [ApiClient] for backend communication and a [PermissionHandler]
  /// to interact with the Health Connect platform.
  HealthConnectSync({
    required ApiClient client,
    required PermissionHandler permissions,
  }) : _client = client,
       _permissionHandler = permissions;

  DateTime? _syncTime;

  /// Executes the entire sync process.
  ///
  /// This method initializes the connection to Health Connect, fetches the data,
  /// and sends it to the backend. It returns `true` if the sync is successful,
  /// otherwise `false`.
  Future<bool> runSync() async {
    try {
      _health = await _permissionHandler.initHealthConnect();

      final data = await _getHealthConnectData();
      final isSuccess = await _sendToBackend(data);

      return isSuccess;
    } catch (e, s) {
      debugPrint("Error during sync: $e\n$s");
      return false;
    }
  }

  /// Fetches health data from Health Connect for the determined time range.
  Future<List<HealthDataPoint>> _getHealthConnectData() async {
    var range = await _getRangeToSync();
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
    final batch = _convertToRequest(data);

    var response = await _client.post(Endpoints.healthConnect, batch.toJson());

    return response.statusCode == 200;
  }

  /// Determines the time range for the sync based on the last successful sync time.
  Future<DateTimeRange> _getRangeToSync() async {
    final response = await _client.get(Endpoints.lastSync);
    DateTime now = DateTime.now();

    DateTime start;

    //TODO Warn user if it's been more than a week since last sync?
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final lastSync = LastSyncResponse.fromJson(json).lastSyncAt;
      start = _startOfDay(lastSync);
    } else if (response.statusCode == 404) {
      final weekAgo = now.subtract(const Duration(days: 7));
      start = _startOfDay(weekAgo);
    } else {
      //TODO Throw exception?
      throw Exception("Failed to load lastSync value");
    }

    /// Syncing from yesterday because some apps are slow to sync to Health Connect
    final yesterday = now.subtract(const Duration(days: 1));
    final end = _endOfDay(yesterday);

    return DateTimeRange(start: start, end: end);
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
