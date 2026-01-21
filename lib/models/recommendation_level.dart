import 'package:flutter/material.dart';

enum RecommendationLevel {
  notRecommended(1),
  fineButNotForMe(2),
  recommendToSimilar(3),
  mustRead(4);

  final int value;
  const RecommendationLevel(this.value);

  static RecommendationLevel fromValue(int value) {
    return RecommendationLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecommendationLevel.recommendToSimilar,
    );
  }

  String get label {
    switch (this) {
      case RecommendationLevel.notRecommended:
        return 'No lo recomendaría';
      case RecommendationLevel.fineButNotForMe:
        return 'Está bien, pero no es para mí';
      case RecommendationLevel.recommendToSimilar:
        return 'Lo recomiendo a gente como yo';
      case RecommendationLevel.mustRead:
        return 'Todo el mundo debería leerlo';
    }
  }

  String get shortLabel {
    switch (this) {
      case RecommendationLevel.notRecommended:
        return 'No recomendado';
      case RecommendationLevel.fineButNotForMe:
        return 'Ni fu ni fa';
      case RecommendationLevel.recommendToSimilar:
        return 'Recomendado';
      case RecommendationLevel.mustRead:
        return 'Imprescindible';
    }
  }

  IconData get icon {
    switch (this) {
      case RecommendationLevel.notRecommended:
        return Icons.thumb_down_off_alt;
      case RecommendationLevel.fineButNotForMe:
        return Icons.sentiment_neutral;
      case RecommendationLevel.recommendToSimilar:
        return Icons.thumb_up_alt;
      case RecommendationLevel.mustRead:
        return Icons.favorite;
    }
  }

  Color get color {
    switch (this) {
      case RecommendationLevel.notRecommended:
        return Colors.red.shade400;
      case RecommendationLevel.fineButNotForMe:
        return Colors.orange.shade400;
      case RecommendationLevel.recommendToSimilar:
        return Colors.blue.shade400;
      case RecommendationLevel.mustRead:
        return Colors.purple.shade400;
    }
  }
}
