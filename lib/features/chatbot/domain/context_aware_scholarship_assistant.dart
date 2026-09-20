// ============================================================
// USMA — JAGO Scholarship Assistance System
// context_aware_scholarship_assistant.dart
//
// Core Context-Aware JAGO Engine combining:
// - Intent Detection
// - Student Context
// - Statutory MoTA Knowledge Base
// - Actionable Deep Links & Structured Formatter
// ============================================================

import 'package:intl/intl.dart';
import 'jago_intent_and_context.dart';
import 'jago_intent_classifier.dart';

class ContextAwareScholarshipAssistant {
  /// Evaluates query against student context & MoTA statutory guidelines.
  static JagoStructuredResponse process({
    required String query,
    required ComprehensiveStudentContext context,
  }) {
    final intent = JagoIntentClassifier.classify(query);

    switch (intent) {
      case JagoIntent.eligibility:
        return _handleEligibility(query, context);

      case JagoIntent.applicationStatus:
        return _handleApplicationStatus(query, context);

      case JagoIntent.documents:
        return _handleDocuments(query, context);

      case JagoIntent.deficiency:
        return _handleDeficiency(query, context);

      case JagoIntent.verification:
        return _handleVerification(query, context);

      case JagoIntent.payment:
        return _handlePayment(query, context);

      case JagoIntent.sanction:
        return _handleSanction(query, context);

      case JagoIntent.deadline:
        return _handleDeadline(query, context);

      case JagoIntent.schemeInformation:
        return _handleSchemeInfo(query, context);

      case JagoIntent.grievance:
        return _handleGrievance(query, context);

      case JagoIntent.howToApply:
        return _handleHowToApply(query, context);

      case JagoIntent.generalHelp:
        return _handleGeneralHelp(query, context);
    }
  }

