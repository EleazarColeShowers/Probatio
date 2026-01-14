import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_local_datasource.dart';
import '../datasources/request_remote_datasource.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;
  final RequestLocalDataSource localDataSource;

  RequestRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ApiResponse>> sendRequest(ApiRequest request) async {
    try {
      // Convert entity to model
      final requestModel = RequestModel.fromEntity(request);

      // Send request via remote data source
      final response = await remoteDataSource.sendRequest(requestModel);

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveRequest(ApiRequest request) async {
    try {
      final requestModel = RequestModel.fromEntity(request);
      await localDataSource.saveRequest(requestModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to save request: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ApiRequest>>> getSavedRequests() async {
    try {
      final requests = await localDataSource.getSavedRequests();
      return Right(requests);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to load requests: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRequest(String requestId) async {
    try {
      await localDataSource.deleteRequest(requestId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to delete request: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequest(ApiRequest request) async {
    try {
      final requestModel = RequestModel.fromEntity(request);
      await localDataSource.updateRequest(requestModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update request: ${e.toString()}',
        statusCode: 500,
      ));
    }
  }
}