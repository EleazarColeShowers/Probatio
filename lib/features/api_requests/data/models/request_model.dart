import 'dart:convert';
import '../../domain/entities/api_request.dart';

class RequestModel extends ApiRequest {
  const RequestModel({
    super.id,
    required super.name,
    required super.url,
    required super.method,
    super.headers,
    super.body,
    required super.createdAt,
  });

  // Create from Entity (for saving)
  factory RequestModel.fromEntity(ApiRequest entity) {
    return RequestModel(
      id: entity.id,
      name: entity.name,
      url: entity.url,
      method: entity.method,
      headers: entity.headers,
      body: entity.body,
      createdAt: entity.createdAt,
    );
  }

  // Create from JSON (from local storage)
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      method: json['method'],
      headers: Map<String, String>.from(json['headers'] ?? {}),
      body: json['body'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'method': method,
      'headers': headers,
      'body': body,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create copy with changes
  RequestModel copyWith({
    String? id,
    String? name,
    String? url,
    String? method,
    Map<String, String>? headers,
    String? body,
    DateTime? createdAt,
  }) {
    return RequestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}