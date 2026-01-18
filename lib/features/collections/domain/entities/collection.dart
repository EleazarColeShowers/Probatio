import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String? id;
  final String name;
  final String description;
  final List<String> requestIds;
  final DateTime? createdAt;

  const Collection({
    this.id,
    required this.name,
    required this.description,
    this.requestIds = const [],
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, requestIds, createdAt];
}
