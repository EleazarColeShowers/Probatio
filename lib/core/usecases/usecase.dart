import 'package:dartz/dartz.dart';
import 'package:probatio/core/error/failure.dart';

// Type aliases for cleaner code
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = ResultFuture<void>;
typedef DataMap = Map<String, dynamic>;

/// Base UseCase class
/// Every use case should extend this and implement call()
///
/// Type = what the use case returns
/// Params = what parameters it needs
abstract class UseCase<Type, Params> {
  const UseCase();

  /// Main method that executes the use case
  ResultFuture<Type> call(Params params);
}

/// Use this when a use case needs no parameters
class NoParams {
  const NoParams();
}
