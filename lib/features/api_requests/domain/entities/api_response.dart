import 'package:equatable/equatable.dart';

class ApiResponse extends Equatable{
  final int statusCode;
  final String statusMessage;
  final Map<String, String> headers;
  final String body;
  final int responseTime;

  const ApiResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.headers,
    required this.body,
    required this.responseTime,
  });

  @override
  List<Object?> get props => [statusCode, headers, body, responseTime];

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  // Helper getter for response status color
  bool get isError => statusCode >= 400;
  bool get isRedirect => statusCode >= 300 && statusCode < 400;
  int get duration => responseTime;

}