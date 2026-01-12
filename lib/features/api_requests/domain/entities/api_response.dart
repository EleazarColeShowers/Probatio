import 'package:equatable/equatable.dart';

class ApiResponse extends Equatable{
  final int statusCode;
  final String statusMessage;
  final Map<String, String> headers;
  final String body;
  final Duration responseTime;

  const ApiResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.headers,
    required this.body,
    required this.responseTime,
  });

  @override
  List<Object?> get props => [statusCode, headers, body, responseTime];
}