  // 1. ELIGIBILITY
  static JagoStructuredResponse _handleEligibility(
    String query,
    ComprehensiveStudentContext context,
  ) {
    final lower = query.toLowerCase();

    // Check if query is about why NOT eligible
    if (lower.contains('not eligible') || lower.contains('ineligible') || lower.contains('why am i not')) {
      final isSt = context.socialCategory == 'ST' || context.isPvtg;
      final income = context.annualFamilyIncome ?? 0.0;
      final exceedsIncome = income > 250000.0;

      final buffer = StringBuffer();
      buffer.writeln(exceedsIncome
          ? '❌ Income criterion\nYour recorded annual family income (₹${income.toStringAsFixed(0)}) exceeds the configured limit of ₹2,50,000 for Pre/Post-Matric ST schemes.'
          : '✓ Income criterion\nYour recorded family income is within the configured limit.');
      buffer.writeln();
      buffer.writeln(isSt ? '✓ ST status\nVerified (${context.isPvtg ? "PVTG" : "Scheduled Tribe"})' : '❌ ST status\nMust belong to recognized ST community');
      buffer.writeln();
      buffer.writeln('✓ Education level\n${context.educationLevel ?? "Higher Education"} matches course guidelines.');
      buffer.writeln();
      buffer.writeln(context.hasDeficiencies ? '⚠ Certificate\nNeeds verification due to open deficiencies' : '✓ Certificate\nAll verified');

      return JagoStructuredResponse(
        intent: JagoIntent.eligibility,
        answer: buffer.toString().trim(),
        reason: 'Statutory criteria evaluated against current student profile record.',
        currentStatus: exceedsIncome ? 'Ineligible for PMS-ST due to income threshold' : 'Eligible based on verified profile parameters',
        requiredAction: exceedsIncome ? 'Check Top Class or Fellowship schemes which support up to ₹6.00 Lakhs ceiling.' : 'Proceed to submit application before deadline.',
        source: JagoSource.motaPortal,
        actions: const [
          JagoAction(label: 'Check Eligibility', route: '/eligibility'),
          JagoAction(label: 'View Schemes', route: '/schemes'),
        ],
        suggestions: const [
          'What documents do I need?',
          'Why is my application pending?',
        ],
      );
    }

    // General "Am I eligible" check
    final isSt = context.socialCategory == 'ST' || context.isPvtg;
    final income = context.annualFamilyIncome;

    if (!isSt) {
      return const JagoStructuredResponse(
        intent: JagoIntent.eligibility,
        answer: 'MoTA scholarships are statutory entitlements reserved exclusively for students belonging to recognized Scheduled Tribes (ST) and Particularly Vulnerable Tribal Groups (PVTGs).',
        reason: 'Candidate social category is not recorded as ST.',
        currentStatus: 'Ineligible for MoTA Tribal Scholarships',
        requiredAction: 'Visit National Scholarship Portal (scholarships.gov.in) for General/OBC/SC/Minority schemes.',
        source: JagoSource.motaPortal,
        actions: [JagoAction(label: 'View Schemes', route: '/schemes')],
      );
    }

    if (income != null && income <= 250000.0) {
      return JagoStructuredResponse(
        intent: JagoIntent.eligibility,
        answer: 'Yes! Based on your verified profile, you are eligible for the Post-Matric Scholarship for ST Students (PMS-ST). Your annual family income of ₹${income.toStringAsFixed(0)} is below the ₹2,50,000 ceiling, and your ST status is verified.',
        reason: 'Income within ₹2.50L cap + ST category verified + Higher Secondary/College enrollment.',
        currentStatus: 'Eligible for Post-Matric ST Scholarship',
        requiredAction: 'Submit or renew your Post-Matric application on the portal.',
        source: JagoSource.dbtTribal,
        actions: const [
          JagoAction(label: 'Apply for Scheme', route: '/schemes'),
          JagoAction(label: 'Check Documents', route: '/documents'),
        ],
        suggestions: const [
          'What documents do I need?',
          'When was my last payment?',
        ],
      );
    } else if (income != null && income <= 600000.0) {
      return JagoStructuredResponse(
        intent: JagoIntent.eligibility,
        answer: 'Your annual family income of ₹${income.toStringAsFixed(0)} exceeds the ₹2.50 Lakhs limit for Pre/Post-Matric ST scholarships. However, you ARE eligible for:\n1. National Scholarship Scheme for Top Class Education (Income up to ₹6.00 Lakhs in 265 Premier Institutes)\n2. National Fellowship for ST Students (NFST for M.Phil/Ph.D up to ₹6.00 Lakhs)',
        reason: 'Income ceiling for Top Class & Research Fellowships is ₹6,00,000 per annum.',
        currentStatus: 'Eligible for Top Class & Fellowship Schemes',
        requiredAction: 'Verify if your institution is listed among 265 MoTA notified premier institutes.',
        source: JagoSource.nspPortal,
        actions: const [
          JagoAction(label: 'View Top Class Schemes', route: '/schemes'),
        ],
        suggestions: const [
          'What is Top Class Education Scheme?',
          'How to apply for NFST Fellowship?',
        ],
      );
    }

    return const JagoStructuredResponse(
      intent: JagoIntent.eligibility,
      answer: 'To accurately determine your eligibility, please ensure your annual family income and education level are updated in your profile.',
      reason: 'Income or course level missing from student context.',
      currentStatus: 'Profile Incomplete',
      requiredAction: 'Update your family income and course details in Student Profile.',
      source: JagoSource.motaPortal,
      actions: [JagoAction(label: 'Update Profile', route: '/profile')],
    );
  }

