<div align="center">
  <!-- You can replace this banner image with an assets/banner.png if available -->
  <h1>🎓 USMA</h1>
  <h3>Unified Scholarship Mobile Application</h3>
  <p><strong>A Unified Single-Window Mobile Platform for MoTA ST Scholarships</strong></p>

  <p>
    <a href="https://sih.gov.in/sih2026PS"><img src="https://img.shields.io/badge/SIH%202026-Problem%20SIH26238-blue.svg?style=for-the-badge" alt="SIH 2026"></a>
    <img src="https://img.shields.io/badge/Ministry-Ministry%20of%20Tribal%20Affairs-orange.svg?style=for-the-badge" alt="Ministry">
    <img src="https://img.shields.io/badge/Framework-Flutter%203.19+-02569B.svg?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/State%20Management-Riverpod-1A237E.svg?style=for-the-badge" alt="Riverpod">
    <img src="https://img.shields.io/badge/Backend-Firebase-FFCA28.svg?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
    <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg?style=for-the-badge" alt="License">
  </p>
</div>

> **Problem Statement (SIH26238):** Development of a Unified Scholarship Mobile Application offering a consolidated single-window experience for Ministry of Tribal Affairs (MoTA) Scheduled Tribe (ST) scholarships.  
> **Target Beneficiaries:** ST Students, Educational Institutions, Verification Officers, and MoTA Administrators.  
> **Core Objective:** Eliminate fragmented scholarship portals, reduce application drop-off rates, provide real-time DBT tracking, and enable offline-ready multilingual accessibility.

---

