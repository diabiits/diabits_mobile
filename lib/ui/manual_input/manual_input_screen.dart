import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/top_bar.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/date_selector.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/medication_form.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/medication_list.dart';
import 'package:diabits_mobile/ui/manual_input/widgets/menstruation_section.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:provider/provider.dart';

import '../shared/primary_button.dart';
import 'manual_input_view_model.dart';

/// The main screen for manually inputting health data.
///
/// This screen aggregates different input widgets for menstruation, medication,
/// and allows users to save their data. It also handles requesting Health
/// Connect permissions when the screen is first displayed.
class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  /// Checks for necessary permissions and prompts the user if they are not granted.
  ///
  /// This method will continuously prompt the user with a non-dismissible dialog
  /// until all required permissions are granted. Once permissions are granted,
  /// it proceeds to load the data for the selected day.
  Future<void> _checkAndRequestPermissions() async {
    final permissionHandler = PermissionHandler();
    bool permissionsGranted = false;

    while (!permissionsGranted) {
      permissionsGranted = await permissionHandler.requestPermissions();
      if (!permissionsGranted && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
              'This app needs health permissions to function properly. Please grant the necessary permissions to continue.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  permission_handler.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }

    // When permissions are finally granted, load the data.
    if (mounted) {
      context.read<ManualInputViewModel>().loadDataForSelectedDate();
    }
  }

  void _showMedicationDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const MedicationForm());
  }

  /// Builds the UI for the manual input screen.
  ///
  /// Lays out the day selector, menstruation section, medication form, and medication list.
  /// Includes a save button that triggers the data submission process.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xffef88ad),
              boxShadow: [
                BoxShadow(color: const Color(0xffa53860), spreadRadius: 5, blurRadius: 7),
              ],
            ),
            child: DateSelector(),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const MenstruationSection(),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Medications", style: Theme.of(context).textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: () {
                            context.read<ManualInputViewModel>().cancelEditing();
                            _showMedicationDialog(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add"),
                        ),
                      ],
                    ),
                    const MedicationList(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Consumer<ManualInputViewModel>(
                builder: (context, viewModel, _) => PrimaryButton(
                  onPressed: () => _submit(context, viewModel),
                  isLoading: viewModel.isLoading,
                  text: "Save All Changes",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the submission of the manual input data.
  ///
  /// Calls the view model to save the data and shows a confirmation
  /// or error message to the user via a [SnackBar].
  Future<void> _submit(BuildContext context, ManualInputViewModel modelView) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await modelView.submit();
      messenger.showSnackBar(const SnackBar(content: Text("Data updated successfully!")));
    } catch (e) {
      messenger.showSnackBar(const SnackBar(content: Text("Failed to save data")));
    }
  }
}
