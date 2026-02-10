import 'package:diabits_mobile/data/manual_input/dtos/manual_input_dto.dart';
import 'package:diabits_mobile/data/manual_input/dtos/medication_value_input.dart';
import 'package:diabits_mobile/data/network/responses/manual_input_response.dart';
import 'package:diabits_mobile/ui/manual_input/managers/menstruation_manager.dart';

class ManualInputTestData {
  static ManualInputDto med(DateTime date, {int id = 1, String name = 'Med', int amount = 2}) =>
      ManualInputDto(
        id: id,
        type: 'MEDICATION',
        dateFrom: date,
        medication: MedicationValueInput(name: name, amount: amount),
      );

  static ManualInputDto mens(
    DateTime date, {
    int id = 1,
    String flow = MenstruationManager.defaultFlow,
  }) => ManualInputDto(id: id, type: 'MENSTRUATION', dateFrom: date, flow: flow);

  static ManualInputResponse response({
    List<ManualInputDto> meds = const [],
    ManualInputDto? mens,
  }) => ManualInputResponse(medications: meds, menstruation: mens);
}