## 📑 Table of Contents
- [📌 Overview](#-overview)
- [✨ Key Modules & Technical Features](#-key-modules--technical-features)
- [🏗️ System Architecture](#️-system-architecture)
- [📂 Repository Structure](#-repository-structure)
- [⚙️ Installation & Setup](#️-installation--setup)
- [📱 APK Release & Testing](#-apk-release--testing)
- [🎯 SIH Compliance Verification](#-sih-compliance-verification)
- [📄 License](#-license)

---

## 📌 Overview

Currently, Scheduled Tribe (ST) students face steep hurdles navigating disparate state and central scholarship portals, ambiguous eligibility criteria, untracked Direct Benefit Transfer (DBT) disbursements, and poor mobile network connectivity in remote tribal pockets.

**USMA (Unified Scholarship Mobile Application)** addresses these gaps with a student-centric, cloud-native Flutter mobile application tailored to MoTA scholarship schemes:
1. **Consolidated Single-Window Dashboard:** Complete visibility into all central & state ST scholarship schemes with deadline alerts and eligibility match scoring.
2. **Dynamic Eligibility Engine:** Real-time eligibility evaluation based on academic, income, domicile, and quota criteria before document submission.
3. **End-to-End DBT & Disbursement Tracker:** Stage-by-stage transparent tracking from institutional verification to bank PFMS credit.
4. **Digital Document Vault:** Secure file uploads, caching, and document status verification eliminating repeated physical paperwork.
5. **Contextual AI Chatbot & Multilingual Support:** In-app multilingual query resolution and FAQ assistance for first-generation scholars.
6. **Offline-Resilient Architecture:** Local caching powered by Hive ensuring application status and submitted profiles remain accessible even in poor connectivity zones.

---

## ✨ Official MoTA Scholarship Schemes Coverage

USMA implements accurate data modeling, statutory rule verification, and portal routing for all five scholarship schemes administered by the **Ministry of Tribal Affairs (MoTA), Government of India** ([tribal.nic.in/ScholarshiP.aspx](https://tribal.nic.in/ScholarshiP.aspx)):

| # | Official Scheme Name | Target Level | Income Ceiling | Key Benefits | Application Route |
|---|----------------------|--------------|----------------|--------------|-------------------|
| 1 | **Pre-Matric Scholarship for ST Students** | Class IX & X | ₹2,50,000 / yr | Monthly maintenance (₹225 Day / ₹525 Hosteller) | State Portal / MoTA DBT Tribal |
| 2 | **Post-Matric Scholarship for ST Students (PMS-ST)** | Class XI to Ph.D | ₹2,50,000 / yr | Compulsory course fees + Monthly allowance (₹230 to ₹1,200) | NSP / State DBT Portal |
| 3 | **National Scholarship / Top Class Education for ST Students** | 265 Notified Premier Institutes (IIT/NIT/IIM/AIIMS/NLU) | ₹6,00,000 / yr | Full tuition fee + ₹3,000/mo living + ₹5,000 books + ₹45,000 computer grant | National Scholarship Portal (NSP) |
| 4 | **National Fellowship for ST Students (NFST)** | Regular M.Phil & Ph.D | ₹6,00,000 / yr | 750 slots/yr; Monthly fellowship (₹31k JRF / ₹35k SRF) + HRA + Contingency | MoTA Fellowship Portal |
| 5 | **National Overseas Scholarship for ST Students (NOS)** | Master's, Ph.D & Post-Doc Abroad (Top 500 QS) | ₹6,00,000 / yr | 20 slots/yr (17 ST + 3 PVTG); Full foreign tuition + USD 15,400/yr + Airfare | MoTA Overseas Portal |

---

## ✨ Key Modules & Technical Features

### 1. 🔍 MoTA Scholarship Explorer (`features/applications`)
- Single-window discovery platform for all 5 statutory MoTA scholarship schemes.
- Visual cards displaying target criteria, income ceilings, main financial benefits, application route, and instant personal eligibility evaluation.
- Official Ministry attribution indicators (`Source: Ministry of Tribal Affairs`).
- Unverified items explicitly marked as `"Information not available / requires verification"`.

### 2. 🎯 Dynamic Scheme-Specific Eligibility Engine (`features/eligibility`)
- Replaces generic filtering with real-world statutory rule validation evaluating:
  - **Community Eligibility:** Valid ST / PVTG tribal category requirement.
  - **Income Ceilings:** Validates ₹2.50L ceiling (Pre/Post-Matric) vs ₹6.00L ceiling (Top Class, NFST, NOS).
  - **Educational & Institutional Fit:** Differentiates school, college, 265 notified premier institutions, M.Phil/Ph.D research, and top 500 QS foreign universities.
  - **Document Completeness:** Checks for Caste Certificate, Income Certificate, Aadhaar seeding, and Valid Passport.
- Provides actionable diagnostic results (`Eligible`, `Conditionally Eligible`, `Ineligible`, `Incomplete Profile`).

### 3. 📊 Consolidated Dashboard (`features/dashboard`)
- Unified interface displaying ongoing scholarship cycles, key deadlines, active application statuses, and urgent notices.
- Personalized scholarship recommendations based on student profile attributes.

### 4. 📝 Applications & Lifecycle Tracking (`features/applications`)
- Intuitive step-by-step application submission workflow.
- Granular tracking with timeline milestones: `Draft` ➔ `Submitted` ➔ `Institute Verified` ➔ `State Approved` ➔ `Sanctioned` ➔ `Disbursed`.

### 5. 💳 DBT & Disbursement Monitoring (`features/disbursements`)
- Transparent tracking of financial disbursements, transaction IDs, payment batch numbers, and PFMS reconciliation.
- Direct Aadhaar-seeded bank account status validation.

### 6. 🤖 Support Chatbot & Helpdesk (`features/chatbot`)
- Integrated automated chatbot for instantaneous assistance regarding criteria, guidelines, and document prerequisites.
- Offline-ready FAQ knowledge base stored natively (`assets/faq/faq.json`).

### 7. 📁 Secure Document Management (`features/documents`)
- DigiLocker integration and digital vault for paperless verification.
- Encrypted storage uploads via Firebase Storage with file integrity validation.

---

## 🏗️ System Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                     Presentation Layer                          │
│        (Flutter Material Design 3 + Riverpod State Management)  │
└────────────────┬───────────────────────────────┬────────────────┘
                 │                               │
                 ▼                               ▼
┌────────────────────────────────┐ ┌──────────────────────────────┐
│       Feature Controllers      │ │     Core App Infrastructure  │
│  - Dashboard & Eligibility     │ │  - AppRouter (GoRouter)      │
│  - Applications & Tracking     │ │  - AppTheme & Design Tokens  │
│  - Chatbot & Notifications     │ │  - Localization & Constants  │
│  - Documents & Profile         │ │  - Network Connectivity Watch│
└────────────────┬───────────────┘ └──────────────┬───────────────┘
                 │                                │
                 ▼                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Data & Domain Services                      │
│        Repository Pattern • DTO Mappings • Local Cache Engine   │
└────────────────┬───────────────────────────────┬────────────────┘
                 │                               │
         ┌───────┴───────┐               ┌───────┴───────┐
         ▼               ▼               ▼               ▼
┌─────────────────┐ ┌─────────┐ ┌─────────────────┐ ┌───────────┐
│ Cloud Firestore │ │ Firebase│ │ Firebase Cloud  │ │   Hive    │
│ (NoSQL Database)│ │ Storage │ │ Messaging (FCM) │ │ (Offline) │
└─────────────────┘ └─────────┘ └─────────────────┘ └───────────┘
```

---

## 📂 Repository Structure

```plaintext
usma/
├── android/                   # Native Android configuration & Gradle build scripts
├── assets/                    # Static assets, fonts, and offline FAQ schemas
│   └── faq/
│       └── faq.json           # Offline-accessible FAQ database
├── lib/
│   ├── main.dart              # Application entry point & service initialization
│   ├── app.dart               # Root MaterialApp configuration & theme setup
│   ├── core/                  # Core abstractions and shared utilities
│   │   ├── network/           # Connectivity listeners & HTTP clients
│   │   ├── router/            # GoRouter navigation paths & guards
│   │   ├── theme/             # Color tokens, typography, and component themes
│   │   └── utils/             # Formatters, validators, and helper utilities
│   └── features/              # Feature-driven modular architecture
│       ├── applications/      # Scholarship application workflows
│       ├── auth/              # Authentication & session controllers
│       ├── chatbot/           # Interactive virtual assistant & FAQ engine
│       ├── dashboard/         # Single-view student dashboard
│       ├── disbursements/     # DBT tracking & transaction history
│       ├── documents/         # Secure document upload & vault
│       ├── eligibility/       # Rule-based eligibility assessment
│       ├── notifications/     # FCM push notifications & inbox
│       ├── profile/           # Student profile & academic background
│       └── settings/          # Language preferences & user settings
├── firestore.rules            # Firestore security rules
├── firestore.indexes.json      # Database compound indexes
├── firebase.json              # Firebase project configuration
└── pubspec.yaml               # Project dependencies and environment specs
```

---

## ⚙️ Installation & Setup

### 1. Prerequisites
- **Flutter SDK:** `>= 3.19.0` (Dart SDK `>= 3.3.0 < 4.0.0`)
- **Android SDK:** Compile SDK `36`, Minimum SDK `21`
- **Java Development Kit (JDK):** OpenJDK 17 or 21
- **Firebase CLI:** Installed and logged in (`npm install -g firebase-tools`)

### 2. Clone the Repository
```bash
git clone <YOUR_REPOSITORY_URL>
cd usma
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Firebase Configuration
1. Place your `google-services.json` inside `android/app/`.
2. Ensure Firebase services (Auth, Firestore, Storage, Cloud Messaging) are activated in your Firebase Console.
3. Deploy Firestore rules and indexes:
   ```bash
   firebase deploy --only firestore
   ```

### 5. Run the Application
```bash
# Debug run on connected Android device or emulator
flutter run
```

---

## 📱 APK Release & Testing

To generate an optimized release APK for testing and deployment:

```bash
flutter build apk --release
```
The compiled APK will be generated at:
```plaintext
build/app/outputs/flutter-apk/app-release.apk
```

*(Pre-built release package `usma-release.apk` is available in the root directory and attached to GitHub Releases for direct installation).*

---

## 🎯 SIH Compliance Verification

- [x] **Unified MoTA Scholarship View:** Consolidated visibility over pre-matric, post-matric, and higher education ST schemes.
- [x] **Transparent DBT Disbursement Tracking:** Step-wise audit trail from institutional sanctioning to bank transfer.
- [x] **Offline-First Resilience:** In-memory & local persistent storage via Hive for students with intermittent remote connectivity.
- [x] **Automated Eligibility Evaluation:** Interactive criteria verification reducing administrative overhead.
- [x] **Digital Document Repository:** Secure paperless credential submission with integrity checks.
- [x] **Multilingual & Conversational Support:** Integrated AI chatbot with offline FAQ fallbacks for intuitive user onboarding.

---

## 📄 License

This project is licensed under the **MIT License** - see the LICENSE file for details.  
Developed with ❤️ for the **Smart India Hackathon (SIH 2026)**.