import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<User>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await _apiClient.get('/users/search', queryParams: {'q': query.trim()});
    if (response['data'] != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => User.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<User> getUserById(String id) async {
    final response = await _apiClient.get('/users/$id');
    return User.fromJson(response['data']);
  }
}
