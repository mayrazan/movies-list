import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test2/models/movie.dart';
import 'package:test2/repositories/movie_repository.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  AddMoviePageState createState() => AddMoviePageState();
}

class AddMoviePageState extends State<AddMoviePage> {
  final MovieRepository _repository = MovieRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  File? _imageFile;

  void _addMovie() async {
    if (_validateInput()) {
      await _saveMovie();
      _navigateBack();
    } else {
      _showErrorDialog();
    }
  }

  bool _validateInput() {
    String title = _titleController.text.trim();
    int year = int.tryParse(_yearController.text.trim()) ?? 0;
    return title.isNotEmpty && year > 0;
  }

  Future<void> _saveMovie() async {
    String title = _titleController.text.trim();
    int year = int.tryParse(_yearController.text.trim()) ?? 0;
    String? image = _imageFile?.path;
    Movie newMovie = Movie(title, year, image: image);
    List<Movie> movies = await _repository.loadMovies();
    movies.add(newMovie);
    await _repository.saveMovies(movies);
  }

  void _navigateBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content:
            const Text('Please enter a valid title and year for the movie.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Movie')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_titleController, 'Movie Title'),
            _buildTextField(_yearController, 'Release Year', isNumber: true),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 10),
            _buildImagePickerButtons(),
            const SizedBox(height: 20),
            _buildAddMovieButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildImagePreview() {
    return _imageFile != null
        ? Image.file(_imageFile!, height: 50)
        : const Placeholder(fallbackHeight: 50, fallbackWidth: double.infinity);
  }

  Widget _buildImagePickerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _getImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
        ),
        ElevatedButton.icon(
          onPressed: () => _getImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
        ),
      ],
    );
  }

  Widget _buildAddMovieButton() {
    return ElevatedButton(
      onPressed: _addMovie,
      child: const Text('Add Movie'),
    );
  }
}
