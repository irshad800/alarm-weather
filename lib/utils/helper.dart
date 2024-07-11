import 'dart:convert';

errorHandler(dynamic response) {
  switch (response.statusCode) {
    case 404:
      throw Exception(jsonDecode(response.body)['message']);
    default:
      throw Exception("Something went wrong");
  }
}