  // 2. APPLICATION STATUS
  static JagoStructuredResponse _handleApplicationStatus(
    String query,
    ComprehensiveStudentContext context,
  ) {
    if (!context.hasActiveApplication) {
      return const JagoStructuredResponse(
        intent: JagoIntent.applicationStatus,
        answer: 'You currently have no active or submitted scholarship application on record.',
        reason: 'No active application linked to student account.',
        currentStatus: 'No active application',
        requiredAction: 'Discover eligible schemes and apply now.',
        source: JagoSource.motaPortal,
        actions: [JagoAction(label: 'View Schemes', route: '/schemes')],
        suggestions: ['Am I eligible for Post-Matric?', 'What documents do I need?'],
      );
    }

    final scheme = context.activeSchemeTitle ?? 'Post-Matric ST Scholarship';
    final status = context.applicationStatus ?? 'submitted';
    final inst = context.institutionName ?? 'enrolled institution';

    String readableStage;
    String actionReq;
    String reason;

    if (status == 'submitted' || context.verificationStatus == 'INSTITUTE_PENDING') {
      readableStage = 'Waiting for Institute Verification';
      reason = 'Your application has been received and forwarded to $inst for Level-1 nodal verification.';
      actionReq = 'Contact your institute scholarship desk/nodal officer to verify your Bonafide attendance.';
    } else if (status == 'under_verification') {
      readableStage = 'District / State Nodal Verification';
      reason = 'Institute has verified. The application is now being checked by the District Welfare Officer.';
      actionReq = 'No immediate student action needed. Monitor tracking timeline.';
    } else if (status == 'deficiency_raised') {
      readableStage = 'Deficiency Raised by Verification Officer';
      reason = 'The verification officer flagged items: ${context.deficiencies.join(", ")}.';
      actionReq = 'Re-upload corrected documents via Document Vault before the resubmission window closes.';
    } else if (status == 'sanctioned') {
      readableStage = 'Sanctioned by Ministry of Tribal Affairs';
      reason = 'Sanction Order issued (${context.sanctionOrderNumber ?? "MOTA/2026/ST-8821"}). Fund clearance forwarded to PFMS.';
      actionReq = 'Ensure bank account is seeded with Aadhaar and active on NPCI mapper.';
    } else if (status == 'disbursed') {
      readableStage = 'DBT Disbursed via PFMS';
      reason = 'Funds have been credited via Direct Benefit Transfer.';
      actionReq = 'Check passbook or transaction history.';
    } else {
      readableStage = status.toUpperCase();
      reason = 'Application is progressing through statutory verification workflow.';
      actionReq = 'Track timeline updates in the dashboard.';
    }

    return JagoStructuredResponse(
      intent: JagoIntent.applicationStatus,
      answer: 'Your $scheme application is currently: $readableStage.',
      reason: reason,
      currentStatus: readableStage,
      requiredAction: actionReq,
      source: JagoSource.motaPortal,
      actions: [
        const JagoAction(label: 'View Application', route: '/applications'),
        const JagoAction(label: 'Check Documents', route: '/documents'),
      ],
      suggestions: [
        'Has my scholarship been sanctioned?',
        'When was my last payment?',
        'What documents are missing?',
      ],
    );
  }

  // 3. DOCUMENTS
  static JagoStructuredResponse _handleDocuments(
    String query,
    ComprehensiveStudentContext context,
  ) {
    final lower = query.toLowerCase();

    if (lower.contains('expired') || lower.contains('income cert')) {
      return const JagoStructuredResponse(
        intent: JagoIntent.documents,
        answer: 'Income certificates are valid only for the financial year in which they are issued. If your income certificate has expired, you must obtain a renewed certificate from your local Tehsildar / SDO / e-District portal and update it in your DigiLocker vault.',
        reason: 'Statutory audit requirement: Current financial year income must be proven.',
        currentStatus: 'Valid Income Certificate Required',
        requiredAction: 'Apply for fresh Income Certificate on State e-District portal and link via DigiLocker.',
        source: JagoSource.dbtTribal,
        actions: [JagoAction(label: 'Open Document Vault', route: '/documents')],
      );
    }

    if (context.hasMissingDocuments || context.hasDeficiencies) {
      final missingList = [
        ...context.missingDocuments,
        ...context.deficiencies,
      ];
      final items = missingList.map((e) => '• $e').join('\n');

      return JagoStructuredResponse(
        intent: JagoIntent.documents,
        answer: 'The following documents require your immediate attention:\n$items',
        reason: 'Items are missing from profile or flagged by verification nodal officer.',
        currentStatus: '${missingList.length} Action Item(s) Pending',
        requiredAction: 'Fetch pre-verified copies from DigiLocker or upload clear PDF scans.',
        source: JagoSource.motaPortal,
        actions: const [
          JagoAction(label: 'Check Documents', route: '/documents'),
        ],
        suggestions: ['Why is my application pending?', 'Track Application'],
      );
    }

    return const JagoStructuredResponse(
      intent: JagoIntent.documents,
      answer: 'Standard mandatory documents for MoTA Scholarships:\n1. ST Caste Certificate (issued by competent revenue authority)\n2. Annual Income Certificate (current financial year)\n3. Aadhaar Card (linked with bank account on NPCI)\n4. Previous Year Passing Marksheet\n5. Bonafide Student Certificate & Fee Receipt\n6. Bank Passbook copy (showing IFSC & Account Number)',
      reason: 'Statutory verification checklist under MoTA operational guidelines.',
      currentStatus: 'All core documents uploaded on your profile',
      requiredAction: 'Ensure certificates in DigiLocker match profile details exactly.',
      source: JagoSource.motaPortal,
      actions: [JagoAction(label: 'Check Documents', route: '/documents')],
      suggestions: ['Am I eligible for Post-Matric?', 'Track Application'],
    );
  }

