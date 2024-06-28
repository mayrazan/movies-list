import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test2/models/movie.dart';
import 'package:test2/repositories/movie_repository.dart';
import 'package:test2/screens/add_movie.dart';

class MoviesListPage extends StatefulWidget {
  const MoviesListPage({super.key});

  @override
  MoviesListPageState createState() => MoviesListPageState();
}

class MoviesListPageState extends State<MoviesListPage> {
  final MovieRepository _repository = MovieRepository();
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<Movie> movies = await _repository.loadMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _deleteMovie(int index) async {
    List<Movie> updatedMovies = List.from(_movies);
    updatedMovies.removeAt(index);
    await _repository.saveMovies(updatedMovies);

    setState(() {
      _movies = updatedMovies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies List'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMoviePage()),
          ).then((_) => _loadMovies());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!),
      );
    }

    if (_movies.isEmpty) {
      return const Center(
        child: Text('No movies to display'),
      );
    }

    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        Movie movie = _movies[index];
        return ListTile(
          title: Text(movie.title),
          subtitle: Text('Year: ${movie.year.toString()}'),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: movie.image != null
                ? Image.file(
                    File(movie.image!),
                    fit: BoxFit.cover,
                  )
                : const Placeholder(),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMovie(index),
          ),
        );
      },
    );
  }
}
