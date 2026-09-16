# Rumi / Nudge — As-built reference and production gap audit

## Contents

- [Purpose and evidence](#purpose-and-evidence)
- [Product and repository](#product-and-repository)
- [Current information architecture](#current-information-architecture)
- [Native screen and journey reference](#native-screen-and-journey-reference)
- [Companion and voice](#companion-and-voice)
- [Agents and reports](#agents-and-reports)
- [Models and data ownership](#models-and-data-ownership)
- [Persistence and account boundaries](#persistence-and-account-boundaries)
- [Web implementation and parity](#web-implementation-and-parity)
- [Design and construction reference](#design-and-construction-reference)
- [Assets and recreation inventory](#assets-and-recreation-inventory)
- [Services and configuration](#services-and-configuration)
- [Safety and governance reality](#safety-and-governance-reality)
- [Production and dead-end register](#production-and-dead-end-register)
- [Recreation and verification boundaries](#recreation-and-verification-boundaries)

## Purpose and evidence

This document describes the existing application, including defects and simulations, so a new product/design/engineering team can understand or recreate it without confusing an interactive demo with a production care service. It is a source audit, not a proposed design, clinical validation, live integration certification, or claim that every screen has been exercised. Proposed changes belong in [the re-scope proposal](RUMI_RESCOPE.md); proposed functional behavior belongs in [the requirements compendium](RUMI_REQUIREMENTS.md).

**Audit date:** September 16, 2026. **Source baseline:** `e11670626f181a73c120118d28eb9d09d3a960ac`. The working tree was clean at the initial inspection. Application source was not changed during preparation of these three documents.

The review covers all 56 native Swift view files, 11 native model files, three view models, five services, six utilities, three shaders, the independently implemented web app, the Worker, configuration, asset inventory, and existing test declarations. Source citations below use repository-relative paths. For compact tables, **N/** means `ios/Nudge/`, **V/** means `ios/Nudge/Views/`, **M** means `ios/Nudge/ViewModels/AppModel.swift`, and **W/** means `web/src/sano/`. Line ranges are snapshot locators; named symbols are the more stable reference after edits.

### Evidence vocabulary

| Classification | Meaning in this document |
|---|---|
| Local — view | A control changes only a screen's own state; leaving/remounting can reset it. |
| Local — session | Shared app memory changes; relaunch/reload is not guaranteed to retain it. |
| Local — persisted | Source includes a local save path. This is not proof of a successful disk write, migration, recovery, account sync, or external outcome. |
| External — client implemented | Source contains a network request, permission request, device API or URL handoff. Credentials, service availability and actual completion are not established. |
| Simulated external outcome | The UI claims or implies sent/paid/booked/connected/delivered, but the handler changes local state rather than accomplishing that outcome. |
| Unreachable / incomplete | A route or action exists without a reachable control, or the flow stops short of its stated purpose. |
| Proposed | Not as-built; only used in the gap register for future remediation. |

`LEGACY_REQUIREMENTS.md`, the v3/v4/v5 specifications and the older polish plan are historical context, not primary evidence. This audit supersedes conflicting **as-built claims** in those documents without rewriting their historical contents. In particular, the terms “faithful mirror,” “everything persists,” “everything deleted,” “always watching,” and “nothing leaves the device” overstate the actual code.

## Product and repository

Rumi is a companion-led chronic-care experience: a persistent orb opens text or voice conversation; Today offers a small set of relevant moments; Care holds clinical tasks; You holds the health story; Journeys represents small habits; Currents presents finite educational content. Warm, intimate language and generative visual treatments distinguish it from a conventional patient portal. The current implementation is best described as a **fixture-backed interactive prototype with real AI/voice transport clients**.

| Registered app | Folder | Actual role |
|---|---|---|
| Nudge | `ios` | SwiftUI app, iOS 18 minimum; iOS 26 glass guarded by availability. Target/product/module naming remains Nudge; CFBundleDisplayName is Rumi in both build configurations, matching the companion/product copy. |
| Rumi | `web` | Independent Vite/React/TypeScript implementation, not shared native UI or shared user data. |
| Functions | `functions` | Dependency-free Cloudflare Worker forwarding speech requests to ElevenLabs. Not a patient database or clinical integration layer. |

Source: `rork.json`; `ios/Nudge.xcodeproj/project.pbxproj`; `web/package.json`; `functions/package.json`.

### Startup and state construction

`NudgeApp.swift` registers bundled fonts, creates the observable model and manages ambient audio around scene changes. `ContentView.swift:10–24` always provides the living background and chooses onboarding or `RootView` using a local onboarding flag. `RootView.swift:14–95` mounts the selected tab, mini-orb, dock, conversation overlay, acknowledgement toast, three sheets and recap cover. There is no server session check at startup.

`AppModel.init:178–254` selects the saved pathway, seeds clinical/engagement arrays from fixtures, then restores a matching local snapshot. `CompanionEngine` holds a weak reference to the model; `OrbState` holds the companion's visual state. The native UI uses Swift Observation and SwiftUI environment/model access. Swift source is not shared with web, whose `SanoProvider` maintains its own state and localStorage snapshot.

### Personas

| Pathway | Fixture person | Domain focus |
|---|---|---|
| `metabolic` | Marcus | Type 2 diabetes, blood pressure, ongoing habits and medication logistics. |
| `oncology` | Elena | Treatment cycles, symptoms and between-visit support. |
| `procedure` | Sam | Procedure preparation and recovery. |
| `cardiometabolic` | Rosa | Diabetes with heart disease and kidney-risk context, multiple specialists. |

`N/Models/CareProfile.swift` defines the pathway/persona shapes; `PersonaFixtures.swift` supplies clinical and engagement scenarios; `CareHubFixtures.swift` supplies messages, appointments, bills, documents, requests and looking-ahead scenarios. Programs, raw record items, sources, consent ledger and initial memory are substantially shared Marcus fixtures. Selecting Rosa does not turn on a kidney prediction model; it chooses a scripted scenario. A user-entered name can appear beside invented clinical data and persona-name reports.

## Current information architecture

This is the **current** map. It is separate from the proposed structural IA owned by [the re-scope proposal](RUMI_RESCOPE.md#proposed-information-architecture). Repeated destinations below often share a view but not a retained navigation stack.

```text
Launch
├── Not onboarded: Welcome → Identity → Pathway → Shaping
│   → Provider connection → Apple Health ask → Conversation questions
│   → Epsilon consent → Today
└── Onboarded: five-destination shell
    ├── Today
    │   ├── Orb / pull → Conversation → Voice
    │   ├── Care alert → Care root
    │   ├── Proposed action → Local approve / decline
    │   ├── Agent pulse → Agent network → Agent detail
    │   ├── Thread moments → You, habit mutation or conversation
    │   ├── Life strip → You / Life (unreliable event-based shortcut)
    │   ├── Quick Log
    │   └── Settings → Privacy Center
    ├── Care
    │   ├── Needs you → Thread / Records / Meds / Bill / Appointment
    │   ├── Messages → Thread; Requests → Compose request
    │   ├── Appointments → Detail → Reschedule / Trip / Visit prep
    │   ├── Care plan → Derived journey marker
    │   ├── Medications → Medication detail → Linked symptom log
    │   ├── Records → Category → Explanation / Lab / Conflict
    │   ├── Bills → Bill detail → Payment confirmation
    │   ├── Documents → Document detail; Add document
    │   ├── Visit prep
    │   ├── Reports → Recipient report review
    │   ├── Wallet
    │   └── Connections → Agent network / Agent detail
    ├── You
    │   ├── Story → Recap
    │   ├── Insights → Explanation / Conversation
    │   ├── Conditions → Labs / Records
    │   ├── Discussion guide
    │   ├── Care team → Guide / Visit prep / Phone handoff
    │   ├── Medications → Detail
    │   └── Life → Entry detail; Add entry
    ├── Journeys
    │   ├── Held photo → Arc viewer; Add photo and caption
    │   ├── Garden / Keep habit
    │   └── Program → Sponsorship explanation / Enroll / Decline
    └── Currents → Read / Watch / Listen / Conversation

Global: mini-orb outside Today; dock hidden during conversation;
Quick Log, Settings and Network sheets; Recap full-screen cover.
Route-only: Savings (no discovered native entry control).
```

### Navigation and return behavior

- Native Care and You use conditionally mounted `NavigationStack`s. Changing tabs can discard nested navigation. Root bars are hidden; most pushed views do not supply an explicit Back button. Source alone cannot guarantee a visible back affordance in all states. The dock supplies a root escape; interactive back behavior was not exercised.
- Quick Log/settings/network are presented modally; recap and voice are covers. Most sheets rely on system dismissal as well as any explicit controls. Agent detail explicitly hides its navigation bar without adding a Back control; dismissal is the reliable source-defined exit.
- Today switches to You and immediately posts a condition/Life notification. You consumes it only while mounted and with an empty path. There is no queued destination; the handoff can be lost. Insight moments select You, not its Insights segment.
- Missing appointment/thread/bill/document IDs show unavailable content. Missing series/medication IDs can produce only the destination background.
- `CareDestination` contains **17 cases**, including `.savings(String)`. A case in this enum is not evidence of a reachable screen. `openCare` has no discovered production caller; pending destination handling does not create a working deep-link system.

Sources: `V/RootView.swift:14–95`; `V/Today/TodayCanvasView.swift:141–145,257–262`; `V/Today/MomentCard.swift:127–145`; `V/You/YouView.swift:47–60,156–188`; `V/Care/CareHubView.swift:243–293`; `N/Models/CareHubModels.swift:12–30`.

## Native screen and journey reference

Every native view file is represented in this section or the shared-component inventory. Names in parentheses identify meaningful secondary screens defined in the same file. Standard return caveats from the preceding section apply unless a more specific exit is noted.

### Welcome and onboarding

| File / surfaces | Entry, content and actions | Result, return and limitations |
|---|---|---|
| `V/Onboarding/OnboardingFlowView.swift` — flow, Welcome, AboutYou, PathChoice, Shaping, Aura | Launch without local onboarding flag. Welcome orb, music toggle; Apple/phone continuation; editable name/birthday; four pathway choices; timed reshaping narrative. | Both sign-in choices only advance. No authentication, SMS number/OTP flow or Apple identity result. Profile/pathway persist locally. No general backward/restart control; untouched birthday can retain its default. Shaping is timed fixture narration. See `158–300,319–499`. |
| `V/Onboarding/RecordConnectView.swift` — provider picker/sign-in/match/found, HealthKitAsk, EpsilonConsent | Seven fixed providers searchable locally; username/password; identity derived from entered profile; delayed discovery sequence; skip/back/not-me; individual Health toggles; separate yes/no personalization consent. | Username nonempty gates mock sign-in; password is unused outside local UI. Match stores provider name only. Health Connect persists its Boolean before the one-second delay, ignoring selected scopes; no HealthKit authorization. Skip continues. Epsilon persists a Boolean but does not gate AI data transmission. See `21–36,177–331,398–560`. |
| `V/Onboarding/OnboardingConversationView.swift` | Two nonblank personal answers followed by tone selection, with local word-streamed questions (about 45ms per word after a 350ms delay). | This step advances to Epsilon. Final onboarding completion after that choice saves answers as memory notes and tone, celebrates and enters Today. These are not model-generated interview turns. No skip/back in this step. See `16–20,36–123`; M.`completeOnboarding`. |

The eight stage identifiers are welcome, aboutYou, path, shaping, connect, healthKit, conversation and epsilon. Completion stamps onboarding time, which later gates looking-ahead visibility. The flow does not include functioning terms acceptance, analytics consent, notification authorization, Google SSO or a crisis handoff. These belong to the proposed re-scope rather than as-built onboarding.

### Today and global entry points

`V/Today/TodayCanvasView.swift:32–111,133–183,215–270,332–475` renders a settings/condition-chip/music header, a large orb, greeting/status, pull-to-talk affordance, care alert, first proposed action, network pulse, up to three moments, Life strip and an independent plus button. A tail spacer clears the dock. Pull progress uses `translation.height × 0.7 / 110` and opens conversation on release at progress ≥0.95, approximately 149.3pt of downward translation; orb scales with that progress. This is a source-defined gesture, not a verified scrolling fix on all devices.

- Orb/tap/pull enters conversation. Settings presents a sheet. Care alert selects Care root, not the exact unread item. Plus opens generic Quick Log.
- First proposed action uses `AgentActionCard`: approval/decline modifies session state and acknowledges. It does not perform a payment/refill/message.
- `LifeThumb` entries route to the shared Life shortcut rather than the selected item. Thumbnail media is bundled/locally resolved.
- `V/Today/MomentCard.swift:50–63,127–160` supports swipe dismissal, local melt, and a single action. Insight selects You; habit keeps the first habit in the first journey; task always seeds refill conversation; check-in opens generic conversation. These are not per-moment typed business operations. Dismissals/kept dates are session-only; there is no undo.
- `V/RootView.swift` also defines `CompanionAckToast`: log acknowledgements appear above the dock; tapping clears them and opens a generic pattern-seeded conversation. Quick Log does not schedule automatic clearance. Some action/report/payment handlers separately clear their acknowledgements after approximately five seconds; the toast itself has no universal timer. The acknowledgement itself is not a delivery receipt or data-quality check.

### Care hub and attention

`V/Care/CareHubView.swift:20–47,79–168,222–293,357–421` includes `CareTile` and `LookingAheadCard`. Eleven tiles lead to Messages, Appointments, Care plan, Medications, Records, Bills, Documents, Visit prep, Reports, Wallet and Connections. Requests is reached from Messages; Savings is not exposed by a tile.

`M.needsYou` builds attention items from unread threads, an unacknowledged result, low supply, unpaid bills and pending appointments. `careUnreadCount` is narrower: new care-team messages plus result. This is derived fixture/local state, not a clinical alert service. The result acknowledgement method exists but no current UI caller was found; opening Records need not clear the result.

Looking-ahead explains a fixture population basis and can add a guide question, then open Guide. Native visibility checks available content, opt-out and 14 days since onboarding. There is no crisis gate in the predicate and no reachable opt-out control found, despite stored support for the preference. This is not a deployed predictive model or personalized probability estimate.

### Messages and requests

| Surface | Journey and content | Actual effects and dead ends |
|---|---|---|
| `V/Care/MessagesView.swift` — Messages, ModeChip | Care/attention → inbox, showing practice/member, latest text, time, unread and channel mode. Requests link opens request list. | Fixture threads and local additions. Channel labels distinguish in-app from portal drafts but establish no transport. See `22–51`. |
| Same file — MessageThread, MessageBubble | Open thread → chronological care/user messages; origin/attachment labels; composer → send or save draft. Dismiss/pop returns to inbox. | Read flag changes without immediate save. Send appends a locally persisted `.sent` or `.draft` message and clears composer. No delivery, retry, attachment handling, new recipient/thread UI or portal copy/open handoff. Attachment is a string label, not a file. See `119–319`; M.`sendMessage`, `markThreadRead`. |
| `V/Care/RequestsView.swift` — Requests, RequestProgress, ComposeRequestSheet | Messages → Requests → create refill/appointment/records/form request; optional subject/detail → Send → sheet closes; read-only three-step progress. | Persists a local submitted request with constructed routing text. Blank subject defaults to kind. No actual office submission, request detail, cancellation, receipt, or transition from submitted to resolved. See `24–246`; M.`submitRequest`. |

Native symptom support, Guide and Visit prep each have additional send-like controls, but their success states are **view-local** rather than even persisted Messages entries. These are distinct implementations, not one reliable communication workflow.

### Appointments and visit logistics

`V/Care/AppointmentsView.swift` defines Appointments, AppointmentDetail, AppointmentRow, DateStone, KindChip, StatusChip, RescheduleSheet and TripView (`22–190,240–275,355–578`).

1. Care → list → selected visit detail. Dates, provider, location, kind/status and goal hint come from fixtures. The list is not strictly future-only.
2. Confirm updates session appointment status and may add a local completed agent task. Reschedule selects a time and confirms in a sheet, then returns to detail. Neither contacts the office or Calendar. Trip departure data is not recalculated after a new appointment date. There is no ordinary booking/cancel UI, despite a model helper for booking.
3. Telehealth Join is enabled by `canJoin` when kind/link qualify and the Calendar whole-minute difference is between −90 and +15. This is approximately 15 minutes before through 90 minutes after, but truncation admits a portion of the adjacent minute rather than enforcing exact elapsed seconds. There is no appointment-status check or dedicated ticking refresh; fixture join URLs use `.example`. The URL handoff is real API code, not a real virtual visit.
4. Trip detail shows fixed depart-by/travel/route/parking/checklist/conflict/ride content. Checklist completion is view-local. Maps opens a query; ride opens a generic Uber page. No route calculation, ride booking, calendar query, conflict resolution or telehealth device-readiness check occurs.
5. Prep opens `VisitPrepView`, which uses `appointments.first` rather than the selected visit. A later visit can show the wrong appointment's brief.

`V/You/CareTeamView.swift:17–126,151–271` defines both CareTeam and VisitPrep. You/Records → team displays people and appointments. Every Call control invokes the same persona office number via `tel://`, not a verified member-specific number. Prep-ready visits link to a brief; Guide is shared. The brief's changes and packing list are fixture text; its question list contains unresolved Guide items of kind question, excluding unresolved observations. Confirming Send flips a local flag; no office delivery occurs. There is no separate HCP/staff app in this repository.

### Care plan and discussion guide

- `V/Care/CarePlanView.swift:10–106`: author/update/intro/goals and current progress. Deriving a tiny journey immediately maps the goal to a behavioral habit and saves a goal marker; no preview, undo/removal or immediate Journey navigation. The journey object is session-only while its marker persists, producing a relaunch inconsistency. Source: M.`deriveJourney`, `behavioralHabit`.
- `V/You/DiscussionGuideView.swift:28–215`: open via You, care team, or looking-ahead. Add question/observation, mark covered/uncovered, delete; these call persisted Guide handlers. Text editing is missing. It identifies the first appointment as next visit. Send confirmation changes only `sent` in the view. Conversation guide tags can insert items automatically, without an additional review step.
- `V/You/ConditionOverviewView.swift:9–43,85–254`: separate read-only condition/phase/plan/expectations view. Metric rows open labs; bottom door opens Records. It does not provide the Care plan's journey-derivation action or condition editing.

### Bills, wallet and savings

| File / surfaces | Content and reachable flow | Implementation reality |
|---|---|---|
| `V/Care/BillsView.swift` — Bills, BillStatusChip, ProgressBar | Care/attention → list → detail; deductible/OOP and future cost estimate. | All claims/amounts/progress are fixtures. No insurance/claims feed. See `9–95`. |
| Same — BillDetail | Explanations, line items/reasons, possible error; choose wallet card and confirm; provider-pay link; already-paid confirmation. | Local paid key persists, but no charge, receipt file, reduced wallet balance or updated cost summary. Insurance cards appear among offered wallet choices. External provider URL is a placeholder. Error flags have no dispute workflow. See `200–397`; M.`payBill`, `markBillPaid`. |
| `V/Care/WalletView.swift` — Wallet, WalletCardView | Care tile → seeded HSA/payment/insurance cards with label/last four and bill summary. | Read-only. Cannot add/edit/remove cards or open the referenced bill from the summary. No tokenized payment provider or insurance verification. See `9–153`. |
| `V/Care/SavingsView.swift` | Router can display options by medication, estimated benefit, basis/sponsor and apply/use action. | No discovered incoming control, so currently unreachable. Applying flips a session flag; no eligibility check, coupon, application or PII delivery. Confirmation language exceeds implemented behavior. See `15–168`; `CareHubView:256`; M.`applySaving`. |

### Documents and conventional records

`V/Care/DocumentsView.swift` defines Documents, DocumentRoute, DocumentDetail and AddDocumentSheet (`50–78,130–205,242–346`). Add accepts **title and type**, not a scan/photo/file. Save persists metadata and dismisses. Detail uses bundled images or a placeholder, with fixture extracted fields/low-confidence flags. Confirm merely marks `confirmed`; it does not add clinical values to Records. Fields cannot be corrected. New manually entered documents have no fields and no confirmation button, while their confirmed flag remains false. Remove confirms then deletes metadata and pops, not an underlying file. Vision's subject lift elsewhere in the app is unrelated to document OCR.

`V/You/RecordsDrawerView.swift` defines RecordsDrawer, RecordCategory and ConflictSheet (`23–77,106–218,246–289`). Entry: Care tile or Conditions. It displays source freshness and seven categories: labs, medications, conditions, immunizations, procedures, notes and documents. Rows can show explanation, a lab trend, medication area, or conflict disclosure. These are primarily shared Marcus `RecordItem` fixtures, not the active pathway's normalized clinical record. They are not the same collection as user-added Care documents.

Conflict view displays disagreement and an Ask action that sets a view-local flag. It neither reconciles data nor submits a request. Some fixture series IDs can be absent in the selected pathway; the resulting lab destination may be blank. There are no dedicated immunization, allergy, note-editing or vital-entry workflows corresponding to the new scope; a category row is not equivalent to those features.

### You, labs, story and insights

| File / surfaces | Content, actions and return | Data/limitations |
|---|---|---|
| `V/You/YouView.swift` — You, YouDestination | Story/Insights segment; doors to conditions, Guide, team, medications, Life; registers only YouDestination. CareHub, not YouView, registers both destination enums. | Starts on Story after mounting. No retained cross-tab back stack. See `20–60,100–123,156–188`. |
| `V/You/StoryTimelineView.swift` | Year-grouped narrative events, curved spine, recap entry. | Events are fixtures plus session additions; rows have no detail/edit screen. Saved Currents do not add Story entries. See `26–42,87–169`. |
| `V/Insights/InsightsHubView.swift` — InsightsHub, InsightSpread | Filter editorial insights; inspect basis; bookmark; action opens contextual conversation. | Seen/bookmarked status is session-only. Heads-up seeds refill, pattern seeds visit; no dedicated execution or automatic acted lifecycle. Visuals/provenance are fixtures. See `9–30,69–208`. |
| `V/You/LabDetailView.swift` | Latest value/date, glow chart/range, scrub, annotation toggle, explanation sheet. | Read-only local series; no data entry/time-window choice/sync. See `19–79`. |
| `V/You/ExplainSheet.swift` — SeriesExplainSheet, ExplainSheet | Metric-specific reading/next-step/question or generic record-category explanation → Ask in conversation; dismiss returns to originating screen. | Opening the explanation uses existing strings, not a live explanation request. Ask subsequently invokes AI. See `5–121`. |
| `V/You/RecapPlayerView.swift` — Recap, Chapter | Full-screen four-chapter pathway slideshow, bundled images/music; tap advances; automatic progression approximately 6.5 seconds/chapter; close/completion returns. | Not generated from actual patient progress, not earned/rare-gated, not exported video. Close/completion celebrates. See `23–72,108–118,153–228`. |

### Medication and Life tracking

`V/Meds/MedicationsView.swift:21–113` lists medication name/dose/schedule/supply with tide imagery. Name/image opens `MedDetailView`; Log near this opens Quick Log already linked to a med. There is no add/edit medication, direct refill submission or reachable Savings link.

`V/Meds/MedDetailView.swift:24–148` shows purpose/guidance/watchlist/dose history, adherence detail and linked symptom rows. Low-supply metabolic content opens refill conversation. Symptom rows show kind/region/time, not a full history/edit interface. Medication `adherence30` and supply are fixtures: logging a medication entry does not recalculate them.

`V/Life/LifeCatalogView.swift` defines LifeCatalog, LifeEntryDetail and AddEntrySheet (`16–54,212–273,281–415,474–662`):

- You Life door or Today shortcut → day-grouped meals/activity/medications; filter; approximate meal calories; tap object → overlay detail. Chevron, background tap or downward drag closes the detail.
- Detail shows image-derived nutrition/minutes; Ask opens conversation; linked medication offers symptom log; Remove immediately persists deletion without confirmation.
- Add menu → form → kind switch, searchable library/free text or medication choice → save at current time → dismiss. No timestamp/portion/duration editor. A `note` state exists but no note input is rendered here.
- Nutrition and effort are **fixed image-key lookup estimates**; a percentage-of-day graphic assumes 2,000 calories. They are not measurements, image recognition or personalized dietary targets.
- Raw `CareEntry.Kind.move` is persisted as **`Moves`** but displayed as **Activity**. Preserve decoding compatibility when renaming UI. Synonymous activity names intentionally share art; old image fact mappings remain for saved entries.

### Quick Log and symptom response

`V/Log/QuickLogView.swift` includes `FluidSeveritySlider` (`62–118,180–431,438–560,604–680`). Today plus opens the generic picker; medication contexts open symptom choice directly.

1. Pick feeling, meal, activity or medication taken. Meal/activity libraries support typing and selection; medication supports choice. Quick-add has a Back action and persists an entry with current time; blank free text can fall through to a default matched item.
2. Feeling → pathway-specific symptom → optional body region → severity 0…1 → optional note → submit. There is no general backward control between these symptom steps; dismissal remains available.
3. `M.addLog` persists the symptom and returns a **scripted, pathway-based SupportPlan**, not a model-generated result. Severity and symptom/pathway select tips and urgency. Temperature is not measured/entered for the fever rule.
4. Support can add a persisted Guide item, open conversation, call the office, or locally claim that a note was sent. Native Send only flips a view-local state. Done closes the sheet. This does not implement the newly clarified combined AI/rules feedback requirement end to end.
5. No general symptom-history/detail/correction/deletion screen is present. Medication-linked rows provide partial history access.

`V/Log/BodyMapView.swift:11–20,59–83` draws nine regions and chooses the nearest to a tap, through a binding. Selection cannot be cleared within this view; skip is available only before a region is selected. Labels exist but accessible region-selection actions are not implemented.

`V/Log/LibraryPicker.swift:16–66,86–162` defines `LifeLibraryPicker`: name/group search, clear query, most-used ordering from existing entries (including fixtures), item selection. Choosing an exact item keeps the broader library visible. Both libraries are local: 39 food names and 24 activity names. Many food names reuse six meal images/estimates.

### Journeys and held memories

`V/Journeys/JourneysView.swift:23–110,132–279` defines Journeys and SponsorExplainSheet. It displays held photos, an inspectable light garden, existing habits, and program offers. Keep appends today's date and celebrates, guarded against duplicate same-day keep. No habit edit/removal/undo or durable habit history. Enrollment creates a session journey/moment/action and a memory note; decline hides the program in session, not for a reliably enforced 90 days.

`V/Components/MemoryOrbView.swift:8–126,134–323` defines MemoryOrbView, MemoryOrbGlass, MemoryPhoto, MemoryArcViewer and AddMemoryOrb. A real PhotosPicker loads a selected photo, saves a separate local file, then asks for caption. Metadata is persisted when accepted. The camera icon does not mean camera capture. Cancel after the file save can leave an orphan; failure has no user-facing recovery. Arc drag/tap selects photos; chevron dismisses. There is no photo edit/delete UI.

Programs and sponsorship are static fixtures, not dynamic eligibility matching or sponsored inventory. Consent and decline limitations are documented under governance.

### Currents

`V/Currents/CurrentsView.swift:9–42,47–120,152–228` defines Currents and CurrentPage: finite paged pieces and an end scene; format controls; save, taste and Ask. `saved` and `taste` change session flags; “saved to story” does not add story content, and taste does not regenerate the feed. There is no daily refresh engine or saved-content browser.

`V/Currents/CurrentsPlayerSheets.swift` defines ListenSheet, WatchSheet, LoopingVideo, LoopingVideoUIView and WaveformView (`6–121,126–293`). Listen plays the **same bundled music**, not narration of the selected article, with pause/seek/progress and displayed piece text. Watch loops thinking-orb footage with timed captions and music, not an article-specific film; no pause/seek/end dismissal. Waveform is procedural. Player music can operate independently of the global music flag; Watch does not restore the ambient bed on exit. These distinctions matter when recreating both the appearance and actual functionality.

### Settings and Privacy Center

`V/Settings/SettingsView.swift:25–87,120–232`: editable names, tone, Auto/Day/Night appearance, sound/music, era warmth, notification classes, quiet-hour display, pathway preview and Privacy navigation. Names/preferences save locally; appearance/audio/tone have consumers. Era warmth is stored without a discovered behavioral consumer. Notification classes are session state with no scheduler. Quiet hours are display-only. Pathway preview swaps fixtures and can discard unsaved/session data; it is not switching authenticated patient accounts.

`V/Settings/PrivacyCenterView.swift` defines PrivacyCenter, MemoryRealm, Lens and FlowingWords (`32–120,134–269,281–434`). Realm words select remembered-note groups; add/forget mutates persisted memory. This is add/delete, not inline text editing. Source freshness is read-only; no provider revoke/reconnect exists. Most personalization explanations are fixed copy. A separate personalization toggle directly changes persisted epsilonConsent. Ledger toggles are session-only except that the epsilon ledger entry writes either Boolean value into that preference; changes through the separate toggle do not synchronize the ledger back. Neither control governs data sent in prompts.

**Export** only sets a view Boolean and shows prepared-copy; no file/share/export. **Delete** calls `PersistenceService.wipe()` for one JSON file, leaving live data, preferences, photos, caches and conversation. A subsequent save can recreate it. Neither action fulfills its on-screen account/data-rights claim.

## Companion and voice

### Conversation surface and orb

`V/Conversation/ConversationView.swift` defines ConversationView, InputGlass, ConversationScene, TurnView, ConversationProgramCard, StreamingText and ThinkingShimmer (`31–35,87–245,334–625`). Companion words render directly on a deeper ambient canvas; user words appear in glass; rich content arrives after text; input can send or enter voice. Closing cancels an active generation and restores the underlying tab but does not clear chat history. Tapping the conversation orb changes its visual mode; it does not start microphone capture. Pathway-specific starter prompts appear while history contains at most one turn. The header also provides direct Day/Night and music controls and drag dismissal (`ConversationView.swift:77–79,115–188`).

`N/ViewModels/OrbState.swift` has seven modes: ambient, listening, thinking, speaking, celebrating, concerned and resting. Energy transitions smooth over approximately 0.9 seconds; celebration returns after approximately 1.6 seconds. Energy/breath pairs are ambient 0.25/4.0s, listening 0.70/2.6s, thinking 0.55/2.0s, speaking 0.62/1.7s, celebrating 1.0/1.2s, concerned 0.16/5.5s, resting 0.10/6.0s. These are visualization states, not evidence that a microphone, model or task is active.

### Request construction

`N/Services/CompanionAI.swift:22–71` posts to `<toolkit-base>/v2/vercel/v1/chat/completions` with bearer authorization, JSON, model **`anthropic/claude-sonnet-4.6`**, streaming, temperature 0.75, requested maximum output 700 tokens and timeout 45 seconds. “Opus 4.8” comments in the services/view model are stale; `N/Utilities/AppConfig.swift:9–11` controls the payload.

`CompanionEngine.swift:12–98,110–203,268–353`:

- Typed/voice requests use the last 14 turns after appending the current user turn. A seeded/greeting request can append an extra synthetic message after 14 historical turns. Rich-card approval state is not included in history.
- Opening the companion for a greeting or topic can itself initiate an external request without a visible user-authored turn.
- Prompt includes pathway/conditions, medications and supply, latest lab readings, appointments/office details, care plan, first eight memory notes, last five symptom logs, first six Life entries, unresolved guide questions, non-declined programs and pending legacy actions. It is not the entire record or full agent-network state.
- Prompt instructions seek short natural replies, empathetic acknowledgement before one concrete step, no diagnosis/dose change, and explicit approval for actions. These are not output validation or authorization controls.
- Failure falls back to keyword-based local replies; typed fallback streams at approximately 34 ms/word. This is not a second live model or validated offline clinical assistant. The fallback does not implement the clinical/crisis rules, and its use is not clearly disclosed.

### Rich action protocol

`CompanionEngine.parse:216–264` removes complete `[[…]]` blocks and selects the first recognized one. At-most-one/final-position is a prompt convention, not enforced placement validation. Unknown complete tags are removed; incomplete final tags can survive final parsing. Streaming holdback reduces visible tag leakage but does not validate action intent, payload length, eligibility or recipient.

| Tag family | Rendering and actual behavior |
|---|---|
| `[[trend:SERIES_ID]]` | Inline lab chart if that ID exists; no mutation and potentially no visible chart for an unknown ID. |
| `[[habit:Title\|context]]` | Proposal card; accepting keeps the first habit of the first journey, not the proposed new habit. Session-only. |
| `[[refill:Med\|detail]]` | Refill card; accepting resolves its visual state. No refill/delivery operation. |
| `[[guide:Question]]` | Automatically adds a locally persisted Guide question, exact-text deduplicated. No separate approval. |
| `[[action:Title\|detail]]` | Approval creates a legacy action already marked done; no external executor. |
| `[[program:Exact title]]` | Case-insensitive fixture lookup; local enroll/decline. Lookup can still match an already declined program. |

`V/Conversation/ConversationView.swift:365–519,543–581` uses a single `richResolved` Boolean for multiple outcomes. Declining can therefore render affirmative completion copy. Approval is not a transaction log; parsed actions lack durable identity, status reconciliation and receipts.

### Voice journey and technical behavior

`V/Conversation/VoiceModeView.swift:13–105,123–199` opens above conversation and starts a real permission/recording path. Mic/orb starts/stops the loop; chevron stops and returns. Unavailable guidance is shown but there is no direct Settings link. `TypewriterText` animates an already returned transcript; it is **not partial live speech recognition**.

`N/Services/VoiceSession.swift` implements idle → listening → transcribing → thinking → speaking → listening, with unavailable state:

- Requests microphone permission normally, records AAC 44.1kHz mono in a fixed temporary `rumi_voice.m4a`, using play-and-record/voice-chat audio category.
- Samples meter approximately every 42ms; normalized speech threshold 0.06 and quiet threshold 0.04. After speech and at least one second of recording, 26 quiet frames commit; about eight seconds without speech silently recycles.
- Uploads a completed recording larger than 2,000 bytes as multipart to `/voice/stt`, requesting `scribe_v2`, diarize false, tag_audio_events false, **no_verbatim true**. Only returned `text` is decoded; there is no confidence/timestamp/user approval stage.
- Uses transcript as a conversation turn and obtains a whole reply before TTS. Voice prompt asks for one or two spoken sentences. TTS `/voice/tts` requests `eleven_turbo_v2_5`; full returned MP3 plays via AVAudioPlayer, whose metering drives glow energy.
- The playback path waits for the player's duration plus about 150ms, then finishSpeaking schedules another approximately 450ms before requesting listening again. This is batch, sequential, hands-free turn-taking, not full-duplex realtime speech or live transcription. Start/interrupt/end controls exist, subject to the cancellation race below.
- Two consecutive empty/missing transcripts trigger supportive miss copy. Permission/recording errors can become unavailable; STT HTTP/network/decode failures return nil and enter the miss/relisten path, TTS failures call finishSpeaking, and chat errors use local fallback. These are not uniformly surfaced as distinct service errors.
- Stop attempts ambient playback with a 1.4s fade only when a current bed exists and music is enabled; teardown restores category but does not itself resume music. A separate finish branch attempts a 1.6s fade. Recording starts during a music fade and triggers a touch sound, so zero music/tap leakage is not guaranteed. Temporary recording is not explicitly deleted.
- The microphone-permission Task is not tracked/cancelled and does not recheck shouldContinue before beginRecording. A late permission grant after Stop/dismissal can therefore start recording again. This is a source-supported race, not a reproduced runtime observation.

Source ranges: `VoiceSession.swift:36–86,95–138,146–238,242–320,330–366`. Neither provider availability nor audio quality/latency was measured in this audit.

## Agents and reports

### Visible agent family

`N/Models/AgentNetwork.swift:126–156` and `AgentActivity.swift:49–274` define eight services: Risk watch, Continuous monitoring, Alerts & escalation, Smart scheduling, Support & education, Care pathway, Medication adherence and Lifestyle support. Task modes are automatic/needsApproval; statuses working/waiting/scheduled/done. Sources label record, Apple Health, pharmacy and optional connection IDs. Seeded task counts are metabolic 10, oncology 9, procedure 9, cardiometabolic 10.

`V/Care/AgentNetworkView.swift` defines Network, AgentRow, AgentDetail, AgentTaskCard, AgentPulseCard, FlowSourceChips, FlowChips and FlowLayout (`13–149,208–424,432–655`). Today pulse/Connections opens overview; agent row opens detail; Done dismisses overview. Detail groups tasks and offers pause/resume/approve/decline/connect-source. Detail lacks explicit Back. Paused agents remain in the overview roster; their waiting tasks are excluded from its waiting section. There is no overview filter control. Handlers do not enforce active state, connected source, task mode or waiting status before approval.

`M.toggleAgentService`, `approveAgentTask`, `declineAgentTask:805–837` alter session flags/task states/story/toast. No autonomous scheduler, agent worker, monitoring process, pharmacy operation or escalation service exists. Decline removes a task rather than maintaining a durable rejection history. Record/Health/pharmacy can appear connected unconditionally. Labeling a task working is not evidence of background work.

### Connected accounts

`V/Care/ConnectionsView.swift:15–21,64–225` defines Connections, ConnectionRow and AgentServiceTile. Gmail, Calendar, iMessage, SMS and Instagram toggle local connected state; `M.toggleConnection/sampleAccount:772–781,846–854` creates sample handles. No OAuth, calendar read/write, email ingestion or messaging-channel integration is implemented. The ability of each provider/platform to support proposed use cases remains a production feasibility question; the prototype's toggle cannot establish access.

### Per-recipient reports

`V/Care/ReportsView.swift:7–50,107–188,296–347` defines Reports, ReportCard, ReportDetail. Care → choose 30/60/90 days → open recipient review → confirm Send → sent state. Swipe dismisses. Reports are deterministic local data composition (`N/Models/AgentNetwork.swift:161–242,270–308`), not AI-generated PDFs.

- Recipient list excludes roles containing pharmacy; nurses/PT may be included, so “doctor only” is not exact.
- Patient name is `persona.firstName`, not entered profile name.
- Selected range filters symptom logs (including counts and average-severity summaries) and meal/activity counts, but not all report sections. Cutoff is lower-bound-only, so future-dated entries can count. Labs compare the last two stored points regardless of range/date; medications use fixture `adherence30`; unresolved guide items are not time/recipient filtered.
- Report latest lab may differ from other screens when stored points are unsorted: builder uses array last, whereas `LabSeries.latest` chooses latest date.
- Cross-team context is static role-based copy. Both report builders reorder all labs by lab-name relevance to the recipient's role; recipient name is not part of the ranking. This is real local tailoring, not recipient-specific exclusion or clinical validation. No record freshness reconciliation, source conflict resolution or actual inter-provider synchronization.
- Identity is recipient plus range, not content version/date; changing data can retain a session sent marker.
- `M.sendReport:731–753` sets local sent keys, story/network entries and toast. It does not create a PDF, transmit a report, attach it to Messages or store a sent report snapshot. Sent markers reset on relaunch.

## Models and data ownership

The following is a domain reconstruction guide, not a proposed database schema. Source files own the exact field types and initial values; fixture arrays should be preserved as fixtures when recreating the demo, never imported as real patient records.

| Native model file | Important shapes / relationships |
|---|---|
| `N/Models/CareProfile.swift` | CarePathway; Persona; conditions/phase/expectations; CarePlan/goal/provenance; SymptomKind; BodyRegion; GuideItem; SupportPlan. Persona joins the clinical and engagement scenario. |
| `N/Models/EngagementModels.swift` | Moment kinds insight/habit/task/checkIn; Insight category, confidence/provenance/sources, visual and lifecycle; AtomicHabit with keptDates; Journey with optional planGoal; Program with sponsor/fit/dividend fields; SymptomLog with kind/severity/time/note/body/med; StoryEvent. |
| `N/Models/RecordModels.swift` | LabSeries with points/unit/reference band/explanation; Medication with guidance/watchlist/history/supply/adherence30; RecordItem with category/conflict/series link; RecordSource/freshness; ConsentEntry; CareTeamMember; Appointment; MemoryItem. |
| `N/Models/CareHubModels.swift` | 17 Care destinations; MessageThread → CareMessage with origin and attachment label; draft/sending/sent/delivered/replied vocabulary; AppointmentKind/status; TripPlan; Bill → BillLineItem, stable bill key; CostSummary; seven DocumentType values; CareDocument → ExtractedField; CareRequest kind/status; MedicationSaving; LookingAheadNudge; NeedsYouItem. |
| `N/Models/ContentModels.swift` | CurrentsPiece format/content/image/AI label/intent/saved/taste; ConversationTurn role/text/rich/resolved/streaming. Intent is a fixture field despite its server-side comment. |
| `N/Models/LifeModels.swift` | CareEntry kind/title/detail/time/image/note/linked med; derived LifeFacts; LifeLibrary names/matchers/facts; held-memory and profile shapes. Display Activity versus persisted Moves is deliberate. |
| `N/Models/AgentNetwork.swift` | WalletCard kind/label/last four; Connection/group/enables; AgentService; ReportLine/Section/DoctorReport and local report generation. |
| `N/Models/AgentActivity.swift` | AgentTask/mode/status/source and pathway task fixtures. |
| `N/Models/PersonaFixtures.swift` | Four scenario worlds and deterministic symptom-support rules. |
| `N/Models/CareHubFixtures.swift` | Per-pathway Care bundle: appointments/messages/bills/cost/documents/savings/requests/result/nudge. |
| `N/Models/MarcusFixtures.swift` | Shared record/source/program/consent/memory seeds and legacy scenario data. |

M owns native view state; `W/types.ts` and `W/store.tsx` define a separate browser model. Common names do not imply shared identifiers, account ownership or synchronization. Many entities generate UUIDs during fixture construction; stable paid-bill keys are explicitly used for relaunch persistence. Cross-reference stability for other saved/generated IDs is not guaranteed by a migration layer.

## Persistence and account boundaries

### Native

`N/Services/PersistenceService.swift:7–54` stores one Documents JSON file, `sano_user_data.json`, with ISO-8601 dates and atomic writes. There is no schema version/migration, user-visible save failure, account scope or remote sync. Failed decode returns nil and startup can reseed fixtures.

| Storage | Contents / actual boundary |
|---|---|
| UserDefaults | Onboarding flag/date, tone, epsilon, era warmth, sound, music, appearance, looking-ahead opt-out, pathway, profile and per-pathway result acknowledgment. Profile includes names, optional birthday, Health Boolean and provider-name list. |
| JSON snapshot | Pathway, entries, logs, memories, guideItems, memoryNotes, threads, requests, documents, paidBillKeys, derivedJourneyGoals. |
| Separate local files | User-selected held photos; temporary microphone audio; lifted-image PNG cache. These are not deleted by `wipe`. |
| Session/view only | Chat, moments, insights, full journeys/habit dates, program enrollment/declines, medication adherence/supply changes, appointments, savings, wallet/connections, agent toggles/tasks/actions, report-sent keys, Currents bookmarks/taste, notification classes/quiet hours, most consent ledger state and send/export confirmation Booleans. |

Defaults: not onboarded; Straight talk; epsilon true; era warmth Subtle; sound/music true; Auto appearance; looking-ahead opt-out false; metabolic pathway. Missing onboarding time falls back to 60 days ago. These are source facts, not recommended privacy defaults.

M.`persistUserData:258–271` is called by entry/log/memory/guide/message/request/document/paid-bill/derived-goal operations, but not every model write. Thread read state and enrollment memory can piggyback on a later snapshot. Persisted does not mean all empty states survive: `M.init:237–249` restores most arrays only when nonempty; deleting the last item can bring fixtures back. Logs are restored even if empty.

`switchPathway:282–320` replaces many arrays and resets conversation without saving the outgoing snapshot or loading a retained incoming profile. It retains some shared data, including programs/raw records/memory notes. One later save overwrites the single snapshot. Derived goal keys can survive while the corresponding Journey does not, preventing recreation. Account export/deletion does not fulfill its claim, as described above.

### Web

`W/store.tsx:122–127,152–207,225–233` reads/writes one `localStorage` key, `sano.web.v1`. The complete 19-key payload is:

```text
hasOnboarded, pathway, profile, tone, appearance, musicOn, soundOn,
epsilon, eraWarmth, notifs, justBloomed,
entries, logs, memories, guideItems, memory, threads, requests, documents
```

No schema validation/migration/account scope/server sync is implemented. Storage failures are swallowed. Bills/paid state, derived-goal keys, journey/habit history, appointments, programs/declines, agent state/connections, report sent state, saved Currents, insights, result acknowledgment, quiet hours and chat are not persisted. Web differs from native even where both appear to save an action.

Pathway switching overwrites this one data set. `cost` remains the initial bundle because it has no setter; some shared memory/program/profile fields remain. Wipe removes this key and reloads: browser reset, not cloud/account deletion. Existing platform storage protections should not be confused with an audited app encryption/retention policy.

## Web implementation and parity

### Routes and complete screen-file map

`web/src/App.tsx:14–26` has **only `/` and wildcard `*`**. `/` renders Index → SanoProvider → SanoApp. The wildcard is NotFound with a home link. `W/SanoApp.tsx:33–87` constrains the product to a maximum 440px column and switches local tabs. Browser Back does not operate the internal stack. React Query provider presence does not establish server-backed care state.

All 13 files under `W/screens/` are covered here; they are not 13 URL routes.

| File | Rendered surfaces and flows |
|---|---|
| `Onboarding.tsx` | Welcome → aboutYou → path → shaping → connect → health → two-question talk → epsilon. Provider picker/sign-in/match are local; declared found phase is not entered. No working social/phone authentication. Provider text fields have empty controlled values/no-op change handlers. Health waits 900ms then appends a label; any connection can incorrectly imply Health connected. |
| `Today.tsx` | Settings, condition→You, orb→chat, care alert→Care, proposed action, network pulse, moments, Life shortcut, Quick Log. Immediate event dispatch after selecting You can lose the Life destination; insight does not select Insights. |
| `Care.tsx` | Hub's same 11 tiles; Messages→thread/requests; appointments→detail/prep; carePlan; meds/detail; records/category/lab; bills/detail/payment; documents/detail; reports/review; wallet; connections/network; Savings renderer without incoming UI. Requests lacks composition; documents lacks add/confirm/remove UI despite store functions. The visitPrep route renders GuideScreen rather than native's separate changes/packing-list brief. |
| `You.tsx` | Story/Insights; conditions, Guide, team, medications, Life. Records/category renderers exist without a You-side entry. `appointmentDetail` renders another CareTeamScreen, so team appointment taps do not open true visit detail. |
| `shared.tsx` | MedicationsScreen, MedDetailScreen, RecordsScreen, RecordCategoryScreen, LabDetailScreen, CarePlanScreen/GoalCard, GuideScreen, ConditionsScreen, CareTeamScreen, LifeCatalogScreen/LifeDetail. Explanations open sheets then chat; Life filters/detail/remove but no add-from-Life. |
| `Conversation.tsx` | Text overlay, rich chart/habit/refill/guide/action/program elements, VoiceOverlay. Approval on most inline cards only resolves their visuals. |
| `QuickLog.tsx` | Pick→symptom→support, or pick→entry→done; body map/severity/note and searchable libraries. Support can create a local care thread unlike native's view-only sent state, but the claimed attached log is not actually attached. |
| `Journeys.tsx` | Memory viewer previous/next; adding a canned memory, not picking a photo; garden; keep; program enroll/decline/sponsor sheet. Garden lights are not individually inspectable. |
| `Currents.tsx` | All/format filter, feed, Reader sheet, timer-driven Player; save/taste/chat. No piece audio/video playback in Player. |
| `Recap.tsx` | Timed slide overlay, previous/next/hold pause, ambient bed, 4.2s per slide. Unlike native's fixed chapters, web composes from entered name, up to three selected Story events, first-series lab comparison and current kept-habit count (`Recap.tsx:33–50`); session additions can affect it. This is not a date-filtered clinical recap, exported film or native dedicated recap score. |
| `Settings.tsx` | Read-only identity, appearance/audio/tone, personalization, notification classes, quiet-hour steppers, pathway, phone handoff, reset. No Privacy Center, editable memories, profile editing or data export. |
| `AgentNetwork.tsx` | Overview/detail within sheet; sources, pause/resume, grouped tasks, local approve/decline, connection toggles; Today pulse. |
| `nav.tsx` | `useStack` push/pop/reset and SubScreen back/scroll, HubHeader, SectionTitle. Memory navigation rather than URL routing. |

Source locators: `W/screens/Care.tsx:27–72,143–155,223–263,308–352,374–443,477–543`; `You.tsx:14–53`; `shared.tsx:28–76,107–187,205–278,309–429`; `QuickLog.tsx:31–57,97–158,235–363`.

### Browser-only defects and missing flows

- **Typed message omitted from request:** `W/store.tsx:362–363,416–417,443–459` schedules the user turn with setState, then `ask` reads the prior ref. It only appends the prompt for hidden/seeded turns. The current typed message is therefore missing from that request. Voice explicitly appends it and does not share this specific defect. Starter chips call the same sendMessage path as typed input and share the omission.
- Prompt contains conditions/meds/labs/appointments/plan/memory/guide/programs, but does not serialize the logs/Life/actions held in its context ref. Native includes those datasets.
- `resolveRich` is only a Boolean change. Habit/refill/generic action cards do not perform the described mutation; program decline in chat only resolves the card, unlike Journeys' decline method.
- Web telehealth styling changes outside the join window, but the link remains clickable. Source does not supply native's disabled behavior.
- Medication thumbnails call `img("med:<id>")`; because that helper always returns a string for a nonempty input, the valid medication fallback is bypassed and a nonexistent filename can be requested.
- `setProfile`, `setEraWarmth`, memory delete/add-note methods, `acknowledgeResult`, `submitRequest`, `rescheduleAppointment`, and document add/confirm/remove have no discovered callers outside store. `applySaving` is referenced only by unreachable Savings. Implemented store methods are not user-accessible features.
- Custom `W/ui/Sheet.tsx:21–48` is a positioned overlay, not a native dialog. Backdrop dismiss exists; focus trapping, Escape and drag dismissal are absent.

### Real browser transport versus simulated outcomes

`W/ai.ts:19–58` uses the same Sonnet model and chat endpoint and parses SSE, but omits native's explicit temperature, max_tokens and 45-second timeout. It can return empty assembled output where native throws an empty-response error. `web/vite.config.ts:21–23` explicitly exposes both VITE and EXPO_PUBLIC prefixes, so use of public EXPO names is intentional here. `HAS_KEY` is unused and not a validity check. Errors fall back to scripts without a clear degraded-mode label.

`W/screens/Conversation.tsx:113–238` uses getUserMedia, MediaRecorder, Web Audio RMS, multipart STT and MP3 TTS. It is a real client path, not verified operational service. Risks include animation-frame-dependent silence thresholds, no no-speech timeout, stop on an inactive recorder, incomplete network-error handling, no cancellation of in-flight voice requests, and potential playback promise wait after a rejected autoplay. Web glow meters microphone but not spoken playback. Server multipart forwarding is also defective, as documented below.

Everything called sent/paid/booked/connected in web still uses local mutations, not external care/payment providers. `W/store.tsx:569–598,639–679` is the critical evidence. Fixtures are the only clinical/agent source; no user account or patient data service joins the two platforms.

### Parity contract currently not met

Native has richer onboarding identity/tone, real held-photo selection, subject lifting, a Privacy Center, request composition, document metadata creation/confirmation/removal, reschedule/Trip views, conflict sheet and inspectable garden. Web has separate navigation/state and weaker media. Both still have simulated clinical operations, unsaved habits and incomplete privacy. Native does not become production-ready merely because web lacks a corresponding screen.

## Design and construction reference

This section records **existing** design/construction so it can be recreated. It is not visual direction for the re-scope, and is intentionally excluded from the functional requirements document. No current Figma file was supplied or checked.

### Tokens and typography

`N/Utilities/Theme.swift:28–98` supplies dynamic day/night colors and separate companion/daypart/conversation palettes. `W/theme.ts` and `web/src/index.css` mirror many colors, not identical rendering.

| Token | Light | Dark |
|---|---|---|
| base | `#F6EEE3` | `#0D1126` |
| surface | `#FFFCF7` | `#1E2449` |
| raised | `#FFF8EE` | `#2A3160` |
| ink | `#2E2418` | `#F4F1EA` |
| inkMuted | `#6F6151` | `#A7ADCE` |
| edge | `#E7D8C4` | `#3A4178` |
| shadow | `#C59A6E` | `#000000` |
| warm | `#E0764E` | `#FF9E7E` |
| life | `#7FAE7E` | `#8FEFC0` |
| sky | `#6E9CC8` | `#8FC6FF` |
| gold | `#D9A348` | `#C8B6FF` |
| rose | `#D8849B` | `#FF9FB2` |
| attention | `#D98A3D` | `#FFBE8F` |
| dockTint | `#F4FBFF` at 0.30 | `#3C4A86` at 0.30 |

The night gold token is lavender. Background dayparts are dawn 05–09, day 09–17, dusk 17–21, night 21–05. Conversation uses deeper palettes. Warm attention is an aesthetic choice, not a substitute for clear urgent meaning.

`N/Utilities/NudgeType.swift:10–59` uses HermioneFREE for display, Fraunces 400/500/600/700 and 400 italic for editorial text, system rounded for functional text and monospaced digits for numbers. Kicker is 11pt semibold. Native registers six bundled fonts at launch; web declares six font faces. Fixed custom font sizes mean Dynamic Type support must be assessed rather than assumed.

`N/Utilities/NudgeSpring.swift` defines UI response/damping 0.42/0.82, gentle 0.55/0.86 and delight 0.38/0.66. The comment that only springs are used is not literal: other animations exist. `Glossary.swift` contains vocabulary constants/commented bans, not a runtime filter.

### Complete shared-component construction inventory

All files in this table live under `V/Components/`; together with the screen map they account for all 56 native view files.

| File | Construction / use / limitation |
|---|---|
| `Chips.swift` | ProvenanceChip, SponsorChip, FreshnessChip, Kicker. Material capsules and supplied source/date; freshness dot is not live connectivity verification. Sponsor delegates an explanation action. |
| `GlassSurface.swift` | GlassSurface, OrganicSurface, NudgeButtonStyle, ChromeIcon, CircularGlass, CapsuleGlass, LightSweep, AmbientLightSweep. iOS 26 glass versus older layered material; organic default radius 36, surface 0.96, gradient edge/tinted shadow; press scale 0.96 and opacity 0.88. Ambient sweep helper has no discovered production caller. |
| `GlowChart.swift` | Swift Charts line/area plus blurred layer, Catmull–Rom interpolation, reference band, reveal and nearest-point scrub. Compact charts omit scrub. Not a new measurement or inference source. |
| `LightGardenView.swift` | GardenEntry and deterministic Canvas lights, capped at 60; touching a light reveals habit/date. Visualizes current dates, not durable progress by itself. |
| `LivingGradientView.swift` | Metal color effect at 20Hz, time factor 0.011; pauses for reduced motion/background. |
| `MeltModifier.swift` | Animatable shader alpha erosion for moment dismissal; not physical fluid geometry. |
| `MemoryOrbView.swift` | Photo inside iOS 26 circular glass or shaded fallback; arc viewer/PhotosPicker described above. |
| `NudgeDock.swift` | Five native buttons, cool-tinted glass capsule and warm selection; Care dot derives from local unread count. Not a standard retained tab-stack controller. |
| `OrbView.swift` | Three procedural shader shells, additive blend, specular highlight, breath/halo and HaloRing; supplied state drives rendering. |
| `ProgressiveBlur.swift` | Three gradient-masked material layers with 2.5/7/14 blur. Approximation, not continuous variable blur. `topMist` helper unused. |
| `RippleEffect.swift` | RippleModifier, RippleEffect, RippleOnTap; radial distortion plus local touch light, 1.2s keyframes, spatial tap; reduced-motion bypass. Applied selectively to moments/action/Life/garden, not universally. |
| `SceneVisual.swift` | Five to seven seeded Canvas light forms, deterministic SeededRandom xorshift; backgrounds/empty states. |
| `TideView.swift` | Three sine-wave layers at 30Hz, height from supplied adherence value; partial reduced-motion handling, no underlying adherence computation. |
| `VideoOrbView.swift` | VideoOrbView, OrbVideoSurface, OrbVideoUIView; below 60pt uses Metal Orb, larger orb uses feathered muted video and two-player 0.7s crossfade with Core Animation breathing. |
| `VoiceGradientGlow.swift` | White-core multicolor gradient and 34 seeded particles responsive to provided audio energy; not a speech detector. |

`N/Shaders/LivingGradient.metal` blends three moving radial centers; `Orb.metal` uses sinusoidal rim/swirl/halo; `Effects.metal` implements alpha melt, ripple displacement, light sweep/lens and touch glow. They are 2D shader constructions, not a physically simulated 3D glass world. Applying Metal layer effects over iOS 26 glass is explicitly cautioned against in Ripple source because it can render placeholders.

### Sound, motion and accessibility

`N/Services/SoundEngine.swift` uses AVAudioPlayer, mixed playback, two bed players/crossfades and pooled effect players. Barley Thunder supports onboarding; Stone Kintsugi is the main world; recap has its own score. Five tap recordings follow a phrase pattern and 90ms throttle. `tick()` is intentionally silent. Sound/music toggles are separate; recap uses the sound flag rather than simply the music flag. Scene background pauses/resumes audio. Browser sound uses HTMLAudioElement, cached effects and frame-based fades, not identical pooling/timing; vibration is optional browser capability.

`N/Utilities/Haptics.swift` defines light, soft, medium, success and three bloom impacts at 0/160/340ms. Comments about universal or once-per-session restraint are not a central enforcement mechanism.

Accessibility is partial, not certified: several labels/adjustable controls and reduced-motion checks exist. Gradient/garden/tide/Metal orb/ripple account for reduced motion; video breathing, memory bob and voice glow do not all stop. Body map lacks equivalent selectable actions; custom text sizing and hidden-back flows need assistive-technology evaluation. Web custom sheets lack modal focus behavior; videos survive the limited CSS reduced-motion rule. Color contrast, large text, VoiceOver, keyboard, switch control, hearing/motion accommodations and device-family layout were not exercised in this audit.

## Assets and recreation inventory

Counts are repository-file inventory, not a remote asset-library query or byte-equality audit. Native catalog has **67 imagesets + one colorset + one appiconset = 69 child directories**. It contains 138 files: 70 JSON, 57 PNG and 11 JPG; imagesets alone have 56 PNG and 11 JPG, with the extra PNG being the icon. Web `public/img` has 46 images: 35 PNG and 11 JPG. The 21 missing web names are the new native activity illustrations, not arbitrary missing media.

### Complete image-name inventory

| Group | Semantic asset names |
|---|---|
| Activity — 21 native-only | `broom_dustpan`, `clay_bicycle`, `clay_dumbbells`, `clay_figure_dancing`, `clay_figure_stretching`, `clay_figure_tai_chi`, `clay_stairs_glow`, `clay_treadmill`, `glowing_clay_orb`, `hands_planting_sprout`, `hands_supporting_knee`, `hiking_boots_walking_pole`, `kettlebell_clay`, `leaf_rake_with_pile`, `leg_quad_extension`, `pilates_ring_and_mat`, `resistance_band_clay`, `standing_desk_workspace`, `walking_shoes_stride`, `water_ripples_goggles`, `yoga_mat_bolster`. |
| Feeling/symptom — 15 shared | `belly_stomach_relief`, `ceramic_bowl_glow`, `clay_head_silhouette_glow`, `glowing_orb_in_leaves`, `hand_sparkles_tingling`, `hinge_joint_clay`, `joint_swelling_glow`, `knee_joint_pain`, `leg_cramp_muscle`, `lips_mouth_tender`, `moon_waves_stars_sleep`, `soft_editorial_3d`, `spiral_light_mist`, `thermometer_warmth`, `thread_unwinding_light`. |
| Meals — 6 shared | `grain_bowl_chicken_quinoa`, `grilled_salmon_lemon_greens`, `lentil_soup_bowl`, `oatmeal_bowl_blueberries`, `vegetable_omelette_plate`, `yogurt_parfait_glass`. |
| Medications — 3 shared | `blister_pack_tablets`, `medicine_bottle_pills`, `medicine_bottle_tablets`. |
| Legacy activity/editorial — 4 shared | `dumbbells_towel_wellness`, `soft_editorial_studio`, `terracotta_cream_sneakers`, `yoga_mat_rolled`. |
| Clinical/editorial/recap — 11 shared JPGs | `condition_chemo`, `condition_diabetes`, `condition_procedure`, `currents_a1c`, `currents_father_son`, `currents_kidney`, `currents_salt`, `currents_walk`, `recap_dawn`, `recap_garden`, `recap_path`. |
| Other — 7 shared | `calendar_heart_stethoscope`, `cozy_dinner_table`, `gift_box_sprout`, `notebook_speech_bubble_star`, `open_folder_documents`, `pastel_gradient_glow_bg`, `tree_path_sunset_walk`. |

Native media resides in `ios/Nudge/Assets.xcassets/<name>.imageset/`; each Contents.json identifies the exact filename. Web references `web/public/img`. The 24 activity choices use 21 native illustrations; shared aliases are intentional. Web's 24 choices still reuse four legacy images, including sneakers for several unlike activities. Native Quick Log's activity-category chooser still uses `yoga_mat_rolled`. `LifeLibrary.moveTable` is most-specific-first; preserve fallback `walking_shoes_stride` and legacy facts for old saved entries. Neither image matching nor approximate facts constitute image recognition or clinical nutrition analysis.

### Fonts and media files

Six fonts in both native Fonts and web public/fonts: `Fraunces-400.ttf`, `Fraunces-500.ttf`, `Fraunces-600.ttf`, `Fraunces-700.ttf`, `Fraunces-400-italic.ttf`, `HermioneFREE.ttf`.

Native Resources has **18 files**:

- Music: `music_ambient_bed.mp3`, `music_recap.mp3`, `music_barley_thunder.m4a`, `music_stone_kintsugi.m4a`.
- Effects: `sfx_bloom.mp3`, `sfx_glass.mp3`, `sfx_tick.mp3`, `sfx_whoosh.mp3`.
- Tap notes: `tap_ta_1.mp3`, `tap_ta_2.mp3`, `tap_ta_3.mp3`, `tap_ta_4.mp3`, `tap_ta_5.mp3`.
- Orb videos: `orb_bloom.mp4`, `orb_day.mp4`, `orb_night.mp4`, `orb_speak.mp4`, `orb_think.mp4`.

Web has 12 audio files and the same five video filenames under public/orb; `music_recap.mp3` is absent. Matching filenames do not prove binary equality or active use. Existing photos/art/fonts/audio need retained source and license/provenance review before commercial distribution; this audit does not establish licensing rights. Files under `tmp/assets` and `tmp/ref2` are reference material, not automatically shipped resources.

Subject lifting (`N/Services/SubjectLifter.swift`) uses Vision foreground-instance masks, NSCache limit 60, in-flight deduplication and a PNG disk cache; UIKit/SwiftUI render the result with contact shadow. Fallback is original imagery. Successful cache reuse is implemented, but “processed exactly once forever” is not guaranteed after failure/cache eviction.

## Services and configuration

### Integration boundary diagram

```text
iOS / web UI
├── Local fixture + local persisted state (no shared patient backend)
├── Chat client → Rork toolkit chat endpoint → configured model provider
├── Voice recorder → Functions /voice/stt → ElevenLabs
├── Reply text → Functions /voice/tts → ElevenLabs → local playback
└── OS/browser URL handoffs: telephone, Maps, generic ride site,
    placeholder provider-pay/telehealth URLs
```

No live chargeable calls were made in this audit. Public environment **names**, not values, are recorded here. Configured client code does not prove a deployed secret, connected provider or working call.

| Configuration | Source consumer / purpose |
|---|---|
| `EXPO_PUBLIC_TOOLKIT_URL` | Native AppConfig and web AI base. Native has a toolkit URL fallback. |
| `EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY` | Client-tier toolkit authorization value, despite its name. No value is reproduced here. |
| `EXPO_PUBLIC_RORK_FUNCTIONS_URL` | Voice Worker base; native contains a historical fallback host. That host is not evidence of live deployment. |
| `ELEVENLABS_API_KEY` | Server-only optional Worker environment binding; absent/blank returns 503. Never an app/UI key. |
| Other project public variables | Project/account/auth/API/function identifiers are declared in the environment listing; declarations alone do not establish implemented auth/data services. |

`N/Utilities/AppConfig.swift` reads generated `Config` values. Generated values were not inspected or copied. `web/vite.config.ts` allows VITE and EXPO_PUBLIC prefixes. `functions/package.json` has no dependency-backed data service. No tracked Wrangler config/bindings were found at conventional paths; the managed deployment configuration/secret availability cannot be reconstructed solely from these source files.

### Worker contract and defects

`functions/index.ts:1–109`:

| Request | Source behavior |
|---|---|
| OPTIONS any route | 204, CORS allow-origin `*`, methods GET/POST/OPTIONS, headers Content-Type/Authorization. |
| `/ping` any non-OPTIONS method | JSON ok/time. Does not exercise either provider integration. |
| POST `/voice/stt` | Requires ElevenLabs key; forwards raw body to `/v1/speech-to-text`. **Drops incoming multipart Content-Type/boundary**, a concrete forwarding defect; runtime failure not exercised. |
| POST `/voice/tts` | Parses JSON; text required; upstream `/v1/text-to-speech/<server-held-voice-id>?output_format=mp3_44100_128`; model defaults to `eleven_turbo_v2_5`; forwards audio. |
| Unmatched | 404 JSON. |

TTS defaults: stability 0.48, similarity boost 0.82, style 0.2, speaker boost true. Caller may override model/settings. The exact voice identifier remains in server source and must be authorized in the provider account to reproduce its sound; it is not an entitlement guaranteed by possession of the app.

There is no caller authentication/authorization, rate limit, app-level upload/text size bound, robust runtime schema validation or top-level upstream-error handling. A non-string text can throw at trim. Proxied responses strip set-cookie and add allow-origin; full CORS headers are not consistently applied to them. “Private proxy” refers only to keeping the provider key server-side, not to protected endpoint access.

### Native project settings

`ios/Nudge.xcodeproj/project.pbxproj` declares iOS 18 minimum, iPhone/iPad, generated Info.plist, camera/microphone/photo-library usage descriptions, Swift language mode 5.0, approachable concurrency and default MainActor isolation. No tracked entitlements file, CODE_SIGN_ENTITLEMENTS or SystemCapabilities declaration was found, and no third-party package products are declared. Permission wording is not proof of a camera/Health/auth implementation. Microphone usage wording implying words go nowhere else conflicts with outbound audio processing.

To recreate configured clients, supply appropriate managed configuration and verify permission text, entitlements, provider access and deployment independently. Do not copy secrets into source or promote the historical fallback URL into a production guarantee.

## Safety and governance reality

| Topic | Executable behavior | Missing or overstated guarantee |
|---|---|---|
| Clinical advice | Prompt says do not diagnose/change doses; deterministic symptom branches exist. | No independent clinical output validation; fallback lacks clinical/crisis handling; invented fixture context is mixed with user input. |
| Oncology fever | Prompt names 100.4°F; scripted fever/chills returns urgent. | No entered temperature or validated temperature rule engine. Threshold is historical source content, not adopted as a universal clinical requirement. |
| Procedure safety | Fixed instructions/dates in prompt/support content. | Not derived from actual surgery schedule/team plan; can be stale or wrong for another patient. |
| Crisis/self-harm | No dedicated, verified end-to-end handoff found. | Concerned orb/prompt empathy is not crisis recognition, localized contact coverage or successful escalation. |
| Looking ahead | Native 14-day/opt-out/content checks. | No crisis predicate, reachable native opt-out control, real predictive service or web equivalent gating. |
| AI sharing | Chat/voice code transmits context/audio. | Consent ledger/epsilon does not filter prompt data; no per-purpose sharing enforcement. |
| Outbound approval | Some confirmation dialogs and local approve/decline buttons. | No universal authorization layer or external executor; many approvals simply mark done; declines can show success. |
| Sponsorship | Sponsor labels/explanations; session declined-program filtering in some surfaces. | No validated eligibility/ranking engine, persistent suppression interval or enforcement that sponsorship cannot affect AI claims. |
| Memory rights | Native notes can be added/deleted locally. | Empty-array restore can resurrect notes; external provider retention is not controlled; web memory UI absent. |
| Account/data rights | Local JSON wipe/browser-key reset. | No account/session deletion, complete export, photo/cache purge or remote retention/deletion process. |
| Terminology | Glossary constants and design intent. | Not runtime enforcement; fixture/agent copy can contradict bans. |

Source: `CompanionEngine.swift:268–383`; `PersonaFixtures.swift` support-plan branches; `M.showsLookingAhead`, `enroll`, `decline`; `V/Settings/PrivacyCenterView.swift`; `N/Utilities/Glossary.swift`. No legal/HIPAA/regulatory certification is inferred from these files. Appropriate legal/privacy/clinical owners must determine applicable obligations and approved content.

## Production and dead-end register

Priorities below are **audit recommendations**, not approved implementation scope. “Before real users” means before processing real patient data or making external clinical/financial claims. Each entry gives the missing outcome so the next team can assess completion without confusing a cosmetic fix with production capability.

| Area / priority | Source-backed gap | Completion evidence needed |
|---|---|---|
| Identity — before real users | Welcome Apple/phone and provider flows only advance; web forms cannot accept credentials. | Verified identity/session, recovery/linking policy, expiry/revocation and account isolation; demo explicitly separated. |
| Consent — before real users | Ledger is not an enforcement layer; audio privacy wording contradicts transport. | Versioned purpose-specific consent, revocation effects, permitted data selection and accurate disclosures. |
| Clinical truth — before real users | Fixture scenarios can be sent as real context; shared Marcus records across pathways. | Source/date/patient provenance, missing/conflict handling and separation of demo/user/clinician/AI information. |
| Crisis/clinical safety — before real users | Prompt-only controls, no verified crisis handoff, stale fixed clinical dates. | Clinician-approved rules/content/precedence, localized escalation, service-unavailable fallback and safety evaluation. |
| Chat correctness — high | Web omits latest typed prompt; action parser not semantically validated; fallback undisclosed. | Correct request history, safe malformed-tag handling, explicit degraded mode and action/response evaluation. |
| Voice — high | Multipart forwarding defect; permission-grant cancellation race and other lifecycle/error/temporary-audio gaps; post-record transcript animated to resemble live transcription. | Successful consented STT/TTS contracts, cancellation/error recovery, retention cleanup, truthful transcript behavior. |
| Service security — before public endpoint use | Voice proxy unauthenticated/unbounded; unhandled upstream failures. | Authorized/rate-limited requests, validated inputs, bounded cost, sanitized monitoring and operational runbook. |
| Persistence — high | Habits/journeys/appointments/declines unsaved; empty collections reseed; pathway mixing. | Round-trip/migration/recovery checks, stable ownership and honest save failure/retry; delete-empty stays empty. |
| Account rights — before real users | Export/deletion are cosmetic/partial. | Usable export artifact; complete scoped deletion/session clearing, declared legal exceptions and provider retention handling. |
| Messaging/requests — high | Local sent/submitted flags; Guide/Prep/support separate dead ends. | Actual reviewed payload/recipient, receipt/error/retry/history; portal draft handoff never reported as sent. |
| Appointments — high | Local confirmation/reschedule, stale trip, wrong prep appointment, placeholder join; web recursive team route. | Provider-confirmed status, selected-visit context, timezone/window rules and real join/logistics handoffs. |
| Results — high | Acknowledgment method unwired; invalid metric IDs can blank destination. | Attention deep link to exact result, durable acknowledgment distinct from clinical resolution, unavailable-data exit. |
| Actions/network — high | Approval creates done state; inactive/disconnected agents can approve; no background work. | Authorized execution with idempotent result reconciliation, durable decline/cancel/failure/receipt and true pause state. |
| Reports — high | Range filters only some data; persona names; future data; no PDF/delivery/version. | Correct patient/range/provenance, review snapshot, artifact/version and verified recipient delivery. |
| Payments — before real charges | Paid locally; insurance card selectable; placeholder provider page. | Payment-provider confirmation, eligible tender, exact amount/recipient approval, duplicate prevention and receipt/refund boundaries. |
| Documents — high | Typed metadata only; no field correction/record merge; web mutations unreachable. | Actual source artifact, reviewable extraction/correction, provenance-preserving updates and consistent delete behavior. |
| Savings/sponsorship — before real offers | Savings route unreachable; local application flag; no durable decline/ranking. | Reachable neutral alternatives, eligibility/PII approval, outcome tracking and disclosure/governance evidence. |
| Connections — integration gate | Toggles manufacture accounts. | Approved provider access/scopes/revocation/sync health; unsupported channels disclosed rather than faked. |
| Navigation — high | Today event race; hidden Back; web internal routes not addressable; missing destinations. | Stable destination identity, correct return/restoration, direct/back navigation, empty/unavailable escape. |
| Tracking — high | No history/editing; estimated facts presented with specific numbers; med logs don't update tide. | Correctable timestamps/units/entries, provenance and truthful computed versus estimated summaries. |
| Content — medium | Static Currents; save-to-story no-op beyond flag; timer-only web players. | Actual content/media availability, durable saves/taste, honest media controls and finite-set refresh policy. |
| Accessibility/parity — high | Partial motion/text/semantic support; 21 activity-art gap; modal/voice differences. | Device/assistive-tech evaluation and explicit platform support contract, not just matching screenshots. |
| Notifications — integration gate | Local toggles/no scheduling or push. | OS permission + app preference handling, quiet hours, delivery/privacy rules and failure behavior. |
| Operations — before production | No clinical backend, execution audit, evaluated prediction service or runtime evidence. | Chosen supported services, data retention/security operations, incident response and monitored end-to-end verification. |

## Recreation and verification boundaries

### What a faithful recreation requires

1. Preserve the five-destination shell, omnipresent companion, bounded Today moments, conditional onboarding and independent Care/You flows described above. Recreating current defects deliberately is different from remedying them; label that choice.
2. Carry the native and browser data models/fixture bundles and **their differences**. Preserve persisted raw values, stable bill keys and legacy image aliases. Do not replace fixtures with assumed real data sources.
3. Reuse the recorded fonts, images, videos, audio, design tokens, shader/component construction and cache behavior. Native glass/Metal effects and browser CSS approximations are not interchangeable implementations.
4. Configure chat/voice through managed public client configuration and private server configuration. Provider keys, entitlements, service contracts and authorizations are separate prerequisites; source alone is insufficient to recreate a working production integration.
5. Reproduce only actual local behavior when demonstrating the baseline, with explicit simulation labeling. Do not claim transactions, monitoring, delivery, export or authentication based on existing success text.
6. Use the gap register to decide what must change before real use. Re-scope approval is not implied by this reference.

### Existing validation assets

Native tests contain four source-declared functions across three files: empty `NudgeTests.example`, launch-only `NudgeUITests.testExample`, `testLaunchPerformance`, and launch screenshot `NudgeUITestsLaunchTests.testLaunch`. Source: `ios/NudgeTests/NudgeTests.swift`, `ios/NudgeUITests/NudgeUITests.swift`, `ios/NudgeUITests/NudgeUITestsLaunchTests.swift`. They do not establish clinical, persistence, AI, consent, action or integration correctness.

Web has two test cases: a trivial true assertion in `web/src/test/example.test.ts` and a generic calendar grid/button smoke case in `web/src/test/calendar.test.tsx`; `setup.ts` configures the test environment. The calendar component test is not an end-to-end appointment workflow test.

**This documentation pass ran no app build, tests, simulator installation or live service calls.** Earlier conversation records a successful native build after a simulator installation error; that is historical build evidence only, not verification that installation or the reported runtime problem was resolved. Documentation review checks scope coverage, source correspondence, links and repository diff; it does not substitute for executable verification.

The source baseline was inspected with read-only Git commands. Rork handles repository synchronization automatically; writing these files is not proof of a remote GitHub commit/push. Final repository status should be reported from observed evidence, without a fabricated commit or deployment claim.
