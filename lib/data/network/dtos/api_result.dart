class ApiResult {
  final bool success;
  final dynamic body;
  final int? statusCode;
  final String? message;

  ApiResult({
    required this.success,
    this.body,
    this.statusCode,
    this.message,
  });
}