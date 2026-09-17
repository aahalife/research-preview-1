# Rumi — Developer Handoff

**Privia web demonstration · Native iOS · Services · Assets · Production transition**

Prepared September 17, 2026. This document distinguishes source implementation, local simulation, executed verification and future production work. It is intended for an engineer who has not seen the project. No credentials or real patient data are included.

**Release classification: synthetic demonstration only.** Rumi is not an endorsed, authenticated or integrated myPrivia product. Neither this handoff nor successful builds establish HIPAA compliance, clinical validation, regulatory clearance, production patient ownership or native/web parity.

## Contents

1. Start here and non-negotiable behavior
2. What is running, what is simulated
3. Web architecture and implementation
4. Native iOS architecture and implementation
5. Shared intelligence and production ownership
6. Endpoint and configuration register
7. Demo-disable and migration runbook
8. Channels, privacy and behavioral contracts
9. Design language and asset reuse
10. Asset generation and delivery procedures
11. Retained-feature coverage: all 43 rows
12. Verification and release gates
13. Key web screens
14. Complete packaged-asset register
15. Reference hierarchy and QMS boundary

<!-- pagebreak -->
## 1. Start here and non-negotiable behavior

### Workspace and setup

The repository contains three registered apps in `rork.json`: `ios` (native Swift), `web` (Vite/React/TypeScript) and `functions` (Cloudflare Worker). Product-facing branding is Rumi; historical names Nudge and Sano remain in target/module names, directories, asset labels and persistence keys. Do not rename those keys casually: doing so can orphan saved work.

**Web:** from `web`, run `bun install`, `bun run dev` for development on port 8080, `bun run test`, and `bun run build` for `dist/`. Run `bun ./node_modules/typescript/bin/tsc -p tsconfig.app.json --noEmit` explicitly; Vite compilation is not a type check. `strictNullChecks` is now enabled and the language library/target is ES2022; the older project still does not enable every strict compiler option. Install the existing Functions dependency with `bun install` from `functions` before running tests that import its source. Managed web checks build and publish the preview.

**Native:** open `ios/Nudge.xcodeproj` in a current Xcode supporting the existing project settings. Target/module: Nudge; display name: Rumi. The project targets iOS 18+, iPhone/iPad, with iOS 26 visual APIs guarded. Managed Rork native build: `runChecks` with `appPath: ios`; tests are separate through `swiftTest`. Do not install a Swift toolchain into the Linux sandbox. Use generated `Config.swift` in native code; never paste credentials into the app.

**Functions:** source is `functions/index.ts` and `functions/fasten.ts`; dependency `standardwebhooks` 1.1.1 is declared in `functions/package.json`. Deployment is managed by Rork. There is no app-owned database, patient authorization server, durable orchestration service or clinical ingestion job in these files.

**Document reproduction:** `python handoff/build_handoff.py` creates this Word file, a source hash register and a full asset CSV from allowlisted roots. `python handoff/validate_handoff.py` checks the artifact and optionally uses LibreOffice to render it. Requirements: python-docx, Pillow, PyMuPDF; LibreOffice for DOCX layout verification. Document files are not placed in `web/public` and therefore are not automatically exposed by the demo website.

### Preserve these invariants

- Keep four destinations: Today, Care, Messages, You. In the new web app the centered Log is an action sheet, not a destination; a separate Rumi control floats above the dock.
- Keep direct, non-chat routes. Someone requesting an address, saving a reading or writing a visit question must not have to explain their emotions or accept AI processing first.
- Preserve the exact patient, appointment, recipient, selected observation and edited draft. Never fill missing Elena records with Marcus fixtures.
- Make room for a concern before proposing logistics. A refusal, pause or unrelated conversation does not imply nonadherence, resistance or consent to outreach.
- Only the patient confirms memory and consequential proposals. An AI reply, local review or saved calendar event cannot order a test, book a draw, send to an EHR or establish clinician receipt.
- Keep evidence distinct from instructions. Emails, calendar text, records and generated prose cannot authorize actions or alter clinical policy.
- Keep the native provider boundary: Temporary AI and Rumi backend have separate workspaces; there is no automatic fallback or silent history replay into another service.
- Preserve the 20 accepted native original/slide pairs. The ten cancelled visit captures are staged evidence, not accepted slides. New web screenshots have their own directory and manifest.

## 2. What is running, what is simulated

### Delivery surfaces

| Surface | Implemented now | Not established |
|---|---|---|
| New Privia web at `/`, `/care`, `/messages`, `/you` | Isolated Elena workspace, direct forms, remembered preferences, real AI request path, sample inbox search/calendar comparison, reviewed local actions and shared channel transcript | Real Google access, patient login, clinical APIs, external sending, booking, SMS or telephony |
| Earlier web at `/legacy` | Existing Sano prototype and saved scenarios, unchanged data keys | Safe new-workspace behavior, corrected legacy external-success claims or feature parity |
| Native iOS | Four tabs, four-stage optional onboarding, selected-context chat, reviewed workflows, appointment prep, habits, router and provisional backend text transport | New Elena web journeys or channel previews; live patient authorization; complete clinical integration |
| Worker | Voice proxy and guarded Fasten test setup endpoints | Shared patient record, central behavioral engine, durable webhook ingestion, clinical writeback or channel dispatcher |

### Elena scenario and actual data ownership

The new web scenario is `privia-elena-52-synthetic`. Browser key: `rumi.privia.elena.v1`. Name Elena, age 52 and the two conditions were created for the selected synthetic example. The visit ID is `elena-visit-2026-09`, initially September 29, 2026 at 10:00 Eastern. Practice/lab addresses use Example Lane and Demo City; emails use `example.invalid`. These are intentional fictional values, not real places to visit or contact.

The initial sample observation is 138/84 mmHg on September 16. It is labeled Sample record, not an imported or verified reading. New entries are patient-entered demo information; incoming sample SMS entries are separately labeled. No medication list or doses were invented for this scenario. A missing list must not be interpreted as taking no medication.

The lab order is initially unconfirmed. A clearly labeled demonstration control stages a clinician-approved sample HbA1c/basic metabolic panel order. The demonstration does not specify fasting, medication adjustment, parking, travel time or special support arrangements. The source email supplies only fictional location and three September 23 planning options; 08:00 conflicts with an existing commitment. Neither the free times nor the order are live vendor data.

Sample calendar writes contain only **Personal appointment**, start/end and linkage metadata. Practice messages are stored with **Simulated · not sent**. The local calendar operation and local message operation are separate; one does not imply the other succeeded. The after-visit plan is introduced only by the explicit staged visit control. It asks to bring readings/questions to follow-up and intentionally does not create a clinical monitoring schedule.

### Source-flow coverage and deliberate exclusions

