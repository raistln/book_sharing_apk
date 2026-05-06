import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

enum RecommendationLevel {
  notRecommended(1),
  fineButNotForMe(2),
  recommendToSimilar(3),
  mustRead(4),
  finishedButTough(5);

  final int value;
  const RecommendationLevel(this.value);

  // Use this list for UI order
  static const List<RecommendationLevel> orderedValues = [
    RecommendationLevel.notRecommended,
    RecommendationLevel.fineButNotForMe,
    RecommendationLevel.finishedButTough,
    RecommendationLevel.recommendToSimilar,
    RecommendationLevel.mustRead,
  ];

  static RecommendationLevel fromValue(int value) {
    return RecommendationLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecommendationLevel.recommendToSimilar,
    );
  }

  String label(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case RecommendationLevel.notRecommended:
        return s.recommendLevel1;
      case RecommendationLevel.fineButNotForMe:
        return s.recommendLevel2;
      case RecommendationLevel.recommendToSimilar:
        return s.recommendLevel3;
      case RecommendationLevel.mustRead:
        return s.recommendLevel4;
      case RecommendationLevel.finishedButTough:
        return s.recommendLevel5;
    }
  }

  String shortLabel(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case RecommendationLevel.notRecommended:
        return s.recommendLevel1Short;
      case RecommendationLevel.fineButNotForMe:
        return s.recommendLevel2Short;
      case RecommendationLevel.recommendToSimilar:
        return s.recommendLevel3Short;
      case RecommendationLevel.mustRead:
        return s.recommendLevel4Short;
      case RecommendationLevel.finishedButTough:
        return s.recommendLevel5Short;
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
      case RecommendationLevel.finishedButTough:
        return Icons.fitness_center;
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
      case RecommendationLevel.finishedButTough:
        return Colors.amber.shade800;
    }
  }
}
