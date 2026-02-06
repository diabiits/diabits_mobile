import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/date_selector.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/medication_form.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/medication_list.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/menstruation_section.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:provider/provider.dart';

import '../shared/primary_button.dart';
import 'manual_input_view_model.dart';

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  @override
  void initState() {
    super.initState();
    _ensurePermissionsAndLoad();
  }

  Future<void> _ensurePermissionsAndLoad() async {
    final permissionHandler = PermissionHandler();

    final granted = await permissionHandler.requestPermissions();
    if (!mounted) return;

    if (!granted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Permissions required'),
          content: const Text(
            'Health permissions are needed to load and save manual input for the selected day.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () {
                permission_handler.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open settings'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _ensurePermissionsAndLoad();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );

      return;
    }

    await context.read<ManualInputViewModel>().loadDataForSelectedDate();
  }

  Future<void> _openMedicationSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 64),
        child: MedicationForm(),
      ),
    );
  }

  Future<void> _openFlowSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: MenstruationFlowSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const TopBar(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xffef88ad),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffa53860),
                  spreadRadius: 2,
                  blurRadius: 6,
                ),
              ],
            ),
            child: const DateSelector(),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    MenstruationInlineTile(
                      onPickFlow: () => _openFlowSheet(context),
                    ),
                    const SizedBox(height: 12),

                    MedicationSection(
                      onAdd: () {
                        context.read<ManualInputViewModel>().cancelEditing();
                        _openMedicationSheet(context);
                      },
                    ),


                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: Consumer<ManualInputViewModel>(
              builder: (context, vm, _) => PrimaryButton(
                onPressed: vm.hasUnsavedChanges && !vm.isLoading ? () => _submit(context, vm) : null,
                isLoading: vm.isLoading,
                text: 'Save changes',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, ManualInputViewModel vm) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await vm.submit();
      messenger.showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Failed to save')));
    }
  }
}

class ActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ActionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicationSection extends StatelessWidget {
  final VoidCallback onAdd;

  const MedicationSection({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final outerColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);
    final innerColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.40);

    return Material(
      color: outerColor,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Medications', style: theme.textTheme.titleMedium),
                  ),
                  IconButton(
                    tooltip: 'Add medication',
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: innerColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const MedicationList(embedded: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
