import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/delete_request.dart';
import '../../domain/usecases/get_saved_requests.dart';
import '../../domain/usecases/save_request.dart';
import '../../domain/usecases/send_request.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final SendRequest sendRequest;
  final SaveRequest saveRequest;
  final GetSavedRequests getSavedRequests;
  final DeleteRequest deleteRequest;

  RequestBloc({
    required this.sendRequest,
    required this.saveRequest,
    required this.getSavedRequests,
    required this.deleteRequest,
  }) : super(RequestInitial()) {
    on<SendRequestEvent>(_onSendRequest);
    on<SaveRequestEvent>(_onSaveRequest);
    on<GetSavedRequestsEvent>(_onGetSavedRequests);
    on<DeleteRequestEvent>(_onDeleteRequest);
    on<LoadRequestEvent>(_onLoadRequest);
  }

  Future<void> _onSendRequest(
      SendRequestEvent event,
      Emitter<RequestState> emit,
      ) async {
    emit(RequestSending());

    final result = await sendRequest(SendRequestParams(request: event.request));

    result.fold(
          (failure) => emit(RequestError(failure.message)),
          (response) => emit(RequestSent(response)),
    );
  }

  Future<void> _onSaveRequest(
      SaveRequestEvent event,
      Emitter<RequestState> emit,
      ) async {
    emit(RequestLoading());

    final result = await saveRequest(SaveRequestParams(request: event.request));

    result.fold(
          (failure) => emit(RequestError(failure.message)),
          (_) => emit(const RequestSaved('Request saved successfully')),
    );
  }

  Future<void> _onGetSavedRequests(
      GetSavedRequestsEvent event,
      Emitter<RequestState> emit,
      ) async {
    emit(RequestLoading());

    final result = await getSavedRequests(NoParams());

    result.fold(
          (failure) => emit(RequestError(failure.message)),
          (requests) => emit(RequestsLoaded(requests)),
    );
  }

  Future<void> _onDeleteRequest(
      DeleteRequestEvent event,
      Emitter<RequestState> emit,
      ) async {
    emit(RequestLoading());

    final result = await deleteRequest(
      DeleteRequestParams(requestId: event.requestId),
    );

    result.fold(
          (failure) => emit(RequestError(failure.message)),
          (_) {
        emit(const RequestDeleted('Request deleted successfully'));
        // Reload requests after deletion
        add(GetSavedRequestsEvent());
      },
    );
  }

  Future<void> _onLoadRequest(
      LoadRequestEvent event,
      Emitter<RequestState> emit,
      ) async {
    emit(RequestLoaded(event.request));
  }
}