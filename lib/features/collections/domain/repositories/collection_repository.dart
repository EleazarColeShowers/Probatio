import 'package:dartz/dartz.dart';
import 'package:probatio/core/error/failure.dart';
import '../entities/collection.dart';

abstract class CollectionRepository {
  Future<Either<Failure, void>> createCollection(Collection collection);
  Future<Either<Failure, List<Collection>>> getCollections();
  Future<Either<Failure, void>> updateCollection(Collection collection);
  Future<Either<Failure, void>> deleteCollection(String collectionId);
  Future<Either<Failure, void>> addRequestToCollection(
      String collectionId,
      String requestId,
      );
  Future<Either<Failure, void>> removeRequestFromCollection(
      String collectionId,
      String requestId,
      );
}