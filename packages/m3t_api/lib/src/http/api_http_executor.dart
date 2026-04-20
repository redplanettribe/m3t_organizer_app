import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/m3t_api_client.dart';
import 'package:m3t_api/src/models/api_error.dart';

/// Builds an API-layer exception from the envelope fields.
///
/// Data sources pass a closure that constructs their specific failure
/// subclass (e.g. `GiveDeliverableFailure`) with these uniform fields.
typedef ApiErrorFactory =
    M3tApiException Function({
      required String message,
      required int statusCode,
      String? errorCode,
      bool showToUser,
    });

/// Low-level HTTP infrastructure shared by all data sources.
///
/// Owns the [http.Client], base URL, object-store URL, and token provider.
/// Exposes helpers used by every data source: [uri], [jsonHeaders],
/// [authHeaders], [decodeJson], and the envelope parsers
/// ([parseEnvelope], [parseListEnvelope]).
///
/// Never throws domain-level failures — callers build their own typed
/// exceptions via the [ApiErrorFactory] passed to the envelope parsers.
final class ApiHttpExecutor {
  const ApiHttpExecutor({
    required http.Client httpClient,
    required String baseUrl,
    Uri? objectStoreBaseUrl,
    TokenProvider? tokenProvider,
  }) : _httpClient = httpClient,
       _baseUrl = baseUrl,
       _objectStoreBaseUrl = objectStoreBaseUrl,
       _tokenProvider = tokenProvider;

  final http.Client _httpClient;
  final String _baseUrl;
  final Uri? _objectStoreBaseUrl;
  final TokenProvider? _tokenProvider;

  /// Returns the [_objectStoreBaseUrl], used when rewriting presigned URLs
  /// for emulator or local device reachability.
  Uri? get objectStoreBaseUrl => _objectStoreBaseUrl;

  /// The underlying HTTP client — data sources use this directly for requests.
  http.Client get client => _httpClient;

  Uri uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get jsonHeaders => {
    'content-type': 'application/json',
  };

  Future<Map<String, String>> authHeaders() async {
    final headers = Map<String, String>.of(jsonHeaders);
    final token = await _tokenProvider?.call();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> decodeJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected JSON object response');
  }

  /// Parses the `{data, error}` envelope of a response whose success payload
  /// is expected to be a JSON object (or absent).
  ///
  /// Throws the exception built by [onError] when:
  /// - the body contains an `error` object, or
  /// - the status code is non-2xx, or
  /// - the response body is not a decodable JSON object.
  ///
  /// Returns the decoded `data` map on success. Returns `null` when the
  /// response is 2xx and has no `data` field (e.g. fire-and-forget endpoints
  /// like `requestLoginCode`).
  Map<String, dynamic>? parseEnvelope(
    http.Response response, {
    required ApiErrorFactory onError,
  }) {
    final body = _safeDecodeObject(response.body);

    final errorJson = body?['error'];
    if (errorJson is Map<String, dynamic>) {
      final err = ApiError.fromJson(errorJson);
      throw onError(
        message: err.message,
        statusCode: response.statusCode,
        errorCode: err.code,
        showToUser: err.showToUser,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw onError(
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (body == null) {
      throw onError(
        message: 'Expected JSON object response',
        statusCode: response.statusCode,
      );
    }

    final data = body['data'];
    if (data == null) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw onError(
      message: 'Unexpected data field shape for object response',
      statusCode: response.statusCode,
    );
  }

  /// Parses the `{data, error}` envelope of a response whose success payload
  /// is expected to be a list of JSON objects.
  ///
  /// Accepts `data` as:
  /// - a top-level JSON array,
  /// - `null` (treated as empty list),
  /// - an empty object,
  /// - a wrapper object with a list under `items`, `results`, `data`, or any
  ///   of the optional [itemKeys] (e.g. `deliverables`).
  ///
  /// Throws the exception built by [onError] for transport errors, error
  /// envelopes, or unexpected shapes.
  List<Map<String, dynamic>> parseListEnvelope(
    http.Response response, {
    required ApiErrorFactory onError,
    List<String> itemKeys = const [],
  }) {
    final body = _safeDecodeObject(response.body);

    final errorJson = body?['error'];
    if (errorJson is Map<String, dynamic>) {
      final err = ApiError.fromJson(errorJson);
      throw onError(
        message: err.message,
        statusCode: response.statusCode,
        errorCode: err.code,
        showToUser: err.showToUser,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw onError(
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (body == null) {
      throw onError(
        message: 'Expected JSON object response',
        statusCode: response.statusCode,
      );
    }

    final data = body['data'];
    return _coerceListPayload(
      data,
      statusCode: response.statusCode,
      onError: onError,
      itemKeys: itemKeys,
    );
  }

  Map<String, dynamic>? _safeDecodeObject(String source) {
    if (source.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  List<Map<String, dynamic>> _coerceListPayload(
    Object? data, {
    required int statusCode,
    required ApiErrorFactory onError,
    required List<String> itemKeys,
  }) {
    if (data == null) {
      return const [];
    }
    if (data is List) {
      return _mapList(data, statusCode: statusCode, onError: onError);
    }
    if (data is Map<String, dynamic>) {
      if (data.isEmpty) {
        return const [];
      }
      final keys = <String>[...itemKeys, 'items', 'results', 'data'];
      for (final key in keys) {
        final nested = data[key];
        if (nested is List) {
          return _mapList(
            nested,
            statusCode: statusCode,
            onError: onError,
          );
        }
      }
    }
    throw onError(
      message: 'Unexpected data field shape for list response',
      statusCode: statusCode,
    );
  }

  List<Map<String, dynamic>> _mapList(
    List<dynamic> list, {
    required int statusCode,
    required ApiErrorFactory onError,
  }) {
    return list.map((e) {
      if (e is Map<String, dynamic>) {
        return e;
      }
      throw onError(
        message: 'List item must be a JSON object',
        statusCode: statusCode,
      );
    }).toList();
  }
}
