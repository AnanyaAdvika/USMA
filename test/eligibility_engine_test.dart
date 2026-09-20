import 'package:flutter_test/flutter_test.dart';
import 'package:usma/features/applications/domain/models/mota_scheme_model.dart';
import 'package:usma/features/eligibility/domain/eligibility_engine.dart';
import 'package:usma/features/eligibility/domain/eligibility_result.dart';

void main() {
  group('MoTA Dynamic Eligibility Engine Tests', () {
    // 1. Setup Mock Scheme Data for the 5 official schemes
    final preMatricScheme = MotaSchemeModel(
      schemeId: 'pre_matric_st',
      schemeName: 'Pre-Matric Scholarship for ST Students',
      shortName: 'Pre-Matric ST',
      description: 'Pre-Matric scheme for Class 9 and 10 ST students',
      targetEducationLevel: 'Pre-Matric (Class IX & X)',
      targetEducationLevels: const ['Pre-Matric', 'Class 9', 'Class 10'],
      whoCanApply: 'ST students in Class 9 & 10',
      eligibilityCriteria: const [
        'Must belong to ST community',
        'Income up to ₹2.50 Lakh',
        'Class 9 or 10 regular student',
      ],
      incomeLimit: const IncomeLimitInfo(
        maxFamilyIncome: 250000.0,
        formattedLimit: '₹2,50,000 per annum',
        description: 'Family income up to ₹2.50 Lakh',
        relaxationNote: '',
      ),
      requiredDocuments: const [
        'ST Community Certificate',
        'Income Certificate',
        'Aadhaar Card',
      ],
      applicationPortal: const ApplicationPortalInfo(
        portalName: 'State Portal / DBT Tribal',
        portalUrl: 'https://dbttribal.gov.in',
        routingType: 'STATE_DBT',
        routingInstructions: 'Apply via State portal',
      ),
      verificationStages: const [],
      scholarshipBenefits: const ScholarshipBenefitsInfo(
        annualMaxEstimatedAmount: 5250.0,
        feeCoverage: 'Information not available / requires verification',
        maintenanceAllowance: '₹225 to ₹525 per month',
        otherAllowances: '',
        frequency: 'Per Annum',
        fundSharingRatio: '75:25',
      ),
      importantDates: const ImportantDatesInfo(
        academicYear: '2026-2027',
        applicationOpenDate: 'Information not available / requires verification',
        applicationClosingDate: 'Information not available / requires verification',
        verificationDeadline: 'Information not available / requires verification',
      ),
      officialGuidelines: const OfficialGuidelinesInfo(
        guidelineDocumentName: 'Pre-Matric Scheme Guidelines',
        lastVerifiedDate: '2026-03-20',
      ),
      faq: const [],
      grievanceInformation: const GrievanceInformation(
        portalUrl: 'https://tribal.nic.in/Grievance/',
        nodalEmail: 'tribal-scholarship@gov.in',
        helplineNumber: '0120-6619540',
        division: 'Scholarship Division',
      ),
    );

    final postMatricScheme = MotaSchemeModel(
      schemeId: 'post_matric_st',
      schemeName: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      shortName: 'Post-Matric ST',
      description: 'Post-Matric scheme for Class 11 to PhD ST students',
      targetEducationLevel: 'Post-Matric (Class XI to Ph.D)',
      targetEducationLevels: const ['Post-Matric', 'Class 11', 'Class 12', 'Graduation', 'B.Tech'],
      whoCanApply: 'ST students in post-matric courses',
      eligibilityCriteria: const [
        'Must belong to ST community',
        'Income up to ₹2.50 Lakh',
        'Post-Matric regular student',
      ],
      incomeLimit: const IncomeLimitInfo(
        maxFamilyIncome: 250000.0,
        formattedLimit: '₹2,50,000 per annum',
        description: 'Family income up to ₹2.50 Lakh',
        relaxationNote: '',
      ),
      requiredDocuments: const [
        'ST Community Certificate',
        'Income Certificate',
        'Aadhaar Card',
      ],
      applicationPortal: const ApplicationPortalInfo(
        portalName: 'National Scholarship Portal',
        portalUrl: 'https://scholarships.gov.in',
        routingType: 'NSP',
        routingInstructions: 'Apply via NSP',
      ),
      verificationStages: const [],
      scholarshipBenefits: const ScholarshipBenefitsInfo(
        annualMaxEstimatedAmount: 13500.0,
        feeCoverage: 'Compulsory non-refundable fees',
        maintenanceAllowance: '₹230 to ₹1,200 per month',
        otherAllowances: '',
        frequency: 'Per Annum',
        fundSharingRatio: '75:25',
      ),
      importantDates: const ImportantDatesInfo(
        academicYear: '2026-2027',
        applicationOpenDate: 'Information not available / requires verification',
        applicationClosingDate: 'Information not available / requires verification',
        verificationDeadline: 'Information not available / requires verification',
      ),
      officialGuidelines: const OfficialGuidelinesInfo(
        guidelineDocumentName: 'Post-Matric Scheme Guidelines',
        lastVerifiedDate: '2026-03-20',
      ),
      faq: const [],
      grievanceInformation: const GrievanceInformation(
        portalUrl: 'https://tribal.nic.in/Grievance/',
        nodalEmail: 'tribal-scholarship@gov.in',
        helplineNumber: '0120-6619540',
        division: 'Scholarship Division',
      ),
    );

    final topClassScheme = MotaSchemeModel(
      schemeId: 'top_class_st',
      schemeName: 'National Scholarship / Top Class Scholarship for Higher Education of ST Students',
      shortName: 'Top Class ST',
      description: 'Central sector scheme for ST students in 265 notified premier institutions',
      targetEducationLevel: 'Higher Education (Notified Premier Institutes)',
      targetEducationLevels: const ['Higher Education', 'B.Tech', 'MBBS', 'MBA', 'Degree'],
      whoCanApply: 'ST students in notified premier institutes (IIT/NIT/IIM/AIIMS/NLU)',
      eligibilityCriteria: const [
        'Must belong to ST community',
        'Income up to ₹6.00 Lakh',
        'Admission in notified premier institute',
      ],
      incomeLimit: const IncomeLimitInfo(
        maxFamilyIncome: 600000.0,
        formattedLimit: '₹6,00,000 per annum',
        description: 'Family income up to ₹6.00 Lakh',
        relaxationNote: '',
      ),
      requiredDocuments: const [
        'ST Community Certificate',
        'Income Certificate',
        'Aadhaar Card',
      ],
      applicationPortal: const ApplicationPortalInfo(
        portalName: 'National Scholarship Portal',
        portalUrl: 'https://scholarships.gov.in',
        routingType: 'NSP',
        routingInstructions: 'Apply via NSP MoTA section',
      ),
      verificationStages: const [],
      scholarshipBenefits: const ScholarshipBenefitsInfo(
        annualMaxEstimatedAmount: 286000.0,
        feeCoverage: 'Full tuition fees',
        maintenanceAllowance: '₹3,000 per month living allowance',
        otherAllowances: '₹5,000/yr books + ₹45,000 one-time computer grant',
        frequency: 'Per Annum',
        fundSharingRatio: '100% Central Sector',
      ),
      importantDates: const ImportantDatesInfo(
        academicYear: '2026-2027',
        applicationOpenDate: 'Information not available / requires verification',
        applicationClosingDate: 'Information not available / requires verification',
        verificationDeadline: 'Information not available / requires verification',
      ),
      officialGuidelines: const OfficialGuidelinesInfo(
        guidelineDocumentName: 'Top Class Scheme Guidelines',
        lastVerifiedDate: '2026-03-20',
      ),
      faq: const [],
      grievanceInformation: const GrievanceInformation(
        portalUrl: 'https://tribal.nic.in/Grievance/',
        nodalEmail: 'topclass-tribal@nic.in',
        helplineNumber: '0120-6619540',
        division: 'Top Class Section',
      ),
    );

    final nfstScheme = MotaSchemeModel(
      schemeId: 'nfst',
      schemeName: 'National Fellowship for ST Students (NFST)',
      shortName: 'National Fellowship (NFST)',
      description: 'Fellowship for M.Phil and Ph.D research ST students',
      targetEducationLevel: 'Research (M.Phil & Ph.D)',
      targetEducationLevels: const ['Research', 'M.Phil', 'Ph.D'],
      whoCanApply: 'ST students in full-time M.Phil / Ph.D',
      eligibilityCriteria: const [
        'Must belong to ST community',
        'Income up to ₹6.00 Lakh',
        'Registered for full-time M.Phil / Ph.D',
      ],
      incomeLimit: const IncomeLimitInfo(
        maxFamilyIncome: 600000.0,
        formattedLimit: '₹6,00,000 per annum',
        description: 'Family income up to ₹6.00 Lakh',
        relaxationNote: '',
      ),
      requiredDocuments: const [
        'ST Community Certificate',
        'Income Certificate',
        'Aadhaar Card',
      ],
      applicationPortal: const ApplicationPortalInfo(
        portalName: 'MoTA Fellowship Portal',
        portalUrl: 'https://fellowship.tribal.gov.in',
        routingType: 'FELLOWSHIP_PORTAL',
        routingInstructions: 'Apply via Fellowship Portal',
      ),
      verificationStages: const [],
      scholarshipBenefits: const ScholarshipBenefitsInfo(
        annualMaxEstimatedAmount: 416000.0,
        feeCoverage: 'As per institution rules',
        maintenanceAllowance: '₹31,000 to ₹35,000 monthly fellowship stipend',
        otherAllowances: 'HRA and annual contingency grant',
        frequency: 'Monthly Stipend',
        fundSharingRatio: '100% Central Sector',
      ),
      importantDates: const ImportantDatesInfo(
        academicYear: '2026-2027',
        applicationOpenDate: 'Information not available / requires verification',
        applicationClosingDate: 'Information not available / requires verification',
        verificationDeadline: 'Information not available / requires verification',
      ),
      officialGuidelines: const OfficialGuidelinesInfo(
        guidelineDocumentName: 'NFST Scheme Guidelines',
        lastVerifiedDate: '2026-03-20',
      ),
      faq: const [],
      grievanceInformation: const GrievanceInformation(
        portalUrl: 'https://tribal.nic.in/Grievance/',
        nodalEmail: 'fellowship-tribal@nic.in',
        helplineNumber: '011-23386128',
        division: 'Fellowship Section',
      ),
    );

    final nosScheme = MotaSchemeModel(
      schemeId: 'nos',
      schemeName: 'National Overseas Scholarship for ST Students (NOS)',
      shortName: 'National Overseas (NOS)',
      description: 'Central sector scheme for ST candidates pursuing Master/PhD abroad',
      targetEducationLevel: 'Overseas Studies (Master\'s & Ph.D Abroad)',
      targetEducationLevels: const ['Overseas', 'Master\'s Abroad', 'Ph.D Abroad'],
      whoCanApply: 'ST students with admission in top 500 QS foreign universities',
      eligibilityCriteria: const [
        'Must belong to ST community',
        'Income up to ₹6.00 Lakh',
        'Admission in top 500 QS university',
        'Min 55% qualifying marks & below 35 years age',
      ],
      incomeLimit: const IncomeLimitInfo(
        maxFamilyIncome: 600000.0,
        formattedLimit: '₹6,00,000 per annum',
        description: 'Family income up to ₹6.00 Lakh',
        relaxationNote: '',
      ),
      requiredDocuments: const [
        'ST Community Certificate',
        'Income Certificate',
        'Aadhaar Card',
        'Valid Indian Passport',
      ],
      applicationPortal: const ApplicationPortalInfo(
        portalName: 'MoTA Overseas Portal',
        portalUrl: 'https://overseas.tribal.gov.in',
        routingType: 'OVERSEAS_PORTAL',
        routingInstructions: 'Apply via Overseas Portal',
      ),
      verificationStages: const [],
      scholarshipBenefits: const ScholarshipBenefitsInfo(
        annualMaxEstimatedAmount: 2800000.0,
        feeCoverage: 'Full foreign university tuition fees',
        maintenanceAllowance: 'USD 15,400 / GBP 9,900 per annum',
        otherAllowances: 'Contingency + airfare + visa + medical insurance',
        frequency: 'Per Annum (USD / GBP)',
        fundSharingRatio: '100% Central Sector',
      ),
      importantDates: const ImportantDatesInfo(
        academicYear: '2026-2027',
        applicationOpenDate: 'Information not available / requires verification',
        applicationClosingDate: 'Information not available / requires verification',
        verificationDeadline: 'Information not available / requires verification',
      ),
      officialGuidelines: const OfficialGuidelinesInfo(
        guidelineDocumentName: 'NOS Scheme Guidelines',
        lastVerifiedDate: '2026-03-20',
      ),
      faq: const [],
      grievanceInformation: const GrievanceInformation(
        portalUrl: 'https://tribal.nic.in/Grievance/',
        nodalEmail: 'overseas-tribal@nic.in',
        helplineNumber: '011-23386128',
        division: 'Overseas Section',
      ),
    );

    final allSchemes = [
      preMatricScheme,
      postMatricScheme,
      topClassScheme,
      nfstScheme,
      nosScheme,
    ];

    // TEST 1: Eligible Student
    test('1. Eligible student passes all criteria for Post-Matric ST', () {
      const student = StudentEligibilityProfile(
        userId: 'student_001',
        isScheduledTribe: true,
        socialCategory: 'ST',
        familyAnnualIncome: 180000.0,
        educationLevel: 'Post-Matric',
        currentClassOrDegree: 'B.Tech',
        institutionType: 'REGULAR_RECOGNIZED',
        hasAadhaar: true,
        availableDocumentTypes: [
          'CASTE_CERTIFICATE',
          'INCOME_CERTIFICATE',
          'AADHAAR',
        ],
      );

      final eval = MoTAEligibilityEngine.evaluateScheme(
        profile: student,
        scheme: postMatricScheme,
      );

      expect(eval.status, EligibilityStatus.eligible);
      expect(eval.isEligible, isTrue);
      expect(eval.failedCriteria, isEmpty);
      expect(eval.missingDocuments, isEmpty);
    });

    // TEST 2: Income-Limit Failure
    test('2. Income-limit failure when income exceeds statutory ceiling of ₹2.50 Lakh for Post-Matric', () {
      const highIncomeStudent = StudentEligibilityProfile(
        userId: 'student_002',
        isScheduledTribe: true,
        socialCategory: 'ST',
        familyAnnualIncome: 350000.0, // Exceeds 2.50 Lakh
        educationLevel: 'Post-Matric',
        currentClassOrDegree: 'B.Tech',
        institutionType: 'REGULAR_RECOGNIZED',
        hasAadhaar: true,
        availableDocumentTypes: [
          'CASTE_CERTIFICATE',
          'INCOME_CERTIFICATE',
          'AADHAAR',
        ],
      );

      final eval = MoTAEligibilityEngine.evaluateScheme(
        profile: highIncomeStudent,
        scheme: postMatricScheme,
      );

      expect(eval.status, EligibilityStatus.ineligible);
      expect(eval.isEligible, isFalse);
      expect(
        eval.failedCriteria.any((f) => f.contains('exceeds scheme ceiling')),
        isTrue,
      );
    });

    // TEST 3: Education-Level Failure
    test('3. Education-level failure when Post-Matric student applies for Pre-Matric', () {
      const collegeStudent = StudentEligibilityProfile(
        userId: 'student_003',
        isScheduledTribe: true,
        socialCategory: 'ST',
        familyAnnualIncome: 150000.0,
        educationLevel: 'Post-Matric',
        currentClassOrDegree: 'B.Tech (Year 2)',
        institutionType: 'REGULAR_RECOGNIZED',
        hasAadhaar: true,
        availableDocumentTypes: [
          'CASTE_CERTIFICATE',
          'INCOME_CERTIFICATE',
          'AADHAAR',
        ],
      );

      final eval = MoTAEligibilityEngine.evaluateScheme(
        profile: collegeStudent,
        scheme: preMatricScheme,
      );

      expect(eval.status, EligibilityStatus.ineligible);
      expect(eval.isEligible, isFalse);
      expect(
        eval.failedCriteria.any((f) => f.contains('Class IX and Class X')),
        isTrue,
      );
    });

    // TEST 4: Missing Document
    test('4. Missing document yields ConditionallyEligible with list of missing items', () {
      const studentWithoutIncomeDoc = StudentEligibilityProfile(
        userId: 'student_004',
        isScheduledTribe: true,
        socialCategory: 'ST',
        familyAnnualIncome: 120000.0,
        educationLevel: 'Post-Matric',
        currentClassOrDegree: 'Class 12',
        institutionType: 'REGULAR_RECOGNIZED',
        hasAadhaar: true,
        availableDocumentTypes: [
          'CASTE_CERTIFICATE',
          // Missing INCOME_CERTIFICATE
          'AADHAAR',
        ],
      );

      final eval = MoTAEligibilityEngine.evaluateScheme(
        profile: studentWithoutIncomeDoc,
        scheme: postMatricScheme,
      );

      expect(eval.status, EligibilityStatus.conditionallyEligible);
      expect(eval.isEligible, isTrue);
      expect(eval.missingDocuments, contains('Annual Income Certificate for current financial year'));
      expect(eval.failedCriteria, isEmpty);
    });

    // TEST 5: Incomplete Profile
    test('5. Incomplete profile yields IncompleteProfile status before running rules', () {
      const incompleteStudent = StudentEligibilityProfile(
        userId: 'student_005',
        isScheduledTribe: true,
        socialCategory: 'ST',
        familyAnnualIncome: null, // Missing income
        educationLevel: null, // Missing education level
      );

      final eval = MoTAEligibilityEngine.evaluateScheme(
        profile: incompleteStudent,
        scheme: topClassScheme,
      );

      expect(eval.status, EligibilityStatus.incompleteProfile);
      expect(eval.isEligible, isFalse);
      expect(eval.failedCriteria.first, contains('Incomplete profile details'));
    });

    // TEST 6: Multiple Potentially Applicable Schemes
    test('6. Evaluates multiple potentially applicable schemes across the 5 MoTA programs', () {
      const premierStudent = StudentEligibilityProfile(
        userId: 'student_006',
        isScheduledTribe: true,
        socialCategory: 'ST',
        familyAnnualIncome: 200000.0, // <= 2.5L and <= 6.0L
        educationLevel: 'Higher Education',
        currentClassOrDegree: 'B.Tech Computer Science (NIT Rourkela)',
        institutionType: 'PREMIER_NOTIFIED',
        hasAadhaar: true,
        availableDocumentTypes: [
          'CASTE_CERTIFICATE',
          'INCOME_CERTIFICATE',
          'AADHAAR',
        ],
      );

      final evaluations = MoTAEligibilityEngine.evaluateAllSchemes(
        profile: premierStudent,
        schemes: allSchemes,
      );

      expect(evaluations.length, 5);

      final preMatricEval = evaluations.firstWhere((e) => e.schemeId == 'pre_matric_st');
      final postMatricEval = evaluations.firstWhere((e) => e.schemeId == 'post_matric_st');
      final topClassEval = evaluations.firstWhere((e) => e.schemeId == 'top_class_st');
      final nfstEval = evaluations.firstWhere((e) => e.schemeId == 'nfst');
      final nosEval = evaluations.firstWhere((e) => e.schemeId == 'nos');

      // Pre-Matric is ineligible (school vs college)
      expect(preMatricEval.isEligible, isFalse);

      // Post-Matric is eligible (income <= 2.5L, higher education)
      expect(postMatricEval.status, EligibilityStatus.eligible);

      // Top Class is eligible (notified premier institute NIT, income <= 6.0L)
      expect(topClassEval.status, EligibilityStatus.eligible);

      // NFST is ineligible (undergraduate vs PhD/M.Phil)
      expect(nfstEval.isEligible, isFalse);

      // NOS is ineligible (domestic vs abroad)
      expect(nosEval.isEligible, isFalse);
    });
  });
}