The supplied [Agentic Flows PDF](https://r2-pub.rork.com/attachments/gsxzidsjq4769xp8v89u5.pdf) was fully downloaded and extracted as one long page, 8,897 text characters, in `tmp/agentic-flows-extracted.txt`. It describes 16 pre-visit, 10 during-visit and 12 post-visit steps. Earlier online summaries omitted the final sections; this handoff uses the complete extraction.

Its original Marcus/54 story is a reference, not the new identity. The build follows concern → evidence → patient choice → reviewed preparation and local follow-through. Its T2/T3 autonomy, automatic EHR briefs, quality-measure closure, device sync, continuous monitoring, medication/insurance handling, rides, caregiver notices and red-flag escalation are **not implemented by this stage**. A drawing of a workflow does not authorize it. During-visit activity is a staged source plan, not live ambient documentation or clinician software.

## 3. Web architecture and implementation

### Source map

| Source | Responsibility |
|---|---|
| `web/src/App.tsx` | Top-level React Query provider, BrowserRouter, new route versus isolated legacy route |
| `web/src/pages/Index.tsx` | Demo-enable gate before mounting PriviaProvider |
| `web/src/pages/Legacy.tsx` | Separate SanoProvider; explicit return link; same demo-disable gate |
| `web/src/privia/model.ts` | Versioned Zod schema, unique patient/visit identity, fixtures, evidence, overlap checks, approval fingerprints, local action validation, SMS parsing and outreach rules |
| `web/src/privia/store.tsx` | Typed context hook, write-before-publish persistence, mutations, cancellation, drafts, current operation ownership, SMS intake and memory/source changes |
| `web/src/privia/ai.ts` | Permission-filtered context, bounded read-only tool loop, structured reply validation and Rork Toolkit call |
| `web/src/privia/PriviaApp.tsx` | Four main destinations, centered Log action, separate companion, sheet routing and orientation |
| `web/src/privia/Conversation.tsx` | Shared transcript, opt-in, selected source inspection/removal, editable suggestions, explicit acceptance and retry |
| `web/src/privia/Workspaces.tsx` | Sample sources/search, lab event planning, practice draft/review, selected visit and discussion guide |
| `web/src/privia/Personal.tsx` | Log form, correction/undo, patient-confirmed memory, response pace and personal support plan |
| `web/src/privia/DemoControls.tsx` | Explicit scenario stages, illustrative starters, SMS/call transcript previews and outreach preferences |
| `web/src/privia/ui.tsx`, `privia.css` | Reusable shadcn-based controls, concentric mark, Fields demo font, mint/blush/butter wash and reduced motion |
| `web/src/test/privia.test.tsx` | Isolation, review, consent, persistence, cancellation and direct-interface regressions |

### State and persistence

All new-workspace saved state belongs to one typed context created with `@nkzw/create-context-hook`, nested inside the existing React Query provider. Components do not read localStorage themselves. Each mutation clones the latest ref, applies the edit, validates the complete shape and writes one JSON value before publishing React state. A quota/write error leaves previous saved state intact and shows a failure. A damaged/foreign/version-mismatched snapshot is not overwritten; export/reload/reset are explicit recovery options.

The schema includes sources, confirmed memory, response pace/pause, turns, composer, context IDs, exclusions, unanswered question, guide/draft, logs/log draft, support fields, sample messages/events and channel preferences/drafts. Message and calendar approval fingerprints are separate. Question draft, edited AI proposal, memory draft and proposed visit date survive component unmounting. Correcting an existing log asks before replacing a different unfinished draft. Repeated log submission uses a stable form ID and a submission guard; sample SMS duplicate value/time pairs do not create another reading.

A browser storage event locks a stale tab instead of silently overwriting another tab's changes. This is not a transactional cross-device merge engine. Data remains unencrypted browser storage; it is unsuitable for real PHI. There is no login, central backup or server record. The demo JSON export is a local snapshot; it does not export AI-provider logs or any external account.

Permission revocation and memory edits end active work, invalidate proposals/approvals and exclude earlier conversation from future model payloads. Old visible history remains available on the device. Observation corrections/removal invalidate old AI context and guide review; source chip removal excludes that source from future requests. Removing remembered text does not automatically redact an independently edited practice draft or exported file: those are separate patient-owned artifacts. Production needs a full retention/deletion contract across copies.

### AI coordination and its limits

`askRumi` uses `anthropic/claude-sonnet-4.6`, confirmed in the live gateway catalog during this build. The chosen model supports tool use; its provider capabilities are metadata, not a compliance agreement. A maximum four-round read-only tool loop can search the permitted sample inbox and compare actual local calendar intervals, then returns `respond` with natural text and at most one optional proposal. It has a 45-second controller deadline, bounded reply text, strict envelope/proposal parsing, current-operation ownership and no scripted-success fallback.

The latest user turn is included explicitly. The request uses up to 18 recent complete conversational turns after the current privacy/history boundary. Patient-confirmed memory, permitted synthetic care facts, selected observations and explicitly selected workspace content support continuity. The source allowlist is formed from the evidence actually supplied or returned by a read, not all imaginable sample documents. A tool result cannot send, book, approve, place an order or modify clinical data.

The AI can offer a source/planning surface, editable visit question, practice message, confirmed memory or nonclinical support step. It never automatically accepts a proposal. Patient edits persist; dismissing a proposal is distinct from an executed external outcome. Every direct form remains available without AI. An interrupted or failed question remains recoverable across reload. Cancellation prevents late output from changing another operation, but cannot prove that a remote model ceased processing.

The response-pace field can be changed directly or from an explicit ordinary-language request interpreted by AI. Brief/practical mode reduces simultaneously presented planning choices and support fields while leaving “more detail” available. The model is instructed to address stated barriers, accept corrections/refusal and avoid hidden profiling. These semantic behaviors are **prompt guidance plus inspected examples**, not a validated behavioral treatment or deterministic clinical safety engine.

### Legacy web boundary

`web/src/sano` is retained at `/legacy`, including broad care, records, medications, Currents, Journeys, Life, reports, billing and original pathways. Its `sano.web.v1` and `sano.web.v1.demo.<pathway>` data are neither read nor migrated by PriviaProvider. Do not mount both providers in the same patient workspace.

Legacy risk items remain: generic Marcus facts across some pathways, local “paid/sent/booked/delivered” handlers, script-based symptom triage, simulated watch/listen progress and old chat fallback/current-turn/interruption defects. Existing temporary voice reads older Functions configuration/fallbacks. The new Privia app does not import that AI/store layer, and these flaws must not be described as corrected across the entire web app. Preserve earlier work for audit, but gate or replace every affected handler before any production release.

## 4. Native iOS architecture and implementation

### Entry, model and navigation

`NudgeApp.swift` creates the central `@Observable AppModel` and injects it into `ContentView.swift`. Content routes to active onboarding or `Views/RootView.swift`. `ViewModels/AppModel.swift` and its Context/CareContinuity/AIConnection extensions own business logic. Four per-tab navigation paths are in memory; `CareRouteView` and `YouRouteView` render typed destinations. Floating Rumi and Log are the native controls; the new web centered-Log placement has not been ported.

Models/fixtures include PersonaFixtures, MarcusFixtures, CareHubFixtures, AgentNetwork and AgentActivity. The four synthetic pathways are metabolic, oncology, procedure and cardiometabolic. Generic Marcus record-category fixtures were restricted to metabolic rather than silently renamed into other patients. The app is still centrally fixture-backed rather than a clinical database repository.

The active onboarding is Welcome → Scenario → optional Records → Preferences. Sign-in is unavailable, not silently successful. The preview leaves active scenario/preferences unchanged. Optional record connection collects editable synthetic demographics, scopes and consent, then produces a local demo import snapshot. Demographic matching is not authorization and this is not Fasten OAuth.

### Durable data and review

`Services/PersistenceService.swift` uses scenario files `Documents/sano_demo_<pathway>.json`, ISO dates, atomic writes and complete-file protection. Legacy `sano_user_data.json` is a same-pathway fallback, not a comprehensive database migration. A corrupt scoped snapshot is protected from overwrite. Persistence failure blocks scenario/provider switching. Photos and some preference/UserDefaults fields have different lifecycles; scenario separation does not establish tenant/account isolation.

`CareContext` carries selected-item identity, source and snapshot into an inspectable composer before explicit Send. Edited contextual questions have keep/replace review. `ReviewedWorkflow` supports Draft, Reviewed · not sent and Declined; editing recipient/content invalidates review. Origin/context lookup reopens existing work rather than manufacturing another completed action.

`AppointmentPrep` ties Focus/Changes/Questions/Review to an exact visit. Missing/cancelled appointments fail closed. Questions must be accepted explicitly from AI. Autosave, save-failure reporting and invalidation after edits/rescheduling are preserved. Reviewed export is a text ShareLink, not an EHR receipt or clinician-authored note.

HabitSupportPlan stores reason, cue, barrier, fallback, confidence, pace, paused and updatedAt. Habit check-ins support replaceable daily status and undo. The inspected native `pace` field has no discovered behavioral editor/consumer; the temporary prompt includes habit title/cue/barrier/fallback, not the full reason/confidence/pace/check-in history. Do not infer the new web response-density behavior exists natively.

### Native AI router

CompanionEngine → ChatTransport → RumiAIRouter selects CompanionAI or RumiWebSocketTransport. Visit question drafting uses the same router. Temporary AI remains the default. Per-scenario/provider/configuration workspaces retain turns, composer, context and separate client IDs; legacy chat migrates only into Temporary AI. Changed backend endpoint/host session produces a fresh workspace; older backend conversations are read-only archives ordered using savedAt.

Provider changes stop work, save outgoing state, restore the selected workspace and abort on persistence failure. Backend host session/JWT are in memory only and clear on background/provider exit/disconnect/configuration change. SecureField clears on disappearance/background. Backend voice is explicitly unavailable and must not route audio to temporary services.

The dedicated backend text adapter is provisional. It sends only latest explicit text/context, not the native temporary prompt or complete local history. Server system policy, behavioral memory and tool gates remain server-owned. Do not add invented system frames or history replay to imitate interoperability.

### Native voice and release defects to preserve in the gap list

VoiceSession uses AVAudioRecorder/metering, then STT → companion answer → TTS playback. Mode/permission/current-operation checks and text/voice ownership guards exist. Recorded input and generated speech do go to external processors in temporary mode. Source audit identified remaining concerns: temporary audio cleanup, maximum recording duration, cancellation before post-request playback, and microphone wording that implies no external processing. These require targeted correction and device tests before live use.

Other priority native gaps: privacy export is partly placeholder; local deletion does not remove every in-memory/UserDefaults/photo/temp copy and future saves can recreate data; consent-ledger controls do not enforce all outbound processing; editable memory is not comprehensively included in AI context; legacy bills/reports/requests still have local completion claims. Full document scan/OCR/forms/attachments, allergy records, complete reminders and attributable refill calculations remain incomplete. No native code was changed in this web stage.

## 5. Shared intelligence and production ownership

### Current architecture

```text
New web surfaces -> PriviaProvider -> localStorage (Elena demo only)
                         |
                         +-> Rork Toolkit -> Claude (conversation + read-only proposals)
                         +-> local sample sources/events/messages/channel transcripts

Native surfaces -> AppModel -> scenario JSON + UserDefaults
                         |
                         +-> RumiAIRouter -> Toolkit OR provisional Rumi text adapter
                         +-> VoiceSession -> Worker STT/TTS (Temporary mode only)

Worker -> ElevenLabs voice proxy
       -> Fasten public setup lookup + rejecting/disabled ingestion boundary
```

The above is **not** a shared longitudinal clinical brain. The supplied `tmp/nudge-system-writeup.md` describes richer profile/memory/planning/proactive systems that were not verified in this repository. Treat it as architecture input, not as deployed functionality.

### Proposed production architecture — not built

```text
Verified patient session + channel identity bindings + consent ledger
                            |
                    Central Rumi orchestration
                     /        |          \
             Memory ledger  Care record   Action ledger
                     \        |          /
                     Policy + clinical safety gates
                            |
        Read adapters / reviewed commands / receipt reconciliation
           |                 |                 |
      Clinical APIs       Google APIs      Channel providers
                            |
             Versioned state/events back to app surfaces
```

Choose one authoritative owner for patient identity, memory, conversation continuity and actions. If the external Rumi AWS service supplies that role, the web/iOS clients should be authenticated surfaces of it, not two additional conflicting memory engines. If another service owns the clinical record, define clear source IDs, revision/observation semantics and explicit read/write boundaries. Rork's Worker currently supplies neither role.

Proposed domain records should include tenant/patient ownership, appointment/context/source IDs, source version/freshness, consent version, patient-confirmed versus tentative assertion, creation/correction/expiry and deletion policy. Keep rejected inference distinct from confirmed facts; never re-infer a forgotten barrier from stale summaries. Use explicit event IDs and user/channel attribution for history.

Proposed action states: Draft → Proposed → exact-version Approved → Enqueued → Submitted → Provider accepted/Rejected/Unknown → Reconciled. Keep clinical fulfillment, read receipt, clinician review and task completion separate. Approval snapshots should be server-side, tamper-resistant, scoped and expiring. Recheck patient ownership, consent, destination, source version and scheduling constraints at execution time. A changed version requires review; an uncertain timeout requires reconciliation before resubmission. Use durable idempotency and transactional outbox patterns rather than trusting a browser fingerprint.

A production planner may combine read tools, resolve missing prerequisites and offer one next decision. It must not silently turn an expression of distress into an outreach campaign, infer demographic personality traits, or optimize raw attendance/engagement at the expense of agency. Allow pause, revision, practical-only help and conversation with no task. Evaluate clinical and behavioral safety with a qualified team, including overreach, refusal, uncertainty, coercion, crisis, source injection and omission of critical information.

## 6. Endpoint and configuration register

### Existing and provisional operations

| Operation | Request/response contract | Status and boundary |
|---|---|---|
| Toolkit `POST /v2/vercel/v1/chat/completions` | OpenAI-compatible messages, model, optional tools; structured completion for new web, SSE for native/legacy | Real network path. New web uses delegated runtime auth, not a manually exposed secret |
| Worker `/ping` | JSON `{ok:true,now:ISO}` | Historical deployed probe passed; not a patient/session service |
| Worker `POST /voice/stt` | Native/legacy multipart audio forwarded to ElevenLabs; upstream response | Exists, not used by new call transcript preview; source forwarding omits multipart Content-Type boundary |
| Worker `POST /voice/tts` | JSON text, optional model_id/voice_settings; MP3 response | Exists, not telephone connectivity |
| `GET /integrations/fasten/test/status` | Metadata flags, organization status, returnURL, webhookURL; no secret values | Setup-only; privateKeyVerified, authorizationEnabled and importEnabled remain false |
| `GET /integrations/fasten/test/webhook` | Readiness with intake disabled | Does not accept clinical records |
| `POST /integrations/fasten/test/webhook` | Bounded raw JSON + Standard Webhooks signature headers; timestamp/test-mode verification | Invalid signature 401; non-test/missing test mode 422; valid test event intentionally 503 until owned durable ingestion |
| `GET /integrations/fasten/test/return` | Query stripped via 303; clean page states no import | Browser return is not authorization or ownership |
| Fasten `GET https://api.connect.fastenhealth.com/v1/bridge/org?public_id=...` | Public organization lookup only; bounded response, no private-key header, no redirects, timeout | Last reported lookup failed; no confirmed organization/private authorization |
| External `GET <tokenBrokerURL>` | Bearer host session; expected JSON `{token:JWT}` | Provisional native profile, no broker implemented in Worker |
| External `GET <serverURL>/getConfig` | Bearer chat JWT; expected `{identifier,chat_type}` | Current deployment/wire contract not supplied |
| External `WSS <serverURL>/ws/<identifier>-<clientUUID>` | Auth/text/control sequence below | Provisional native text client only, not verified deployed interoperability |

Historical deployed Worker address: `https://research-preview-1-backend.rork.app`, code ID `ac8e0faf28de876c70594248381505a9`. Do not infer that every client's injected Functions URL currently matches this address. Older native/web fallbacks can reference `https://nudge-plus-d9rx5y5-backend.rork.app`. New Privia AI uses the injected Toolkit URL, falling back only to `https://toolkit.rork.com`; it does not call the Worker for simulated channels. The web preview produced by managed validation is `https://8bj7q7lzrlxpwebjl7tla-web.rork.live`; it is a demo, not a production domain guarantee.

### Provisional native wire examples

Placeholders below are **not credentials**. Verify the current backend trace before connecting any patient.

```json
{"type":"auth","value":"<short-lived-chat-JWT>"}
{"type":"flag","text":"1"}
{"type":"control","value":"client_speaking"}
{"type":"text","value":"<explicit latest user input and context>"}
{"type":"control","value":"client_paused"}
```

Incoming `control/server_processing` selects `message_id`; only `data.text` with that ID accumulates. Matching `control/server_paused` completes. `session_expired` allows one same-socket token refresh with the same configuration identifier; it does not replay the user turn. `auth_failed` fails explicitly. Transport opening is not authentication success; an auth ACK is not verified in the provisional profile. There is no reliable server cancellation, resume cursor, native PCM/MP3 duplex voice or deduplication contract.

Native URLs require HTTPS/WSS, reject embedded credentials/query/fragment and redirects, and use ephemeral cookie/cache/credential-free sessions. Opening/reply deadlines and bounded payloads apply. JWT local validation checks shape and remaining lifetime (over 15 and at most 660 seconds), not signature/issuer/audience/tenant ownership. The host/backend must enforce those cryptographically.

### Configuration names — never copy secret values into handoff artifacts

- Public platform bindings: `EXPO_PUBLIC_PROJECT_ID`, `EXPO_PUBLIC_RORK_API_BASE_URL`, `EXPO_PUBLIC_RORK_APP_KEY`, `EXPO_PUBLIC_RORK_AUTH_URL`, `EXPO_PUBLIC_RORK_FUNCTIONS_URL`, `EXPO_PUBLIC_TEAM_ID`, `EXPO_PUBLIC_TOOLKIT_URL`.
- Native/server Toolkit credential binding: `EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY`. Browser builds use short-lived delegated runtime auth; do not manually mint, persist or expose this value in new web code. `web/vite.config.ts` supports the existing EXPO_PUBLIC prefix as well as VITE.
- New demo gate: `VITE_RUMI_DEMO_ENABLED`. Exact string `false` disables new and legacy web entry points; unset remains demo-enabled for the current showcase.
- Server-only: `ELEVENLABS_API_KEY`, `FASTEN_TEST_PUBLIC_ID`, `FASTEN_TEST_PRIVATE_KEY`, `FASTEN_TEST_WEBHOOK_SECRET`, `FASTEN_TEST_REDIRECT_URI`.
- Native settings without credentials: serverURL, tokenBrokerURL, allowsSyntheticTesting and workspace/config ID. Host session/JWT are not persisted configuration.

The public/private Fasten test credential prefixes are accepted with opaque printable suffixes; an earlier restrictive validator was fixed. Format acceptance is not vendor authorization. The endpoint-specific signing secret and redirect registration remain open work. Before real use, replace voice-proxy wildcard CORS/unrestricted caller access, add authentication, size/time limits, rate/abuse controls and sanitized errors; correct multipart forwarding and verify the complete voice pipeline. Do not log tokens, raw clinical bodies or signed callback values.

## 7. Demo-disable and migration runbook

### Web immediate containment

1. Export any demonstration work that must be retained. Treat exports as synthetic artifacts, not patient records.
2. Set `VITE_RUMI_DEMO_ENABLED=false` in the release environment and rebuild. Both Index and Legacy gate before mounting their patient providers. Confirm root, direct `/care`/`messages`/`you`, `/legacy` and reload show Demo disabled and make no AI request.
3. This is a **kill switch**, not a production implementation. The disabled screen truthfully says real patient access is not implemented. Do not remove the Demo label while leaving fixtures/action handlers intact.
4. Add separate authenticated production entry, verified patient association and tenant-bound service repositories. No fallback to Elena/Marcus, initialState or demo browser keys may occur when production fetches fail or return empty collections.
5. Put demo, vendor sandbox and live use in different environments/tenants and storage namespaces. Do not copy turns, source IDs, approvals, synthetic events or imported demo snapshots into a real account. Avoid an automatic migration from `rumi.privia.elena.v1` or `sano.web.v1*`.
6. Remove or build-exclude legacy demo code, development controls and unnecessary public assets from the live release. The current gate disables entry behavior but does not promise all fixture text/assets are absent from the bundle. Code-splitting alone is not authorization.
7. Replace applyLab/applyMessage with authenticated server commands preserving the patient review surface. Do not reuse their local “success” semantics. Derive visible status from provider receipts and reconciliation.
8. Rebuild, clear CDN/service-worker caches if introduced, test fresh and existing browser profiles, blocked storage, revoked sessions, another patient, offline state and restored backups. Verify no Demo action can execute against a real adapter.

### Native immediate containment

There is no complete production-mode switch in the current native app. Onboarding hasOnboarded is not identity. Before distribution to real patients, add a build/environment gate that prevents fixture seeding and demo entry outside an explicitly separate demo environment, then introduce verified sign-in and patient ownership before constructing the production AppModel/repositories.

Preserve scenario files for demonstration only; do not relabel them into a new user. Split global UserDefaults, photographs and transient caches by authenticated owner where appropriate. Implement versioned migration with backup/rollback and corruption recovery. Fix privacy deletion/export and all legacy reports/bills/requests before treating a release as clinical software. Disable the manual host test-session entry in production; replace it with the approved authenticated host flow and Keychain-managed session lifecycle.

### Migration and rollback acceptance

- Empty provider collections remain empty; no default medication, patient, result or conversation is seeded into live use.
- Pending demo approvals and sample receipts never survive a switch into a production account.
- Logout/revocation cancels pending work, disconnects streams, wipes in-memory credentials and prevents another user seeing cached data.
- Server idempotency owns duplicate prevention across devices/retries. The client fingerprint is not a security boundary.
- Rollback must preserve schema compatibility or restore a verified backup; never silently overwrite a newer snapshot with an older fixture shape.
- Document data retention, legal deletion exceptions, upstream processor deletion limitations and notification/call logs. A local reset is not an enterprise deletion workflow.

## 8. Channels, privacy and behavioral contracts

### What the current previews do

SMS and telephone are inside Demonstration controls, not extra daily destinations. SMS accepts synthetic incoming text, clarifies pressure entries without date/time/pair, saves an explicit valid reading and returns an allowlisted nonclinical acknowledgment. STOP/PAUSE/UNSUBSCRIBE disables both outreach channels. A note can resume in the same app transcript; correction is available in Your logs. This is not a bidirectional carrier integration or an SMS identity verification scheme.

The call preview is a transcript interaction using the same conversational state after simulated identity/private-moment confirmation. Rumi identifies itself as AI. It can be interrupted and continued in the app. No audio is recorded, no phone call is placed, and the confirmation button is not production identity verification. Revocation/STOP is checked again at send time. Backgrounding clears the in-memory call verification.

Optional invitation previews require channel permission, no pause/stop, nonquiet Eastern hours and at most one invitation per 24 hours across channels. These illustrative numeric limits are not approved production policy. No scheduler runs in the background, no ignored text escalates to a call, and equal start/end quiet hours conservatively blocks outreach all day.

### Proposed production channel policy matrix

| Channel | Conservative allowed outbound content | Requirements before richer interaction |
|---|---|---|
| App | Detailed patient-controlled records, drafts and source evidence | Verified session/ownership, consent, retention and access audit |
| SMS / email / notification | Neutral invitation/acknowledgment only; no diagnosis, values, medicines or personal concerns | Verified destination, outreach consent, sensitive-input handling, provider/legal review and secure app return |
| Shared calendar | Neutral event title and approved time only | Correct account/calendar, least-privilege write scope, review and provider receipt |
| Telephone | AI identification and privacy/identity check; neutral voicemail only | Verified answerer, private moment, current consent, recording policy, safe handoff and opt-out |
| Apple business messaging | Separately approved business-messaging conversation | Approved provider/business setup and platform policies; not arbitrary outbound personal iMessage |

An app-return link must contain no clinical text, carry only opaque bounded state and never grant access without authentication. Consent must be checked at enqueue and immediately before delivery. Revocation stops queued work and future model/tool access. Log the minimal delivery metadata, not sensitive content. Handle shared phones, recycled numbers, forwarded links, unknown answerers, voicemail and wrong recipients explicitly.

Sensitive inbound SMS must not be reflected back in an outbound acknowledgment. Define identity uncertainty, intake storage/retention, human escalation and secure transfer. A neutral message is not safe merely because it omits a diagnosis if the sender or timing itself exposes a relationship. Privacy/security/clinical/legal owners must approve the entire workflow, vendors, BAAs where applicable, outreach and recording consent—not only the UI text.

### Behavioral acceptance examples

- “Only the address”: provide the supplied address or say it is missing; no feelings interview, calendar search or proposed habit.
- “I keep putting it off”: allow explanation; do not assume motivation, fear or an appointment preference.
- “I felt faint last time”: take the concern seriously and offer an editable question about available support; no invented assurance of safety or confirmed accommodation.
- “That’s not why”: accept correction, discard the rejected interpretation and do not preserve it as established memory.
- “Not now”: stop proposing. A patient may pause support while still logging or chatting.
- “Make it smaller”: adapt an optional practical step, not prescribed medicine/monitoring. A notebook placement or a question can be enough.
- After a gap: resume agreed work without guilt or inferred adherence. Nonresponse is not consent to intensified outreach.

Production evaluation should measure correct restraint, useful continuity, source fidelity and patient agency, not only action completion. Human review should include brief and verbose requests, changing goals, clinically urgent exceptions, uncertain data, adversarial source text, accessibility and channel transitions.

## 9. Design language and asset reuse

### Brand and surfaces

Native brand tokens: mint **#4CC9AB**, blush **#F5BCB5**, butter **#FFE27C**, forest **#00211A**. The new Privia web interpretation uses diffuse tinted washes, fine procedural texture, opaque warm-white clinical/review cards, restrained shadows and forest text. Default card corners are approximately 26px, control corners 16px, main content margins 24px. Tap targets are generally at least 44px; native target is 44pt. Motion communicates active work or button feedback; reduced motion removes animation without removing information.

Liquid Glass is native navigation/control chrome only, with iOS 26 guards and material fallbacks. Clinical details, errors, consent and consequential review must remain opaque and readable. The new web uses translucent dock/control chrome, not simulated glass over clinical text. Its background is CSS, not a newly generated image.

The current new-web companion is a CSS concentric mark. Native RumiMarkView is a native concentric drawing. Existing orb MP4s and Metal visuals are different implementations and should not be conflated. Do not add large decorative AI orbs to every care card.

### Fonts and licensing

- Native registers six Fields Display OTFs named `fontspring-demo-fieldsdisplay-{regular,medium,semibold,bold,extrabold,black}.otf`. Current title helpers select regular/medium/semibold/bold; extra weights are packaged but not necessarily selected.
- Embedded metadata explicitly identifies **FONTSPRING DEMO**, The Type Founders, LLC, designer Adam Ladd. The font zip has six demo OTFs and no production embedding grant. Production app/web embedding rights remain unverified.
- New web imports the existing native regular OTF through Vite CSS; the build emits a content-hashed font asset. This deliberately reuses the same supplied file without silently asserting a license. The repository must contain both web and ios folders for that relative font build path.
- Both platforms also package Fraunces 400/500/600/700 and 400 italic TTFs. Inspected metadata cites The Fraunces Project Authors (2020), the undercasetype/Fraunces project and SIL OFL; add the appropriate standalone notice before release. Native VoiceMode still uses Fraunces italic.
- HermioneFREE.ttf is packaged in both; legacy web uses the Hermione alias. Metadata includes nendeskombet/Sahid and “All rights reserved.” “FREE” in a filename does not prove commercial embedding permission. Native registers it but current main helpers do not select it.
- Rounded body faces fall back to system fonts; names such as Nunito/Quicksand in old CSS are not bundled font files. Screenshot presentation fonts are a separate delivery choice, not the app's type system.

### Asset families and current consumers

Every image family member appears with exact path, size/hash, dimensions and source-token matches in `handoff/asset_inventory.csv`. Native image convention: `ios/Nudge/Assets.xcassets/<name>.imageset/<name>.<ext>`; web images: `web/public/img/<name>.<ext>`. Most shared PNGs are opaque 1024-square art, not transparent cutouts. Condition/Currents JPEGs are typically landscape; recap images are portrait. Packaging metadata `author: xcode` is not artist attribution.

| Family | Representative assets / paths | Consumers and limits |
|---|---|---|
| Food | oatmeal_bowl_blueberries, grain_bowl_chicken_quinoa, grilled_salmon_lemon_greens, vegetable_omelette_plate, lentil_soup_bowl, yogurt_parfait_glass | Both Life libraries, QuickLog and history; new Privia log uses oatmeal only as illustration. Never derive measured nutrients from these images |
| Original activity | terracotta_cream_sneakers, yoga_mat_rolled, dumbbells_towel_wellness, soft_editorial_studio | Legacy web library/history; native seeded histories and Life scenes remain consumers. New Privia Activity uses sneakers as illustration |
| Native specific activity | walking_shoes_stride, hiking_boots_walking_pole, clay_bicycle, water_ripples_goggles, clay_treadmill, clay_stairs_glow; yoga_mat_bolster, clay_figure_stretching, pilates_ring_and_mat, clay_figure_tai_chi, glowing_clay_orb, clay_figure_dancing; clay_dumbbells, resistance_band_clay, kettlebell_clay, leg_quad_extension, hands_supporting_knee; hands_planting_sprout, leaf_rake_with_pile, broom_dustpan, standing_desk_workspace | 21 native-only activity images, LifeModels mappings and LibraryPicker/QuickLog/LifeCatalog. Not automatically present in web |
| Medication | medicine_bottle_tablets, blister_pack_tablets, medicine_bottle_pills | Life/medication resolvers, logged entries and native medication screens. Art is not dosage, dispensing or pill identification evidence |
| Symptom/feeling | belly_stomach_relief, ceramic_bowl_glow, thermometer_warmth, lips_mouth_tender, hand_sparkles_tingling, leg_cramp_muscle, knee_joint_pain, joint_swelling_glow, hinge_joint_clay, clay_head_silhouette_glow, spiral_light_mist, moon_waves_stars_sleep, thread_unwinding_light, soft_editorial_3d, glowing_orb_in_leaves | feelingImage mappings and symptom selection; no clinical classification implied |
| Conditions/editorial | condition_diabetes, condition_chemo, condition_procedure; currents_a1c, currents_father_son, currents_kidney, currents_salt, currents_walk | Persona/condition/Currents screens, not documentation of this patient's family or diagnoses |
| Memories/recap | recap_dawn, recap_garden, recap_path, tree_path_sunset_walk, cozy_dinner_table | Native Recap/Story/Journeys; web garden/path/memories. No current web reference to recap_dawn found |
| Background and unused illustrations | pastel_gradient_glow_bg; calendar_heart_stethoscope, gift_box_sprout, notebook_speech_bubble_star, open_folder_documents | Pastel background is legacy web onboarding; four illustration files have no current static app-source consumer found. Do not delete without checking persisted imageName strings |

Forty-six web images and twelve shared audio files matched same-named native originals byte-for-byte in the source audit. Native has 67 imagesets plus AppIcon/AccentColor. Static token matching is an inventory aid, not reachability proof: dynamic string aliases and saved imageName values matter. Keep legacy aliases until migration is understood.

**Known alias risks:** web `img()` only selects extension. The legacy medication list's `img('med:' + id)` creates a nonexistent path, preventing its intended fallback. Food labels can map tofu to a chicken-bowl illustration or salad to salmon art; numeric facts keyed to those images are not measurements. Correct these before reusing the catalog in clinical/nutrition workflows. Unknown icon strings can fall back to a circle.

### Audio, video, shaders and icons

Audio paths: native `ios/Nudge/Resources`, web `web/public/audio`. Shared files include `music_barley_thunder.m4a` (onboarding), `music_stone_kintsugi.m4a` (ambient/legacy recap), `tap_ta_1.mp3` through `tap_ta_5.mp3`, sfx_bloom, sfx_whoosh and sfx_glass. `sfx_tick.mp3` and `music_ambient_bed.mp3` are packaged with no current resource-name consumer found; native sfx_glass also lacks a found consumer. Native-only `music_recap.mp3` has its own Recap player. New Privia web does not autoplay these beds.

Five orb videos exist at native Resources and `web/public/orb`: orb_day.mp4, orb_night.mp4, orb_speak.mp4, orb_think.mp4, orb_bloom.mp4. They correspond to ambient, dark ambient, speaking/listening, thinking and celebration states in legacy web Orb/native VideoOrbView. New Privia uses the lightweight mark instead. Source-copy aliases and processing are retained in `tmp/assets/process_orbs.py`: original orb_day/orb_1/orb_colorful/orb_sphere2/orb_check → day/night/speak/think/bloom. Processing crops/resizes to 540-square H.264 and strips audio. The probed day file is 30fps/5 seconds; do not assume all clips have the same duration without ffprobe.

Native `Shaders/Effects.metal`, `LivingGradient.metal`, `Orb.metal` support procedural surfaces/visuals. Web LivingGradient/DataViz are separate CSS/SVG implementations, not shared Metal code. Native SubjectLifter provides runtime image lifting; it is not provenance or OCR of clinical records.

Native AppIcon is `Assets.xcassets/AppIcon.appiconset/icon.png`. Web `public/icon.png` and `favicon.png` are separately referenced in index.html and have different hashes. Brand delivery references are `tmp/brand-delivery/LInden - Green V1 01.jpg` through 04.jpg; the latest 02 image was directly inspected. They are visual references, not runtime backgrounds. Native captured originals, presentation slides and screenshot backgrounds live under `screenshots/`; an accepted slide is defined by its ledger, not by the presence of a PNG.

## 10. Asset generation and delivery procedures

### Provenance and reuse first

The project asset library reported 58 image assets with durable uniqueKeys and R2 URLs (the captured key register is [library_assets.json](handoff/library_assets.json)); it reported no library audio/video/3D records, although audio/video files are physically bundled in this repository. Never conclude “no asset” from one registry alone. The library does not expose all original generation prompts in its listing; original prompts/model revisions/rights are not fully established. Record unknown provenance rather than reconstructing it as fact.

Existing library assets can be addressed by their returned R2 URL or the project alias pattern `https://rork.app/pa/8bj7q7lzrlxpwebjl7tla/<uniqueKey>`. Original image generator metadata and manual transformations should be collected into a rights/provenance register before release. Do not regenerate equivalent images just because a legacy alias differs; inspect library, local files, hash and call sites first.

### Repeatable future image workflow

1. State the asset's job and target surface, not just an aesthetic. Choose dimensions, opaque versus alpha background, focal placement and safe crop. For care, avoid misleading anatomy, implied treatment claims or image-derived numeric facts.
2. Read the project's asset-library and assets skills. Use `listExistingAssets` first. For new art use `generateImageAsset`; for app icons use `generateIcon`, not the image asset tool.
3. Describe warm tactile editorial art, mint/blush/butter/forest context, soft light, no text/logos and the subject needed. This is a **future prompt template**, not a recovered original prompt. Obtain rights/clinical review appropriate to the use.
4. Schedule independent generations in the background, continue coding and wait for all generation IDs together. Retain tool/model/date/prompt, references, returned uniqueKey/URL, chosen variant and reviewer decision.
5. Inspect actual output at UI size, contrast/crop/alpha and unintended artifacts. Optimize without overwriting the only master. Record the master-to-derived transformation and hashes.
6. Native: bundle only selected images through the supported asset-saving flow; use asset names and size-anchored SwiftUI overlays for aspect-fill imagery. Audio/video belong in Resources. Synchronized folders discover source automatically; avoid duplicate project entries.
7. Web: save a new versioned filename under public or import from src for content hashing. Do not overwrite a stable public URL and assume browsers refresh. Update all references, test loading/crop and run web checks. Do not assume native-only art exists in public.
8. Preserve existing aliases if persisted logs reference them. Add accessible labels where imagery conveys meaning; mark purely decorative art accordingly.

### Audio, video and screenshots

Use the audio generation workflow for intentional sound/SFX/voiceover, retaining text/voice permissions and versioned source. Keep informative sounds optional and never the only status indication. Do not invent an original composer/model from a filename. For orb animation retain original clips, crop script, codec/alpha/audio choices and state mappings. Check looping, reduced-motion alternative, memory use, lifecycle pause and no unexpected audio.

Use `screenshots/capture_privia.py` for the independent web chapter: a fresh browser profile, fixed viewport, actual control interactions, synthetic input and no fabricated live-AI answers. Wait for transitions before capturing. Captions identify the patient decision and local outcome. Screenshots are dated evidence, not proof of all failure/device/accessibility states. Native capture tools rent a simulator; do not rerun the cancelled batch without authorization. Never replace accepted originals just because a newer deck is generated.

Development-time media generation tools are not APIs available to a shipped patient app. If patients need generated images, nutrition imagery, exercise instruction or voice generation, implement authenticated runtime service access, consent, content/clinical review, storage/retention, cost controls and ownership separately. Media does not establish measured intake, performed exercise or approved medical advice.

## 11. Retained-feature coverage: all 43 rows

This is a scope/implementation matrix, not a claim of completeness. “Native” refers to current source, not fresh device execution. “Legacy web” is retained at `/legacy`; “new web” is the Elena workspace. Production requirements remain in the separate compendium.

| # / capability | Native / legacy status | New Privia web and remaining work |
|---|---|---|
| 1 Welcome Router | Native optional onboarding and preview; legacy scripted onboarding | Direct visibly labeled demo; production routing/auth not built |
| 2 Mobile SMS OTP Auth | Not implemented | SMS preview is not OTP or identity |
| 3 Apple Auth | Not implemented | No Apple login |
| 4 Google Auth | Not implemented | Sample Gmail is not Google sign-in or OAuth |
| 5 Terms & Privacy Consent | Partial UI, versioned legal ledger incomplete | AI/source opt-ins exist; production legal acceptance missing |
| 6 Analytics Consent | Enforcement incomplete | No new analytics integration; consent policy remains work |
| 7 Select Care Pathway | Four native/legacy scenarios | One isolated Elena scenario; earlier scenarios retained separately |
| 8 Records Connection | Native local import demo, separate Fasten setup | Sample record permission; no import or OAuth |
| 9 Notification Consent | Partial preferences | No push; explicit channel-preview permission only |
| 10 Interactive Elements | Broad native/legacy controls | Four routes, centered Log sheet, review forms and accessible controls |
| 11 Crisis/Self-Harm Handoff | Prompt/rules, dedicated approved workflow incomplete | Safety prompt/generic urgent-help notice; no validated triage/human service |
| 12 Visible Editable Memory | Native notes editable, AI enforcement incomplete | Confirm/edit/forget memory affects payload boundary; not hidden profiling |
| 13 Agentic Action Cards | Native reviewed-not-sent workflows; legacy overclaims remain | Read-only tools, one proposal, editable acceptance and local reviewed actions |
| 14 Sponsored Responses | Sponsored chat intentionally inactive | Not introduced; do not mix commercial persuasion with care |
| 15 Relevant Card Stack / Thread | Native Today/Thread; legacy moments | Continuing conversation and saved plan, not agent roster |
| 16 Needs You clinical alerts | Fixture-derived, not live monitoring | No continuous clinical alerts claimed |
| 17 Tracking Entry Point | Native/legacy QuickLog | Direct BP/symptom/medication/meal/activity log, correction/undo |
| 18 Care Plan | Native fixture plan and habits | Staged source plan plus patient-owned practical support |
| 19 Discussion Guide | Native exact-visit prep/review/export | Exact visit questions, ordering, selected observations and reviewed text export |
| 20 Providers | Native/legacy fixture team | Sample primary care/scheduling recipient choices; no live directory |
| 21 Appointments Mgmt | Native selected appointment; legacy local actions | Explicit reviewed sample date change, invalidated prep linkage; no booking |
| 22 Virtual Visits | Native readiness; legacy fixture links | Not added; no real telehealth connection |
| 23 Messaging | Native drafts/workflows; legacy local threads | Reviewed sample messages, distinct AI transcript and staged practice response |
| 24 Forms | Partial native/legacy metadata | No production forms/attachments/scanning workflow |
| 25 AI Companion, Atomic Habits & Journeys | Native chat/router/habits; legacy broader Journeys | Real AI path, remembered preferences, personal plan, pacing, pause and check-in |
| 26 Medications with AI support | Native selected med context; legacy fixtures | No verified med list; free-text taking log and questions only |
| 27 Medications Sponsored Pages | Native/legacy optional example pages | Retained separately; no savings/eligibility application |
| 28 Immunizations with AI support | Native record context | No new immunization history invented |
| 29 Documents with AI support | Metadata/context; real scans incomplete | Source evidence only, no absent document OCR claim |
| 30 Notes with AI support | Native supplied note context | Patient guide/support notes; no clinician-authorship claim |
| 31 Vitals with AI support | Native series/context | Dated BP entries and selected context; no device sync |
| 32 Labs with AI support | Native fixture series/context | Staged order evidence, no released-result trend fabrication |
| 33 Conditions with AI support | Native condition/context | Only selected two-condition synthetic scenario |
| 34 Allergies / other clinical information | Allergy-specific workflow incomplete | Missing records remain missing, never “no known allergies” |
| 35 Sponsored Programs | Native/legacy illustrative programs | Not added or enrolled |
| 36 Symptom Tracking with AFB | Native/legacy scripted support rules, not validated AFB | Direct symptom description; no new automated triage |
| +1 Unified longitudinal record | Partial fixture categories; reconciliation incomplete | Small linked evidence set, not full longitudinal FHIR store |
| +2 Pre-visit brief to EHR | Native review/text export; delivery unavailable | Reviewed guide export; no EHR sending |
| +3 Priority provider messaging | Drafts, no promised response | Review and local sample outcome; no priority clinical SLA |
| +4 Results viewing | Native fixtures; Fasten ingestion gated | Order/evidence only; no live results |
| +5 Privia scheduling/rescheduling | Live vendor service unavailable | Reviewed sample change; actual scheduling/receipt still required |
| +6 In-app care-plan reminders | Native management incomplete | Saved personal-plan time shown in Today; no scheduler/push/snooze engine |
| +7 Medication-derived refill tracking | Calculation basis incomplete | Not added; requires dated supply/dose verification, no complex pharmacy scope |

## 12. Verification and release gates

### Evidence recorded in this stage

- New web source and legacy integration were type-checked and passed the managed static checks/build. Earlier failures (Zod nullability/compiler settings, stylesheet layer scope, missing local Functions dependency and two test option typings) were corrected, not waived.
- The complete web runner passed **68 tests** at the final checkpoint: **39 new Privia tests**, one demo-disable regression, ten existing navigation, one calendar, one trivial baseline and sixteen Fasten boundary cases. These include mocked AI responses, not proof that every semantic response is safe.
- The browser capture journey ran against a fresh local Chromium instance at 390 × 844, 2x scale. Twelve key screens were captured via real UI interactions, with zero page errors and successful reload/transcript restoration. Final capture/visual evidence is in its manifest; no native capture was replaced.
- Native was inspected, not rebuilt/tested in this web stage. Historical latest native evidence is **42 selected tests / 86 seconds**, preceded by 39/59s and earlier runs; do not present these as newly executed. Source has 38 unit-test declarations, eight behavioral UI methods and one launch method. A unit suite includes a configured live synthetic gateway smoke, so it is not completely offline.
- Historical Fasten deployed probes verified `/ping`, status/readiness, unsigned webhook rejection and return stripping. No new end-to-end Fasten/private backend/channel production verification occurred here.
- Two live synthetic browser replies returned HTTP 200: the first did not jump to scheduling when asked not to; the second produced an editable practice-message proposal about a stated past faintness concern. No action was applied. Their exact outputs and two supplementary captures are recorded in `handoff/live_ai_verification.json`. The sandbox browser initially could not trust the platform token endpoint's certificate chain; the successful check used a disposable browser-only certificate override. No app TLS/authentication code was weakened, and production certificate/device verification remains separate.
- Four viewport checks (320×740, 390×844, 768×1024, 1365×900) passed horizontal overflow, Escape dismissal and log-draft recovery checks. See `handoff/browser_verification.json`. This is not a full accessibility evaluation.
- The actual DOCX was rendered using LibreOffice and checked for complete section coverage, 43 feature rows, embedded screenshots, local links, asset hashes and page text bounds. Contact sheets were inspected for layout. `handoff/verification.json` records final artifact hashes/counts; generation alone is not clinical or regulatory approval.

### Platform-specific release checks

**Web:** enforce verified session/ownership, secure service access, no fixture fallback, CSP/cookie/CSRF policy, no PHI localStorage, redirect/deep-link validation, dependency/security review, rate/cost controls and consent before network. Check Safari/iOS keyboard viewport, Chrome/Android, desktop browser sizes, reduced motion, 200% text/zoom, keyboard/focus order, screen readers, contrast and offline recovery. Full browser/device accessibility breadth is not certified by the current Chromium journey.

**Native:** physical iPhone/iPad and Release/archive verification, iOS 18 and current iOS compatibility, privacy labels/manifests, permission strings reflecting external processing, background/audio lifecycle, microphone interruption, complete export/deletion, Keychain/session controls, source/recipient review and no legacy false-send/payment states. Verify font/media licenses and app-store review requirements. Simulator tests do not establish physical-device voice or production readiness.

**Backend:** verified tenant/patient mapping, object authorization, secure credential storage/rotation, encrypted durable record/memory/action stores, ingestion deduplication, consent/audit trails, token lifecycle, request size/time/rate limits, provider receipt reconciliation, bounded retries and dead-letter recovery. Approve monitoring, backups/restore, incident response and access review. Assign explicit operational ownership before scheduling outreach or monitoring clinical values.

### Prioritized production backlog and owners

| Priority | Work | Accountable role / acceptance |
|---|---|---|
| P0 | Verified identity and separation of Demo/vendor-test/live | Security/backend: cross-tenant tests, no fixture/account crossover |
| P0 | Clinical/privacy/legal scope and processor agreements | Clinical, privacy and legal: documented approval, not inferred from code |
| P0 | Replace legacy false outcomes; correct privacy deletion/export and voice exposure | Platform leads/security: end-to-end failure/revoke tests and truthful status |
| P0 | Font/media rights | Product/legal: production embedding and media permissions recorded |
| P1 | Central memory/orchestration and durable action ledger | Backend/Rumi service owner: revision, consent, cancellation and idempotency contracts |
| P1 | Owned Fasten authorization/ingestion and clinical API adapters | Integration lead: signed owned delivery, corrections/duplicates and receipts |
| P1 | Privia/athena messaging, scheduling, briefs | Integration/clinical operations: capability-by-capability vendor confirmation |
| P1 | Google consent/token/scopes/verification | Integration/security: read/write least privilege, token revocation, account/recipient binding |
| P1 | SMS/telephone/business messaging | Channel/privacy owners: provider setup, consent, identity, quiet hours, STOP, handoff and no sensitive previews |
| P1 | Clinical/behavioral evaluation | Clinical/product research: source fidelity, uncertainty, refusal, safety escalation and agency |
| P2 | Broader feature parity, documents, forms, reminders/refill basis | Platform leads: direct complete routes plus failure/recovery tests |
| P2 | Cross-platform accessibility, device/Release and operations | QA/release: recorded devices/browsers, rollback, monitoring and incident drills |

## 13. Key web screens

These are actual web captures, not native device screenshots or fabricated provider outcomes. The saved chapter is separate from previously accepted native slides. Captions distinguish the source, patient choice and local result. A manually entered sample concern in a practice draft is not evidence of live AI generation. The two live-AI screenshots at the end are a supplementary fresh-browser concern → editable-draft episode, identified in the separate live verification report. They do not pretend to be part of the manually prepared control walkthrough.

<!-- screenshots -->

<!-- pagebreak -->
## 14. Complete packaged-asset register

The register is generated from local files after the written audit. It complements the family-level usage and licensing notes above. Source consumers and hashes are available in the adjacent CSV; unused status is conservative because persisted/dynamic references can exist. Remote asset-library items not bundled locally are separate from this register.

<!-- asset-register -->

## 15. Reference hierarchy and QMS boundary

For implementation claims, use current source, actual executed results and this handoff's verification artifacts. Requirements describe intended behavior, not necessarily shipped behavior. Later dated continuations supersede conflicting historical sections, but not clinical/privacy release gates.

- [Functional requirements](RUMI_REQUIREMENTS.md): intended 36 retained features plus seven additions and shared constraints.
- [Working re-scope](RUMI_RESCOPE.md): implementation decisions and historical continuations.
- [As-built audit](RUMI_AS_BUILT.md): implementation history; older palette/dependency/test tables contain superseded statements.
- [Feature and screenshot library](RUMI_SCREEN_LIBRARY.md): all 43 rows, native capture acceptance and new web chapter pointer.
- [Accepted native ledger](screenshots/library-captures.json): twenty accepted pairs and ten excluded staged originals.
- [New web ledger](screenshots/privia-web/manifest.json): actual chapter source, captions and verification scope.
- `tmp/nudge-system-writeup.md`, chat portal PDF and behavioral-intelligence references: supplied external architecture, not repository deployment proof.
- `tmp/brand-delivery/LInden - Green V1 02.jpg`: directly inspected style reference.

Rork manages repository synchronization. The deliverable is the actual checked Word artifact plus reproducible source and evidence saved in the repository workspace. Do not claim a manual commit or remote push without observing that managed delivery evidence; neither was performed by this agent.

This is a functional requirements document intended to give Design and Engineering a working starting point. It is not a formal traceable requirements record. Traceable product requirements (MRD/SRS) for regulatory purposes are maintained in Greenlight Guru, the official QMS system of record.
