import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_request_to_collection.dart';
import '../../domain/usecases/create_collection.dart';
import '../../domain/usecases/delete_collection.dart';
import '../../domain/usecases/get_collections.dart';
import '../../domain/usecases/remove_request_from_collection.dart';
import 'collection_event.dart';
import 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CreateCollection createCollection;
  final GetCollections getCollections;
  final DeleteCollection deleteCollection;
  final AddRequestToCollection addRequestToCollection;
  final RemoveRequestFromCollection removeRequestFromCollection;

  CollectionBloc({
    required this.createCollection,
    required this.getCollections,
    required this.deleteCollection,
    required this.addRequestToCollection,
    required this.removeRequestFromCollection,
  }) : super(CollectionInitial()) {
    on<CreateCollectionEvent>(_onCreateCollection);
    on<GetCollectionsEvent>(_onGetCollections);
    on<DeleteCollectionEvent>(_onDeleteCollection);
    on<AddRequestToCollectionEvent>(_onAddRequestToCollection);
    on<RemoveRequestFromCollectionEvent>(_onRemoveRequestFromCollection);
  }

  Future<void> _onCreateCollection(
      CreateCollectionEvent event,
      Emitter<CollectionState> emit,
      ) async {
    emit(CollectionLoading());

    final result = await createCollection(
      CreateCollectionParams(collection: event.collection),
    );

    result.fold(
          (failure) => emit(CollectionError(failure.message)),
          (_) {
        emit(const CollectionCreated('Collection created successfully'));
        add(GetCollectionsEvent()); // Reload collections
      },
    );
  }

  Future<void> _onGetCollections(
      GetCollectionsEvent event,
      Emitter<CollectionState> emit,
      ) async {
    emit(CollectionLoading());

    final result = await getCollections(NoParams());

    result.fold(
          (failure) => emit(CollectionError(failure.message)),
          (collections) => emit(CollectionsLoaded(collections)),
    );
  }

  Future<void> _onDeleteCollection(
      DeleteCollectionEvent event,
      Emitter<CollectionState> emit,
      ) async {
    emit(CollectionLoading());

    final result = await deleteCollection(
      DeleteCollectionParams(collectionId: event.collectionId),
    );

    result.fold(
          (failure) => emit(CollectionError(failure.message)),
          (_) {
        emit(const CollectionDeleted('Collection deleted successfully'));
        add(GetCollectionsEvent()); // Reload collections
      },
    );
  }

  Future<void> _onAddRequestToCollection(
      AddRequestToCollectionEvent event,
      Emitter<CollectionState> emit,
      ) async {
    final result = await addRequestToCollection(
      AddRequestToCollectionParams(
        collectionId: event.collectionId,
        requestId: event.requestId,
      ),
    );

    result.fold(
          (failure) => emit(CollectionError(failure.message)),
          (_) => add(GetCollectionsEvent()), // Reload to show updated collection
    );
  }

  Future<void> _onRemoveRequestFromCollection(
      RemoveRequestFromCollectionEvent event,
      Emitter<CollectionState> emit,
      ) async {
    final result = await removeRequestFromCollection(
      RemoveRequestFromCollectionParams(
        collectionId: event.collectionId,
        requestId: event.requestId,
      ),
    );

    result.fold(
          (failure) => emit(CollectionError(failure.message)),
          (_) => add(GetCollectionsEvent()), // Reload to show updated collection
    );
  }
}