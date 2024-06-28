class Movie {
  String title;
  int year;
  String? image;

  Movie(this.title, this.year, {this.image});

  Movie.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        year = json['year'],
        image = json['image'];

  Map<String, dynamic> toJson() =>
      {'title': title, 'year': year, 'image': image};
}
