import 'package:equatable/equatable.dart';

class ApiRequest extends Equatable{
  final String? id;
  final String name;
  final String url;
  final String method;
  final Map<String, String>? headers;
  final String? body;
  final DateTime createdAt;

  const ApiRequest({
    this.id,
    required this.name,
    required this.url,
    required this.method,
    this.headers,
    this.body,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, url, method, headers, body, createdAt];
}