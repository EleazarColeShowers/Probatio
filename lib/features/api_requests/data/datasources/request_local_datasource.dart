import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/request_model.dart';

abstract class RequestLocalDataSource {
  Future<void> saveRequest(RequestModel request);
  Future<List<RequestModel>> getSavedRequests();
  Future<void> deleteRequest(String requestId);
  Future<void> updateRequest(RequestModel request);
}

class RequestLocalDataSourceImpl implements RequestLocalDataSource {
  static const String boxName = 'requests';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(boxName);
    return _box!;
  }

  @override
  Future<void> saveRequest(RequestModel request) async {
    try {
      final requestBox = await box;
      final id = request.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final requestWithId = request.copyWith(
        id: id,
        createdAt: request.createdAt,
      );

      await requestBox.put(id, requestWithId.toJson());
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<RequestModel>> getSavedRequests() async {
    try {
      final requestBox = await box;
      final requests = <RequestModel>[];

      for (var item in requestBox.values) {
        requests.add(RequestModel.fromJson(Map<String, dynamic>.from(item)));
      }

      // Sort by creation date, newest first
      requests.sort((a, b) =>
          (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now())
      );

      return requests;
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      final requestBox = await box;
      await requestBox.delete(requestId);
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updateRequest(RequestModel request) async {
    try {
      if (request.id == null) {
        throw CacheException(
          message: 'Cannot update request without ID',
          statusCode: 400,
        );
      }
      final requestBox = await box;
      await requestBox.put(request.id, request.toJson());
    } catch (e) {
      throw CacheException(message: e.toString(), statusCode: 500);
    }
  }
}