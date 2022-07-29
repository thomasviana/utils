part of http;

class HttpException implements IOException {
  final int statusCode;
  final String message;

  HttpException(this.statusCode, this.message);

  @override
  String toString() =>
      'HttpException{statusCode: $statusCode, message: $message}';
}

extension ResponseExt on Response {
  bool isSuccessful() => statusCode >= 200 && statusCode < 300;

  Map decodeJson() => jsonDecode(body);

  Map decodeJsonWithCookies() {
    final jsonBody = decodeJson();

    headers['set-cookie']
        ?.split(',')
        .map((rawCookie) => Cookie.fromSetCookieValue(rawCookie))
        .forEach((element) => jsonBody[element.name] = element.value);

    return jsonBody;
  }
}

extension FutureResponseExt on Future<Response> {
  Future<T> mapResponse<T>(T Function(Response response) mapper) {
    return then((response) {
      if (response.isSuccessful()) {
        return mapper(response);
      } else {
        throw HttpException(response.statusCode, response.reasonPhrase ?? '');
      }
    });
  }
}
