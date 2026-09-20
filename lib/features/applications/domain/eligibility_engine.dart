import 'models/scheme_model.dart';

class EligibilityInput {
  final bool isScheduledTribe;
  final String educationLevel;
  final double familyAnnualIncome;
  final bool alreadyHoldsScholarship;

  const EligibilityInput({
    required this.isScheduledTribe,
    required this.educationLevel,
    required this.familyAnnualIncome,
    required this.alreadyHoldsScholarship,
  });
}

class SchemeEligibilityResult {
  final SchemeModel scheme;
  final bool eligible;
  final List<String> reasons;

  const SchemeEligibilityResult({
    required this.scheme,
    required this.eligible,
    required this.reasons,
  });
}

/// Pure domain matcher. Scheme ceilings come from data files, not widgets.
class EligibilityEngine {
  const EligibilityEngine();

  List<SchemeEligibilityResult> evaluate({
    required EligibilityInput input,
    required List<SchemeModel> schemes,
  }) {
    return schemes.map((scheme) => evaluateScheme(input, scheme)).toList();
  }

  SchemeEligibilityResult evaluateScheme(
    EligibilityInput input,
    SchemeModel scheme,
  ) {
    final reasons = <String>[];

    if (!input.isScheduledTribe) {
      reasons.add('Scheme is for Scheduled Tribe students only.');
    }
    if (input.familyAnnualIncome > scheme.maxFamilyIncome) {
      reasons.add(
        'Family income exceeds the scheme ceiling of ₹${scheme.maxFamilyIncome.toStringAsFixed(0)}.',
      );
    }
    if (!scheme.educationLevels.contains(input.educationLevel)) {
      reasons.add(
        'Education level does not match this scheme (${scheme.educationLevels.join(', ')}).',
      );
    }
    if (input.alreadyHoldsScholarship) {
      reasons.add(
        'A student may hold only one scholarship or fellowship at a time.',
      );
    }

    return SchemeEligibilityResult(
      scheme: scheme,
      eligible: reasons.isEmpty,
      reasons: reasons,
    );
  }
}
