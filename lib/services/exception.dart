import 'package:http/http.dart';

class TenorException implements Exception {
  final String body;
  final String url;
  final int statusCode;

  TenorException({
    required this.body,
    required this.url,
    required this.statusCode,
  });

  factory TenorException.fromResponse(Response response) {
    return TenorException(
      body: response.body,
      url: response.request?.url.toString() ?? '',
      statusCode: response.statusCode,
    );
  }

  @override
  String toString() {
    return "TenorException: Failed to get $url with $statusCode status code\nResponse: $body";
  }
}
