class UserProfile {
  final String name;
  final String email;
  final String residence;
  final String favoriteBook;
  final String favoriteGenre;
  final String bio;
  final String? imagePath;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.residence = '',
    this.favoriteBook = '',
    this.favoriteGenre = '',
    this.bio = '',
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'residence': residence,
      'favoriteBook': favoriteBook,
      'favoriteGenre': favoriteGenre,
      'bio': bio,
      'imagePath': imagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      residence: json['residence'] as String? ?? '',
      favoriteBook: json['favoriteBook'] as String? ?? '',
      favoriteGenre: json['favoriteGenre'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? residence,
    String? favoriteBook,
    String? favoriteGenre,
    String? bio,
    String? imagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      residence: residence ?? this.residence,
      favoriteBook: favoriteBook ?? this.favoriteBook,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
