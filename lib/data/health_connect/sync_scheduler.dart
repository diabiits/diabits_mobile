import 'package:diabits_mobile/data/auth/token_storage.dart';
import 'package:diabits_mobile/data/health_connect/health_connect_sync.dart';
import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

/// Controls registration of background sync tasks for Health Connect data.
/// WorkManager runs tasks in a separate isolate, so the scheduler cannot use DI.
class SyncScheduler {
  bool _initialized = false;

  /// Starts background syncing by initializing WorkManager and registering periodic tasks.
  /// The daily sync is scheduled at 06:00 and syncs the previous days data.
  Future<void> startBackgroundSync() async {
    if (_initialized) return;

    await Workmanager().initialize(callbackDispatcher);
    //TODO Remove when done testing/exam
    await Workmanager().registerOneOffTask("uniqueName", "taskName");

    await Workmanager().registerPeriodicTask(
      "dailyHealthSync",
      "dailyHealthSyncTask",
      frequency: const Duration(days: 1),
      initialDelay: _calculateInitialDelayFor6AM(),
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
    );

    _initialized = true;
  }

  /// Used when the user logs out or permissions change.
  Future<void> stopBackgroundSync() async {
    await Workmanager().cancelAll();
    _initialized = false;
  }

  Duration _calculateInitialDelayFor6AM() {
    final now = DateTime.now();
    final sixAM = DateTime(now.year, now.month, now.day, 6);

    return now.isBefore(sixAM)
        ? sixAM.difference(now)
        : sixAM.add(const Duration(days: 1)).difference(now);
  }
}

/// WorkManager callback used for background execution.
/// This must be a top-level function because background work runs in its own isolate.
/// Dependencies are recreated here because runtime instances from the main isolate (Provider, app state, etc.) are not available.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await dotenv.load();

    final tokenStorage = TokenStorage();
    final client = ApiClient(tokens: tokenStorage);
    final permissions = PermissionHandler();

    final sync = HealthConnectSync(client: client, permissions: permissions);
    final success = await sync.runSync();
    return success;
  });
}