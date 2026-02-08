import 'package:diabits_mobile/ui/manual_input/widgets/date_selector.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/medication/medication_form.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/medication/medication_section.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/menstruation_section.dart';
import 'package:diabits_mobile/ui/shared/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/medication_input.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ManualInputViewModel>().loadDataForSelectedDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      extendBody: true,
      body: Column(
        children: [
          const DateSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  const SizedBox(height: 12),
                  const MenstruationSection(),
                  const SizedBox(height: 12),
                  MedicationSection(
                    onAdd: () => _openMedicationSheet(),
                    onEdit: (med) => _openMedicationSheet(med),
                    onDelete: (id) => context.read<ManualInputViewModel>().removeMedicationAt(id),
                  ),
                  const SizedBox(height: 120),
                ],
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
            child: Selector<ManualInputViewModel, ({bool hasUnsavedChanges, bool isLoading})>(
              selector: (_, vm) =>
                  (hasUnsavedChanges: vm.hasUnsavedChanges, isLoading: vm.isLoading),
              builder: (context, s, _) => PrimaryButton(
                onPressed: s.hasUnsavedChanges && !s.isLoading
                    ? () => _submit(context, context.read<ManualInputViewModel>())
                    : null,
                isLoading: s.isLoading,
                text: 'Save changes',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMedicationSheet([MedicationInput? med]) {
    final vm = context.read<ManualInputViewModel>();

    if (med != null) {
      vm.startEditing(med);
    } else {
      vm.cancelEditing();
    }

    try {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: MedicationForm(initial: med),
        ),
      );
    } finally {
      vm.cancelEditing();
    }
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
