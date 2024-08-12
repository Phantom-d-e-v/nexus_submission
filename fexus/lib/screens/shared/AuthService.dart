
import 'package:fexus/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart'; // Add this line to decode JWT tokens

class AuthenticationService {
  final http.Client httpClient = http.Client();
  late String _accessToken;
  late String _refreshToken;

  AuthenticationService(
      {required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // Function to check if the token is expired
  Future<bool> isTokenExpired(String token) async {
    try {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      int exp = decodedToken['exp'];
      return DateTime.now()
          .isAfter(DateTime.fromMillisecondsSinceEpoch(exp * 1000));
    } catch (e) {
      print("Error decoding token: $e");
      return true;
    }
  }

  // Function to refresh access token
  Future<void> refreshToken() async {
    try {
      var url = Uri.parse('http://localhost:8000/api/users/token/refresh/');
      var response = await httpClient.post(url, body: {
        'refresh': _refreshToken,
      });

      Map<String, dynamic>? tokens = jsonDecode(response.body);
      if (tokens != null && tokens.containsKey('access')) {
        // Save the refreshed tokens back into UserPreferences
        UserPreferences userPrefs =
            UserPreferences(interests: [], strengths: []);
        await userPrefs.saveTokens(_refreshToken, tokens['access']);

        // Reload the tokens from UserPreferences into AuthenticationService
        Map<String, dynamic> loadedTokens = await userPrefs.loadTokens();
        _refreshToken = loadedTokens['refresh'] ??
            ''; // Provide a default empty string if null
        _accessToken = loadedTokens['access'] ??
            ''; // Provide a default empty string if null

        print("Tokens refreshed: $_accessToken");
      } else {
        throw Exception('Unexpected response from token refresh endpoint');
      }
    } catch (error) {
      print("Error refreshing token: $error");
    }
  }

  // Method to save tokens
  Future<void> saveTokens(String refreshToken, String accessToken) async {
    // Implement token storage logic here
    _refreshToken = refreshToken;
    _accessToken = accessToken;
    // Optionally, save tokens to secure storage for persistent login
  }

  Future<http.Response> makeAuthenticatedRequest({
    required String url,
    required Map<String, String> headers,
    required String body,
    required String method,
  }) async {
    // Check if the token is expired and refresh if necessary
    if (await isTokenExpired(_accessToken)) {
      try {
        await refreshToken();
      } catch (e) {
        throw Exception('Failed to refresh token');
      }
    }

    // Define the request
    late http.Response response;

    // Perform the request based on the method
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(Uri.parse(url),
            headers: {'Authorization': 'Bearer $_accessToken'});
        break;
      case 'POST':
        response = await http.post(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: body);
        break;
      case 'PUT':
        response = await http.put(Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: body);
        break;
      case 'DELETE':
        response = await http.delete(Uri.parse(url),
            headers: {'Authorization': 'Bearer $_accessToken'});
        break;
      default:
        throw Exception('Unsupported HTTP method');
    }

    return response;
  }
}
