import 'package:equatable/equatable.dart';
import '../../domain/entities/collection.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class CreateCollectionEvent extends CollectionEvent {
  final Collection collection;

  const CreateCollectionEvent(this.collection);

  @override
  List<Object?> get props => [collection];
}

class GetCollectionsEvent extends CollectionEvent {}

class UpdateCollectionEvent extends CollectionEvent {
  final Collection collection;

  const UpdateCollectionEvent(this.collection);

  @override
  List<Object?> get props => [collection];
}

class DeleteCollectionEvent extends CollectionEvent {
  final String collectionId;

  const DeleteCollectionEvent(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

class AddRequestToCollectionEvent extends CollectionEvent {
  final String collectionId;
  final String requestId;

  const AddRequestToCollectionEvent({
    required this.collectionId,
    required this.requestId,
  });

  @override
  List<Object?> get props => [collectionId, requestId];
}

class RemoveRequestFromCollectionEvent extends CollectionEvent {
  final String collectionId;
  final String requestId;

  const RemoveRequestFromCollectionEvent({
    required this.collectionId,
    required this.requestId,
  });

  @override
  List<Object?> get props => [collectionId, requestId];
}