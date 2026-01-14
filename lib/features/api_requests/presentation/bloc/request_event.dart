import 'package:equatable/equatable.dart';
import '../../domain/entities/api_request.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

class SendRequestEvent extends RequestEvent {
  final ApiRequest request;

  const SendRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class SaveRequestEvent extends RequestEvent {
  final ApiRequest request;

  const SaveRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class GetSavedRequestsEvent extends RequestEvent {}

class DeleteRequestEvent extends RequestEvent {
  final String requestId;

  const DeleteRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class LoadRequestEvent extends RequestEvent {
  final ApiRequest request;

  const LoadRequestEvent(this.request);

  @override
  List<Object?> get props => [request];
}