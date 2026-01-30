import 'package:http/http.dart' as http;

class ApiResult {
  final bool success;
  final String? message;
  final http.Response? response;

  ApiResult({
    required this.success,
    this.message,
    this.response,
  });
}