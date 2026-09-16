# Rumi — Re-scope proposal for review

## Contents

- [Purpose and approval boundary](#purpose-and-approval-boundary)
- [Sources and confirmed decisions](#sources-and-confirmed-decisions)
- [Product direction](#product-direction)
- [Complete attachment scope](#complete-attachment-scope)
- [Retained signature experiences](#retained-signature-experiences)
- [Proposed information architecture](#proposed-information-architecture)
- [Signature end-to-end journeys](#signature-end-to-end-journeys)
- [Dependencies and sequencing](#dependencies-and-sequencing)
- [Release boundaries and unresolved decisions](#release-boundaries-and-unresolved-decisions)
- [Review and document ownership](#review-and-document-ownership)

## Purpose and approval boundary

This proposal turns the attached re-scope into a coherent patient experience while preserving Rumi's companion, small habits, contextual insights and visible agentic help. It separates requested capabilities from the existing prototype and recommends how to complete journeys rather than add disconnected screens. It is a **document for review**, not permission to change the app, implement integrations, process real patient information or ship a clinical product.

The three review documents have distinct ownership:

- [As-built reference](RUMI_AS_BUILT.md): what the current source actually does, including design/construction, assets, demo wiring, defects and production gaps.
- **This proposal:** scope, retained experiences, proposed structural information architecture, dependencies and unresolved product decisions.
- [Functional requirements](RUMI_REQUIREMENTS.md): proposed testable behavior, feature by feature, with edge/blocking states and explicit open questions. It does not duplicate the current design specification.

No application code, visual design, assets, configuration or dependencies are changed by these documents. The earlier polish plan remains historical context; its demo-only external actions are not automatically promoted to production commitments.

## Sources and confirmed decisions

### Attachment evidence

The original files were downloaded directly and the Word document's paragraph/table text was extracted, rather than relying on a web-reader summary.

- **rumi re-scope.docx:** [original attachment](https://r2-pub.rork.com/attachments/nitdpu5h7tpnl9lddpjk2.docx), 15,230 bytes; SHA-256 `cdabc82c6d9b0d60500fc5d68f51a3e6612d0cb8926f5d416b66ddb0f9862135`.
- **SKILL (1).md:** [original guidance](https://r2-pub.rork.com/attachments/af18ygma9iqe3h088cc6e.md), 22,739 bytes; SHA-256 `65edb9223c812137ff0d8ad683c933c2ec2c6bc6b3643fabafa366d3e534d1db`.
- **Source audit baseline:** `e11670626f181a73c120118d28eb9d09d3a960ac`, September 16, 2026. Detailed evidence is in the as-built reference.

The re-scope begins: “Net new/rescoped features below. But also retain the key features around AI, agentic AI etc from previous build –”. It then lists **36 feature names in one table**. It does not supply detailed rules, thresholds, priorities, integration vendors, launch country, commercial agreements or acceptance criteria. The proposed behavior below is therefore a reasoned draft, not text falsely attributed to the attachment.

### Confirmed in this review

- Exactly **three review documents** are requested. The requirements document will be a feature-by-feature compendium, an explicitly approved packaging exception to the guide's separate-page-per-feature rule. Its linked feature index serves the review; later Confluence publication must reconcile existing pages rather than create duplicates.
- “AFB” in Symptom Tracking means **both AI-generated and rules-based feedback** for this scope. No unsupported expansion of the acronym or clinical thresholds is assumed.
- Work is documentation-only until user review/approval; preserving signature AI/agentic experiences is mandatory.
- Tone should remain intimate, empathetic, intelligent and human, with agent work visible without overwhelming existing features; iOS and web should be functionally consistent.

### Guidance applied

The requirements compendium follows the attached guide's TOC → one-paragraph Summary → meaningful feature sections with conditional user stories, testable acceptance criteria, condition tables, explicit blockers, and closing QMS note. It avoids invented requirement IDs, ticket links, dev-handoff banners, changelog and a test-case section. It does not prescribe architecture, visual layout or literal in-app copy.

By the guide's organizational convention, **future visual specifications and in-app UI copy belong in Figma**, and implementation choices belong to Engineering. This avoids competing specifications and stale copy after design iteration. Supplied approved marketing/legal/compliance copy, including SMS/push content, may be captured verbatim; none was supplied here. Jira stories must link to requirements, not the reverse, so later ticket decomposition cannot make this document's references stale. The as-built document may record existing visuals/code because its purpose is forensic recreation, not a competing future PRD. No Confluence/Figma access or current authoritative IA page was available; these repository drafts must be reconciled with any live pages before publication. Functional information and source references are not a claim of regulatory traceability; Greenlight Guru remains the QMS owner under the supplied guidance.

## Product direction

### The central experience

Rumi should help a person move from **understanding → choosing → acting → seeing the true outcome**. Conversation is the connective experience, not an alternative application that forgets which medication, symptom, result or appointment the person was viewing. Conventional records, forms and provider workflows remain accessible without requiring chat.

The re-scope should not turn Rumi into a generic chatbot with portal links, or a clinical dashboard with an ornamental orb. A person can enter through a real-life concern; Rumi identifies the relevant evidence, explains what it can and cannot know, helps prepare a concrete next step, and records whether that step is only drafted, awaiting permission, actually submitted, completed or unsuccessful.

### Proposed functional principles

- One consistent patient context across conversation and feature screens; never substitute persona fixtures for missing patient data.
- Every factual clinical explanation can be traced to a source/date, with user-entered and AI-generated information identified separately.
- The user can inspect and correct remembered context; forgetting something affects future personalization rather than only removing a chip.
- Routine coaching can be conversational; clinical urgency and self-harm handoff require approved rules and defined fallback behavior independent of model availability.
- No consequential external action is described as completed until supported by the receiving service's outcome. Permission, submission and completion are separate events.
- Existing local affordances stay useful when a service is unavailable: save a draft, review a guide, log a symptom, inspect an old record. No fabricated connection or delivery fills the gap.
- Sponsorship is disclosed and separated from clinical relevance, user autonomy and safety; declining does not block ordinary care.
- Both platforms use the same behavioral contract. Platform-specific limitations must be named instead of hiding them behind a success animation.

### Creative direction — non-binding for later design consideration

Preserve the personal, reassuring character: the companion feels present, small actions feel acknowledged, progress avoids guilt, and the day has an intentional end rather than an endless feed. Preserve the recognizable orb, editorial world, meaningful motion and rich logged objects where they serve comprehension. These are inputs to Design, not acceptance criteria for color, spacing, composition or animation. No new screen layout is approved here.

## Complete attachment scope

Feature names below preserve the attachment's groupings. “Needs You'” retains its source wording; presentation wording can be normalized later in the design source. Every row owns a same-named section in [the requirements compendium](RUMI_REQUIREMENTS.md). Status is relative to current code, not release readiness.

| Attachment feature | Existing baseline | Proposed scope and companion connection |
|---|---|---|
| Welcome Router | Local onboarding flag only. | Route by verified identity and required onboarding/consent state; preserve intended destination without exposing another user's data. |
| Mobile SMS OTP Auth | Phone button advances; no number or code verification. | Real phone verification/session/recovery boundaries, with delivery, expiry, resend and abuse states defined. |
| Apple Auth (SSO) | Apple-labeled continuation only. | Verified Apple identity, account linking and cancellation/revocation handling; no invented name/profile data. |
| Google Auth (SSO) | No working Google sign-in. | Verified Google identity/account continuity on supported platforms, separate from granting Gmail/Calendar scopes. |
| Terms & Privacy Consent | Epsilon preference and descriptive ledger are not this feature. | Versioned legal acceptance and transparent AI/external-processing disclosure; meaningful required versus optional choices. |
| Analytics Consent | No enforceable analytics permission flow. | Separate optional analytics decision with actual effect, withdrawal and approved event/data boundaries. |
| Select Care Pathway | Four fixture worlds. | Retain four scenario concepts but let a real patient identify care context without replacing their record; clinician-confirmed versus self-reported distinguished. |
| Records Connection | Mock provider/Health flows, fixed source labels. | Identity-matched source connection, selective permissions, fresh/stale/disconnected states, source conflicts and manual alternatives. |
| Notification Consent | Preference UI without OS/delivery pipeline. | Purpose-specific app preference plus OS permission, safe previews, quiet hours and approved urgent-exception policy. |
| Interactive Elements (buttons, cards) | Many controls work locally; several dead ends or false success states. | Consistent keyboard/assistive interaction, cancellation/back/recovery, correct entity targeting and action state across all surfaces. |
| Crisis/Self-Harm Handoff | No complete verified workflow. | Approved recognition and localized handoff, independent fallback and honest contact status; no diagnosis or assumed rescue. |
| Visible Editable Memory | Native add/forget notes; no full editor/web equivalent; restore defects. | Inspect source/context, edit/delete remembered information, control future use and explain limits for previously transmitted/clinical records. |
| Agentic Action Cards | Local approval/resolution, sometimes success after decline. | Review exact action/data/recipient, authorize or decline, execute only with capability, reconcile actual status and receipt. |
| Sponsored Responses | Program disclosure and prompt conventions. | Clearly identify sponsored conversational content, distinguish neutral options and prevent commercial content from displacing safety. |
| Relevant Card Stack ("Thread") | Up to three fixture-driven moments; some generic targets. | Bounded, relevant next steps with exact context, reasoning, dismissal/deferral and truthful task status; not a new infinite feed. |
| Needs You' Clinical Alerts | Local unread/result/supply/bill/visit aggregation; result acknowledgment unwired. | Evidence-based attention with severity/source/time, exact destination, durable acknowledgment and a distinct unresolved-care state. |
| Tracking Entry Point | Generic plus and contextual med log; unreliable Life shortcut. | Unified entry to symptoms, medication taken, meals/activity and proposed vitals, preserving context and return path. |
| Care Plan | Read-only fixture plan and partial journey derivation. | View clinician-authored plan/provenance; ask about it; derive user-chosen behavioral habits without rewriting treatment instructions. |
| Discussion Guide | Local add/resolve/delete; send-only flag. | Patient-controlled questions/observations from any feature, editable and appointment-linked, with reviewable sharing through real supported channels. |
| Providers | Fixture people, one shared office call. | Correct provider identities/contact/capabilities, provider-specific context and appropriate visit/message/report destination. |
| Appointments Mgmt | Local confirm/reschedule, no service or complete booking/cancel path. | Browse and manage supported visits with provider confirmation, timezones/conflicts, selected-visit prep and status history. |
| Virtual Visits | Windowed placeholder URL handoff; weaker web gating. | Verified visit-specific joining, provider/platform readiness rules, cancellation and unavailable-link recovery; scope of hosted video remains open. |
| Messaging | Local care threads and portal drafts; multiple disconnected send buttons. | Unified patient communication with recipient/category/source attachments, reviewed sends, real delivery or explicit portal handoff and retry. |
| Forms | Request kind/document type, not completion flow. | Obtain, complete, validate, review and submit provider forms; draft recovery and receipt, no fabricated answers. |
| AI Companion Atomic Habits & Journeys | Visual garden and local habits/programs; progress not durable. | Co-create small habits from patient goals/plan, confirm/edit/pause them and preserve actual history; avoid guilt or clinical instruction invention. |
| Medications (w/ AI support) | Fixture list/detail, symptom links, scripted refill cards. | Explain reconciled meds with source/date, log actual taking/barriers and prepare approved refills/questions; never autonomously change dose. |
| Medications Sponsored Pages | Savings/program seeds, no dedicated operational pages. | Disclosed medication support information and neutral alternatives; approved safety/eligibility and explicit data-use application flows. |
| Immunizations (w/ AI support) | Generic raw-record category. | Read and understand documented immunizations; clarify missing/conflicting evidence, prepare questions; recommendation rules need approved authority. |
| Documents (w/ AI support) | Typed metadata and fixture fields; no scanning/extraction pipeline. | Real source upload/capture where supported, readable original, reviewable extraction and grounded explanations; no silent record writes. |
| Notes (w/ AI support) | Raw-record category, Guide items and memory are separate. | Patient note capture/editing and source-labeled clinical notes, AI summaries/questions with original retained; explicit sharing boundary. |
| Vitals (w/ AI support) | Existing lab-like display, no dedicated vital workflow. | Supported manual/connected readings with units/timestamps, grounded explanation and approved alert rules. |
| Labs (w/ AI support) | Fixture trends/explanation, partial report use. | Dated sourced results with units/ranges/status/conflicts, explanation and guide handoff; no unsourced diagnosis. |
| Conditions (w/ AI support) | Fixture conditions/phase view. | Clarify current/history/self-reported conditions, source and care-plan context; support understanding without diagnosing. |
| Allergies and other clinical information | No dedicated allergy workflow. | Structured allergy/reaction/status evidence and correction pathway; define the otherwise unbounded “other” list before implementation. |
| Sponsored Programs | Local offers/enroll/decline and disclosure. | Governed eligibility/disclosure, independent neutral options, reviewable enrollment/data consent, real receipt and durable decline. |
| Symptom Tracking w/ AFB | Native scripted support + separate AI conversation; web similar fragmented flows. | Persist a correctable symptom entry, apply approved rules and contextual AI feedback, prioritize safety, then Guide/message/handoff with true outcomes. AFB includes both feedback types, as confirmed. |

## Retained signature experiences

The attachment's retention instruction is broader than its feature table. The following are explicitly retained in this proposal, not silently removed because their names are absent from that table. Existing external simulations remain simulations until independently approved integrations are delivered.

| Existing experience to retain | What remains valuable | What must change before a production claim |
|---|---|---|
| Contextual text companion and voice | Persistent conversational continuity across record, symptom, medication, content and task contexts. | Correct web current-turn bug; permitted/sourced context; honest degraded mode; secure working speech transport and cancellation. |
| Orb and omnipresent conversation entry | A recognizable relationship rather than a separate chatbot tab. | Visual mode must not imply recording or execution that is not occurring; accessible alternatives remain available. |
| Visible eight-agent network and Today pulse | Understand what help is available, what is active and what needs permission. | Tasks/services reflect real capability/status; pause/revoke honored; no seed text passed off as background monitoring. |
| Per-recipient reports and visit preparation | One coherent brief spanning labs, meds, observations, habits and questions. | Correct patient/visit/time range/provenance; reviewed snapshot and real export/delivery evidence. |
| Bill explanations, wallet and savings | Help with confusing cost/administrative burdens in context. | Payment/eligibility/PII flow requires separately approved providers; simulated paid state never implies a real charge. |
| Connections and cross-channel continuity | Ability to connect permitted context and communicate outside the app where supported. | Feasibility and provider scopes verified; unsupported iMessage/Instagram/etc. claims are not assumed feasible. |
| Story, Insights and lab explanations | Patient-understandable narrative with source/basis, not an unexplained chart dump. | Actual dated evidence, honest statistical uncertainty, durable saves and source-conflict handling. |
| Life gallery, meal/activity/medication logs | Tangible, approachable record of everyday life, including the new activity-art set. | Correctable entries, truthful estimates and accessible alternatives; iOS/web artwork and behavior parity. |
| Light garden and held photos | Positive, guilt-free sense of progress and personal meaning. | Durable habit dates, real supported photo flows and deletion/retention controls. |
| Currents and recap | Finite education, content-to-conversation handoff and reflective narrative. | Real playback/saves/content provenance; do not claim article narration or personalized film from a timer/fixture slideshow. |
| Settings, privacy and data rights | User control of experience, remembered context and data. | Actual export/deletion/permissions behavior, not cosmetic acknowledgements; account-scoped persistence. |

The complete retained functional sections are included after the 36 attachment features in the requirements compendium. They are not delegated to the old legacy document as if its claims were acceptance criteria.

## Proposed information architecture

This is a **proposed text-only IA**, derived from the existing five destinations and the attachment. It is not a new design layout and does not authorize moving screens. No authoritative external IA page was accessible; reconcile this map against any existing Confluence IA before treating it as current. This section owns the proposal's single IA for the three-document review package.

```text
Rumi patient experience (iOS and web)
├── Access and onboarding
│   ├── Welcome routing / intended destination
│   ├── Phone OTP / Apple SSO / Google SSO
│   ├── Required terms and privacy acceptance
│   ├── Care pathway and patient context
│   ├── Records / supported health-source connections
│   └── Optional analytics / notification permissions
├── Today
│   ├── Relevant Thread
│   ├── Needs You attention → exact clinical/task destination
│   ├── Tracking entry → symptom / vital / meal / activity / medication
│   └── Agent pulse → network / reviewable action
├── Care
│   ├── Care plan
│   ├── Providers
│   ├── Appointments → preparation / manage / virtual join / trip
│   ├── Messages → compose / draft / thread / supported portal handoff
│   ├── Requests and forms → complete / review / status
│   ├── Medications → support / questions / sponsored support / refill
│   ├── Reports → recipient / range / review / share status
│   └── Costs → bills / wallet / savings (integration-gated)
├── You
│   ├── Story and Insights
│   ├── Clinical information
│   │   ├── Conditions
│   │   ├── Medications
│   │   ├── Allergies and agreed other categories
│   │   ├── Immunizations
│   │   ├── Vitals
│   │   ├── Labs
│   │   ├── Notes
│   │   └── Documents
│   ├── Discussion guide (also available during visit preparation)
│   ├── Life and tracking history → detail / correction
│   ├── Memory → inspect / edit / forget
│   └── Account and preferences → consent / connections / export / delete
├── Journeys
│   ├── Co-created habits and progress
│   ├── Held memories
│   └── Sponsored Programs
├── Currents
│   ├── Finite content set / saved pieces
│   └── Read / listen / watch → contextual conversation
└── Cross-cutting experiences
    ├── Text companion ↔ voice, with preserved origin context
    ├── Agent network / approvals / execution history
    ├── Crisis and clinical escalation handoff
    └── Recap / source explanation / consent checks
```

A medication reached from Care and the same medication reached from You refer to the same patient entity; they are not separately authored facts. Discussion Guide is one list with optional visit links, not copies per conversation/appointment. Memory remains distinct from clinical records and private notes. Provider/staff systems are external actors/dependencies; a new HCP portal is **not** implicitly included in this patient-app re-scope.

## Signature end-to-end journeys

These describe intended product outcomes for review. Detailed functional behavior and blockers are owned by the corresponding requirements sections rather than duplicated here.

### A concern becomes support, not a dead end

Patient opens tracking from Today or a medication → logs symptom, severity/context and time → saved entry is acknowledged → approved rules assess the entry while AI offers grounded, appropriately bounded support → patient can inspect why, correct the entry, talk further, add a Guide question or review a care-team message → escalation remains available without waiting for AI → any submitted message reports its real status. In combined AFB, AI cannot override the approved safety rule. Exact thresholds and overlapping-risk precedence require clinical approval.

### A result becomes understanding and preparation

Patient opens a Needs You result → sees source/date/status and relevant context → asks what it means → explanation identifies its evidence and uncertainty → patient captures a question in the shared Guide → links it to the right visit → includes it in a reviewed report/message if desired → acknowledgement stops duplicate attention without claiming the clinical matter is resolved.

### A plan becomes one chosen habit

Patient reads an attributed care-plan goal → asks how it might fit everyday life → companion proposes a small behavioral habit, not a new medical instruction → patient accepts or edits context → it appears in Journeys and optionally Thread → keeps/pauses/corrects are durable → useful observations can inform an explicitly reviewed visit summary. Declining does not create a habit or success state.

### A visit becomes a prepared and completed handoff

Patient chooses a specific provider/appointment → reviews correct time/channel and relevant changes/Guide → prepares a recipient-specific report for an explicit range → reviews source context and exclusions → approves sharing → follows verified delivery status → joins the correct virtual visit or uses supported logistics → retains a traceable preparation/sharing record. Another appointment must not silently replace the selected one.

### Permission becomes a verifiable action

Patient asks Rumi to arrange a supported task → action shows exactly what will happen, to whom, with what data/cost → missing permission/source/capability is explained before approval → patient approves or declines → only the approved scope executes → delayed/unknown outcome is not reissued blindly → receipt or failure appears in chat, task history and the originating feature. Turning an agent off prevents new work rather than hiding it.

### Personalization remains understandable and reversible

Patient reviews what Rumi remembers → sees origin and how it affects support → corrects or forgets a note → later replies stop using the superseded memory → separate clinical records remain attributed and unchanged → consent withdrawal and data deletion explain which stored/shared copies are affected. This must work on both platforms, not only in native visual memory chips.

### Education can help without commercial pressure

Patient reads a finite Currents piece or medication explanation → asks a contextual question → clinical/source information is distinct from sponsorship → patient may inspect a sponsored support option and neutral alternatives → any enrollment or sharing requires its own review → decline is remembered for the approved interval and does not interrupt ordinary education, care or crisis support.

## Dependencies and sequencing

This is a **recommended dependency order**, not an approved release schedule or estimate. All attachment features remain in scope; staged delivery must not silently drop a row. Buildable scope cannot be finalized until the open safety/legal/integration questions have owners.

| Sequence | Workstream / feature ownership | Exit condition before depending on it |
|---|---|---|
| Review first | Approve these documents; reconcile Confluence/Figma/IA; resolve launch population/market and demo versus live boundaries. | Accepted scope, named decision owners and explicit blocked features; no app work before approval. |
| Trust foundation | Welcome/authentication; terms/privacy; analytics; account/data rights; permissions and patient-context ownership. | Real or explicitly demo identity, enforceable data choices, account isolation, durable local/remote behavior and truthful UI claims. |
| Clinical foundation | Records connection; providers; conditions/medications/allergies/immunizations/vitals/labs/notes/documents; source freshness/conflicts. | Patient-linked evidence is distinguishable from fixtures/AI text, recoverable and correctable through an approved process. |
| Companion and safety | Text/voice reliability; editable memory; crisis handoff; combined symptom AFB; source-grounded explanations. | Approved safety/precedence rules and degraded behavior; working consented transport; correct context and memory controls. |
| Everyday guidance | Thread; Needs You; tracking/history; care plan; Guide; atomic habits/Journeys; retained Life/Story/Insights. | Complete entry→response→next-step→return loops; durable progress, correct targeting and no false acknowledgement resolution. |
| Care coordination | Messaging/requests/forms; appointments/virtual visits; reports/preparation; action cards and network. | Supported recipients/services, explicit approvals, real receipt/failure handling and durable shared action status. |
| Commercial and optional channels | Sponsored responses/pages/programs; costs/wallet/savings; optional external connections. | Separate legal/commercial eligibility/disclosure and integration access; unavailable services remain honestly unavailable. |
| Parity and release readiness | Both-platform behavior, accessibility, notifications, Currents/media/recap fidelity, runtime evaluation/operations. | No unclassified dead ends; real outcomes verified in supported environments; approved nonfunctional and safety acceptance complete. |

Cross-cutting requirements are authored once: legal/data permission in Terms & Privacy and account rights; analytics in Analytics Consent; notifications in Notification Consent; crisis logic in Crisis/Self-Harm; execution in Agentic Action Cards; clinical record quality in Records Connection; sponsorship in Sponsored Responses. Dependents link to those owners in the requirements compendium.

### Completion levels must be declared

| Level | What may be demonstrated | What may not be claimed |
|---|---|---|
| Source-complete local behavior | Logging, saved drafts, history, source display and local user controls with verified persistence. | That local saved state implies provider delivery, authentic identity or cross-device sync. |
| Explicit demonstration | Fixture scenarios and simulated external actions clearly identified as such. | Live monitoring, paid bills, verified clinical prediction or actual care-team contact. |
| Supported live integration | Consented connected service with proven operation, status reconciliation and recovery. | Universal provider/channel support beyond the verified coverage. |
| Production release | Approved legal/clinical/security/operational controls plus validated supported journeys. | Safety/regulatory certification merely because a build passes or the app looks complete. |

## Release boundaries and unresolved decisions

Recommendations in this document are not enough to answer domain questions absent from the attachment. These should be settled during review, with the chosen policy entered into the owning requirements section. Work outside the undecided branch can continue after scope approval; a blocked clinical/legal/financial behavior must not be filled with a plausible guess.

| Decision | Why it matters / proposed review owner |
|---|---|
| Initial country, languages, age range and patient eligibility | Determines legal text, crisis resources, emergency numbers, identity requirements and consent capacity. Product + Legal + Clinical. No country is assumed from fixture examples. |
| Patient-only versus caregivers/proxies/minors | Changes record authority, authentication, sharing and messaging. This draft covers patient actions; no delegated access or staff portal is silently added. |
| What exactly ships live in the first approved release? | The current prototype has no clinical/payments backend. Explicitly choose supported services and demo-only boundaries. Product + Engineering + Operations. |
| Existing Confluence IA/requirements and Figma source | Prevents competing pages/specs. Requirements owner supplies/reconciles current sources; none was accessible here. |
| Authentication rules | Supported phone countries, OTP lifetime/attempts/resends, recovery and cross-provider linking need an approved policy, not arbitrary numbers. Security + Product. |
| Care pathway selection and overlap | Are pathways single-choice, multi-condition context, patient-selectable or clinician-established? How are changes approved without losing data? Product + Clinical. |
| Crisis and AFB rule authority | Approved symptoms/thresholds, ambiguity treatment, resources, handoff and overlapping-alert precedence. Clinical + Safety. Confirmed AFB mechanism does not define clinical logic. |
| Clinical record edit/reconciliation rights | Which user corrections annotate versus replace external facts, and who verifies a conflict? Clinical + Integration owners. |
| Other clinical information | Define exact categories beyond allergies rather than letting the phrase become unlimited scope. Product + Clinical. |
| Virtual visit scope | External provider handoff or a separately supported in-app video service? Join windows/readiness/cancellation depend on chosen coverage. Product + provider integration owner. |
| Clinical communication service | Supported practices, response expectations, portal draft fallback, recipient identity, attachments and receipts. Operations + integration owner. |
| Memory/history retention and cross-device expectations | Determines account rights, export/delete, external processor obligations and conversation continuity. Privacy + Product + Engineering. |
| Analytics and notification policy | Exact optional purposes/events, sensitive-data exclusions, quiet-hour/urgent exceptions and lock-screen content. Privacy + Clinical + Product. |
| Sponsorship and program policy | Approved sponsors/content, ranking/eligibility, data sharing, decline interval and whether marketing consent is separately required. Legal + Clinical + Commercial. |
| Payments, savings and connection coverage | Supported tender/financial roles, eligibility, provider APIs and permitted channel use; do not assume iMessage or consumer social inbox access. Product + Legal + Engineering. |
| Reports and content authority | Approved recipients/ranges, export format, authorship/review labels, content freshness and whether AI summaries require clinician review. Clinical + Product. |
| Performance/reliability/accessibility targets | Agreed supported devices/browsers, response/timeout expectations, retention, recovery and evaluation gates must be measurable. Engineering + Design + Product. |

### Not inferred or silently added

- No diagnostic, autonomous dose-adjustment or emergency-dispatch authority.
- No HCP/staff portal, clinician scheduling console, insurance claims processor or caregiver application unless separately approved.
- No assumption that every advertised consumer channel exposes the required APIs.
- No automatic adoption of historical 100.4°F/procedure-date fixture content as universal rules.
- No approval to make live charges, send real clinical information, replace the existing design or generate more assets during document preparation.
- No requirement IDs that compete with Greenlight Guru. Section names/links provide review navigation only.

## Review and document ownership

The three files are repository review artifacts; they have not been published to Confluence or matched against Figma. Update each in place rather than creating v2 copies. The as-built reference records its baseline; this proposal owns proposed scope/IA; the compendium owns proposed functional criteria. If later split into feature pages, migrate each feature's content once, preserve cross-links, and reconcile existing authoritative pages instead of leaving two active versions.

Review in this order: first confirm the audit's distinction between real/local/simulated behavior; then approve or revise feature retention, IA and integration boundaries; then resolve the compendium's inline product/clinical/legal questions. The requirements owner must check the eventual Figma design against approved functional behavior before engineering handoff. Document approval alone does not establish a successful build, runtime service, clinical validation or release approval.

Rork manages repository synchronization. A local file write is not evidence of a GitHub commit or remote push; only observed repository/remote evidence may support such a claim. No manual commit or push is performed as part of this documentation work.
