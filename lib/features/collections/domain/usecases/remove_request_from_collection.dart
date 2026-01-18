import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/collection_repository.dart';

class RemoveRequestFromCollection extends UseCase<void, RemoveRequestFromCollectionParams> {
  final CollectionRepository repository;

  RemoveRequestFromCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveRequestFromCollectionParams params) async {
    return await repository.removeRequestFromCollection(
      params.collectionId,
      params.requestId,
    );
  }
}

class RemoveRequestFromCollectionParams {
  final String collectionId;
  final String requestId;

  RemoveRequestFromCollectionParams({
    required this.collectionId,
    required this.requestId,
  });
}