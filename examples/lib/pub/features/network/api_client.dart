import 'dart:convert';
import 'dart:io';

import 'package:examples/pub/features/network/http_clients.dart';
import 'package:http/http.dart';
import 'package:state_watcher/state_watcher.dart';

final refApiClient = Provided((_) {
  return ApiClient(
    baseUri: Uri.https('pub.dev', 'api'),
    httpClient: MemoryCacheClient(),
  );
});

class ApiClient {
  ApiClient({
    required Uri baseUri,
    required Client httpClient,
  })  : _baseUri = baseUri,
        _httpClient = httpClient;

  final Uri _baseUri;
  final Client _httpClient;

  Future<Map<String, Object?>> send({
    required HttpMethod method,
    required String path,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _baseUri.replace(
      pathSegments: [
        ..._baseUri.pathSegments,
        ...Uri.parse(path).pathSegments,
      ],
      queryParameters: queryParameters,
    );
    return sendFromUri(method: method, uri: uri, headers: headers);
  }

  Future<Map<String, Object?>> sendFromUri({
    required HttpMethod method,
    required Uri uri,
    Map<String, String>? headers,
  }) async {
    final request = Request(method.verb, uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    request.headers[HttpHeaders.acceptHeader] = 'application/vnd.pub.v2+json';
    final response = await _httpClient.send(request);
    if (!response.isSuccessful) {
      throw UnsucessfulResponseException(response);
    }

    final body = await response.stream.bytesToString();
    final json = body.isNotEmpty ? jsonDecode(body) : const {};
    return json;
  }
}

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE'),
  patch('PATCH');

  const HttpMethod(this.verb);

  final String verb;
}

extension on StreamedResponse {
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}

class UnsucessfulResponseException implements Exception {
  const UnsucessfulResponseException(this.response);

  final StreamedResponse response;

  @override
  String toString() {
    return 'UnsucessfulResponseException: ${response.statusCode} ${response.reasonPhrase}';
  }
}