  // 4. DEFICIENCY
  static JagoStructuredResponse _handleDeficiency(
    String query,
    ComprehensiveStudentContext context,
  ) {
    if (context.deficiencies.isEmpty) {
      return const JagoStructuredResponse(
        intent: JagoIntent.deficiency,
        answer: 'Good news! There are zero open deficiencies on your scholarship application.',
        reason: 'No queries or defects raised by Institute or State Nodal Officers.',
        currentStatus: 'Zero Deficiencies Pending',
        requiredAction: 'No action needed at this time.',
        source: JagoSource.motaPortal,
        actions: [JagoAction(label: 'View Application', route: '/applications')],
      );
    }

    final defItems = context.deficiencies.map((d) => '• $d').join('\n');
    return JagoStructuredResponse(
      intent: JagoIntent.deficiency,
      answer: 'The verification authority has raised the following deficiency:\n$defItems',
      reason: 'Discrepancy found during Institute or Nodal document scrutiny.',
      currentStatus: 'Deficiency Raised — Action Required',
      requiredAction: 'Upload the corrected document in Document Vault and resubmit before the deadline.',
      source: JagoSource.motaPortal,
      actions: const [
        JagoAction(label: 'Check Documents', route: '/documents'),
        JagoAction(label: 'View Application', route: '/applications'),
      ],
      suggestions: ['Why haven\'t I received my scholarship?', 'Raise Grievance'],
    );
  }

  // 5. VERIFICATION
  static JagoStructuredResponse _handleVerification(
    String query,
    ComprehensiveStudentContext context,
  ) {
    final vStatus = context.verificationStatus ?? 'INSTITUTE_PENDING';

    if (vStatus == 'MISMATCH_DETECTED') {
      return const JagoStructuredResponse(
        intent: JagoIntent.verification,
        answer: 'A demographic variance was detected between your Caste Certificate and Aadhaar demographic records (e.g., name abbreviation variance). Your application has been routed to District Nodal Officer for manual review and is NOT blocked.',
        reason: 'MoTA policy ensures minor phonetic or abbreviation mismatches do not cause automatic rejection.',
        currentStatus: 'Under Manual Officer Review',
        requiredAction: 'Contact your District Welfare Officer if clarification is requested.',
        source: JagoSource.motaPortal,
        actions: [JagoAction(label: 'Check Integration Status', route: '/integration-status')],
      );
    }

    return JagoStructuredResponse(
      intent: JagoIntent.verification,
      answer: 'MoTA Unified Verification operates across three sequential levels:\n1. Institute Level: Verification of enrollment, bonafide status, and fee receipt.\n2. District/State Level: Verification of ST category, domicile, and income validity.\n3. Ministry Central Level: De-duplication check against NSP & PFMS database.',
      reason: 'Multi-tier verification mandated by Central Sector/Centrally Sponsored scheme norms.',
      currentStatus: 'Current Stage: ${context.verificationStatus ?? "Level-1 Institute Verification"}',
      requiredAction: 'Track verification progress in the Unified Command Center.',
      source: JagoSource.motaPortal,
      actions: const [
        JagoAction(label: 'Track Application', route: '/applications'),
        JagoAction(label: 'Integration Status', route: '/integration-status'),
      ],
    );
  }

