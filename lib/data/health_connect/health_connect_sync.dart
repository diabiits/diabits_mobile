import 'package:diabits_mobile/data/health_connect/health_connect_constants.dart';
import 'package:diabits_mobile/data/network/endpoints.dart';
import 'package:diabits_mobile/data/network/requests/last_sync_request.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../network/api_client.dart';
import '../network/requests/health_connect_request.dart';
import '../network/responses/last_sync_response.dart';
import 'permission_handler.dart';

/// A class responsible for syncing Health Connect data with the backend.
class HealthConnectSync {
  final ApiClient _client;
  final PermissionHandler _permissionHandler;
  late final Health _health;

  HealthConnectSync({required ApiClient client, required PermissionHandler permissions})
    : _client = client,
      _permissionHandler = permissions;

  DateTime? _syncTime;

  Future<bool> runSync() async {
    _health = await _permissionHandler.initHealthConnect();

    final range = await _getRangeToSync();
    if (range == null) return false;

    final data = await _getHealthConnectData(range);
    return await _sendInBatches(data);
  }

  Future<DateTimeRange?> _getRangeToSync() async {
    final result = await _client.get(Endpoints.lastSync);

    DateTime now = DateTime.now();
    DateTime start;

    if (result.success) {
      final lastSync = LastSyncResponse.fromJson(result.body).lastSyncAt;
      start = _startOfDay(lastSync);
    } else if (result.statusCode == 404) {
      final weekAgo = now.subtract(const Duration(days: 7));
      start = _startOfDay(weekAgo);
    } else {
      return null;
    }

    final yesterday = now.subtract(const Duration(days: 1));
    final end = _endOfDay(yesterday);

    if (start.isAfter(end)) return null;

    return DateTimeRange(start: start, end: end);
  }

  //TODO Get steps in hour increments?
  Future<List<HealthDataPoint>> _getHealthConnectData(DateTimeRange range) async {
    _syncTime = range.end;

    final data = await _health.getHealthDataFromTypes(
      types: HealthConnectConstants.types,
      startTime: range.start,
      endTime: range.end,
      preferredUnits: {HealthDataType.BLOOD_GLUCOSE: HealthDataUnit.MILLIMOLES_PER_LITER},
    );

    return _health.removeDuplicates(data);
  }

  Future<bool> _sendInBatches(List<HealthDataPoint> data) async {
    if (data.isEmpty) return true;

    const int batchSize = 1000;
    for (var i = 0; i < data.length; i += batchSize) {
      final end = (i + batchSize < data.length) ? i + batchSize : data.length;
      final chunk = data.sublist(i, end);

      final request = _convertToRequest(chunk);

      final result = await _client.post(
        Endpoints.healthConnect,
        request.toJson(),
        timeout: const Duration(minutes: 5),
      );

      if (!result.success) {
        debugPrint("Failed to sync batch starting at index $i");
        return false;
      }
    }
    await _client.put(Endpoints.lastSync, LastSyncRequest(syncTime: _syncTime!.toIso8601String()));
    return true;
  }

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
      workouts: workouts,
      numerics: numerics,
    );
  }

  DateTime _startOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 0, 0, 0);

  DateTime _endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);
}
