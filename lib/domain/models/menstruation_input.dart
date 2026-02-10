import 'package:diabits_mobile/data/manual_input/dtos/manual_input_dto.dart';

import 'manual_input_ids.dart';

/// Represents a single menstruation data record for a specific day.
///
/// This model is used in the domain layer to handle menstruation data, separating
/// it from the data transfer objects (DTOs) used for API communication.
class MenstruationInput {
  final int id;
  final String flow;
  final DateTime dateFrom;

  /// A flag indicating whether this record is persisted in the remote database.
  /// `true` if it has been saved, otherwise `false`.
  final bool isSavedInDatabase;

  /// Creates a new, unsaved [MenstruationInput] instance with a unique ID.
  ///
  /// This is used when a user creates a new menstruation entry in the UI.
  MenstruationInput({required this.flow, required this.dateFrom})
    : id = ManualInputIds.next(),
      isSavedInDatabase = false;

  /// Creates a [MenstruationInput] instance with a specified ID and save status.
  ///
  /// This private constructor is used internally by the [fromDto] factory and the
  /// [copyWith] method.
  MenstruationInput._({
    required this.id,
    required this.flow,
    required this.dateFrom,
    required this.isSavedInDatabase,
  });

  /// Creates a [MenstruationInput] instance from a [ManualInputDto].
  ///
  /// This is used to map data from the data layer to the domain model.
  /// Records created this way are marked as `isSavedInDatabase = true`.
  factory MenstruationInput.fromDto(ManualInputDto dto) {
    return MenstruationInput._(
      id: dto.id!,
      flow: dto.flow!,
      dateFrom: dto.dateFrom,
      isSavedInDatabase: true,
    );
  }

  /// Creates a new [MenstruationInput] instance with updated properties.
  ///
  /// This allows for the creation of a modified copy of the object while
  /// preserving its original state.
  MenstruationInput copyWith({String? flow}) {
    return MenstruationInput._(
      id: id,
      flow: flow ?? this.flow,
      dateFrom: dateFrom,
      isSavedInDatabase: isSavedInDatabase,
    );
  }
}