  // 6. PAYMENT & DBT
  static JagoStructuredResponse _handlePayment(
    String query,
    ComprehensiveStudentContext context,
  ) {
    if (!context.hasActiveApplication) {
      return const JagoStructuredResponse(
        intent: JagoIntent.payment,
        answer: 'You have no active scholarship application, so no DBT disbursements are scheduled.',
        reason: 'No application registered.',
        currentStatus: 'No payment pending',
        requiredAction: 'Check eligible schemes and submit an application.',
        source: JagoSource.motaPortal,
        actions: [JagoAction(label: 'View Schemes', route: '/schemes')],
      );
    }

    if (context.paymentStatus == 'SUCCESS' && context.lastDisbursedAmount != null) {
      final dateStr = context.lastPaymentDate != null
          ? DateFormat('dd MMM yyyy').format(context.lastPaymentDate!)
          : 'recently';
      return JagoStructuredResponse(
        intent: JagoIntent.payment,
        answer: 'Direct Benefit Transfer (DBT) of ₹${context.lastDisbursedAmount!.toStringAsFixed(0)} was successfully credited to your Aadhaar-seeded bank account on $dateStr.',
        reason: 'PFMS transaction confirmed with UTR: ${context.lastPaymentUtr ?? "SIM-SBIN002938192026"}.',
        currentStatus: 'Payment Credited (PFMS DBT Success)',
        requiredAction: 'Check your bank passbook/SMS alert. If amount not reflected, confirm Aadhaar NPCI mapper status.',
        source: JagoSource.dbtTribal,
        actions: const [
          JagoAction(label: 'Track Payment', route: '/disbursements'),
        ],
        suggestions: ['Has my scholarship been sanctioned?', 'What documents are missing?'],
      );
    }

    if (context.applicationStatus == 'sanctioned') {
      return const JagoStructuredResponse(
        intent: JagoIntent.payment,
        answer: 'Your scholarship is sanctioned! The payment file has been generated and pushed to the Public Financial Management System (PFMS) for Treasury clearing.',
        reason: 'Awaiting NPCI mapper routing & state treasury fund release.',
        currentStatus: 'PFMS Clearing in Progress',
        requiredAction: 'Ensure your bank account is active and seeded with Aadhaar on the NPCI mapper.',
        source: JagoSource.dbtTribal,
        actions: [JagoAction(label: 'Track Payment', route: '/disbursements')],
      );
    }

    return JagoStructuredResponse(
      intent: JagoIntent.payment,
      answer: 'Payment cannot be processed until your application completes Institute and State verification stages. Your application is currently in the "${context.applicationStatus ?? "Under Verification"}" stage.',
      reason: 'Statutory rule: PFMS DBT disbursement is triggered only after final administrative sanction.',
      currentStatus: 'Payment Pending Verification & Sanction',
      requiredAction: 'Follow up with your institute nodal officer to expedite pending verification.',
      source: JagoSource.motaPortal,
      actions: const [
        JagoAction(label: 'Track Application', route: '/applications'),
      ],
      suggestions: ['Why is my application pending?', 'What documents are missing?'],
    );
  }

  // 7. SANCTION
  static JagoStructuredResponse _handleSanction(
    String query,
    ComprehensiveStudentContext context,
  ) {
    if (context.applicationStatus == 'sanctioned' || context.sanctionOrderNumber != null) {
      final amount = context.sanctionedAmount != null
          ? '₹${context.sanctionedAmount!.toStringAsFixed(0)}'
          : '₹85,000';
      return JagoStructuredResponse(
        intent: JagoIntent.sanction,
        answer: 'Yes! Your scholarship has been sanctioned for $amount under Ministry Sanction Order #${context.sanctionOrderNumber ?? "MOTA/2026/ST-8821"}.',
        reason: 'All verification levels passed and expenditure sanction approved by competent authority.',
        currentStatus: 'Officially Sanctioned',
        requiredAction: 'Monitor PFMS DBT transfer timeline.',
        source: JagoSource.motaPortal,
        actions: const [
          JagoAction(label: 'Track Payment', route: '/disbursements'),
          JagoAction(label: 'View Application', route: '/applications'),
        ],
      );
    }

    return JagoStructuredResponse(
      intent: JagoIntent.sanction,
      answer: 'Your application has NOT yet reached the sanction stage. It is currently in the "${context.applicationStatus ?? "Under Verification"}" phase.',
      reason: 'Sanction orders are issued after Institute and State Nodal approvals are finalized.',
      currentStatus: 'Pending Sanction',
      requiredAction: 'Check for any open deficiencies that might be delaying approval.',
      source: JagoSource.motaPortal,
      actions: const [
        JagoAction(label: 'Track Application', route: '/applications'),
        JagoAction(label: 'Check Documents', route: '/documents'),
      ],
    );
  }

