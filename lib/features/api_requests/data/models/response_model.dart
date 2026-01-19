import '../../domain/entities/api_response.dart';

class ResponseModel extends ApiResponse {
  const ResponseModel({
    required super.statusCode,
    required super.statusMessage,
    required super.headers,
    required super.body,
    required super.responseTime,
  });

  // Create from HTTP response
  factory ResponseModel.fromHttpResponse({
    required int statusCode,
    required String statusMessage,
    required Map<String, String> headers,
    required String body,
    required int responseTime,
  }) {
    return ResponseModel(
      statusCode: statusCode,
      statusMessage: statusMessage,
      headers: headers,
      body: body,
      responseTime: responseTime,
    );
  }
}
