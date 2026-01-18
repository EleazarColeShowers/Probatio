import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/collection_repository.dart';

class DeleteCollection extends UseCase<void, DeleteCollectionParams> {
  final CollectionRepository repository;

  DeleteCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCollectionParams params) async {
    return await repository.deleteCollection(params.collectionId);
  }
}

class DeleteCollectionParams {
  final String collectionId;

  DeleteCollectionParams({required this.collectionId});
}