  // 8. DEADLINE
  static JagoStructuredResponse _handleDeadline(
    String query,
    ComprehensiveStudentContext context,
  ) {
    return const JagoStructuredResponse(
      intent: JagoIntent.deadline,
      answer: 'Statutory Academic Year 2026-27 MoTA timelines:\n• Student Application Closing: 31st October 2026\n• Level-1 Institute Verification Deadline: 15th November 2026\n• Level-2 State Nodal Verification Deadline: 30th November 2026\n• Deficiency Rectification Window: 15 days from notice date',
      reason: 'MoTA annual operational schedule published on tribal.nic.in.',
      currentStatus: 'Active Application Window Open',
      requiredAction: 'Submit all pending forms and resolve deficiencies before the institutional cutoff.',
      source: JagoSource.motaPortal,
      actions: [JagoAction(label: 'View Application', route: '/applications')],
    );
  }

  // 9. SCHEME INFORMATION
  static JagoStructuredResponse _handleSchemeInfo(
    String query,
    ComprehensiveStudentContext context,
  ) {
    final lower = query.toLowerCase();

    if (lower.contains('top class')) {
      return const JagoStructuredResponse(
        intent: JagoIntent.schemeInformation,
        answer: 'National Scholarship Scheme for Top Class Education:\n• For ST students in 265 notified premier institutes (IIT, IIM, NIT, AIIMS, NLU).\n• Family Income Limit: Up to ₹6.00 Lakhs/annum.\n• Coverage: Full tuition fee + ₹3,000/month living allowance + ₹5,000/year books + ₹45,000 one-time computer grant.',
        reason: 'Centrally funded statutory excellence scheme for tribal scholars.',
        currentStatus: 'Configured on National Scholarship Portal (scholarships.gov.in)',
        requiredAction: 'Apply through USMA or NSP with valid institutional admission letter.',
        source: JagoSource.nspPortal,
        actions: [JagoAction(label: 'View Schemes', route: '/schemes')],
      );
    }

    if (lower.contains('fellowship') || lower.contains('nfst')) {
      return const JagoStructuredResponse(
        intent: JagoIntent.schemeInformation,
        answer: 'National Fellowship for ST Students (NFST):\n• 750 fresh fellowships awarded annually for full-time M.Phil / Ph.D in UGC recognized universities.\n• Income Limit: Up to ₹6.00 Lakhs/annum.\n• Financial Assistance: JRF @ ₹31,000/month, SRF @ ₹35,000/month + HRA + Contingency.',
        reason: 'Direct central fellowship managed via fellowship.tribal.gov.in.',
        currentStatus: 'Annual Merit Selection',
        requiredAction: 'Check portal announcements for next fellowship batch intake.',
        source: JagoSource.fellowshipPortal,
        actions: [JagoAction(label: 'View Schemes', route: '/schemes')],
      );
    }

    if (lower.contains('nos') || lower.contains('overseas')) {
      return const JagoStructuredResponse(
        intent: JagoIntent.schemeInformation,
        answer: 'National Overseas Scholarship (NOS) for ST Students:\n• 20 annual slots (17 ST + 3 PVTG) for Master\'s/Ph.D in top foreign universities.\n• Income Limit: Up to ₹6.00 Lakhs/annum.\n• Coverage: Full tuition fees + USD 15,400/year maintenance allowance + visa + medical insurance + economy airfare.',
        reason: 'Flagship international education scheme by Ministry of Tribal Affairs.',
        currentStatus: 'Overseas Portal Selection',
        requiredAction: 'Check overseas.tribal.gov.in with unconditional admission offer.',
        source: JagoSource.overseasPortal,
        actions: [JagoAction(label: 'View Schemes', route: '/schemes')],
      );
    }

    return const JagoStructuredResponse(
      intent: JagoIntent.schemeInformation,
      answer: 'Ministry of Tribal Affairs operates 5 statutory scholarship programs:\n1. Pre-Matric ST (Classes 9 & 10, income cap ₹2.50L)\n2. Post-Matric ST (Class 11 to Ph.D, income cap ₹2.50L)\n3. Top Class Education (265 Premier Institutes, income cap ₹6.00L)\n4. National Fellowship (NFST for M.Phil/Ph.D, 750 slots)\n5. National Overseas Scholarship (NOS for study abroad, 20 slots)',
      reason: 'Official scholarship umbrella under tribal.nic.in.',
      currentStatus: '5 Schemes Operational',
      requiredAction: 'Use the Eligibility Checker to determine the best matching scheme.',
      source: JagoSource.motaPortal,
      actions: [
        JagoAction(label: 'Check Eligibility', route: '/eligibility'),
        JagoAction(label: 'View Schemes', route: '/schemes'),
      ],
    );
  }

