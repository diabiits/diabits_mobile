import '../../manual_input/dtos/manual_input_dto.dart';

/// Represents the data transfer object (DTO) for a bulk manual input request.
///
/// This class is used to batch and send multiple new medication and menstruation
/// records to the backend in a single request.
class ManualInputRequest {
  final List<ManualInputDto> items;

  ManualInputRequest({required this.items});

  Map<String, dynamic> toJson() => {"items": items.map((m) => m.toJson()).toList()};
}

class ManualInputDeleteRequest {
  final List<int> ids;

  ManualInputDeleteRequest({required this.ids});

  Map<String, dynamic> toJson() => {"ids": ids};
}
