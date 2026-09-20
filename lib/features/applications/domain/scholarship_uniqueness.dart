import '../../../core/errors/failures.dart';
import 'models/application_model.dart';

class ScholarshipUniqueness {
  const ScholarshipUniqueness();

  /// Returns a [ConflictFailure] if another active award exists.
  ConflictFailure? conflictIfApplying({
    required List<ApplicationModel> existing,
    required String userId,
    String? replacingApplicationId,
  }) {
    final active = existing.where(
      (app) =>
          app.userId == userId &&
          app.isActive &&
          app.id != replacingApplicationId,
    );
    if (active.isNotEmpty) {
      final current = active.first;
      return ConflictFailure(
        'You already have an active application (${current.id} — ${current.schemeTitle}). '
        'A student may hold only one scholarship or fellowship at a time.',
      );
    }
    return null;
  }
}
