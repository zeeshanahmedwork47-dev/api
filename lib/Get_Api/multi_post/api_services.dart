import 'dart:convert';
import 'package:api_testing/Get_Api/multi_post/model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://jsonplaceholder.typicode.com";

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
      headers: {
        "Accept": "application/json",
        "User-Agent": "flutter-client"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load posts: ${response.statusCode}");
    }
  }
}
