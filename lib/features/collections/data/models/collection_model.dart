import '../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({
    super.id,
    required super.name,
    required super.description,
    super.requestIds,
    super.createdAt,
  });

  factory CollectionModel.fromEntity(Collection entity) {
    return CollectionModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      requestIds: entity.requestIds,
      createdAt: entity.createdAt,
    );
  }

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      requestIds: List<String>.from(json['requestIds'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requestIds': requestIds,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  CollectionModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? requestIds,
    DateTime? createdAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      requestIds: requestIds ?? this.requestIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
