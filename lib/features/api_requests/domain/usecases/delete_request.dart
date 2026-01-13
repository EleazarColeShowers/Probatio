import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/request_repository.dart';


class DeleteRequest extends UseCase<void, DeleteRequestParams> {
  final RequestRepository repository;

  DeleteRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRequestParams params) async {
    return await repository.deleteRequest(params.requestId);
  }
}

class DeleteRequestParams {
  final String requestId;

  DeleteRequestParams({required this.requestId});
}
