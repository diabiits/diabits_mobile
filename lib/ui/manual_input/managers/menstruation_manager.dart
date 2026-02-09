import 'package:diabits_mobile/domain/models/menstruation_input.dart';
import '../../../data/manual_input/dtos/manual_input_dto.dart';

/// Manages menstruation state for the manual input feature.
///
/// Responsibilities:
/// - Owns the current menstruation input for the selected date (or null if none).
/// - Applies business defaults (e.g. default flow) when creating new entries.
/// - Tracks changes relative to the last loaded/committed state so the UI can
///   enable/disable saving and the ViewModel can build correct backend requests.
/// - Produces the minimum set of backend operations:
///   create (new), update (changed), delete (removed).
///
/// Non-responsibilities:
/// - No UI concerns (no widgets, formatting, dialogs).
/// - No networking or persistence (handled by repository via ViewModel).
class MenstruationManager {
  static const String defaultFlow = 'LIGHT';

  /// Current menstruation input for the selected date, or null when not menstruating.
  MenstruationInput? menstruation;

  /// Snapshot of the last committed state used for dirty tracking.
  MenstruationInput? _original;

  void setIsMenstruating(bool isMenstruating, DateTime selectedDate) {
    if (isMenstruating) {
      menstruation ??= MenstruationInput(flow: defaultFlow, dateFrom: selectedDate);
      return;
    } else {
      menstruation = null;
    }
  }

  void setFlow(String newFlow) {
    if (menstruation == null) return;
    menstruation = menstruation!.copyWith(flow: newFlow);
  }

  void loadFromDto(ManualInputDto? dto) {
    if (dto == null) {
      clear();
    } else {
      menstruation = MenstruationInput.fromDto(dto);
      _original = menstruation;
    }
  }

  void clear() {
    menstruation = null;
    _original = null;
  }

  // Computed properties
  bool get isDirty {
    if (_original == null && menstruation == null) return false;
    if (_original == null || menstruation == null) return true;
    return _original!.flow != menstruation!.flow;
  }

  int? get idToDelete =>
      (isDirty && _original != null && menstruation == null) ? _original!.id : null;

  ManualInputDto? get updateDto {
    if (!(isDirty && _original != null && menstruation != null)) return null;
    return ManualInputDto(
      id: _original!.id,
      type: 'MENSTRUATION',
      dateFrom: menstruation!.dateFrom,
      flow: menstruation!.flow,
    );
  }

  ManualInputDto? get createDto {
    if (isDirty && menstruation != null && !menstruation!.isSavedInDatabase) {
      return ManualInputDto(
        type: 'MENSTRUATION',
        dateFrom: menstruation!.dateFrom,
        flow: menstruation!.flow,
      );
    }
    return null;
  }
}
