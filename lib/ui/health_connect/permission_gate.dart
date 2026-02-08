import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/ui/manual_input/manual_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

import '../shared/loading_screen.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool? _isGranted;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // TODO Implement check only method when not asking for permissions so aggressively (show dialog before asking)
    final granted = await context.read<PermissionHandler>().requestPermissions();
    setState(() => _isGranted = granted);
  }

  @override
  Widget build(BuildContext context) {
    if (_isGranted == null) {
      return const LoadingScreen();
    }

    if (_isGranted == true) {
      return const ManualInputScreen();
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.health_and_safety, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Health Connect Permissions Required',
              style: theme.textTheme.headlineSmall,
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Diabits requires Health Connect permissions to sync your data. '
              'Please grant the permissions in system settings and then press \'Grant Permission\'.',
              textAlign: .center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ph.openAppSettings(),
              child: const Text('Open System Settings'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _checkPermissions, child: const Text('Grant Permissions')),
          ],
        ),
      ),
    );
  }
}
