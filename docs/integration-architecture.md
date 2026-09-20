# USMA Integration Architecture

**Unified Scholarship Mobile Application — Ministry of Tribal Affairs**
**Document type:** Technical Architecture Reference
**Status:** Prototype / Demonstration

---

> **IMPORTANT DISCLAIMER**
> This document describes a *proposed* integration architecture.
> The USMA application does **not** currently hold production credentials for,
> or live connections to, any of the government systems listed below
> (UIDAI, DigiLocker, UDISE+, APAAR, AISHE, NSP, PFMS, UGC, NTA,
> or State e-District portals).
> All provider implementations are **MOCK / DEMO** adapters that return
> deterministic simulated data. They are clearly labelled in source code.

---

## 1. Current Architecture (Demo Mode)

```
  Student Mobile App (Flutter)
          │
          ▼
  IntegrationOrchestrator          ← REAL domain logic
          │
          ├─── DigiLockerMockProvider      ← MOCK
          ├─── UDISEMockProvider           ← MOCK
          ├─── APAARMockProvider           ← MOCK
          ├─── AISHEMockProvider           ← MOCK
          ├─── NSPMockProvider             ← MOCK
          ├─── PFMSMockProvider            ← MOCK
          ├─── StateEDistrictMockProvider  ← MOCK
          ├─── UGCMockProvider             ← MOCK
          └─── NTAMockProvider             ← MOCK
          │
          ▼
  VerificationAuditLog (in-memory)
          │
          ▼
  OrchestrationResult
  (VERIFIED / MISMATCH / MANUAL_REVIEW / PENDING / SOURCE_UNAVAILABLE)
```

## 2. Future Production Architecture

```
  Student Mobile App (Flutter)
          │
          ▼
  USMA Backend (Cloud Run / GCP)   ← Government API calls NEVER from client
          │
          ▼
  Integration Gateway
          │
          ├─── DigiLocker Pull API (MeitY)       → OAuth 2.0
          ├─── UDISE+ REST API (MoE/NIEPA)       → API key per state NIC node
          ├─── APAAR / ABC API (MoE)             → OAuth 2.0 + APAAR token
          ├─── AISHE API (NIEPA)                 → API key from AISHE nodal officer
          ├─── NSP API (MoE/NIC)                 → NSP institution credentials
          ├─── PFMS DBT API (MoF)                → PFMS agency code + API key
          ├─── State e-District APIs             → Per-state NIC API key
          ├─── UGC Portal API                    → UGC credentials (pending)
          └─── NTA Result Verification API       → NTA credentials (pending)
          │
          ▼
  Unified Verification Result → Firestore (with strict security rules)
```

## 3. Proposed Data Flow

```
Student submits scholarship application
          │
          ▼
Orchestrator determines which providers are needed for this scheme
          │
          ▼
Parallel calls to relevant mock providers (with timeout + retry)
          │
          ├── All match  → status = VERIFIED
          ├── Any mismatch → status = MISMATCH → Manual Review queue
          └── Any timeout  → Retry (max 2×) → SOURCE_UNAVAILABLE → Manual Review queue
          │
          ▼
Audit entry written (field names only, no PII values)
          │
          ▼
OrchestrationResult returned to student + officer dashboard
```

## 4. Provider → Verification-Type Mapping

| Verification Type | Proposed Provider | Auth Required |
|---|---|---|
| Identity (eKYC / Aadhaar) | DigiLocker / UIDAI | OAuth 2.0 (MeitY) |
| Academic record (school) | UDISE+ | NIC API key |
| Academic ID | APAAR / ABC | OAuth 2.0 |
| College/University | AISHE | NIEPA API key |
| NET/JRF | UGC + NTA | Separate credentials |
| ST/Caste Certificate | State e-District | State NIC API key |
| Income Certificate | State e-District | State NIC API key |
| Domicile Certificate | State e-District | State NIC API key |
| Scholarship application | NSP | NSP institution login |
| DBT payment | PFMS | MoF agency code |

> These mappings are **proposed architecture**, not official API contracts.

## 5. Failure Handling

```
Provider call
    │
    ▼
Success? ──YES──► return IntegrationResponse(status: verified)
    │
    NO (timeout/error)
    │
    ▼
Retry (attempt 1) ──Success?──YES──► return response
    │
    NO
    ▼
Retry (attempt 2) ──Success?──YES──► return response
    │
    NO
    ▼
IntegrationResponse(status: sourceUnavailable, requiresManualReview: true)
    │
    ▼
Application NOT rejected. Routed to District Nodal Officer.
```

## 6. Mismatch Handling

```
Source A: name = "Rahul Kumar"
Source B: name = "Rahul K."
          │
          ▼
status = MISMATCH
requiresManualReview = true
applicationBlocked = false  ← ALWAYS false
          │
          ▼
Student sees: "Information mismatch detected"
Officer sees: mismatch in officer dashboard
          │
          ▼
Officer reviews → resolves → application proceeds
```

## 7. Privacy & Security Model

| Principle | Implementation |
|---|---|
| Minimum data | Audit log stores field **names** only, not field values |
| No Aadhaar in logs | `toMap()` never includes raw Aadhaar or bank account numbers |
| No sensitive debug prints | No `debugPrint` of PII anywhere in the integration layer |
| Role-based access | Firestore rules restrict student records to owner UID; officers get scoped read |
| Synthetic data only | All demo student data is synthetic — no real identifiers |
| Client isolation | Government API calls must be made from USMA backend, never from client |
| API timeout | Every provider exposes a `timeout` duration; orchestrator enforces it |
| Retry with back-off | 800 ms delay between retries; max 2 retries per provider |

## 8. Files Reference

| File | Status | Purpose |
|---|---|---|
| `lib/features/verification/domain/integration_provider.dart` | REAL | Abstract interface & models |
| `lib/features/verification/data/providers/mock_providers.dart` | MOCK | 9 demo provider implementations |
| `lib/features/verification/data/integration_orchestrator.dart` | REAL | Retry, routing, result assembly |
| `lib/features/verification/data/verification_audit_log.dart` | REAL | Immutable audit entries (no PII) |
| `lib/features/verification/data/verification_gateways.dart` | MOCK | Legacy gateway (pre-existing) |
| `lib/features/verification/data/unified_verification_orchestrator.dart` | MOCK | Legacy orchestrator (pre-existing) |
| `lib/features/verification/presentation/integration_status_screen.dart` | REAL UI | Shows per-system status |
| `test/integration_provider_test.dart` | TESTS | Full provider + orchestrator tests |

## 9. Activating Production Integrations

When MoTA or MeitY provisions production credentials:

1. Create a `LiveXxxProvider` implementing `IntegrationProvider`.
2. Make real HTTPS calls from the **USMA backend** (not the Flutter client).
3. Forward results to the Flutter client via a USMA REST/gRPC endpoint.
4. Replace the mock entry in `_mockProviderRegistry` with the live adapter.
5. Set `isSimulated = false` in the live provider.
6. Remove `AppConfig.isDemo` guard; the demo banner will disappear automatically.

**The `IntegrationProvider` interface and `IntegrationOrchestrator` require
zero modification when swapping from mock to live.**

---

*Document generated: September 2026*
*Ministry of Tribal Affairs — USMA Prototype*
*Source: Ministry of Tribal Affairs — https://tribal.nic.in/ScholarshiP.aspx*
