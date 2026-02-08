import 'package:diabits_mobile/data/manual_input/dtos/manual_input_dto.dart';
import 'package:uuid/uuid.dart';

import '../../data/manual_input/dtos/medication_value_input.dart';

/// Represents a single medication intake record.
///
/// This model is used in the domain layer to handle medication data, separating
/// it from the data transfer objects (DTOs) used for API communication.
class MedicationInput {
  final String id;
  final String name;
  final int amount;
  final DateTime time;

  /// A flag indicating whether this record is persisted in the remote database.
  final bool isSavedInDatabase;

  /// Creates a new, unsaved [MedicationInput] instance with a unique ID.
  /// This is used when a user creates a new medication entry in the UI.
  MedicationInput({
    required this.name,
    required this.amount,
    required this.time,
  })  : id = const Uuid().v4(),
        isSavedInDatabase = false;

  /// Creates a [MedicationInput] instance with a specified ID and save status.
  /// This private constructor is used internally, primarily by the [fromDto] factory.
  MedicationInput._({
    required this.id,
    required this.name,
    required this.amount,
    required this.time,
    required this.isSavedInDatabase,
  });

  /// Creates a [MedicationInput] instance from a [ManualInputDto].
  /// This is used to map data from the data layer to the domain model.
  /// Records created this way are marked as `isSavedInDatabase = true`.
  factory MedicationInput.fromDto(ManualInputDto dto) {
    return MedicationInput._(
      id: dto.id!,
      name: dto.medication!.name,
      amount: dto.medication!.amount,
      time: dto.dateFrom,
      isSavedInDatabase: true,
    );
  }

  /// Converts domain model back to DTO for API submission
  ManualInputDto toDto() {
    return ManualInputDto(
      id: isSavedInDatabase ? id : null,
      type: 'MEDICATION',
      dateFrom: time,
      medication: MedicationValueInput(name: name, amount: amount),
    );
  }

  MedicationInput copyWith({
    String? name,
    int? amount,
    DateTime? time,
  }) {
    return MedicationInput._(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      time: time ?? this.time,
      isSavedInDatabase: isSavedInDatabase,
    );
  }
}
