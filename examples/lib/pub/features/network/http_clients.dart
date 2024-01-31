import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

abstract class DelegatedHttpClient extends BaseClient {
  DelegatedHttpClient([Client? inner]) : _inner = inner ?? IOClient();

  final Client _inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

class MemoryCacheClient extends DelegatedHttpClient {
  MemoryCacheClient([super.inner]);

  final Map<String, _CachedResponse> _cache = {};

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (request.method != 'GET') {
      // Only cache GET requests.
      return super.send(request);
    }

    final key = request.url.toString();
    final cachedResponse = _cache[key];
    if (cachedResponse != null) {
      return cachedResponse.toStreamedResponse();
    }

    // Not in the cache, we need to save it.
    final response = await super.send(request);

    if (response.statusCode == HttpStatus.ok) {
      final responseToCache = await response.toCachedResponse();
      _cache[key] = responseToCache;

      // We cannot return resposne, since it has already been consumed.
      return responseToCache.toStreamedResponse();
    }

    return response;
  }
}

class _CachedResponse {
  _CachedResponse({
    required this.bytes,
    required this.headers,
  });

  final Uint8List bytes;
  final Map<String, String> headers;

  StreamedResponse toStreamedResponse() {
    return StreamedResponse(
      ByteStream.fromBytes(bytes),
      HttpStatus.ok,
      headers: headers,
      contentLength: bytes.length,
    );
  }
}

extension on StreamedResponse {
  Future<_CachedResponse> toCachedResponse() async {
    final bytes = await stream.toBytes();

    return _CachedResponse(
      bytes: bytes,
      headers: headers,
    );
  }
}
