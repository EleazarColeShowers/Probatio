import 'package:equatable/equatable.dart';
import '../../domain/entities/collection.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionsLoaded extends CollectionState {
  final List<Collection> collections;

  const CollectionsLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class CollectionCreated extends CollectionState {
  final String message;

  const CollectionCreated(this.message);

  @override
  List<Object?> get props => [message];
}

class CollectionUpdated extends CollectionState {
  final String message;

  const CollectionUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class CollectionDeleted extends CollectionState {
  final String message;

  const CollectionDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object?> get props => [message];
}
