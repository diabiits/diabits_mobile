import 'package:diabits_mobile/domain/models/menstruation_input.dart';
import '../../../data/manual_input/dtos/manual_input_dto.dart';

/// Manages the state of menstruation data for the manual input screen.
///
/// This class handles adding, updating, removing, and tracking changes to menstruation.
/// It works with [ManualInputViewModel] to synchronize the state with the backend.
class MenstruationManager {
  /// The current menstruation input. It can be null if the user is not menstruating.
  MenstruationInput? menstruation;

  /// The original menstruation input when the data was loaded from the database.
  /// Used to check if the input has been modified by the user.
  MenstruationInput? _originalMenstruation;

  /// A computed property that returns true if there are any unsaved changes.
  bool get isDirty {
    if (_originalMenstruation != null && menstruation == null) return true; // Deleted
    if (_originalMenstruation == null && menstruation != null) return true; // Created
    if (_originalMenstruation != null && menstruation != null) {
      return _originalMenstruation!.flow != menstruation!.flow; // Updated
    }
    return false; // No change
  }

  void loadFromDto(ManualInputDto? dto) {
    if (dto != null) {
      menstruation = MenstruationInput.fromDto(dto);
      _originalMenstruation = MenstruationInput.fromDto(dto);
    } else {
      clear();
    }
  }

  void setIsMenstruating(bool isMenstruating, DateTime selectedDate) {
    if (isMenstruating && menstruation == null) {
      menstruation = MenstruationInput(flow: 'LIGHT', dateFrom: selectedDate);
    } else if (!isMenstruating && menstruation != null) {
      menstruation = null;
    }
  }

  void setFlow(String newFlow) {
    if (menstruation != null) {
      menstruation = menstruation!.copyWith(flow: newFlow);
    }
  }

  String? get idToDelete => (isDirty && _originalMenstruation != null && menstruation == null)
      ? _originalMenstruation!.id
      : null;

  ManualInputDto? get updateDto =>
      (isDirty && _originalMenstruation != null && menstruation != null)
      ? ManualInputDto(
          id: _originalMenstruation!.id,
          type: 'MENSTRUATION',
          dateFrom: menstruation!.dateFrom,
          flow: menstruation!.flow,
        )
      : null;

  List<ManualInputDto> buildCreateRequest() {
    if (isDirty && menstruation != null && !menstruation!.isSavedInDatabase) {
      return [
        ManualInputDto(
          type: 'MENSTRUATION',
          dateFrom: menstruation!.dateFrom,
          flow: menstruation!.flow,
        ),
      ];
    }
    return [];
  }

  void commit() => _originalMenstruation = menstruation;

  void clear() {
    menstruation = null;
    _originalMenstruation = null;
  }
}
