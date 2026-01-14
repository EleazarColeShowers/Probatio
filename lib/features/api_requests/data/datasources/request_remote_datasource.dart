import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';

abstract class RequestRemoteDataSource {
  Future<ResponseModel> sendRequest(RequestModel request);
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final http.Client client;

  RequestRemoteDataSourceImpl({required this.client});

  @override
  Future<ResponseModel> sendRequest(RequestModel request) async {
    try {
      final startTime = DateTime.now();

      // Parse URL
      final uri = Uri.parse(request.url);

      // Make HTTP request based on method
      http.Response response;

      switch (request.method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: request.headers);
          break;
        case 'POST':
          response = await client.post(
            uri,
            headers: request.headers,
            body: request.body,
          );
          break;
        case 'PUT':
          response = await client.put(
            uri,
            headers: request.headers,
            body: request.body,
          );
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: request.headers);
          break;
        case 'PATCH':
          response = await client.patch(
            uri,
            headers: request.headers,
            body: request.body,
          );
          break;
        default:
          throw ServerException(
            message: 'Unsupported HTTP method: ${request.method}',
            statusCode: 400,
          );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      // Convert headers to Map<String, String>
      final responseHeaders = <String, String>{};
      response.headers.forEach((key, value) {
        responseHeaders[key] = value;
      });

      return ResponseModel.fromHttpResponse(
        statusCode: response.statusCode,
        statusMessage: response.reasonPhrase ?? 'Unknown',
        headers: responseHeaders,
        body: response.body,
        durationMs: duration,
      );

    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}