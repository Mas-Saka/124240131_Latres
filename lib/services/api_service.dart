import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  static Future<List<Character>> getCharacters({
    String status = '',
    String name = '',
  }) async {
    final query = <String, String>{};
    if (status.isNotEmpty) query['status'] = status.toLowerCase();
    if (name.isNotEmpty) query['name'] = name;

    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((item) => Character.fromJson(item)).toList();
    }
    if (response.statusCode == 404) return [];
    throw Exception('Gagal mengambil data karakter (${response.statusCode})');
  }

  static Future<Character> getCharacterDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/character/$id'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return Character.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal mengambil detail karakter');
  }

  static Future<List<Episode>> getEpisodes() async {
    final response = await http.get(Uri.parse('$baseUrl/episode'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((item) => Episode.fromJson(item)).toList();
    }
    throw Exception('Gagal mengambil data episode');
  }
}
