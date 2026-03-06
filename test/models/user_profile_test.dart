import 'package:book_sharing_app/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('constructor sets default values', () {
      const profile = UserProfile();
      expect(profile.name, '');
      expect(profile.email, '');
      expect(profile.residence, '');
      expect(profile.favoriteBook, '');
      expect(profile.favoriteGenre, '');
      expect(profile.bio, '');
      expect(profile.imagePath, null);
    });

    test('constructor sets provided values', () {
      const profile = UserProfile(
        name: 'John',
        email: 'john@example.com',
        residence: 'New York',
        favoriteBook: '1984',
        favoriteGenre: 'Sci-Fi',
        bio: 'Reader',
        imagePath: 'path/to/image',
      );
      expect(profile.name, 'John');
      expect(profile.email, 'john@example.com');
      expect(profile.residence, 'New York');
      expect(profile.favoriteBook, '1984');
      expect(profile.favoriteGenre, 'Sci-Fi');
      expect(profile.bio, 'Reader');
      expect(profile.imagePath, 'path/to/image');
    });

    test('toJson returns correct map', () {
      const profile = UserProfile(
        name: 'John',
        email: 'john@example.com',
        residence: 'New York',
        favoriteBook: '1984',
        favoriteGenre: 'Sci-Fi',
        bio: 'Reader',
        imagePath: 'path/to/image',
      );
      final json = profile.toJson();
      expect(json['name'], 'John');
      expect(json['email'], 'john@example.com');
      expect(json['residence'], 'New York');
      expect(json['favoriteBook'], '1984');
      expect(json['favoriteGenre'], 'Sci-Fi');
      expect(json['bio'], 'Reader');
      expect(json['imagePath'], 'path/to/image');
    });

    test('fromJson creates correct UserProfile', () {
      final json = {
        'name': 'John',
        'email': 'john@example.com',
        'residence': 'New York',
        'favoriteBook': '1984',
        'favoriteGenre': 'Sci-Fi',
        'bio': 'Reader',
        'imagePath': 'path/to/image',
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.name, 'John');
      expect(profile.email, 'john@example.com');
      expect(profile.residence, 'New York');
      expect(profile.favoriteBook, '1984');
      expect(profile.favoriteGenre, 'Sci-Fi');
      expect(profile.bio, 'Reader');
      expect(profile.imagePath, 'path/to/image');
    });

    test('fromJson handles null values', () {
      final json = {
        'name': null,
        'email': null,
        'residence': null,
        'favoriteBook': null,
        'favoriteGenre': null,
        'bio': null,
        'imagePath': null,
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.name, '');
      expect(profile.email, '');
      expect(profile.residence, '');
      expect(profile.favoriteBook, '');
      expect(profile.favoriteGenre, '');
      expect(profile.bio, '');
      expect(profile.imagePath, null);
    });

    test('copyWith returns new instance with updated values', () {
      const profile = UserProfile(
        name: 'John',
        email: 'john@example.com',
      );
      final updated = profile.copyWith(
        name: 'Jane',
        bio: 'Updated bio',
      );
      expect(updated.name, 'Jane');
      expect(updated.email, 'john@example.com');
      expect(updated.bio, 'Updated bio');
      expect(updated.residence, '');
    });
  });
}
