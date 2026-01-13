import 'package:dartz/dartz.dart';
import 'package:probatio/core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/api_request.dart';
import '../entities/api_response.dart';
import '../repositories/request_repository.dart';

class SendRequest extends UseCase<ApiResponse, SendRequestParams> {
  final RequestRepository repository;

  SendRequest(this.repository);

  @override
  Future<Either<Failure, ApiResponse>> call(SendRequestParams params) async {
    return await repository.sendRequest(params.request);
  }
}

class SendRequestParams {
  final ApiRequest request;

  SendRequestParams({required this.request});
}
