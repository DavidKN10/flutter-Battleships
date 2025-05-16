import 'package:http/http.dart' as http;

// REST api implementation

class ApiHelper {
  ApiHelper._internal();

  static const String apiUrl = "https://battleships-app.onrender.com/";

  static Map inverse(Map f) {
    return f.map((key, value) => MapEntry(value, key));
  }

  static Future<http.Response> callApi(String route, data,
    {String token = ""}) async {
      
      Map<String, String> headers = {};
      headers["Content-Type"] = "application/json";

      if (token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      return http.post(
        Uri.parse("$apiUrl$route"),
        headers: headers,
        body: data,
      ); 
  }

  static Future<http.Response> callApiGet(String route, data,
    {String token = ""}) async {

      Map<String, String> headers = {};
      headers["Content-Type"] = "application/json";
      
      if (token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      return http.get(
        Uri.parse("$apiUrl$route"),
        headers: headers,
      );
  }

  static Future<http.Response> callApiPut(String route, data,
    {String token = ""}) async {
      Map<String, String> headers = {};
      headers["Content-Type"] = "application/json";
      
      if (token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      return http.put(
        Uri.parse("$apiUrl$route"),
        headers: headers,
        body: data,
      );
  }

  static Future<http.Response> callApiDelete(String route, data,
    {String token = ""}) async {
      Map<String, String> headers = {};
      headers["Content-Type"] = "application/json";
      
      if (token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      return http.delete(
        Uri.parse("$apiUrl$route"),
        headers: headers,
      );
  }

}