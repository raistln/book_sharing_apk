import 'package:book_sharing_app/models/recommendation_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationLevel', () {
    test('fromValue returns correct level for valid values', () {
      expect(RecommendationLevel.fromValue(1), RecommendationLevel.notRecommended);
      expect(RecommendationLevel.fromValue(2), RecommendationLevel.fineButNotForMe);
      expect(RecommendationLevel.fromValue(3), RecommendationLevel.recommendToSimilar);
      expect(RecommendationLevel.fromValue(4), RecommendationLevel.mustRead);
    });

    test('fromValue returns recommendToSimilar as fallback for invalid values', () {
      expect(RecommendationLevel.fromValue(0), RecommendationLevel.recommendToSimilar);
      expect(RecommendationLevel.fromValue(5), RecommendationLevel.recommendToSimilar);
      expect(RecommendationLevel.fromValue(99), RecommendationLevel.recommendToSimilar);
    });

    test('label returns correct labels', () {
      expect(RecommendationLevel.notRecommended.label, 'No lo recomendaría');
      expect(RecommendationLevel.fineButNotForMe.label, 'Está bien, pero no es para mí');
      expect(RecommendationLevel.recommendToSimilar.label, 'Lo recomiendo a gente como yo');
      expect(RecommendationLevel.mustRead.label, 'Todo el mundo debería leerlo');
    });

    test('shortLabel returns correct short labels', () {
      expect(RecommendationLevel.notRecommended.shortLabel, 'No recomendado');
      expect(RecommendationLevel.fineButNotForMe.shortLabel, 'Ni fu ni fa');
      expect(RecommendationLevel.recommendToSimilar.shortLabel, 'Recomendado');
      expect(RecommendationLevel.mustRead.shortLabel, 'Imprescindible');
    });

    test('icon returns correct icons', () {
      expect(RecommendationLevel.notRecommended.icon, Icons.thumb_down_off_alt);
      expect(RecommendationLevel.fineButNotForMe.icon, Icons.sentiment_neutral);
      expect(RecommendationLevel.recommendToSimilar.icon, Icons.thumb_up_alt);
      expect(RecommendationLevel.mustRead.icon, Icons.favorite);
    });

    test('color returns correct colors', () {
      expect(RecommendationLevel.notRecommended.color, Colors.red.shade400);
      expect(RecommendationLevel.fineButNotForMe.color, Colors.orange.shade400);
      expect(RecommendationLevel.recommendToSimilar.color, Colors.blue.shade400);
      expect(RecommendationLevel.mustRead.color, Colors.purple.shade400);
    });
  });
}
