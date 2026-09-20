import '../../applications/domain/models/mota_scheme_model.dart';
import 'eligibility_result.dart';

class MoTAEligibilityEngine {
  static const double prePostMatricIncomeCeiling = 250000.0;
  static const double higherEduResearchOverseasIncomeCeiling = 600000.0;

  /// Evaluates student profile against a single MoTA scheme based on authentic government rules.
  static SchemeEligibilityEvaluation evaluateScheme({
    required StudentEligibilityProfile profile,
    required MotaSchemeModel scheme,
  }) {
    final passed = <String>[];
    final failed = <String>[];
    final missingDocs = <String>[];
    final pendingActions = <String>[];

    // 1. Incomplete profile check
    if (!profile.hasCompleteBasicProfile) {
      return SchemeEligibilityEvaluation(
        schemeId: scheme.schemeId,
        schemeName: scheme.schemeName,
        status: EligibilityStatus.incompleteProfile,
        isEligible: false,
        passedCriteria: const [],
        failedCriteria: const ['Incomplete profile details (Income, Caste Category, or Education Level missing)'],
        missingDocuments: const [],
        pendingActions: const ['Complete your student profile to evaluate eligibility.'],
        recommendation: 'Please provide complete income, category, and education details in your profile.',
      );
    }

    // 2. ST Community verification (Mandatory across all 5 MoTA schemes)
    final isSt = (profile.socialCategory == 'ST' ||
            profile.socialCategory == 'PVTG' ||
            profile.isScheduledTribe == true);
    if (!isSt) {
      failed.add('Only candidates belonging to recognized Scheduled Tribe (ST) communities are eligible for MoTA schemes.');
    } else {
      passed.add('Belongs to recognized Scheduled Tribe (ST) community.');
    }

    // 3. Income Ceiling Rule
    final double schemeMaxIncome = scheme.incomeLimit.maxFamilyIncome;
    final double income = profile.familyAnnualIncome!;
    if (income > schemeMaxIncome) {
      failed.add('Annual family income (₹${income.toStringAsFixed(0)}) exceeds scheme ceiling of ₹${schemeMaxIncome.toStringAsFixed(0)} (${scheme.incomeLimit.formattedLimit}).');
    } else {
      passed.add('Family annual income (₹${income.toStringAsFixed(0)}) is within the eligible limit of ${scheme.incomeLimit.formattedLimit}.');
    }

    // 4. Scheme-Specific Education Level and Institutional Rules
    final eduLevel = (profile.educationLevel ?? '').trim().toLowerCase();
    final course = (profile.currentClassOrDegree ?? '').trim().toLowerCase();
    final instType = profile.institutionType ?? 'REGULAR_RECOGNIZED';

    switch (scheme.schemeId) {
      case 'pre_matric_st':
      case 'pre_matric':
        final isPreMatric = eduLevel.contains('pre-matric') ||
            eduLevel.contains('pre_matric') ||
            eduLevel.contains('class 9') ||
            eduLevel.contains('class 10') ||
            course.contains('class 9') ||
            course.contains('class 10') ||
            course.contains('ix') ||
            course.contains('x');
        if (!isPreMatric) {
          failed.add('Pre-Matric scholarship is strictly applicable for Class IX and Class X students only.');
        } else {
          passed.add('Enrolled in regular Class IX or Class X.');
        }
        break;

      case 'post_matric_st':
      case 'post_matric':
        final isPostMatric = eduLevel.contains('post-matric') ||
            eduLevel.contains('post_matric') ||
            eduLevel.contains('higher education') ||
            eduLevel.contains('class 11') ||
            eduLevel.contains('class 12') ||
            eduLevel.contains('college') ||
            eduLevel.contains('degree') ||
            eduLevel.contains('graduation') ||
            eduLevel.contains('polytechnic') ||
            eduLevel.contains('diploma') ||
            eduLevel.contains('iti') ||
            course.contains('b.tech') ||
            course.contains('b.sc') ||
            course.contains('ba') ||
            course.contains('m.tech') ||
            course.contains('ph.d');
        if (!isPostMatric || eduLevel.contains('pre-matric')) {
          failed.add('Post-Matric scholarship is applicable for students pursuing Class XI up to Ph.D in recognized institutions.');
        } else {
          passed.add('Enrolled in recognized Post-Matric / Post-Secondary course.');
        }
        break;

      case 'top_class_st':
      case 'top_class':
        final isHigherEdu = eduLevel.contains('higher education') ||
            eduLevel.contains('degree') ||
            eduLevel.contains('post-matric') ||
            course.contains('b.tech') ||
            course.contains('mbbs') ||
            course.contains('mba') ||
            course.contains('ll.b');
        final isPremierInst = instType == 'PREMIER_NOTIFIED' ||
            course.contains('iit') ||
            course.contains('nit') ||
            course.contains('iim') ||
            course.contains('aiims') ||
            course.contains('nlu');
        if (!isHigherEdu) {
          failed.add('Top Class scholarship requires enrollment in notified undergraduate or postgraduate professional degree courses.');
        } else {
          passed.add('Enrolled in recognized professional higher education degree.');
        }
        if (!isPremierInst && instType != 'PREMIER_NOTIFIED') {
          failed.add('Top Class scheme requires admission in one of the 265 MoTA-notified premier institutions (IITs, NITs, IIMs, AIIMS, NLUs, etc.).');
        } else {
          passed.add('Admitted in MoTA-notified Premier Higher Education Institution.');
        }
        break;

      case 'nfst':
        final isResearch = eduLevel.contains('research') ||
            eduLevel.contains('m.phil') ||
            eduLevel.contains('ph.d') ||
            eduLevel.contains('phd') ||
            course.contains('ph.d') ||
            course.contains('mphil') ||
            course.contains('doctorate');
        if (!isResearch) {
          failed.add('National Fellowship (NFST) is strictly for full-time regular M.Phil and Ph.D research scholars.');
        } else {
          passed.add('Registered for regular full-time M.Phil / Ph.D research.');
        }
        break;

      case 'nos':
        final isOverseas = eduLevel.contains('overseas') ||
            eduLevel.contains('abroad') ||
            instType == 'FOREIGN_QS500' ||
            course.contains('abroad') ||
            course.contains('overseas');
        if (!isOverseas) {
          failed.add('National Overseas Scholarship (NOS) is strictly for Master\'s and Ph.D programmes at top 500 QS-ranked foreign universities.');
        } else {
          passed.add('Enrolled / Admitted for Master\'s / Ph.D in foreign university.');
        }
        if (profile.qualifyingMarksPercentage != null &&
            profile.qualifyingMarksPercentage! < 55.0) {
          failed.add('NOS requires minimum 55% marks or equivalent grade in qualifying degree.');
        } else if (profile.qualifyingMarksPercentage != null) {
          passed.add('Qualifying marks criteria satisfied (≥ 55%).');
        }
        if (profile.studentAge != null && profile.studentAge! >= 35) {
          failed.add('NOS requires candidate to be below 35 years of age on 1st July of application year.');
        }
        break;
    }

    // 5. Mandatory Document Verification
    final availableDocs = profile.availableDocumentTypes.map((d) => d.toUpperCase()).toSet();
    if (!availableDocs.contains('CASTE_CERTIFICATE') && !availableDocs.contains('ST_CERTIFICATE')) {
      missingDocs.add('Scheduled Tribe (ST) Certificate');
    }
    if (!availableDocs.contains('INCOME_CERTIFICATE')) {
      missingDocs.add('Annual Income Certificate for current financial year');
    }
    if (!availableDocs.contains('AADHAAR') && !profile.hasAadhaar) {
      missingDocs.add('Aadhaar Card (Aadhaar-seeded bank account)');
    }
    if (scheme.schemeId == 'nos' && !availableDocs.contains('PASSPORT')) {
      missingDocs.add('Valid Indian Passport');
    }

    // 6. Determine Resulting Status
    if (failed.isNotEmpty) {
      return SchemeEligibilityEvaluation(
        schemeId: scheme.schemeId,
        schemeName: scheme.schemeName,
        status: EligibilityStatus.ineligible,
        isEligible: false,
        passedCriteria: passed,
        failedCriteria: failed,
        missingDocuments: missingDocs,
        pendingActions: failed,
        recommendation: 'Criteria not met for ${scheme.shortName}. Explore other MoTA schemes.',
      );
    } else if (missingDocs.isNotEmpty) {
      pendingActions.add('Upload missing documents: ${missingDocs.join(', ')}');
      return SchemeEligibilityEvaluation(
        schemeId: scheme.schemeId,
        schemeName: scheme.schemeName,
        status: EligibilityStatus.conditionallyEligible,
        isEligible: true,
        passedCriteria: passed,
        failedCriteria: const [],
        missingDocuments: missingDocs,
        pendingActions: pendingActions,
        recommendation: 'Eligible! Upload required documents to complete verification.',
      );
    } else {
      return SchemeEligibilityEvaluation(
        schemeId: scheme.schemeId,
        schemeName: scheme.schemeName,
        status: EligibilityStatus.eligible,
        isEligible: true,
        passedCriteria: passed,
        failedCriteria: const [],
        missingDocuments: const [],
        pendingActions: ['Proceed to apply via ${scheme.applicationPortal.portalName}'],
        recommendation: 'Fully eligible. You can proceed with the application.',
      );
    }
  }

  /// Evaluates student profile across all schemes
  static List<SchemeEligibilityEvaluation> evaluateAllSchemes({
    required StudentEligibilityProfile profile,
    required List<MotaSchemeModel> schemes,
  }) {
    return schemes.map((s) => evaluateScheme(profile: profile, scheme: s)).toList();
  }
}
