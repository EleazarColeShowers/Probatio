import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/api_request.dart';
import '../repositories/request_repository.dart';

class SaveRequest extends UseCase<void, SaveRequestParams> {
  final RequestRepository repository;

  SaveRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveRequestParams params) async {
    return await repository.saveRequest(params.request);
  }
}

class SaveRequestParams {
  final ApiRequest request;

  SaveRequestParams({required this.request});
}
