import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/models/movie.dart';

class MovieRepository {
  static const _key = 'movies';

  Future<List<Movie>> loadMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Movie> movies = [];
    List<String>? jsonStringList = prefs.getStringList(_key);
    if (jsonStringList != null) {
      movies = jsonStringList
          .map((jsonString) => Movie.fromJson(jsonDecode(jsonString)))
          .toList();
    }

    return movies;
  }

  Future<void> saveMovies(List<Movie> movies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList =
        movies.map((movie) => jsonEncode(movie.toJson())).toList();
    await prefs.setStringList(_key, jsonStringList);
  }
}
