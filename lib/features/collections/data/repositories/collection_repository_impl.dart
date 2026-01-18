import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_local_datasource.dart';
import '../models/collection_model.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionLocalDataSource localDataSource;

  CollectionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> createCollection(Collection collection) async {
    try {
      final collectionModel = CollectionModel.fromEntity(collection);
      await localDataSource.createCollection(collectionModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to create collection: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Collection>>> getCollections() async {
    try {
      final collections = await localDataSource.getCollections();
      return Right(collections);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to load collections: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateCollection(Collection collection) async {
    try {
      final collectionModel = CollectionModel.fromEntity(collection);
      await localDataSource.updateCollection(collectionModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update collection: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCollection(String collectionId) async {
    try {
      await localDataSource.deleteCollection(collectionId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete collection: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> addRequestToCollection(
      String collectionId,
      String requestId,
      ) async {
    try {
      // Get current collections
      final collections = await localDataSource.getCollections();

      // Find the target collection
      final collection = collections.firstWhere(
            (c) => c.id == collectionId,
        orElse: () => throw CacheException(
          message: 'Collection not found',
          statusCode: 404,
        ),
      );

      // Add request ID if not already present
      final updatedRequestIds = List<String>.from(collection.requestIds);
      if (!updatedRequestIds.contains(requestId)) {
        updatedRequestIds.add(requestId);
      }

      // Update collection
      final updatedCollection = collection.copyWith(
        requestIds: updatedRequestIds,
      );

      await localDataSource.updateCollection(updatedCollection);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to add request to collection: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> removeRequestFromCollection(
      String collectionId,
      String requestId,
      ) async {
    try {
      final collections = await localDataSource.getCollections();

      final collection = collections.firstWhere(
            (c) => c.id == collectionId,
        orElse: () => throw CacheException(
          message: 'Collection not found',
          statusCode: 404,
        ),
      );

      final updatedRequestIds = List<String>.from(collection.requestIds)
        ..remove(requestId);

      final updatedCollection = collection.copyWith(
        requestIds: updatedRequestIds,
      );

      await localDataSource.updateCollection(updatedCollection);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to remove request from collection: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }
}