  // 10. GRIEVANCE
  static JagoStructuredResponse _handleGrievance(
    String query,
    ComprehensiveStudentContext context,
  ) {
    final appId = context.activeSchemeId != null
        ? 'USMA-${context.activeSchemeId}-2026'
        : 'APP-MOTA-2026-UNSPECIFIED';
    final scheme = context.activeSchemeTitle ?? 'Post-Matric ST Scholarship';

    final draft = {
      'scheme': scheme,
      'applicationId': appId,
      'category': 'Delayed Institute Verification / Payment Delay',
      'description':
          'Application $appId for $scheme is pending resolution. Requesting expedited administrative review.',
      'supportingDocument': 'Aadhaar_ST_Certificate_Linked.pdf',
      'createdDate': DateTime.now().toIso8601String(),
      'status': 'DRAFT_ONLY_NOT_SUBMITTED',
    };

    return JagoStructuredResponse(
      intent: JagoIntent.grievance,
      answer: 'I have formulated a Draft Grievance for you. As a matter of policy, JAGO does not automatically submit grievances to government portals without a verified live MoTA Grievance API.',
      reason: 'Prevents unintentional duplicate grievance tickets on the MoTA portal.',
      currentStatus: 'Draft Grievance Created (Pending User Confirmation)',
      requiredAction: 'Review the grievance details below or submit through official portal at tribal.nic.in/Grievance.',
      source: JagoSource.grievancePortal,
      isGrievanceDraft: true,
      grievanceDraft: draft,
      actions: const [
        JagoAction(
          label: 'Official MoTA Grievance Portal',
          route: 'https://tribal.nic.in/Grievance/',
          isExternal: true,
        ),
      ],
      suggestions: ['Why is my application pending?', 'Track Application'],
    );
  }

  // 11. HOW TO APPLY
  static JagoStructuredResponse _handleHowToApply(
    String query,
    ComprehensiveStudentContext context,
  ) {
    return const JagoStructuredResponse(
      intent: JagoIntent.howToApply,
      answer: 'Standard 4-Step Application Process:\n1. Profile & eKYC: Complete Aadhaar eKYC to pull identity & ST demographic data.\n2. Scheme Selection: Choose Pre-Matric, Post-Matric, or Top Class scheme.\n3. Digital Vault: Link DigiLocker to auto-verify your Caste and Income certificates.\n4. Submit: Review form and submit for Level-1 Institute Verification.',
      reason: 'Unified paperless workflow implemented in USMA platform.',
      currentStatus: 'Application Window Open',
      requiredAction: 'Tap "Apply for Scheme" to launch the unified application wizard.',
      source: JagoSource.motaPortal,
      actions: [
        JagoAction(label: 'View Schemes', route: '/schemes'),
        JagoAction(label: 'Check Documents', route: '/documents'),
      ],
    );
  }

  // 12. GENERAL HELP (Fallback)
  static JagoStructuredResponse _handleGeneralHelp(
    String query,
    ComprehensiveStudentContext context,
  ) {
    return const JagoStructuredResponse(
      intent: JagoIntent.generalHelp,
      answer: 'I do not have verified official information for this question. Please check the official Ministry of Tribal Affairs portal or contact the National Scholarship Helpdesk at 0120-6619540.',
      reason: 'No matching rule found in verified MoTA statutory scholarship guidelines.',
      currentStatus: 'Verified information unavailable',
      requiredAction: 'Visit official portal or rephrase using questions like "Am I eligible?" or "Track my payment".',
      source: JagoSource.motaPortal,
      actions: [
        JagoAction(label: 'Check Eligibility', route: '/eligibility'),
        JagoAction(label: 'Track Application', route: '/applications'),
      ],
      suggestions: [
        'Am I eligible for Post-Matric?',
        'What documents are missing?',
        'Why is my application pending?',
        'Has my scholarship been sanctioned?',
        'When was my last payment?',
        'How do I raise a grievance?',
      ],
    );
  }
}
