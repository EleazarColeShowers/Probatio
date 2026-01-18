import 'package:dartz/dartz.dart';
import 'package:probatio/core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class CreateCollection extends UseCase<void, CreateCollectionParams> {
  final CollectionRepository repository;

  CreateCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateCollectionParams params) async {
    return await repository.createCollection(params.collection);
  }
}

class CreateCollectionParams {
  final Collection collection;

  CreateCollectionParams({required this.collection});
}
