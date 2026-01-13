import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/api_request.dart';
import '../repositories/request_repository.dart';


class GetSavedRequests extends UseCase<List<ApiRequest>, NoParams> {
  final RequestRepository repository;

  GetSavedRequests(this.repository);

  @override
  Future<Either<Failure, List<ApiRequest>>> call(NoParams params) async {
    return await repository.getSavedRequests();
  }
}
