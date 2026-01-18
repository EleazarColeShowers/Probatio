import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/collection_repository.dart';

class AddRequestToCollection extends UseCase<void, AddRequestToCollectionParams> {
  final CollectionRepository repository;

  AddRequestToCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(AddRequestToCollectionParams params) async {
    return await repository.addRequestToCollection(
      params.collectionId,
      params.requestId,
    );
  }
}

class AddRequestToCollectionParams {
  final String collectionId;
  final String requestId;

  AddRequestToCollectionParams({
    required this.collectionId,
    required this.requestId,
  });
}