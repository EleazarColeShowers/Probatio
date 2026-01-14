import 'package:equatable/equatable.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestSending extends RequestState {}

class RequestSent extends RequestState {
  final ApiResponse response;

  const RequestSent(this.response);

  @override
  List<Object?> get props => [response];
}

class RequestSaved extends RequestState {
  final String message;

  const RequestSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestsLoaded extends RequestState {
  final List<ApiRequest> requests;

  const RequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RequestDeleted extends RequestState {
  final String message;

  const RequestDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestLoaded extends RequestState {
  final ApiRequest request;

  const RequestLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class RequestError extends RequestState {
  final String message;

  const RequestError(this.message);

  @override
  List<Object?> get props => [message];
}