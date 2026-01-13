import 'package:dartz/dartz.dart';
import 'package:probatio/core/error/failure.dart';

// Already defined in usecase.dart, but repeated here for reference
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = Future<Either<Failure, void>>;
typedef DataMap = Map<String, dynamic>;
