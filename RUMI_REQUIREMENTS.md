# Rumi: functional requirements compendium

## Table of Contents

**Review context**
- [Summary](#summary)
- [Scope, ownership and shared conventions](#scope-ownership-and-shared-conventions)

**Connected-care foundations**
- [Demonstration and regular use](#demonstration-and-regular-use)
- [Unified longitudinal patient record](#unified-longitudinal-patient-record)

**Attachment features: original grouping and order**
- [Welcome Router](#welcome-router)
- [Mobile SMS OTP Auth](#mobile-sms-otp-auth)
- [Apple Auth (SSO)](#apple-auth-sso)
- [Google Auth (SSO)](#google-auth-sso)
- [Terms & Privacy Consent](#terms--privacy-consent)
- [Analytics Consent](#analytics-consent)
- [Select Care Pathway](#select-care-pathway)
- [Records Connection](#records-connection)
- [Notification Consent](#notification-consent)
- [Interactive Elements (buttons, cards)](#interactive-elements-buttons-cards)
- [Crisis/Self-Harm Handoff](#crisisself-harm-handoff)
- [Visible Editable Memory](#visible-editable-memory)
- [Agentic Action Cards](#agentic-action-cards)
- [Sponsored Responses](#sponsored-responses)
- [Relevant Card Stack ("Thread")](#relevant-card-stack-thread)
- [Needs You' Clinical Alerts](#needs-you-clinical-alerts)
- [Tracking Entry Point](#tracking-entry-point)
- [Care Plan](#care-plan)
- [Discussion Guide](#discussion-guide)
- [Providers](#providers)
- [Appointments Mgmt](#appointments-mgmt)
- [Virtual Visits](#virtual-visits)
- [Messaging](#messaging)
- [Forms](#forms)
- [AI Companion Atomic Habits & Journeys](#ai-companion-atomic-habits--journeys)
- [Medications (w/ AI support)](#medications-w-ai-support)
- [Medications Sponsored Pages](#medications-sponsored-pages)
- [Immunizations (w/ AI support)](#immunizations-w-ai-support)
- [Documents (w/ AI support)](#documents-w-ai-support)
- [Notes (w/ AI support)](#notes-w-ai-support)
- [Vitals (w/ AI support)](#vitals-w-ai-support)
- [Labs (w/ AI support)](#labs-w-ai-support)
- [Conditions (w/ AI support)](#conditions-w-ai-support)
- [Allergies and other clinical information](#allergies-and-other-clinical-information)
- [Sponsored Programs](#sponsored-programs)
- [Symptom Tracking w/ AFB](#symptom-tracking-w-afb)

**Retained signature experiences and shared obligations**
- [Companion continuity and voice](#companion-continuity-and-voice)
- [Agent network and connected services](#agent-network-and-connected-services)
- [Visit preparation and recipient reports](#visit-preparation-and-recipient-reports)
- [Bills, wallet and savings](#bills-wallet-and-savings)
- [Life history and held memories](#life-history-and-held-memories)
- [Story, Insights, Currents and recap](#story-insights-currents-and-recap)
- [Account, preferences and data rights](#account-preferences-and-data-rights)
- [Platform consistency and release constraints](#platform-consistency-and-release-constraints)
- [Review questions and publication](#review-questions-and-publication)

## Summary

Rumi helps patients understand health information, record daily experiences and prepare for care. Patients can use its text/voice companion or open features directly. This draft defines behavior for the 36 retained feature areas, signature experiences and seven connected-care additions: a longitudinal record, reviewed EHR brief, provider messaging, connected results, scheduling, care-plan reminders and refill tracking. It separates approved product scope from unresolved specialist and service decisions. Rumi must remain empathetic and patient-controlled, with clear limits on clinical advice and accurate status for every action.

## Scope, ownership and shared conventions

**Status:** working functional requirements. The requester approved staged implementation of the connected-care plan, including all seven additions. That approval does not approve unresolved clinical, legal, privacy, security or numerical defaults, or authorize live release. The [as-built reference](RUMI_AS_BUILT.md) records current functionality and gaps. The [change specification](RUMI_RESCOPE.md) covers scope, design, draft UI copy, assets, engineering, backend work and migration. It also owns the [proposed navigation map](RUMI_RESCOPE.md#proposed-information-architecture).

The requester approved one evolving functional compendium rather than separate feature files. The latest request also adds a [visual feature and screen library](RUMI_SCREEN_LIBRARY.md); the [working specification](RUMI_RESCOPE.md) and [implementation audit](RUMI_AS_BUILT.md) retain separate ownership. This is an exception to the supplied guide's one-page-per-feature format. Each named section still owns its feature's rules. Shared rules appear once, with links from dependent features. Keep the attachment's feature names and order.

No Confluence access or current Figma reference was available. Reconcile existing feature and IA pages before publishing or splitting this file. Do not create competing requirements pages.

The attached product-requirements guide applies only to this file. It excludes visual specifications, literal in-app copy and prescribed architecture from functional requirements. The as-built reference and change specification include those details. This distinction preserves the technical and design information needed to change the existing app.

Under the guide, final visual specifications and UI copy belong in Figma. Engineering owns implementation decisions. Keeping them outside this file avoids stale, competing instructions as the design changes. Approved marketing, legal and compliance copy, including SMS and push text, may appear verbatim here. None was supplied, so those texts remain pending.

Jira stories link to the requirements page, not the reverse. This avoids stale links when Engineering splits a story. Greenlight Guru owns formal regulatory requirement IDs. Section links here are only navigation.

The language edit uses the supplied [Unslop](https://skillsllm.com/skill/unslop) and [ASD-STE100 writing reference](https://github.com/danyuchn/asd-ste100-skill). It preserves requirement strength, clinical uncertainty and exact feature names. It does not claim certified STE compliance.

### Actors and supported surfaces

- **Patient:** the user of the iOS app or web app. Requirements below apply to both unless a platform restriction is stated.
- **Care recipient/service:** an external provider, office, pharmacy or other authorized destination. Requirements distinguish patient actions from recipient-confirmed outcomes. They do not add a staff or clinician portal.
- **Clinical, privacy, commercial and operational reviewers:** approve rules, content and service coverage. Their work does not imply a new administration product.
- Caregivers, delegated users, minors and clinician-facing applications are unconfirmed scope. Do not infer patient authorization on someone else's behalf.

### Shared functional conventions

- A saved item survives closing and reopening within its stated account/storage scope. If saving fails, retain recoverable input and report the failure. Do not show success. [Account, preferences and data rights](#account-preferences-and-data-rights) defines storage scope and retention.
- Actions that send information, change care arrangements or incur costs use the lifecycle in [Agentic Action Cards](#agentic-action-cards). Draft, approval, submission, service acceptance and completion are distinct states.
- [Records Connection](#records-connection) owns clinical source, date, identity, conflict and missing-data rules. They apply to all clinical features.
- [Companion continuity and voice](#companion-continuity-and-voice) owns AI evidence, conversation context, limited fallback and voice behavior. Each feature identifies the context and actions it contributes.
- Clinical/crisis thresholds and overlapping-risk precedence are **not invented**. The owning clinical sections state blockers. Historical fixture thresholds are not automatically adopted.
- Unresolved specialist rules remain proposals until their owners approve them. Product-scope approval must not be interpreted as approval of OTP limits, medical thresholds, retention periods or response times.
- Use the device timezone for patient-entered events; when a visit or service uses a different timezone, make both times understandable. Preserve event time, receipt time and, for backdated input, entry time separately.
- Support the patient's chosen units and supported language across relevant features. Retain original units, source language and provenance; convert only with approved, unambiguous conversions.
- Patients can complete all in-scope essential workflows without chat. Consolidation must preserve discoverability, selected-item context, saved history and return to unfinished work.
- Information presented for a decision must be relevant to that decision. Supporting evidence remains accessible without repeated summaries; safety, uncertainty, cost, recipient and consent information cannot be omitted when consequential.

## Demonstration and regular use

**User Story:** As a patient or evaluator, I want to know whether I am using synthetic information or connected services, without a demonstration affecting real care.

### Acceptance Criteria

- Provide explicitly identified Demo journeys with coherent synthetic patient records, including multi-condition, treatment and procedure scenarios. Illustrative personas do not restrict supported real patient needs.
- Preserve linked changes across a demo journey: appointments, preparation, messages, results, follow-up tasks, reminders and refill estimates use the same scenario history.
- Support repeatable demonstration of partial imports, corrections, conflicting records, delayed replies, denied access, failed submissions, unavailable slots, unknown outcomes and recoverable offline drafts, as well as success.
- A simulated provider reply or receipt is identified as simulated. Demo never sends clinical messages, makes real bookings/payments or writes clinical records externally.
- Keep Demo, vendor testing and regular use separate in identity, records, drafts, approvals, pending work and saved history. Switching modes never promotes synthetic data or replays a demo approval into real use.
- Resetting a scenario affects only that scenario; returning to another mode restores its own permitted state.
- Regular use requires verified identity, authorized patient association and applicable consent for connected actions. An unavailable service must not fall back to sample records or simulated success; unaffected features remain usable.

| Situation | Required outcome |
|---|---|
| Demo action approved | Simulate only within the selected scenario, with a labeled outcome. |
| Regular use lacks verified access | Do not submit; explain the missing access and preserve permitted draft input. |
| Connected operation has an unknown outcome | Reconcile before retrying; never substitute a simulated receipt. |
| Account, patient or mode changes during work | Stop unauthorized new work; retain outcomes only in their originating scope. |
| Vendor test succeeds | Identify the test environment; do not present it as production verification. |

The mode boundary takes precedence over a task's local approval state. Clinical/Legal/Security approvals still gate applicable production use.

## Unified longitudinal patient record

**User Story:** As a patient, I want one coherent history across my conditions and sources so I do not need to reconcile different versions of my care myself.

### Acceptance Criteria

- Provide authorized longitudinal access to results, medications, conditions, allergies, immunizations, vitals, procedures, notes and documents, with category-specific behavior defined in the owning sections.
- Each fact retains patient association, origin, event date, available source status and original evidence. Distinguish imported clinical facts, patient reports and generated explanations.
- Preserve source corrections and conflicting statements for inspection. Uncertain matches do not silently merge patients or replace one source with another.
- Use consistent facts in care workflows, reports, alerts and permitted companion context. A pathway changes relevance, not identity or other conditions.
- Record refresh exposes progress, partial availability, failures and last successful receipt. Failure preserves permitted prior records with their actual age; it cannot establish current completeness.
- Connected results are available only where the authorized source supplies them; distinguish pending, final and corrected states when supported. Opening or acknowledging a result is not clinician review or clinical resolution.

**Dependencies and blockers:** [Records Connection](#records-connection) owns authorization and source reconciliation. Available data categories must be verified for each connection. The approved Fasten source relationship does not imply appointment, messaging or writeback capabilities.

## Welcome Router

**User Story:** As a patient, I want to start at the right step without repeating completed setup or seeing another person's information.

### Acceptance Criteria

**Behavior**
- On launch or a supported incoming destination, determine verified session status and required onboarding/consent completion before showing protected patient content.
- Preserve an intended destination through authentication/onboarding and resume it only if the authenticated patient can access it.
- Completed optional steps do not repeat on every launch; declined optional permissions do not prevent ordinary entry.
- Return to the last valid required step after an interrupted onboarding session without manufacturing completed verification.

| Condition | Required routing outcome |
|---|---|
| No verified session | Offer supported authentication; do not show protected prior-account content. |
| Valid session, required acceptance incomplete | Complete the required acceptance before protected use. |
| Valid session and acceptance, required patient context incomplete | Resume the missing required onboarding step. |
| Valid session and required setup complete | Open authorized intended destination, otherwise Today. |
| Expired/revoked session | Require re-verification; preserve only permitted recoverable state. |
| Intended object missing or unauthorized | Explain unavailability without exposing its data; offer a safe destination. |

**Constraints and blocking states**
- The rows for verified users are sequential prerequisites, not competing priorities: identity, required acceptance, required setup, destination authorization.
- Explicit Demo entry follows [Demonstration and regular use](#demonstration-and-regular-use); it is not verified patient authentication.
- Offline verification cannot be represented as newly successful authentication.

**Dependencies / open questions:** Authentication sections and [Terms & Privacy Consent](#terms--privacy-consent). Product/Security must approve offline-session policy, required onboarding fields. Demo entry is approved product scope.

## Mobile SMS OTP Auth

**User Story:** As a patient, I want to verify my phone number and recover from code-delivery problems without creating a duplicate account.

### Acceptance Criteria

**Behavior**
- Accept a phone number with country context; validate against supported numbering coverage before requesting a code.
- State whether a code request was accepted by the delivery service; distinguish that from proof the patient received it.
- Verify the submitted code before creating or renewing a session. Invalid, expired or previously consumed codes cannot authenticate.
- Let the patient correct the number, retry eligible delivery and cancel without marking authentication complete.
- Enforce approved expiry, attempts, resend limits and abuse restrictions; explain when another attempt becomes available without revealing internal defenses.

| State | Patient-visible outcome |
|---|---|
| Code requested | Identify the intended masked destination and the next verification step. |
| Wrong code | Keep the patient in verification with a permitted correction/retry path. |
| Expired code | Require an eligible replacement; never accept the expired code. |
| Delivery failure | Offer retry or another supported sign-in method; no completed session. |
| Resend/attempt restricted | Explain the restriction and supported recovery route. |
| Number changed | Rebind verification to the new number; old verification cannot verify it. |

**Constraints and blocking states**
- Successful phone verification follows the shared account-linking policy; it must not silently overwrite an existing account's records.
- Codes must not appear in analytics, conversation context or patient-visible diagnostic details.
- Loss of access to the old phone uses an approved recovery process, not an unverifiable bypass.

**Dependencies / open questions:** [Account rights](#account-preferences-and-data-rights). Security/Product must approve supported countries, delivery coverage, limits, recovery and recycled-number handling. Approved SMS text is still needed. An invalid or expired code can coincide with attempt or resend restrictions. Which outcome and recovery options take precedence? Security/Product must resolve this overlap. Existing restrictions remain in force while it is undecided.

## Apple Auth (SSO)

**User Story:** As a patient, I want Apple sign-in to open my existing account even when Apple shares limited profile information.

### Acceptance Criteria

- Offer Apple authentication only where the chosen platform flow is supported; authenticate from a verified provider result, not a button tap.
- Provider cancellation returns safely without a session or changed account data. Provider failure allows retry or another supported method.
- Treat a provider name/email as optional; missing or relay information must not be replaced with clinical persona identity.
- Retain permitted first-authorization profile information and allow patient correction of editable profile fields.
- Existing provider identity resolves to its authorized account; potential duplicate accounts require the approved linking process and verification of both identities.
- Revocation, expired proof and account sign-out follow [account/session boundaries](#account-preferences-and-data-rights).

**Blocking states / open questions:** Apple entitlement/configuration and web/native coverage must be established; linking, recovery and missing-profile requirements need Security/Product approval. Sign-in itself grants no medical-record, analytics or external-channel consent; those are owned separately.

## Google Auth (SSO)

**User Story:** As a patient, I want Google sign-in to open my Rumi account without granting access to my email or calendar.

### Acceptance Criteria

- Complete authentication only after verifying the supported Google provider result; errors/cancellation leave the patient unauthenticated.
- Identify the selected account and allow correction through the provider flow when multiple accounts are available.
- Apply the same duplicate-account/linking rules as other sign-in methods; an email string match alone does not merge patient records.
- Missing profile fields can be completed without populating fixture identity or conditions.
- Google sign-in does **not** imply Gmail/Calendar connection. Optional channel scopes are separately reviewed under [Agent network and connected services](#agent-network-and-connected-services).
- Revocation/expiry requires appropriate re-verification and does not display another cached account's data.

**Blocking states / open questions:** Product/Security must approve provider/platform coverage, linking/recovery rules and consent wording. Unsupported browser/device combinations offer an honest alternative rather than a simulated success.

## Terms & Privacy Consent

**User Story:** As a patient, I want to understand the terms and optional data uses before agreeing. I also want to know what withdrawal changes.

### Acceptance Criteria

**Display and decision**
- Provide the applicable approved terms/privacy content and version before acceptance is requested; make the current version accessible afterwards.
- Distinguish required legal acceptance from optional analytics, notifications, personalization and external data-sharing permissions.
- Explain AI/audio processing destinations and purposes accurately; do not claim processing stays on the device if it does not.
- Record the patient's decision, applicable version, purpose and time; changing optional choices must have an observable effect on future covered processing.
- Required nonacceptance prevents only use that requires that acceptance, while explaining available next steps and access to permitted rights/support.

| Decision/context | Required result |
|---|---|
| Required terms accepted | Continue when other prerequisites are met. |
| Required terms not accepted | Do not enter uses requiring acceptance; preserve a safe exit and appropriate rights information. |
| Optional use declined | Keep unrelated care features available; do not execute the declined optional purpose. |
| Applicable terms change | Follow the approved reacceptance policy; retain the prior decision record. |
| Consent withdrawn | Stop future covered uses and explain effects on existing work and retained/shared data. |

**Constraints and blockers**
- No optional choice is inferred from selecting a care pathway or authenticating.
- Legal approval is needed for jurisdictions, age/capacity, required versus optional purposes, reacceptance and retention exceptions. This draft supplies no legal copy.
- Analytics and notification mechanics belong to their own sections. General data export/deletion is owned by [Account rights](#account-preferences-and-data-rights); do not equate memory deletion with withdrawal from all external processors.

## Analytics Consent

**User Story:** As a patient, I want to decide about optional analytics without losing ordinary access to care features.

### Acceptance Criteria

- Present optional analytics as a separate purpose from care delivery and required service/security operation.
- Explain the approved categories of analytics data and purposes; the choice is revisitable in preferences.
- Until the applicable optional permission is granted, covered analytics collection/transmission must not occur; withdrawal stops future covered activity.
- Changing the choice does not change access to non-analytics-dependent care functions.
- Conversation text, audio, clinical values, authentication codes and identifiers are not included in optional analytics unless specifically approved and disclosed for a defined purpose; generic consent is not blanket authorization.
- Retain the consent decision under [Terms & Privacy Consent](#terms--privacy-consent), and distinguish any legally justified operational/security telemetry from optional analytics.

**Edge/blocking states:** Handle unavailable consent storage without silently treating it as granted. Privacy/Product must approve event inventory, sensitive-data exclusions, lawful basis, retention and whether already collected data is affected by withdrawal. No analytics provider or event schema is mandated here.

## Select Care Pathway

**User Story:** As a patient, I want to choose relevant care pathways without changing my medical record or erasing my history.

### Acceptance Criteria

- Describe available supported pathway choices and their purpose before selection.
- Identify whether context was self-reported, drawn from verified records or assigned by a care team, following [record provenance](#records-connection).
- Apply an approved selection to relevant tracking options, education and conversational context; existing personal entries and records remain intact.
- Permit review/correction according to the approved authority model; when a pathway changes, explain which experiences change and retain unrelated data.
- Missing/unsupported/uncertain pathway has an approved general-support or assistance route; never auto-diagnose to fill it.
- Keep demonstration personas separate from patient choices and clearly identified.

**Blocking questions:** Are pathways single-choice or concurrent; which are available at launch; can patients self-select oncology/procedure context; how are conflicting care-team and patient choices reconciled? Product/Clinical must determine these rules. Existing Marcus/Elena/Sam/Rosa fixtures are references, not verified users or an approved clinical classification system.

## Records Connection

**User Story:** As a patient, I want to connect my own records and understand missing, old or conflicting information from different sources.

### Acceptance Criteria

**Onboarding and profile confirmation**
- Offer record connection during first use, including a clearly identified demonstration path. Patients can skip connection and finish unrelated setup; returning later preserves permitted work.
- Prefill only information actually provided by the chosen identity provider, preserving field provenance. First name, last name, date of birth and other source-required matching fields can be confirmed or corrected before use. Missing date of birth, legal name, address or other attributes must not be invented or inferred from social data.
- Social sign-in authenticates an application account, not ownership of a medical record. Demographic confirmation alone never grants record access. Patient association requires the connected source's authorized portal or approved identity-proofing and consent process.
- Collect only attributes required by the chosen access path. Additional address or identity verification is requested when the service requires it, not through an unnecessary general onboarding questionnaire. Provider credentials and identity documents use the approved authorization surface, not simulated credential fields.
- Demo prefills, authorization, matching and imported records remain explicitly synthetic. No personal demographics are sent externally from Demo; vendor sandbox testing is separately identified. A demo match cannot be reused in regular mode.
- Cancelling or previewing setup does not connect sources, grant consent, switch the active patient or replace saved records. Edited identifying information invalidates any previous association/consent decision affected by that change.

**Vendor-test setup boundary**
- Keep developer configuration checks separate from synthetic Demo imports and regular patient authorization. Checking setup sends no patient demographics, notes or record data and changes no active patient or saved work.
- Keep private credentials and webhook signing secrets server-only. Test operations must reject live-mode credentials even when entered under test variable names.
- Distinguish credential presence, format validation, public organization recognition, private-key authorization, registered return URL, verified signed delivery, authorized patient connection and completed import. None implies the next.
- Verify webhook authenticity and freshness before using payload fields. Do not acknowledge clinical processing or follow download links until ownership, durable deduplication and ingestion are available. Browser return parameters do not establish ownership.
- Register the return URL and webhook in the vendor's authorized developer account; obtain the endpoint-specific signing secret after registration. Do not invent a signing secret or silently replace configured credentials.

**Connection and permission**
- Identify supported sources and the information/use permissions sought before connection.
- Verify authorization and patient matching before attaching external records. Ambiguous or mismatched identity cannot be silently accepted.
- Support cancel, denied permission, expired/revoked access, reconnect and disconnect without discarding unrelated user-entered information.
- Display connection state separately from data freshness and import success; a signed-in source can still have no available records.
- For Fasten-supported sources, authorization, record collection and ingestion are separate observable steps. Show category-level availability, partial results and missing/pending categories without claiming a complete history. A browser return or authorization success is not proof of completed ingestion.
- Only authenticated, source-confirmed results may advance a connected import. Duplicate/out-of-order notifications do not duplicate clinical items or attach them to another patient. Interrupted/expired collection has a recoverable state; never synthesize a successful receipt or record.
- Each successful import can be inspected by source, scope, receipt time and original event dates; removal/disconnection explains its effect on retained history and does not delete unrelated manual work.
- Platform-specific health permissions reflect actual granted categories; a local toggle cannot stand in for authorization.

**Clinical information quality — shared owner**
- Each clinical item exposes patient association, source, relevant event/result time, units where applicable, and provenance category: source record, patient report, or AI-derived interpretation.
- Imported originals are distinguishable from summaries/corrections. Patient annotation cannot silently rewrite a clinician-authored source.
- Missing information is labeled unknown/not available, not replaced with fixtures or assumed normality.
- Duplicate/conflicting information remains inspectable until resolved by the approved reconciliation process; retain attribution and do not silently pick an arbitrary clinical truth.
- Distinguish the item's event time from the time it was received/synced; display unavailable freshness honestly.

| Source/data condition | Required behavior |
|---|---|
| Authorized, matched and current | Make permitted data available with provenance. |
| Authorized, no records | Explain that no records were returned; offer other supported input/connection options. |
| Ambiguous patient match | Block association and offer an approved resolution route. |
| Disconnected or revoked | Stop new access; apply disclosed policy to already retained data. |
| Stale data | Keep permitted prior data identifiable as stale; do not claim a fresh reading. |
| Conflicting sources | Expose the conflict and approved reconciliation path; AI cannot quietly resolve it. |
| Partial import/failure | Identify incomplete categories and retry/recovery scope; do not claim all records connected. |

**Blocking questions:** Supported sources/countries, matching authority, source priority, freshness thresholds, conflict reviewer, correction rights and retained-data policy need Clinical/Privacy/Integration approval. When stale and conflicting simultaneously, both qualifications remain visible; the medical precedence decision is not assumed.

## Notification Consent

**User Story:** As a patient, I want useful reminders and care updates under my control, without sensitive information appearing unexpectedly outside the app.

### Acceptance Criteria

- Explain the intended notification purposes before requesting platform permission; distinguish OS permission from category preferences.
- Support grant, deny, later enable/disable and platform-level revocation. Denial does not block viewing the same permitted information inside the app.
- Apply selected categories and approved quiet-hour/timezone rules to future delivery, not only to preference display.
- Notification previews use the approved privacy level; sensitive detail is protected until authorized access.
- Opening a notification routes to the exact authorized item through [Welcome Router](#welcome-router); a deleted/unavailable item has a safe fallback.
- State of reminders, clinical alerts and communication receipts must remain truthful even if notification delivery fails.

| Condition | Delivery behavior |
|---|---|
| App category enabled and platform permission granted | Eligible notifications may be delivered under approved scheduling/privacy rules. |
| Platform permission denied/revoked | Do not pretend a notification is scheduled for delivery; retain in-app access. |
| App category disabled | Suppress that category under the approved policy. |
| Quiet hours active | Apply the approved quiet-hour rules. |
| Urgent event during quiet hours or a disabled category | **Blocked policy decision:** Clinical/Privacy must define allowed exceptions and informed user controls. |

**Blocking questions:** Launch categories, exact quiet-hour behavior/timezone changes, urgent exceptions, content and consent text, expiry and delivery expectations. No rule here assumes emergency access overrides permission. An exception cannot be guessed when multiple conditions apply.

## Interactive Elements (buttons, cards)

**User Story:** As a patient using touch, keyboard or assistive technology, I want predictable actions and a way back after cancellation or failure.

### Acceptance Criteria

- Each actionable element exposes its purpose and state to the platform's supported assistive interaction; noninteractive content is not presented as an executable action.
- Activating an element targets the exact displayed entity/context. Repeated or overlapping activation cannot silently create duplicate consequential operations.
- Distinguish available, unavailable, in-progress, completed, declined/cancelled and unsuccessful outcomes by meaning, not color or animation alone.
- Every destination/presentation has an operable return or dismissal route. A missing entity shows an unavailable state with an exit, not a blank surface.
- Preserve entered data through recoverable failures; warn before discarding unsaved work when applicable.
- Switching tab, opening chat or following a notification preserves intended context without relying on whether a destination is already mounted.
- Provide non-gesture alternatives for essential swipe/drag actions; respect reduced-motion and audio choices without losing information or control.
- Modal and browser navigation support appropriate focus, dismissal and return behavior under [Platform consistency](#platform-consistency-and-release-constraints).

**Constraints:** This section defines behavior, not component dimensions, visuals or copy. Consequential operation details are owned by [Agentic Action Cards](#agentic-action-cards). No visible enabled action may terminate at a decorative success flag unless explicitly identified as a simulation.

## Crisis/Self-Harm Handoff

**User Story:** As a patient with an immediate safety concern, I want help options even when Rumi cannot reply or connect a service.

### Acceptance Criteria

**Patient experience**
- Apply clinically approved recognition and response rules to the supported text/symptom contexts; identify uncertainty according to those rules rather than improvising a diagnosis.
- Present approved, location-appropriate immediate help and contact alternatives; ask for needed location context only as permitted by the approved process.
- Keep core safety resources available when AI generation fails, times out or is unavailable. Do not require completing a routine task, sponsored flow or optional consent first.
- A patient-initiated call/link/share reports only the action actually taken; opening a dialer is not a connected call, and sending a message is not evidence someone is responding.
- Allow return/retry/alternative contact without losing the safety guidance. Do not suggest the system is continuously monitoring or dispatching help unless that supported service exists.

**Recipient/service boundary**
- Disclosing information or initiating a managed handoff follows the approved legal/clinical authorization policy; the system identifies the actual destination and sharing scope.
- Unavailable/closed/unsupported resources provide approved alternatives rather than a fabricated handoff confirmation.

| Overlapping or uncertain condition | Required treatment pending policy |
|---|---|
| Clear trigger under an approved rule | Execute that rule's approved guidance/handoff flow. |
| Ambiguous or incomplete information | Use the approved clarification/safety fallback; no invented risk score. |
| Crisis and acute medical alert both apply | **Open precedence question:** Clinical must define ordering and combined guidance. |
| AI disagrees with the approved safety rule | The AI does not suppress or weaken the approved rule's required action; record the conflict for review. |
| Location/country unsupported | Present the approved fallback for unknown coverage, not an assumed country's emergency number. |

**Release blockers:** Launch population/region, rule owner, thresholds/trigger definitions, crisis versus medical precedence, resource validity, age/capacity, privacy exceptions and operational response obligations must be approved. No actual clinical threshold or emergency number is derived from the prototype.

## Visible Editable Memory

**User Story:** As a patient, I want to see and correct what Rumi remembers so future support reflects me rather than a mistaken assumption.

### Acceptance Criteria

- Show remembered items with their content and source/context; distinguish preferences/inferences from clinical records, private notes and message history.
- Allow adding, editing and forgetting an eligible memory item; confirm the resulting saved state and retain recoverable edits if save fails.
- A corrected item replaces the superseded item for future memory-based personalization. Forgetting removes it from future memory retrieval in the declared scope, including after reopening.
- Deleting the final item leaves an empty memory state; fixture memories must not reappear as patient memories.
- Explain limits where content also exists in clinical records, previously sent messages or external processor retention; do not claim forgetting deletes those independent copies.
- The patient can understand why a remembered item affected a suggestion, using the applicable context/provenance information.
- Both platforms provide these controls and consistent outcomes, not merely the native memory visualization.

**Edge/blocking states:** Use [Account rights](#account-preferences-and-data-rights) for concurrent edits, account changes and interrupted deletion. Privacy/Product must approve eligible memories, confirmation of inferred memories, retention and treatment of earlier generated content. Editing memory must not silently amend clinical source records.

## Agentic Action Cards

**User Story:** As a patient, I want to understand and authorize exactly what Rumi will do, then see whether it really happened.

### Acceptance Criteria

**Review and authorization**
- Before approval, show the action, patient, exact recipient and affected item. Include the data to be shared or changed, any cost or commitment, and required permissions.
- Offer approval, decline and correction where applicable. Decline/cancel is a distinct result, never a success label.
- Require a new review if the recipient, material data, cost or action scope changes after approval. Do not execute the changed proposal first.
- Verify that the task is supported and permissions/source/account state remain valid when it executes. Paused/revoked agents cannot start new unauthorized work.
- A chat-generated proposal has no authority to bypass these checks; malformed/unknown/unsupported proposals cannot cause hidden side effects.

**Execution and outcome — shared owner**
- Show the same action and status in conversation, its source feature and network history. Retrying or approving again must not duplicate the external action.
- Distinguish approval from actual submission, acceptance, delivery and completion. Only supported external evidence permits corresponding success claims.
- When the outcome is unknown, reconcile before retrying an operation that may already have succeeded.
- Keep the action's approved scope, outcome and available receipt in history. Dismissing a card does not erase an operation already in progress.
- Background failure or missing patient input creates an attributable attention item and an eligible notification. Completion remains inspectable in the originating feature/history; duplicate surfaces must not create duplicate tasks.

| Action state | Available meaning and behavior |
|---|---|
| Proposed | Awaiting patient decision; no external execution. |
| Blocked | Identify missing capability/permission/input and a recovery or safe decline route. |
| Expired | An unanswered or expired proposal does not execute; preserve reason and history and require renewed review where eligible. |
| Approved, not submitted | Authorization exists; no claim that the recipient received it. Cancellation follows approved service constraints. |
| Submitted/accepted | Receiving service confirms the applicable state; show pending completion when necessary. |
| Completed | Verified outcome and relevant receipt/details are available. |
| Unsuccessful | Explain recoverable next step; preserve original proposal/history and avoid duplicate retry. |
| Unknown outcome | Reconcile or route to support; do not label complete or blindly resend. |
| Declined/cancelled | Do not execute outside any already irrevocable commitment; show the actual cancellation result. |

**Blocking questions:** Product, Legal and integration owners must decide which tasks can run automatically and which need approval. Define authorization expiry, cancellation or reversal limits, receipt types and the owner of unresolved outcomes. Approve these rules for each task. Demonstrations must disclose simulated execution.

## Sponsored Responses

**User Story:** As a patient, I want to know when a conversational recommendation is sponsored and retain access to neutral information and ordinary care.

### Acceptance Criteria

- Identify sponsored content, sponsor and funded purpose before the patient acts on it; disclose material conditions relevant to participation or data use.
- Keep source-based clinical explanation distinct from sponsored material; sponsorship does not establish medical eligibility, safety or personalized benefit.
- Provide access to applicable neutral alternatives and do not make care navigation or ordinary answers conditional on selecting a sponsor.
- Apply the same approved eligibility, placement, frequency, decline and consent rules in chat, medication pages and programs.
- Suppress sponsored recommendations within active safety/crisis handling under [Crisis/Self-Harm Handoff](#crisisself-harm-handoff); do not delay necessary care guidance for a commercial offer.
- Do not transmit information to a sponsor merely because a response is displayed; sharing/enrollment is separately reviewed and authorized.

| Content situation | Required distinction |
|---|---|
| Neutral sourced explanation | Clinical/source provenance, no implied sponsorship. |
| Sponsored educational/support content | Sponsor and purpose disclosed, with approved claims only. |
| Eligibility uncertain | No claim of eligibility or guaranteed financial/clinical benefit. |
| Patient declined within approved exclusion policy | Do not re-offer through another surface to bypass the decision. |
| Crisis/urgent guidance active | Safety handling proceeds without a sponsored recommendation. |

**Blocking questions:** Clinical/Legal/Commercial must approve sponsor inventory, content, eligibility, ranking independence, user targeting/data use and decline interval. Existing fixture offers and the historical 90-day wording are not a validated policy. This section owns shared sponsorship rules; feature-specific pages link here instead of repeating them.

## Relevant Card Stack ("Thread")

**User Story:** As a patient, I want a small set of relevant next steps that relate to my actual care and remain under my control.

### Acceptance Criteria

- Present a bounded set of current eligible moments rather than an endless feed; retain the existing maximum of three simultaneous Today moments as the proposed review default.
- Each moment identifies its purpose, related item, relevant time and next step. If personal data influenced selection, let the patient inspect the reason.
- The action opens or changes the displayed subject, not the first unrelated habit, generic refill or default Story segment.
- Dismissal/deferral is saved under an approved resurfacing policy; it cannot be mistaken for completing a clinical/financial task.
- Completed/expired/superseded moments are removed or updated consistently with their source event; an empty set has a clear resolved/no-current-items meaning.
- Agent approvals and clinical alerts use their owning rules, even when surfaced through Thread.

**Edge/blocking states:** Missing or stale sources, pathway changes, repeated events and offline use must not produce invented relevance. Product/Clinical must approve ranking above the cap, resurfacing and deferral intervals, and priority relative to [Needs You](#needs-you-clinical-alerts). The cap is a retained product choice. It does not establish clinical priority.

## Needs You' Clinical Alerts

**User Story:** As a patient, I want to open the exact update that needs attention and distinguish acknowledgment from completed clinical follow-up.

### Acceptance Criteria

- Identify alert source, event time, meaning and required patient action using approved clinical rules; distinguish clinical alerts from routine messages/bills/tasks.
- Open the exact related result/message/medication/appointment; when that item is unavailable, explain and provide an alternative action.
- Persist acknowledgment where supported and prevent duplicate attention for the same acknowledged event under the approved policy.
- Acknowledgment does not imply the condition is treated, an office has responded or a task is completed. Those statuses retain their own evidence.
- Unread message counts, outstanding action counts and clinically urgent status remain distinguishable and consistent across Today, Care and notification entry points.
- AI may explain the evidence under [Companion continuity](#companion-continuity-and-voice) but may not invent severity or override the approved alert rule.

| Event change | Required behavior |
|---|---|
| New eligible event | Offer attention and a relevant action under the approved priority policy. |
| Patient acknowledges | Save acknowledgment; preserve any unresolved care/task state. |
| Source corrects/retracts event | Reflect correction with provenance; do not retain an unqualified obsolete alert. |
| Repeated source event | Do not multiply identical patient actions. |
| Conflicting or stale clinical evidence | Show uncertainty and route using the approved clinical policy. |
| Multiple urgent events / crisis overlap | Clinical priority is a release-blocking decision; do not infer ordering from the old UI array. |

**Dependencies / blockers:** [Records Connection](#records-connection), [Notification Consent](#notification-consent), [Crisis handoff](#crisisself-harm-handoff). Clinical owners must approve event criteria, severity, acknowledgment policy, recurrence and overlap precedence; current fixture low-supply counts are not universal clinical rules.

## Tracking Entry Point

**User Story:** As a patient, I want to record something from where I already am and return with the correct context preserved.

### Acceptance Criteria

- Provide a discoverable route to each supported tracking type: symptoms, medication taken, meals, activity and proposed vitals where in launch scope.
- Contextual entry from a medication/condition preserves that entity but allows correction before saving.
- Patients can review/correct entry type and relevant date/time before submission; a note or value cannot silently attach to a different patient/entity.
- After saving, identify the saved entry and offer applicable follow-up/history access; save failure preserves recoverable input.
- Cancelling returns to the originating context without creating an entry. Switching tracking type must not inadvertently retain incompatible fields.
- Search/browse uses the relevant supported library; no match permits an explicitly supported manual entry or states its limitation rather than assigning an unrelated default.

**Dependencies / open questions:** Symptom behavior is owned by [Symptom Tracking w/ AFB](#symptom-tracking-w-afb); vital validation by [Vitals](#vitals-w-ai-support); everyday entry history by [Life history](#life-history-and-held-memories). Product must approve launch tracking types, supported manual fields, backdating and correction policies.

## Care Plan

**User Story:** As a patient, I want to understand my team's plan and translate suitable parts into manageable habits without Rumi inventing medical instructions.

### Acceptance Criteria

- Show the current plan with author/source, relevant date and status, following [record quality](#records-connection); previous/superseded plans remain distinguishable under the retention policy.
- Separate clinician instructions from patient goals and AI explanations. Asking about a plan carries the selected plan/goal and evidence into conversation.
- When a goal can support a behavioral habit, let the patient review/edit/accept the proposed habit before creating it under [Journeys](#ai-companion-atomic-habits--journeys).
- Do not automatically convert medication/procedure instructions into modified clinical advice.
- Linked habits retain their source goal; changing/withdrawing a plan identifies affected links for patient review rather than silently discarding progress or rewriting treatment.
- Creating/removing a habit link and the corresponding journey cannot diverge after reopening; do not retain a marker for a missing journey.

**Care-plan reminders**
- Let patients set, edit, snooze, pause and remove in-app reminders linked to individual care-plan tasks, including choosing no reminder.
- Retain the task, chosen timing, timezone and reminder state after reopening. In-app access remains available without push permission.
- Acknowledging a reminder does not complete the task; completing a task is separately attributable to the patient or source.
- When a task changes, is withdrawn or ends, identify affected reminders for review and stop obsolete reminders rather than silently retaining old instructions.
- These reminders do not authorize automatic SMS outreach or duplicate provider-owned appointment confirmation/reminder communications.

**Blocking states:** Missing plan, conflicting versions or unclear instruction requires source clarification/Guide assistance. Clinical/Product must define plan update authority, eligibility for habit derivation and behavior when a plan is withdrawn. No plan-authoring portal is included here.

## Discussion Guide

**User Story:** As a patient, I want one editable guide for my questions and observations, with control over what I bring to each visit.

### Acceptance Criteria

- Capture patient questions/observations and AI-drafted suggestions with origin/source and draft status; make AI-generated additions identifiable and editable/removable.
- Add, edit, mark discussed/unresolved and delete items, including the final item, with durable outcomes.
- Associate chosen items with the selected visit/provider without replacing the patient's broader Guide or duplicating conflicting copies.
- Avoid duplicate suggestions for the same context when the patient has already retained or dismissed them under the approved policy.
- Review recipient and selected content before sharing. Use [Messaging](#messaging) or [recipient reports](#visit-preparation-and-recipient-reports), not an independent send-success flag.
- Sending a Guide does not mark every question discussed or answered. Preserve actual conversation/visit status separately.

**Edge/open questions:** If an appointment changes or is cancelled, retain its questions and allow reassignment. Product must decide whether AI can save a labeled draft automatically or needs approval before adding it. AI may never silently send it. Guide actions remain usable when AI is unavailable.

## Providers

**User Story:** As a patient, I want to know the person or practice I am contacting and which services they support.

### Acceptance Criteria

- Display verified provider/practice identity, role, contact information and supported communication/visit capabilities with source/freshness where relevant.
- Calling, messaging, scheduling and preparing a report each target the selected provider/practice; do not substitute one global office contact.
- Explain unsupported capabilities and provide an approved alternative; absence of an in-app message channel cannot be labeled secure in-app delivery.
- A provider selected from a record/result/appointment maintains that context in the destination.
- Changes to the care team do not silently redirect an approved message or report to a new recipient; changed sharing scope requires review under [Action Cards](#agentic-action-cards).

**External recipient boundary:** This feature does not add a clinician or staff interface. The patient app needs an accurate provider directory and service capabilities. Product, Clinical and Operations must define the source, verification of patient-added providers, after-hours coverage and treatment of inactive providers. Never replace missing or invalid contacts with fixture destinations.

## Appointments Mgmt

**User Story:** As a patient, I want to manage a specific visit with the right provider and know whether a change is requested or actually confirmed.

### Acceptance Criteria

**Patient actions**
- List supported upcoming/past/cancelled visits with provider, date/time/timezone, location/channel and source status; identify pending requests separately from confirmed visits.
- Support booking and rescheduling within authorized Privia practices, and confirmation/cancellation where supported. Available visit types, providers, locations and times follow the connected practice's actual capabilities; explain unavailable operations rather than simulating them in regular use.
- Review the selected visit/time/provider and relevant conditions before requesting a consequential change through [Action Cards](#agentic-action-cards).
- Preparation, Guide, reports, virtual joining and logistics retain the selected appointment rather than defaulting to the first appointment.
- After a confirmed change, update related preparation/join/reminder/logistics context and preserve the prior outcome in history as applicable.

**Provider/service outcomes**
- Available times and confirmed status come from the supported authoritative source, not fixture slots or a local mutation.
- Concurrent slot loss, provider rejection, delayed confirmation or unknown result is surfaced with a safe next step; avoid double booking on retry.

| Situation | Required result |
|---|---|
| Slot/service accepts request but not final booking | Show request pending, not booked. |
| Booking/change confirmed | Reflect the verified new appointment and dependent context. |
| Slot no longer available | Preserve preferences and permit another choice. |
| Cancellation not supported or too late | Explain the approved alternative and actual appointment state. |
| Calendar conflict detected from authorized data | Identify the conflict; patient chooses under approved scheduling rules. |
| Timezone or daylight-saving ambiguity | Clarify the actual visit time before confirmation. |

**Blocking questions:** Supported providers/operations, cancellation rules, timezone presentation, reminder timing and calendar permissions. No office response SLA or automatic calendar write is assumed. [Virtual Visits](#virtual-visits) owns join rules.

## Virtual Visits

**User Story:** As a patient, I want to join the correct virtual visit and get help if my device or provider link is not ready.

### Acceptance Criteria

- Associate virtual-visit access with the selected appointment and patient; distinguish in-person visits, cancelled visits and virtual visits without a valid join destination.
- Apply the provider-approved join window and readiness conditions consistently on iOS/web; unavailable joining cannot remain an active link disguised as disabled.
- Identify whether the user is opening an external provider service or an explicitly supported in-app visit, and request device permissions only as needed for that selected service.
- Offer approved readiness/help steps and alternatives when permissions, connectivity, device capability or the provider destination fail.
- Opening a visit destination does not by itself prove attendance, connection to a clinician or completion of care.
- Returning from an external visit preserves the appointment context and does not mark it completed without authoritative evidence or clearly labeled patient report.

**Blocking questions:** Product/Operations must choose external handoff versus in-app visit coverage, provider join windows, readiness requirements, accessibility support and late/cancelled behavior. No video platform or clinical attendance policy is mandated. [Crisis handoff](#crisisself-harm-handoff) remains separate from a scheduled video visit.

## Messaging

**User Story:** As a patient, I want to review who receives my message and understand whether it is a private draft, submitted communication or a confirmed reply.

### Acceptance Criteria

**Patient composition and history**
- Choose/confirm an authorized provider/practice, supported category and channel before sending. Show the channel's capabilities and approved response expectations.
- Provider messaging is a primary product capability. This priority does not establish emergency monitoring, clinical triage priority or a faster response promise.
- Preserve drafts with their patient/recipient/context; allow editing/discarding without sending. Changes of recipient require re-review of included context.
- Carry source context from symptom/result/Guide/report/form actions as reviewable content; an attachment claim must correspond to an actual included artifact or explicit text excerpt.
- Before submission, let the patient inspect, include or remove attachments and edit generated wording. An AI draft does not establish patient approval.
- Show chronological conversation with authorship, sent/received time and supported delivery states. Read acknowledgment is distinct from reply or clinical resolution.

**Requests**
- Retain refill, appointment, records and form requests. Let patients compose, review and inspect each request on both supported platforms.
- Show the selected recipient, request kind, submitted content and actual status. A form request is not a completed form response.
- Use the shared action lifecycle for submission, supported cancellation and recovery. Preserve legacy local/demo requests without claiming verified delivery or submitting them automatically.

**Recipient/service outcomes**
- Follow the shared [action lifecycle](#agentic-action-cards), including failure/unknown/duplicate-retry handling.
- When only a portal handoff is supported, provide the usable draft/handoff and label it as not yet sent unless actual delivery evidence is available.
- Incoming messages and changed statuses are associated with the correct thread and patient; new unread state links through [Needs You](#needs-you-clinical-alerts).

| Channel/outcome | Required distinction |
|---|---|
| Local draft | Not sent; editable and recoverable. |
| Portal handoff prepared | Ready for the patient to use externally; no delivery claim. |
| Service accepts submission | Submitted/sent according to actual service semantics, with later delivery separate if supported. |
| Delivery confirmed | Show only the level of confirmation the service supplies. |
| Team reply received | Attribute actual sender/content/time; not an AI-fabricated care-team response. |
| Submission failed/unknown | Preserve content and provide safe recovery under the action lifecycle. |

**Blockers:** Practices/channels, clinical response expectations, attachment types/size constraints, retention, emergency-use warnings and portal integration coverage need approval. This does not create an HCP inbox product. Urgent/crisis flows follow their owning rules rather than treating asynchronous messaging as guaranteed immediate care.

## Forms

**User Story:** As a patient, I want to complete the right provider form, save my work and know when it was actually received.

### Acceptance Criteria

- Identify form owner, purpose, applicable patient/visit, version, due date where provided and submission destination.
- Distinguish required/optional fields using the authoritative form definition; conditional questions follow approved form logic rather than guessed medical answers.
- Permit a recoverable draft, review/correction and cancellation; do not mark a partially completed form submitted.
- Any proposed prefill identifies its source and remains reviewable. AI must not invent missing answers, signatures or consent.
- Validate required/conditional answers before submission, preserving completed work and locating unresolved fields by accessible means.
- Submit only after patient review through [Action Cards](#agentic-action-cards); provide actual receipt/status or a usable supported external handoff.
- A replaced/expired form cannot silently receive answers intended for another version; explain migration or restart needs.

**External recipient boundary / blockers:** Provider-owned form definitions, signature/legal requirements, conditional logic, attachment limits, resubmission/correction rights and allowed AI assistance require approval. This is patient completion, not a new form-builder/staff administration system. Uploaded form documents use [Documents](#documents-w-ai-support); request status uses [Messaging](#messaging) and the shared action lifecycle.

## AI Companion Atomic Habits & Journeys

**User Story:** As a patient, I want to choose small habits that fit my life and see genuine progress without guilt or Rumi changing my clinical plan.

### Acceptance Criteria

- Allow the companion to propose a habit with its behavioral purpose and everyday context, grounded in the patient's stated priorities or linked care-plan goal.
- The patient reviews, edits, accepts or declines the specific proposal. Acceptance creates that habit, not the first existing habit; decline creates nothing and cannot show completion.
- Support agreed habit editing, pausing/resuming and removal without rewriting past logged history or clinical source instructions.
- Keeping a habit records the relevant date in the patient's time context; duplicate activation does not create duplicate keeps. Provide an approved correction/undo path for mistaken entries.
- Journeys, linked plan goals and kept history remain consistent after reopening and across the declared supported account scope.
- Describe progress from actual records without invented streaks, compliance judgments or fabricated improvement claims.
- Program-associated habits retain sponsor/context information and remain subject to [Sponsored Programs](#sponsored-programs).
- Group habits under patient-chosen journey themes; each habit belongs to one journey and may also link to a plan goal or program.
- Acceptance offers reminder days/time or none. Repeated non-keeps may prompt a smaller, optional habit without judgment.
- Offer a weekly, skippable and disableable review with one reflective question, not scores or rankings. Ending a journey preserves readable history and stops its reminders.
- Help the patient link a chosen action to their own reason, an existing routine/event cue, a stated obstacle and an optional smaller fallback. A rotating schedule must not be forced into a fixed clock-time cue.
- An optional doability rating is the patient's self-report, not an inferred psychological trait, a clinical score or eligibility criterion. Low confidence invites a smaller choice, never automatic pressure or an increased goal.
- Check-ins distinguish the intended action, a smaller alternative, a barrier and a deliberate skip. Each retains its dated context and relevant plan version; accepting a plan is not evidence the action occurred. Mistaken check-ins can be corrected or undone without affecting other habits.
- Adaptation uses the person's stated barrier and reported outcome. The patient can retain, edit, pause or decline a suggested adjustment. Silence, non-use and setbacks are not failure, lack of motivation or consent to outreach.
- Keep patient statements, hypotheses and AI suggestions distinct. The person's correction takes precedence in future personalization. No assistant suggestion or demographic stereotype can be promoted to patient evidence or commitment.
- Any inferred-profile factor requires attributable evidence, stated uncertainty, purpose-limited use, correction and approved retention/deletion. Sensitive psychological classification, scoring, confidence/decay thresholds, automated outreach and learning-policy promotion remain subject to separate privacy/clinical/quality approval. The supplied behavioral-engine writeup does not itself approve these policies or establish implementation.

**Edge/blocking states:** Plan changes, timezone changes, late entries and pausing/removing a journey require agreed behavior. Product/Clinical must approve eligible clinical-plan derivations and history correction rules. Garden/celebration are retained creative concepts, not specified visual implementations; meaningful progress information remains accessible without them.

## Medications (w/ AI support)

**User Story:** As a patient, I want help understanding and managing my medications. Rumi must not prescribe or change my treatment.

### Acceptance Criteria

- Show medication identity, available dose/schedule/status, source/date, purpose information, supply/pharmacy when known, and relevant attributed guidance under [record quality](#records-connection).
- Distinguish active, paused and stopped medications with source/date and accessible history. Patient-entered OTC medicines and supplements remain labeled separately from source records; do not merge uncertain dose/schedule records silently.
- Contextual questions include the selected medication and relevant permitted clinical evidence under [Companion continuity](#companion-continuity-and-voice).
- Record medication-taking reports separately from prescriptions; summaries identify what they are based on and do not infer adherence from an unrelated fixture array.
- Symptom/barrier logging retains medication context and uses [Symptom Tracking w/ AFB](#symptom-tracking-w-afb); temporal association is not automatically a causal adverse-effect claim.
- Refill/coverage/office requests use approved recipients and [Action Cards](#agentic-action-cards) with actual outcomes; expose reachable neutral savings/support where eligible.
- Neither a chat response nor a habit action autonomously changes dose, schedule or treatment. Clinical uncertainty routes to an approved care-team/pharmacist question.

**Medication-derived refill tracking**
- Derive an estimated refill date only from dated, attributable supply and regimen information, with patient-confirmed updates where needed. Make the basis and uncertainty inspectable.
- Unknown supply, variable dosing and as-needed use must not produce a guessed date. Preserve the medication and offer clarification rather than presenting an exact estimate.
- Supply or regimen changes update future estimates without rewriting past reports. Paused or stopped medication requires state-aware review, not an automatic refill request.
- Link an eligible due item to that medication and a reviewed provider request. Request submission never means the prescription was issued, filled or dispensed.
- Complex pharmacy integrations, stock checks, transfers, automatic prescribing and delivery management are excluded.

**Blocking questions:** Supported medication sources, reconciliation authority, dose-log fields/corrections, adherence/supply calculation policy, interaction/side-effect content authority and refill service coverage. No medication safety thresholds or substitution recommendations are invented here.

## Medications Sponsored Pages

**User Story:** As a patient, I want to understand medication-related sponsored support and its limitations before using it or sharing information.

### Acceptance Criteria

- Associate each page with the correct medication/support program and available approved content; identify sponsor, purpose and current applicability under [Sponsored Responses](#sponsored-responses).
- Keep educational/safety information, financial estimates and promotional claims distinguishable and sourced.
- Do not treat appearance on a patient's medication page as proof of eligibility, coverage or clinician endorsement.
- Provide applicable neutral alternative/support access without requiring enrollment in the sponsored offering.
- Any application or data sharing identifies fields, recipient and terms for review under [Action Cards](#agentic-action-cards); report actual enrollment/application outcome.
- Expired, withdrawn or unsupported content remains unavailable or appropriately qualified, rather than presenting an active false offer.

**Blocking questions:** Clinical, Commercial and Product must decide whether these are medication-brand pages, support-program pages or both. Approve claims, safety content, eligibility, commercial agreements and consent. The feature remains requested, but no brand inventory is assumed. Keep neutral care and crisis support accessible.

## Immunizations (w/ AI support)

**User Story:** As a patient, I want to understand my documented immunizations and ask about gaps without Rumi treating a missing record as a missing vaccination.

### Acceptance Criteria

- Display available immunization identity, administration date, dose/series details when present, source and status under [Records Connection](#records-connection).
- Distinguish documented administration, patient report, unavailable documentation and conflicting entries.
- AI explanations cite the selected record and approved educational sources; missing documentation is not automatically interpreted as an overdue clinical need.
- Support source correction/annotation through the approved record process and adding a question to [Discussion Guide](#discussion-guide).
- If reminders or eligibility recommendations are included, use approved population/jurisdiction/clinical rules and show their evidence/limitations; do not infer them from age/pathway alone without approved logic.

**Blocking states/questions:** Unknown series, duplicate imports, ambiguous historical products and unavailable dates must remain explicit. Clinical/Product must approve launch immunization coverage, schedule authority and whether eligibility/reminders are included. No new clinical schedule is authored in this document.

## Documents (w/ AI support)

**User Story:** As a patient, I want to keep the original document and review AI-extracted information before using it in my record or sharing it.

### Acceptance Criteria

- Support approved capture, upload and import methods on each platform. Identify unavailable methods. Saving a document title must not imply that an original was uploaded.
- Retain an accessible original with type, origin/time, page information where available and patient association; allow patient title/category correction.
- Identify extraction/summarization as generated work and expose proposed fields with uncertain/unreadable items flagged.
- Patients can inspect and correct eligible extracted values before an approved record update. Confirmation alone cannot falsely claim a clinical merge if none occurred.
- AI questions/explanations reference the selected document and available page/source evidence, not unrelated fixture text.
- Share only reviewed selected content through [Messaging](#messaging)/[Action Cards](#agentic-action-cards); deletion follows [Account rights](#account-preferences-and-data-rights) and describes affected original/extracted copies.

| Document state | Required outcome |
|---|---|
| Upload/capture in progress | No claim that the original is available until retained successfully. |
| Invalid/unsupported/unreadable file | Preserve recoverable context and offer permitted retry/manual alternatives. |
| Original saved, extraction pending | Original remains usable; no invented extracted facts. |
| Low-confidence or conflicting extraction | Require approved review/correction before clinical use. |
| Extraction accepted | Apply only the approved update scope with provenance and true saved status. |
| Deleted/restricted original | Do not leave an unqualified live link or silently resurrect it from fixtures. |

**Blocking questions:** Accepted formats/sizes/pages, storage/retention, allowed extraction fields, reviewer authority, source-page citation and record-merge policy. Engineering owns implementation; no OCR/model/vendor is prescribed.

## Notes (w/ AI support)

**User Story:** As a patient, I want to write my own notes and understand clinical notes without confusing either with what Rumi remembers about me.

### Acceptance Criteria

- Distinguish patient-authored private notes, imported clinical notes, AI summaries and remembered personalization; each retains appropriate source/time/ownership.
- Patient-authored notes support creation, editing and deletion with recoverable draft/save failure states. Imported clinical notes use the approved correction/annotation route rather than silent overwrite.
- AI can summarize/explain a selected note under [Companion continuity](#companion-continuity-and-voice), retaining access to the original and labeling generated interpretation.
- Patients choose what becomes a Guide question, remembered preference or shared message; creating a private note does not automatically send it to a provider or sponsor.
- Search/retrieval returns only authorized notes and identifies no-match without substituting unrelated source records.

**Blocking questions:** Product/Privacy must define private-note AI inclusion defaults, search scope, retention and whether note versions are patient-accessible. Clinical must define handling of sensitive/restricted clinical notes and correction authority. A Guide item, memory chip and clinical note are not interchangeable records.

## Vitals (w/ AI support)

**User Story:** As a patient, I want to record a reading with its units and time, then receive feedback within clinically approved limits.

### Acceptance Criteria

- Support the approved vital types with value, units, measurement time, source/device or patient-entry attribution, and relevant context fields.
- Validate format/unit compatibility and approved plausibility constraints without silently converting an uncertain unit or discarding an unusual but possible reading.
- Permit patient correction of eligible manual readings with provenance; duplicate imports or repeated saves do not create misleading trends.
- Present trends from comparable measurements and distinguish measurement time from receipt time under [record quality](#records-connection).
- AI explanations use the selected readings/context; alerts and suggested escalation follow approved [Needs You](#needs-you-clinical-alerts) / [crisis](#crisisself-harm-handoff) rules rather than generated thresholds.
- Missing connectivity or a failed save does not fabricate a reading; permitted manual entry remains available when in scope.

**Blocking questions:** Clinical/Product must approve vital types, units, reference/alert ranges, device coverage, plausibility rules, backdating and repeat-measurement guidance. Multiple abnormal readings or missing clinical context require approved precedence/fallback. No numerical clinical rule is inferred from old charts.

## Labs (w/ AI support)

**User Story:** As a patient, I want to understand a specific laboratory result in context and know which questions belong with my care team.

### Acceptance Criteria

- Show available test identity, result/value, unit, reference interval, specimen/result date, source, status and relevant annotations under [Records Connection](#records-connection).
- Distinguish preliminary, final, corrected and unavailable results where the source supplies those states; do not label all results definitive.
- Chronological comparison uses actual dated, compatible results; array order or an unrelated patient's series cannot determine the latest value.
- Explain the selected result with evidence and uncertainty under [Companion continuity](#companion-continuity-and-voice); do not infer diagnosis from an isolated value.
- Permit adding an attributed question to [Discussion Guide](#discussion-guide) and including selected results in [reports](#visit-preparation-and-recipient-reports).
- Alert acknowledgment uses [Needs You](#needs-you-clinical-alerts) and is distinct from clinical follow-up being complete.

**Edge/blocking states:** Incompatible units/reference intervals, corrected source values, unsorted/duplicate data and missing ranges must be explicit. Clinical/Integration owners must approve result normalization, reference-interval authority, critical-result handling and whether any comparisons must be withheld. Source correction does not silently leave a stale unqualified report.

## Conditions (w/ AI support)

**User Story:** As a patient, I want to understand which conditions are in my record and how they relate to my plan without Rumi diagnosing me.

### Acceptance Criteria

- Identify condition name, source/date and available status such as active/history/self-reported/uncertain under [record quality](#records-connection).
- Separate a patient's selected care pathway from a verified diagnosis; neither selection nor AI inference creates a clinician-confirmed condition.
- Contextual explanations relate the selected condition to attributed plan/medication/record information with uncertainty made explicit.
- Support questions/correction requests through Guide or the approved record process; do not silently replace externally authored facts.
- Multi-condition context used in reports/chat includes relevant source evidence and does not suppress a condition merely because another pathway is selected.

**Blocking questions:** Clinical/Product must approve condition status vocabulary, patient-entry/correction authority, reconciliation and scope of educational recommendations. A prediction/looking-ahead suggestion must not be presented as a new condition; any predictive capability requires its own approved evidence and indication.

## Allergies and other clinical information

**User Story:** As a patient, I want important allergy information to remain accurate and visible, including when the record is uncertain.

### Acceptance Criteria

- For supported allergy records, display available substance, reaction, severity/status, source and date with approved unknown/not-assessed states.
- Distinguish a documented negative allergy history from no available allergy information; never infer one from the other.
- Patient reports/corrections retain attribution and follow [Records Connection](#records-connection) rather than silently overwriting clinical source records.
- Relevant permitted allergy context is available to medication/clinical explanations, without implying an evaluated interaction check unless that capability is approved.
- Conflicting allergy reports require the approved clinical reconciliation/escalation path; AI cannot choose a convenient record as definitive.
- Retain access to the existing Procedures category and its source records under the shared provenance, permission and correction rules.
- Name and bound any additional clinical category before implementation. Each follows the same shared rules. Retaining Procedures does not authorize new procedure advice or scheduling.

**Blocking questions:** Clinical/Product must define allergy terms, patient correction rights, contraindication use and urgent handling. They must also name any additional clinical categories beyond the retained records and new Allergies. The phrase "other clinical information" does not authorize unlimited history, genetics, family-history or unrelated data collection.

## Sponsored Programs

**User Story:** As a patient, I want to decide whether a sponsored program fits me and know what enrollment actually commits or shares.

### Acceptance Criteria

- Display approved program purpose, sponsor, eligibility basis, participation conditions, material costs/benefits and data-sharing implications under [Sponsored Responses](#sponsored-responses).
- Separate confirmed eligibility from a potentially relevant opportunity; estimates remain estimates until verified.
- Patients can inspect neutral alternatives, decline or review an enrollment proposal without losing ordinary care functionality.
- Enrollment uses reviewed fields/recipient/terms and [Action Cards](#agentic-action-cards); service rejection/pending/confirmed states are distinct from local acceptance.
- Program-created habits or tasks are identifiable and patient-controlled under [Journeys](#ai-companion-atomic-habits--journeys); declining a program creates no hidden journey.
- Persist decisions and apply the approved cross-surface resurfacing/exclusion policy after reopening; an old chat card cannot bypass a current decline or changed eligibility.
- Ending participation explains consequences for program-specific tasks and shared/retained information.

**Blocking questions:** Clinical/Legal/Commercial must approve available programs, eligibility/ranking, enrollment/withdrawal terms, data uses and decline interval. No fixture copay/sponsored program represents an authorized commercial integration.

## Symptom Tracking w/ AFB

**User Story:** As a patient, I want to record what I am experiencing, receive appropriate feedback and reach a useful next step without losing my original observation.

**Confirmed scope:** AFB includes **both AI-generated and rules-based feedback**. This confirmation defines the mechanisms, not a clinical algorithm, threshold or approved emergency policy.

### Acceptance Criteria

**Patient entry and history**
- Capture the symptom, severity on the approved scale and observation time. Include optional body region, note and relevant medication/condition context. Allow review and correction before saving.
- Preserve the saved original observation and provenance; patients can access and correct eligible history under approved retention rules.
- Do not infer temperature, duration or other clinical facts not entered or available from authorized sources.
- Save failure retains input and clearly distinguishes an unsaved entry from a saved entry awaiting feedback.

**Rules and AI feedback**
- Apply the clinically approved rules to eligible input. Rule-based guidance remains available under the approved offline/service-failure policy, independent of AI response success.
- AI feedback references the actual selected entry and permitted context, explains uncertainty and offers bounded support under [Companion continuity](#companion-continuity-and-voice).
- Distinguish rule-based feedback from AI interpretation when it affects trust or action. AI cannot weaken or contradict an approved safety rule's required action.
- If essential context is missing, request an approved clarification or use approved conservative fallback; never fill it from a demo persona.
- Offer applicable follow-up choices: discuss further, add/edit a Guide question, review a care-team message, or use approved urgent/crisis contact. Each choice retains the entry context.

| Condition | Required result / unresolved policy |
|---|---|
| Entry saved, rules produce ordinary support | Show approved support and eligible optional AI/contextual follow-up. |
| Entry saved, AI unavailable | Preserve entry and approved rule/fallback guidance; disclose the unavailable generated response. |
| Approved clinical urgency trigger | Present the required action without waiting for generative advice. |
| AI conflicts with rule-required action | Retain the rule-required action; do not present unsafe contrary instruction as equivalent. |
| Crisis trigger also applies | Follow the clinically approved overlap policy in [Crisis handoff](#crisisself-harm-handoff); ordering remains a blocker until specified. |
| Input ambiguous/outside approved scope | Clarify or use approved fallback; no invented certainty or automated diagnosis. |
| Entry corrected after feedback/action | Reassess eligible feedback, mark prior context appropriately and never silently rewrite an already sent message. |

**Blockers:** Clinical must approve symptom taxonomy/severity scale, rules/thresholds, required clarifications, feedback precedence for overlapping clinical rules, escalation destinations, reassessment and offline fallback. Existing oncology/procedure fixture content is not clinical approval. Product must approve whether body-region entry is optional per symptom and how historical corrections affect prior derived summaries.

## Companion continuity and voice

**User Story:** As a patient, I want conversation to retain my record or task context. I want to understand AI limits and audio processing.

### Acceptance Criteria

**Contextual conversation — shared owner**
- Provide conversation entry from relevant clinical/lifestyle/task surfaces; preserve selected patient/entity/time and return destination.
- Provide a consistently reachable lower-screen companion entry throughout the main app without obscuring navigation, input or critical review controls. Conversation remains optional; direct care workflows remain available.
- Retain the unsent composer and completed conversation within their declared identity/mode scope. Dismissal returns to the originating task; stopping generation is a distinct action. After interruption or relaunch, a partial answer is identified as incomplete, never silently presented as complete.
- Rapid sends, cancellation, reconnection and late responses cannot overwrite a newer reply, duplicate the current patient message, apply an obsolete proposal or mutate another scenario's history. Retry is associated with the intended patient message and preserves ordering.
- Transport/provider errors have an explicit retry or non-chat recovery route. A static/scripted offline response cannot pretend to be a generated answer, clinical reassurance or evidence of synced records. No action is extracted from an incomplete response.
- Each response addresses the patient's current message in its permitted context. A previous turn or hidden prompt cannot replace the current message or cause a duplicate response.
- Use only permitted, attributed context under [Terms & Privacy Consent](#terms--privacy-consent), [Records Connection](#records-connection) and [Visible Editable Memory](#visible-editable-memory). Missing facts are not replaced with fixture values.
- Ground clinical explanations in the selected evidence; distinguish quoted/source facts, AI interpretation and uncertainty. Model wording alone cannot establish diagnosis, authorization or execution.
- Present proposed actions through the shared [action lifecycle](#agentic-action-cards). Generated internal tags/unknown payloads are not exposed as patient content or executed silently.
- Preserve conversation history according to the approved retention/scope policy and reflect corrected/deleted memory in future context. Past messages are not silently rewritten.
- Generation failure/cancellation has a recoverable outcome. If scripted or limited fallback is used, make its limitations understandable; do not masquerade it as a successful live answer.

**Voice**
- Explain actual external audio/text processing and request microphone permission before recording. Denial has a text alternative and supported permission-recovery path.
- Clearly distinguish listening, processing and playback; the visual companion state cannot claim recording when the microphone is inactive.
- Support starting, interrupting and ending a session; stopping prevents new recording and further unintended processing/playback within the declared cancellation policy.
- Describe transcript availability accurately. Do not present text returned after recording as live partial recognition. Support patient corrections before using it for a consequential action.
- After a completed spoken turn, continue listening only when the patient has opted into the ongoing voice session. Silence does not generate invented speech.
- Ambient sound does not undermine intelligibility or cause the app's own audio to be interpreted as patient intent. Audio interruption/device changes have recoverable states.
- Voice and text share the same safety and approval boundaries; a spoken response does not authorize a payment/message/medical action.

**Blocking questions:** Product, Privacy and Clinical must approve history/context limits, response and cancellation timing, transcript review, audio retention and background behavior. They must also decide whether live streaming transcription is required. Engineering chooses the model and transport. This draft does not claim a response speed.

## Agent network and connected services

**User Story:** As a patient, I want to know what Rumi's helpers can actually do, what is waiting on me and which connected information they use.

### Acceptance Criteria

- Retain visibility of the eight existing assistance domains—risk, monitoring, escalation, scheduling, education, care pathway, medication adherence and lifestyle—without claiming unsupported services are running.
- Each service identifies supported purpose, required sources/permissions, actual enabled/paused/unavailable state, work in progress and patient decisions needed.
- Tasks display consistent state/details with chat and originating features under [Agentic Action Cards](#agentic-action-cards); completed work has an actual outcome, not a fixture cadence string.
- Pausing/disconnecting prevents new covered work and explains treatment of already submitted/irrevocable operations. Hiding a service is not equivalent to stopping it.
- Connect accounts only through supported authorized access; distinguish sign-in from Gmail/Calendar/other channel permission. Show actual connected account/scope, freshness and failure/revocation status.
- Reading/sharing through a channel follows the patient's permitted scope and approved platform capabilities. Unsupported iMessage/social access is explicitly unavailable, not a sample connected handle.
- A source change that alters a pending action's material payload requires re-review; overdue/unknown status has recovery rather than automatic completion.

**Blocking questions:** Define which helpers are live at launch, permitted automatic work, background frequency, provider/channel coverage, revocation and operational ownership. Prediction and continuous-monitoring claims need approved evidence and scope. Showing a network does not prove that a clinical model is validated.

## Visit preparation and recipient reports

**User Story:** As a patient, I want to review an accurate summary for the selected recipient and visit, then choose what to share.

### Acceptance Criteria

**Patient preparation**
- Offer a reversible guided route for the selected appointment: patient priority, changes/symptoms, medication concerns, questions and practical barriers, then review. Each step may be skipped; progress survives leaving and reopening that visit.
- AI assistance is optional and uses only the permitted selected-visit context and the patient's supplied answers. Explain external processing before using entered information. Suggestions remain separate until selected; never invent symptoms, a medication change, a diagnosis or a clinician's instruction.
- Patients can choose existing Guide questions explicitly, add their own and prioritize them. A question in the general Guide does not silently become part of every appointment.
- Review applies to the exact content and appointment/recipient revision. Editing or rescheduling invalidates affected review status; other appointment drafts remain unchanged. Export is a patient-controlled handoff, not proof of sending, EHR acceptance or clinician review.
- Select or confirm patient, provider/recipient, appointment where applicable and report time range; never substitute a fixture persona name or first appointment.
- Include the approved categories of records, observations, medications, everyday logs and Guide questions, with source/date and clear inclusion/exclusion meaning.
- Use the selected interval in all time-bound report sections. Label ongoing medication or condition information from outside that interval as background context. Do not count it as an observation within the interval.
- Exclude future observations from a historical interval unless explicitly selected and labeled; use actual dated records rather than array order for trends.
- Tailor emphasis to the recipient using approved rules while preserving relevant multi-condition context and evidence. Do not invent cross-provider agreement or causal conclusions.
- Permit review, eligible correction/exclusion and confirmation of the exact report snapshot; AI-generated material is identified as a draft according to approved authorship rules.
- Provide a usable retained/exportable artifact in the approved format when export is included; a PDF-like view is not a generated PDF.

**Recipient/service boundary**
- Sharing uses [Messaging](#messaging)/[Action Cards](#agentic-action-cards), identifying recipient/payload and actual receipt status.
- Support delivery of the patient-approved pre-visit brief to the selected practice's EHR through the authorized workflow. Approval, submission and EHR acceptance are distinct; retain the approved version and attributable receipt or failure/unknown outcome.
- EHR acceptance is not clinician authorship, signature or proof of review. Unsupported writeback must not be represented as completed; the patient retains an exportable reviewed copy.
- Distinguish report versions by content, range and recipient. Changed content must not inherit a previous sent state. Keep earlier shared copies distinguishable under the retention policy.
- The patient can inspect what was sent, when and to whom, or see a clear unsuccessful/unknown outcome.

**Blocking questions:** Approved report recipients, range boundaries/timezones, included data/metrics, AI versus clinician authorship/review, export format and recipient transport. No clinical significance calculation or medication adherence estimate is invented from log counts.

## Bills, wallet and savings

**User Story:** As a patient, I want to understand care costs and approve supported payments. I need to distinguish estimates and local acknowledgments from confirmed payments.

### Acceptance Criteria

- Show sourced bill/provider/encounter/amount/status and explanatory line items where available; distinguish estimates, patient-reported payments and confirmed financial records.
- Explain uncertainty or suspected discrepancies without claiming a dispute was filed; offer a supported inquiry/dispute route where approved.
- Wallet identifies supported payment methods and permissible use; insurance information is not treated as a chargeable card.
- Before a payment, review bill/recipient/exact amount/method and material terms under [Action Cards](#agentic-action-cards). No charge occurs outside approved scope.
- Payment status and receipt follow the processor/provider's evidence; unknown outcomes reconcile before retry. A patient marking already-paid is labeled patient-reported unless verified.
- Payment changes and financial totals remain consistent; a decorative local paid marker must not imply the balance was charged or claims totals recalculated.
- Savings offers identify source, estimate versus verified benefit, eligibility and sponsorship under [Sponsored Responses](#sponsored-responses); applications review personal data and recipient before submission.
- Expired/unsupported methods, rejected eligibility and unavailable provider handoffs have an honest recovery route, not a placeholder link or successful animation.

**Blocking questions:** Payment/savings providers, supported tender including HSA restrictions, financial authority, refunds/cancellations/disputes, wallet-management scope, receipt/claims reconciliation and compliance obligations. These are retained but integration-gated capabilities; no live financial operations are authorized by approving this draft.

## Life history and held memories

**User Story:** As a patient, I want to keep and correct my everyday history and photos. I need estimates to remain distinct from measurements.

### Acceptance Criteria

- Retain browse/search/logging for meals, activity and medication-taking reports; contextual selections use the selected item rather than a generic unrelated default.
- Entries include relevant title/type/time and approved optional context; support history/detail/correction/removal and return to the originating surface.
- Nutrition/effort information states whether measured, user-entered or estimated, including applicable portion/context. A shared illustration does not establish an exact nutrient or exercise dose.
- Daily totals derive from eligible entries and stated assumptions; correcting/removing an entry updates applicable summaries without changing unrelated clinical prescriptions.
- Medication-taking entries link to medication records without rewriting them; any adherence summary uses the approved calculation/source policy from [Medications](#medications-w-ai-support).
- Held memories support the approved real photo-selection/caption flow on each platform; cancellation/failure does not leave falsely completed or unintended patient-visible memories.
- Patients can access and remove eligible held photos/metadata under [Account rights](#account-preferences-and-data-rights); memory photos are distinct from editable companion memory notes.
- Preserve existing stored activity compatibility during future migration while presenting the agreed Activity concept consistently.

**Blocking questions:** Manual fields, units/portions, estimation source, backdating, correction history and photo retention/export/deletion. Product must choose equivalent web photo capability rather than retaining a canned-memory substitute as if it were upload.

## Story, Insights, Currents and recap

**User Story:** As a patient, I want reflection and a finite set of educational content based on my actual context, with working saves and media.

### Acceptance Criteria

**Story and Insights**
- Story events identify their origin/date and distinguish imported facts, patient reports and generated reflection under [record quality](#records-connection).
- Insight explanations expose evidence and limitations; do not claim statistical patterns or causal relationships unsupported by the approved analysis.
- Saving, dismissing and acting on an insight has a durable, inspectable result; opening an insight from Today selects that insight/context rather than generic Story.
- Looking-ahead/prediction content appears only under approved eligibility, consent and safety restrictions and cannot assert a new diagnosis. The current fixture nudge is not a production prediction requirement.

**Currents and recap**
- Provide a finite current content set with a clear end and approved refresh policy; avoid an endless feed by default.
- Identify content source, applicable date and AI-generation/sponsorship where relevant; content-to-chat handoff retains the selected piece and evidence.
- Save/taste actions persist with a discoverable saved-item outcome and approved effect on later recommendations; do not claim an item was added to Story if it was only bookmarked elsewhere.
- Listen/watch controls operate actual supported content and reflect real progress, pause/seek/end states. A timer cannot represent audio/video playback that does not exist.
- Captions/text alternatives are available according to supported content requirements; playback respects user audio choices and restores the appropriate state afterwards.
- Recap identifies the actual period/data basis, remains skippable and does not invent personal milestones; static illustrative material is not misrepresented as the patient's own photograph or measured improvement.

**Blocking questions:** Approve content sources, review and refresh intervals, personalization, media rights, prediction evidence/eligibility and recap criteria. The proposed editorial design is described in the change specification, not prescribed here.

## Account, preferences and data rights

**User Story:** As a patient, I want control of my account, preferences and stored information, including an honest way to export it or request deletion.

### Acceptance Criteria

**Identity and durable state — shared owner**
- Each account's data is isolated from other accounts and demonstration personas; signing out or changing accounts does not expose prior private content.
- Define and communicate the storage/sync scope of saved information. Patient-created entries, drafts, Guide, habits/history, memory choices, consent and action outcomes retain the approved durable state after reopening.
- Empty/deleted collections remain empty/deleted; failed restoration cannot silently turn fixtures into the patient's record.
- Recoverable save/sync failures preserve input and identify what has not been saved; version/conflict recovery does not silently overwrite newer authorized changes.
- Profile corrections and tone/appearance/audio preferences have consistent observable effects where supported. Optional notification/analytics/personalization choices follow their owning sections.
- Sign-out, revocation and deletion stop future unauthorized account activity; actual in-flight external commitments are reported rather than silently erased.

**Export and deletion**
- Export creates a usable artifact containing the approved categories, relevant provenance and declared exclusions; report preparation/progress/failure and successful availability truthfully.
- Explain deletion scope and consequences before confirmation. Apply the approved policy to eligible live and saved data, photos, attachments, caches and external processor copies.
- Where legal/operational retention prevents full removal, identify the applicable category, reason and effect without claiming everything is erased.
- Completion is based on verified scoped deletion status, not merely hiding the screen or deleting one local file; subsequent ordinary saves cannot recreate removed data unintentionally.
- Memory forgetting, disconnection, sign-out, local reset and full account deletion remain distinct choices and outcomes.

| Rights operation | Meaning |
|---|---|
| Forget a companion memory | Affects future eligible personalization; not all historical records. |
| Disconnect a source | Stops authorized future access under the disclosed retained-data policy. |
| Sign out | Ends the applicable session; not account deletion. |
| Reset an explicit demo | Removes/reset demo state without affecting real accounts. |
| Export | Produces accessible scoped data, not a prepared-success label alone. |
| Delete account/data | Performs the confirmed scope with retention exceptions and outcome tracking. |

**Release blockers:** Privacy/Legal/Product must approve storage/sync promises, conversation/audio/photo retention, export categories/format, deletion deadlines/exceptions, processor obligations, recovery/linking and account-access support. This section specifies outcomes, not a database or encryption implementation.

## Contextual assistance and inspectable agent work

### Acceptance Criteria
- When a patient asks for help from an item, retain that selected item's identity, relevant content, source and date; never replace it with a generic topic or unrelated first item.
- Before sending contextual information for AI processing, the patient can inspect what is attached, remove it, edit their question or return without sending. Entering assistance must not discard an existing unsent message.
- The context used for a sent turn remains associated with that turn for review and retry. A later selection must not silently change the evidence behind an earlier answer or proposal.
- Returning from assistance preserves the originating workflow and patient-created work. Scenario/account changes cannot carry the other patient's pending context into the new conversation.
- Explain, suggest, prepare, approve, submit and receive are distinct outcomes. Generated text, fixture narratives and local rules must not masquerade as newly verified clinical facts or external receipts.
- An agent proposal identifies the patient's intended task, its known basis, the exact proposed content and required patient decision. Unknown recipients, missing evidence, unsupported destinations and changed drafts remain unresolved rather than guessed.
- Patients can edit, decline or save a proposal without sending. Review-only availability must remain clear at the consequential decision; local approval cannot create a delivery, booking, payment or dispensing success.
- Paused or unavailable agent capabilities cannot execute a proposal. Existing completed history remains inspectable and is not erased by a pause.
- Routine navigation, consent and entry remain usable without AI. Assistance appears because it addresses the current patient task, not merely because a feature has an AI label.

The latest [re-scope attachment](https://r2-pub.rork.com/attachments/ra176ma71ass9gt2x7vv9.docx) reiterates retained AI and agentic capabilities. It does not approve new autonomous clinical authority, sponsor ranking, hidden profiling or external integration contracts.

## Platform consistency and release constraints

### Acceptance Criteria

- iOS and web use the same approved behavior, record/status meanings and consent, clinical and action rules. Disclose when an action is local-only on one platform but sends externally on the other.
- Maintain documented supported devices/browsers and platform differences for identity, health data, microphone/photo permissions, notifications, media and external handoffs.
- Every supported primary journey works with the platform's agreed accessibility methods, including navigation, form input, modal return, vital/symptom selection and action approval. Meaning does not depend only on color, animation, sound or a drag gesture.
- Respect reduced motion and sound preferences throughout companion, media and progress experiences while retaining the underlying information and controls.
- Loading/empty/denied/offline/expired/partial/failed states preserve truth and provide a safe exit or recovery; no placeholder service or fixture success is promoted to production evidence.
- Security/privacy handling protects account/session/clinical information according to approved policy; logs and user-visible errors do not expose credentials, OTPs or unnecessary sensitive data.
- Agreed response-time, timeout, retry, availability, retention and recovery targets are documented and observable before release. A successful build alone cannot satisfy these constraints.
- Supported live clinical/financial integrations require demonstrated authorized outcomes and recovery in their intended environment before claims of readiness.

**Blocking questions:** Product, Engineering, Design and Clinical must approve supported platforms, measurable reliability/performance and accessibility targets, security review, evaluation datasets and criteria, and operational owners. This draft does not invent service-level targets or a regulatory classification. Keep test procedures in the separate quality process, not this requirements file.

## Review questions and publication

The attachment supplies feature names but no approved clinical, legal or financial rules. The open questions above identify what each feature still needs. The [change specification](RUMI_RESCOPE.md#release-boundaries-and-unresolved-decisions) groups those decisions by owner and shows their dependencies.

Before implementing affected features, approve the launch population and region, patient/delegated access, live service coverage, account recovery and linking. Clinical must approve rules, overlapping-risk handling, record corrections and AFB thresholds/fallbacks. Communication and virtual-visit coverage, sponsor policy and account retention/rights also need decisions.

AFB's combined AI/rules scope, the evolving working/functional/visual document package, the seven additions, optional connected onboarding, patient-controlled habit support, separate Demo/vendor-test/regular use, retained contextual secondary capabilities and the approved navigation direction are confirmed. The revised Functional Requirements and Design Context govern further reconciliation; specialist rules and proposed numerical defaults remain unapproved. The change specification owns navigation and presentation decisions.

This repository draft does not replace an unchecked Confluence or Figma page. Reconcile existing feature pages and the IA before publication. Keep one evolving requirements page per feature and link dependent features to it. Do not add competing versioned pages or regulatory IDs.

Before engineering handoff, the requirements owner must check the approved design and UI copy against these functional requirements. The change specification supplies review detail, but this document cannot establish that the final design matches.

*This is a functional requirements document intended to give Design and Engineering a working starting point. It is not a formal traceable requirements record. Traceable product requirements (MRD/SRS) for regulatory purposes are maintained in Greenlight Guru, the official QMS system of record.*
