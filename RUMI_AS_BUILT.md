# Rumi / Nudge: as-built reference and production gap audit

## Current delivery — September 17, connected onboarding and continuity

This section supersedes older native implementation descriptions in the historical audit below. The [working specification](RUMI_RESCOPE.md#active-handoff--september-17-connected-onboarding-and-behavioral-support) is the active engineering handoff, [functional requirements](RUMI_REQUIREMENTS.md) define expected behavior, and [screen library](RUMI_SCREEN_LIBRARY.md) lists current/planned journeys and capture coverage. Web and the voice Worker were not changed in this pass.

### Implemented in native source
- **Brand:** supplied mint `#4CC9AB`, blush `#F5BCB5`, butter `#FFE27C`, deep green `#00211A`, with derived accessible text/surface variants. Fields Display OTFs are bundled and registered for headlines; rounded system body remains. Supplied font files are demo versions; production font license remains unverified.
- **Onboarding:** Welcome → Scenario → optional Records → Preferences. `FastenConnectionView` adds a separate profile/scopes/import/review sheet. First/last/email are explicitly sample social-prefill examples; DOB starts empty. Validity and selected synthetic persona are checked; sharing begins unchecked; selected categories and partial demo result states are supported. No social OAuth, Fasten calls or verified patient matching occur. Pending imports commit only on completion, not in Settings preview.
- **Records:** `FastenRecordsCard` in Records and Connections exposes persisted sample import details, provenance, repeat/removal and a real-connection-unavailable notice. Imports are snapshots of selected fixture data, not new clinical originals or vendor sandbox responses.
- **Access:** Rumi and Log sit above the four-tab dock on every main destination. Upper-corner-only companion entry and Today-only Log were replaced; modal workflows retain their own navigation.
- **Chat:** `ChatTransport` is an injectable seam with a stable request identifier. `CompanionAI` retains the configured `anthropic/claude-sonnet-4.6` gateway, validates HTTP/content type/SSE completion and preserves blank separators from raw bytes. The earlier `.lines` framing lost separators and failed the live smoke test; raw-byte framing corrected that issue. No WebSocket adapter is connected.
- **Conversation continuity:** completed turns/composer persist per local demo scenario; streaming restores as interrupted; Stop cancels, Close hides without cancelling. Obsolete requests are guarded by generation/turn identity. Latest failed/interrupted replies can retry without appending another patient turn. No fabricated scripted offline answer remains. Automatic Guide side effects and fake refill/action completion were removed from active chat.
- **Prompt:** removed universal/date-stale medication rules, human/nurse impersonation and never-disclose-limit language. The current prompt states AI/demo/service limits and non-diagnostic guidance, follows patient topic/pace, and uses sample lab context plus patient-chosen habits. This is prompt guidance, not a validated crisis/clinical policy engine. Comprehensive contextual record selection is still pending.
- **Visit prep:** four guided panels for the selected persisted appointment: Focus, Changes, Questions, Review. Notes/practical barriers/medication concerns are patient-authored. Optional AI suggestions send only the selected draft/visit after explicit disclosure; completion is reviewed before inclusion. Export shares reviewed text, not a PDF or EHR receipt. Editing/rescheduling invalidates review. Global Guide items are added explicitly, not copied to every visit. Missing/cancelled visits never fall back.
- **Habits:** extended `AtomicHabit`/`Journey` Codable storage; `HabitSupportPlan` owns reason/cue/barrier/fallback/self-rated doability/pause. New and existing habits can be edited. `HabitCheckIn` records selected-habit outcomes and the plan at the time; one editable daily entry, with smaller alternative, skip, barrier and undo. No clinical plan changes, personality inference, notification scheduling or reinforcement learning are implemented. Today's habit CTA opens Journeys rather than completing an arbitrary first habit.
- **Review-first proposals:** `ReviewedWorkflow` persists draft, reviewed-not-sent and declined states. `WorkflowReviewView` requires an intended recipient and exact text; edits invalidate review. Reopen from chat or the agent overview. This is a local review queue, not a service executor; many older task/report/payment handlers elsewhere remain prototype behavior.
- **Persistence:** optional new snapshot fields preserve compatibility with old JSON: appointments, journeys, check-ins, prep, conversation, composer, import and workflow queue. IDs survive snapshot restoration. Writes use atomic complete-file-protection and return a failure signal. Main shell offers retry; scenario switching aborts on save failure; unreadable existing snapshots are not overwritten. Complete account isolation, recovery/export/deletion, photo cleanup and database migration remain unfinished. Existing Privacy deletion is still not a full coordinated wipe and must be corrected before relying on it.

### Verification so far
- Simulator build succeeded after fixing a MainActor default-initializer error. Device/release build remains unverified.
- First combined selection (`NudgeTests` + `NudgeUITests/NudgeUITests`): 19 passed, 3 failed. Failures were an optional-enum assertion, live SSE framing and connector UI-state checking.
- Corrected selection (`NudgeTests` + connector consent/import UI test): **18 passed in 60 seconds**. After visual inspection corrected Fields Medium/Semibold internal font names and added a font-resolution test, the full selected suite (`NudgeTests` + `NudgeUITests/NudgeUITests`) passed **23 tests in 100 seconds**. It includes the synthetic live gateway smoke check, request cancellation isolation, snapshot/ID continuity, habit correction, review invalidation and five UI journeys. This does not establish clinical quality or all screen states.
- A separate synthetic HTTP probe returned status 200 with SSE and terminal completion. This establishes one technical response path, not clinical response quality, service availability guarantees, Fasten access or the user's dedicated AI backend.
- Ten branded presentation screenshots were accepted; original captures are indexed under `screenshots/captures/iphone/captures.json`. Visual review confirmed real chat response/proposal and selected-visit review in the captured app, and caught the corrected font-name issue. All ten originals and presentation slides were refreshed and accepted after that correction; links are embedded in the screen library. These captures cover primary screens, not every variant. Full VoiceOver, large text, physical-device, voice backend, clinical evaluation and exhaustive visual/state capture remain outstanding.

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

This document records what the existing app does and how it is built. It includes the design, assets, models, service calls, local simulations and known gaps. A new team can use it to understand or recreate the current app.

The findings come from source inspection. They do not establish clinical safety, working production integrations or successful use of every screen. Proposed design, copy, backend and migration changes belong in [the change specification](RUMI_RESCOPE.md). Proposed patient-visible behavior belongs in [the requirements file](RUMI_REQUIREMENTS.md).

The attached product-requirements guide applies only to the requirements file. It does not restrict this reference's design or technical detail. This revision uses the supplied [Unslop](https://skillsllm.com/skill/unslop) and [ASD-STE100 writing reference](https://github.com/danyuchn/asd-ste100-skill) to improve clarity. Exact code names, values, source quotes and uncertainty are retained. No certified STE compliance is claimed.

**Audit date:** September 16, 2026. **App source baseline:** `e11670626f181a73c120118d28eb9d09d3a960ac`. The initial working tree was clean. This documentation revision started from `d0f62d427e333e6d0a3219e86170574c7e791ea8`. Application source was not changed during either documentation pass. The subsequent approved first implementation stage changes navigation, reply drafts, selected-visit preparation and demo-scenario snapshot handling as described below. Older line ranges remain baseline locators, not current line numbers.

The original source review covered 56 native Swift view files, 11 models, three view models, five services, six utilities and three shaders. It also covers the separate web app, Worker, configuration, assets and declared tests.

Paths are relative to the repository root. In tables, **N/** means `ios/Nudge/`, **V/** means `ios/Nudge/Views/`, **M** means `ios/Nudge/ViewModels/AppModel.swift`, and **W/** means `web/src/sano/`. Line ranges refer to the inspected snapshot. Use named symbols to locate code after later edits.

### Historical native warm-style validation — earlier September 17 pass

- Applied the supplied Platform Flows visual language in the native app only: cream/amber/earthy tokens, quieter cards, smaller companion mark, labeled Log control and compact visit/metric access. Web remains at the prior visual/onboarding version.
- Replaced native onboarding with three screens and a non-mutating Settings preview. Stored user data and saved preference values are not reset; this is not a new authenticated patient mode.
- `swiftTest` selection `NudgeTests` plus `NudgeUITests/NudgeUITests` passed **12 tests** in 106 seconds. The selection contains nine unit tests and three UI flows covering onboarding selection/Back/Skip, unavailable sign-in and preservation of the active scenario after welcome preview. An earlier attempt could not compile because an obsolete animation counter was still referenced; that reference was removed before this passing run.
- Simulator compilation succeeded. Full VoiceOver, large-text, day/night visual evaluation, physical-device builds and service integration validation remain outstanding. These tests do not establish clinical readiness.

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

`LEGACY_REQUIREMENTS.md`, the v3/v4/v5 specifications and the older polish plan provide historical context. Source code takes precedence when describing current behavior. This audit corrects conflicting as-built claims without rewriting those historical documents. Claims such as "everything persists", "everything deleted", "always watching" and "nothing leaves the device" exceed what the code implements. The web app is not a faithful behavioral mirror of native.

## Product and repository

Rumi is a chronic-care companion app. Its persistent orb opens text or voice conversation. Today shows a few moments, Care holds care tasks, and You holds the health story. Journeys shows small habits. Currents provides a finite set of educational pieces.

The app uses warm language, day/night backgrounds, glass controls and illustrated objects. It is a **fixture-backed interactive prototype with real AI and voice network clients**. The clients can send data externally. They do not make the simulated clinical and financial operations real.

| Registered app | Folder | Actual role |
|---|---|---|
| Nudge | `ios` | SwiftUI app, iOS 18 minimum; iOS 26 glass guarded by availability. Target/product/module naming remains Nudge; CFBundleDisplayName is Rumi in both build configurations, matching the companion/product copy. |
| Rumi | `web` | Independent Vite/React/TypeScript implementation, not shared native UI or shared user data. |
| Functions | `functions` | Dependency-free Cloudflare Worker forwarding speech requests to ElevenLabs. Not a patient database or clinical integration layer. |

Source: `rork.json`; `ios/Nudge.xcodeproj/project.pbxproj`; `web/package.json`; `functions/package.json`.

### Startup and state construction

`NudgeApp.swift` registers fonts, creates the observable model and manages ambient audio when the scene changes. `ContentView.swift:10–24` draws the living background. A local flag selects onboarding or `RootView`. `RootView.swift:14–95` mounts the tab, mini-orb, dock, conversation, acknowledgment toast, three sheets and recap cover. Startup does not check a server session.

`AppModel.init:178–254` selects the saved pathway and seeds clinical and engagement arrays from fixtures. It then restores a matching local snapshot. `CompanionEngine` holds a weak model reference. `OrbState` holds the companion's visual state.

Native uses Swift Observation and SwiftUI environment access. Web has its own `SanoProvider`, state and localStorage snapshot. The two apps do not share Swift source or patient data.

### Personas

| Pathway | Fixture person | Domain focus |
|---|---|---|
| `metabolic` | Marcus | Type 2 diabetes, blood pressure, ongoing habits and medication logistics. |
| `oncology` | Elena | Treatment cycles, symptoms and between-visit support. |
| `procedure` | Sam | Procedure preparation and recovery. |
| `cardiometabolic` | Rosa | Diabetes with heart disease and kidney-risk context, multiple specialists. |

`N/Models/CareProfile.swift` defines pathways and personas. `PersonaFixtures.swift` supplies clinical and engagement scenarios. `CareHubFixtures.swift` supplies messages, appointments, bills, documents, requests and looking-ahead content.

Programs, raw records, sources, consent entries and initial memory largely use shared Marcus fixtures. Selecting Rosa chooses a scripted scenario, not a kidney prediction model. An entered name can appear beside invented clinical data, while reports still use the persona's name.

## Current information architecture

**First implementation stage:** both platforms now expose Today / Care / Messages / You. Native shares `CareRouteView` and `YouRouteView`; Care, Messages and You navigation paths live in `AppModel`. Web retains scoped `useStack` paths in `SanoProvider`; these remain internal routes, not browser URLs. Reply drafts are persisted separately from sent/demo messages. The [change specification](RUMI_RESCOPE.md#proposed-information-architecture) owns further target changes.

The map below retains the detailed historical route inventory for compatibility. Its hierarchy is the **pre-change baseline**, not the current visible menu. Current entry-point ownership is: four Care tiles (Appointments, Care plan, Meds & refills, Records & results); Messages owns inbox/requests; You has Journeys, Currents, Life, Connections and Settings; visits retain Guide/reports; Records retains Documents; Bills retains Wallet.

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

- Native Care, Messages and You use conditionally mounted `NavigationStack`s with session paths retained in `AppModel`. Changing tabs no longer discards those paths. Root bars are hidden; most pushed views do not supply an explicit Back button. Source alone cannot guarantee a visible back affordance in all states. The dock supplies a root escape; interactive back behavior was not exercised.
- Quick Log/settings/network are presented modally; recap and voice are covers. Most sheets rely on system dismissal as well as any explicit controls. Agent detail explicitly hides its navigation bar without adding a Back control; dismissal is the reliable source-defined exit.
- Today condition/Life shortcuts set the retained destination before selecting You. Insight moments clear stale You detail paths and select Insights; they still do not focus an exact insight item.
- Missing appointment/thread/bill/document IDs show unavailable content. Shared native You routing now also supplies unavailable states for missing series and medication IDs.
- `CareDestination` contains **17 cases**, including `.savings(String)`. A case in this enum is not evidence of a reachable screen. `openCare` is called by Today updates and sends communication destinations to Messages. This is internal contextual routing, not verified external deep-link support.

Sources: `V/RootView.swift:14–95`; `V/Today/TodayCanvasView.swift:141–145,257–262`; `V/Today/MomentCard.swift:127–145`; `V/You/YouView.swift:47–60,156–188`; `V/Care/CareHubView.swift:243–293`; `N/Models/CareHubModels.swift:12–30`.

## Native screen and journey reference

This section and the shared-component inventory cover every native view file. Parentheses identify secondary screens defined in the same file. The preceding navigation limitations apply unless a specific exit is described.

### Welcome and onboarding

**Current native refinement (September 17):** three screens replace the eight-stage flow: welcome, explicit demo scenario, optional tone/music preferences. Back retains local selection. Skip completes without applying edited preferences. No onboarding chat, wait sequence, name/birthday collection, pretend identity confirmation or provider/Health connection tour remains on the active path. Sign in presents an unavailable notice and does not advance. Settings → Preview the welcome runs the same screens without writing preferences, changing scenarios or resetting saved data. Live identity, legal acceptance and clinical connectivity remain unimplemented. The legacy connection/interview components below are retained source, no longer stages of native onboarding.

| File / surfaces | Entry, content and actions | Result, return and limitations |
|---|---|---|
| `V/Onboarding/OnboardingFlowView.swift` | Welcome → sample story → optional preferences, with Back, explicit Continue and Skip. Three-stage progress; cream/amber treatment; small concentric mark. | Native sign-in is explicitly unavailable, not simulated. Final completion commits the chosen sample pathway and optionally preferences. Preview completion only dismisses. No personal identity fields are collected. |
| `V/Onboarding/RecordConnectView.swift` — provider picker/sign-in/match/found, HealthKitAsk, EpsilonConsent | Seven fixed providers searchable locally; username/password; identity derived from entered profile; delayed discovery sequence; skip/back/not-me; individual Health toggles; separate yes/no personalization consent. | Username nonempty gates mock sign-in; password is unused outside local UI. Match stores provider name only. Health Connect persists its Boolean before the one-second delay, ignoring selected scopes; no HealthKit authorization. Skip continues. Epsilon persists a Boolean but does not gate AI data transmission. See `21–36,177–331,398–560`. |
| `V/Onboarding/OnboardingConversationView.swift` | Two nonblank personal answers followed by tone selection, with local word-streamed questions (about 45ms per word after a 350ms delay). | This step advances to Epsilon. Final onboarding completion after that choice saves answers as memory notes and tone, celebrates and enters Today. These are not model-generated interview turns. No skip/back in this step. See `16–20,36–123`; M.`completeOnboarding`. |

The current native stage identifiers are welcome, scenario and preferences. The old web onboarding remains separate and unchanged. Completion stamps onboarding time, which later gates looking-ahead visibility. The flow does not include functioning terms acceptance, analytics consent, notification authorization, Google SSO or a crisis handoff. These belong to the proposed re-scope rather than as-built onboarding.

### Today and global entry points

`V/Today/TodayCanvasView.swift` renders a Rumi wordmark, Demo label and Settings; a mute control appears if music is playing. A 66pt concentric mark, date and greeting replace the large video orb. The earliest upcoming non-cancelled appointment links to that exact visit and preparation; past fixtures are not substituted. Consolidated updates retain their routes. Up to three sample metrics show actual stored values and dated sparklines, linking to exact series details under Care. Existing proposed action, helper link and up to three moments remain below. Life appears only with today's entries. A labeled static Log button replaces the pulsing plus; a bottom spacer clears the dock.

Today no longer binds pull-to-talk or offsets the scroll view. Tapping the small mark or the labeled Ask Rumi button opens the companion. The conversation header now uses the compact amber mark rather than a large tappable video orb.

- The companion mark or Ask Rumi enters conversation. Settings presents a sheet. Today updates open their stored destination: exact threads, bills and appointments; result/refill targets remain category-level and need further work. Plus opens generic Quick Log.
- First proposed action uses `AgentActionCard`: approval/decline modifies session state and acknowledges. It does not perform a payment/refill/message.
- `LifeThumb` entries route to the shared Life shortcut rather than the selected item. Thumbnail media is bundled/locally resolved.
- `V/Today/MomentCard.swift:50–63,127–160` supports swipe dismissal, local melt, and a single action. Insight selects You/Insights; habit keeps the first habit in the first journey; task always seeds refill conversation; check-in opens generic conversation. These are not per-moment typed business operations. Dismissals/kept dates are session-only; there is no undo.
- `V/RootView.swift` also defines `CompanionAckToast`: log acknowledgements appear above the dock; tapping clears them and opens a generic pattern-seeded conversation. Quick Log does not schedule automatic clearance. Some action/report/payment handlers separately clear their acknowledgements after approximately five seconds; the toast itself has no universal timer. The acknowledgement itself is not a delivery receipt or data-quality check.

### Care hub and attention

`V/Care/CareHubView.swift:20–47,79–168,222–293,357–421` includes `CareTile` and `LookingAheadCard`. Four tiles lead to Appointments, Care plan, Meds & refills, and Records & results. Care team and Bills & wallet are quiet secondary links. Messages/Requests have their own primary home. Visit prep and reports are with appointments, Documents with Records, and Connections with You. Savings retains its renderer but still lacks a discovered native entry control.

`M.needsYou` builds attention items from unread threads, an unacknowledged result, low supply, unpaid bills and pending appointments. `careUnreadCount` is narrower: new care-team messages plus result. This is derived fixture/local state, not a clinical alert service. The result acknowledgement method exists but no current UI caller was found; opening Records need not clear the result.

Looking-ahead explains a fixture population basis and can add a guide question, then open Guide. Native visibility checks available content, opt-out and 14 days since onboarding. There is no crisis gate in the predicate and no reachable opt-out control found, despite stored support for the preference. This is not a deployed predictive model or personalized probability estimate.

### Messages and requests

| Surface | Journey and content | Actual effects and dead ends |
|---|---|---|
| `V/Care/MessagesView.swift` — Messages, ModeChip | Care/attention → inbox, showing practice/member, latest text, time, unread and channel mode. Requests link opens request list. | Fixture threads and local additions. Channel labels distinguish in-app from portal drafts but establish no transport. See `22–51`. |
| Same file — MessageThread, MessageBubble | Open thread → chronological care/user messages; origin/attachment labels; composer → send or save draft. Dismiss/pop returns to inbox. | Read flags and reply drafts now save immediately; reply draft text survives tab changes/relaunch within its saved scenario. Send appends a locally persisted `.sent` or `.draft` message and clears composer. No delivery, retry, attachment handling, new recipient/thread UI or portal copy/open handoff. Attachment is a string label, not a file. See `119–319`; M.`sendMessage`, `markThreadRead`. |
| `V/Care/RequestsView.swift` — Requests, RequestProgress, ComposeRequestSheet | Messages → Requests → create refill/appointment/records/form request; optional subject/detail → Send → sheet closes; read-only three-step progress. | Persists a local submitted request with constructed routing text. Blank subject defaults to kind. No actual office submission, request detail, cancellation, receipt, or transition from submitted to resolved. See `24–246`; M.`submitRequest`. |

Symptom support still has a separate view-local send-success control. Guide and Visit prep now explain that EHR delivery is not connected and do not claim success or create a Messages entry. They are not connected to one communication workflow.

### Appointments and visit logistics

`V/Care/AppointmentsView.swift` defines Appointments, AppointmentDetail, AppointmentRow, DateStone, KindChip, StatusChip, RescheduleSheet and TripView (`22–190,240–275,355–578`).

1. Care → list → selected visit detail. Dates, provider, location, kind/status and goal hint come from fixtures. The list is not strictly future-only.
2. Confirm updates session appointment status and may add a local completed agent task. Reschedule selects a time and confirms in a sheet, then returns to detail. Neither contacts the office or Calendar. Trip departure data is not recalculated after a new appointment date. There is no ordinary booking/cancel UI, despite a model helper for booking.
3. Telehealth Join is enabled by `canJoin` when kind/link qualify and the Calendar whole-minute difference is between −90 and +15. This is approximately 15 minutes before through 90 minutes after, but truncation admits a portion of the adjacent minute rather than enforcing exact elapsed seconds. There is no appointment-status check or dedicated ticking refresh; fixture join URLs use `.example`. The URL handoff is real API code, not a real virtual visit.
4. Trip detail shows fixed depart-by/travel/route/parking/checklist/conflict/ride content. Checklist completion is view-local. Maps opens a query; ride opens a generic Uber page. No route calculation, ride booking, calendar query, conflict resolution or telehealth device-readiness check occurs.
5. Prep carries the appointment UUID into `VisitPrepView` and resolves only that visit. Missing selections show unavailability rather than substituting the first appointment. The underlying clinical summary remains sample text, not a generated reviewed EHR artifact.

`V/You/CareTeamView.swift:17–126,151–271` defines both CareTeam and VisitPrep. You/Records → team displays people and appointments. Every Call control invokes the same persona office number via `tel://`, not a verified member-specific number. Prep-ready visits link to a brief; Guide is shared. The brief's changes and packing list are fixture text; its question list contains unresolved Guide items of kind question, excluding unresolved observations. Send now explains that EHR delivery is unavailable; no office delivery or success flag occurs. There is no separate HCP/staff app in this repository.

### Care plan and discussion guide

- `V/Care/CarePlanView.swift:10–106`: author/update/intro/goals and current progress. Deriving a tiny journey immediately maps the goal to a behavioral habit and saves a goal marker; no preview, undo/removal or immediate Journey navigation. The journey object is session-only while its marker persists, producing a relaunch inconsistency. Source: M.`deriveJourney`, `behavioralHabit`.
- `V/You/DiscussionGuideView.swift:28–215`: open via You, care team, or looking-ahead. Add question/observation, mark covered/uncovered, delete; these call persisted Guide handlers. Text editing is missing. The general Guide no longer assigns itself to the first appointment. Send explains that delivery is not connected without claiming a sent outcome. Conversation guide tags can insert items automatically, without an additional review step.
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

Programs and sponsorship use static fixtures. There is no live eligibility matching or sponsored inventory service. Consent and decline limitations appear in the governance section.

### Currents

`V/Currents/CurrentsView.swift:9–42,47–120,152–228` defines Currents and CurrentPage: finite paged pieces and an end scene; format controls; save, taste and Ask. `saved` and `taste` change session flags; “saved to story” does not add story content, and taste does not regenerate the feed. There is no daily refresh engine or saved-content browser.

`V/Currents/CurrentsPlayerSheets.swift` defines ListenSheet, WatchSheet, LoopingVideo, LoopingVideoUIView and WaveformView (`6–121,126–293`). Listen plays the **same bundled music**, not narration of the selected article, with pause/seek/progress and displayed piece text. Watch loops thinking-orb footage with timed captions and music, not an article-specific film; no pause/seek/end dismissal. Waveform is procedural. Player music can operate independently of the global music flag; Watch does not restore the ambient bed on exit. These distinctions matter when recreating both the appearance and actual functionality.

### Settings and Privacy Center

`V/Settings/SettingsView.swift:25–87,120–232`: editable names, tone, Auto/Day/Night appearance, sound/music, era warmth, notification classes, quiet-hour display, pathway preview and Privacy navigation. Names/preferences save locally; appearance/audio/tone have consumers. Era warmth is stored without a discovered behavioral consumer. Notification classes are session state with no scheduler. Quiet hours are display-only. Pathway preview swaps fixtures and can discard unsaved/session data; it is not switching authenticated patient accounts.

`V/Settings/PrivacyCenterView.swift` defines PrivacyCenter, MemoryRealm, Lens and FlowingWords (`32–120,134–269,281–434`). Realm words select remembered-note groups; add/forget mutates persisted memory. This is add/delete, not inline text editing. Source freshness is read-only; no provider revoke/reconnect exists. Most personalization explanations are fixed copy. A separate personalization toggle directly changes persisted epsilonConsent. Ledger toggles are session-only except that the epsilon ledger entry writes either Boolean value into that preference; changes through the separate toggle do not synchronize the ledger back. Neither control governs data sent in prompts.

**Export** only sets a view Boolean and shows prepared-copy; no file/share/export. **Delete** calls `PersistenceService.wipe()` for one JSON file, leaving live data, preferences, photos, caches and conversation. A subsequent save can recreate it. Neither action fulfills its on-screen account/data-rights claim.

## Companion and voice

### Conversation surface and orb

`V/Conversation/ConversationView.swift` defines ConversationView, InputGlass, ConversationScene, TurnView, ConversationProgramCard, StreamingText and ThinkingShimmer (`31–35,87–245,334–625`). Companion words render directly on a deeper ambient canvas; user words appear in glass; rich content arrives after text; input can send or enter voice. Closing cancels an active generation and restores the underlying tab but does not clear chat history. The conversation's old decorative tap-to-listen orb was removed; voice is still entered through the explicit microphone/voice control. Pathway-specific starter prompts appear while history contains at most one turn. The header also provides direct Day/Night and music controls and drag dismissal (`ConversationView.swift:77–79,115–188`).

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

The table below describes the current domain models. It is not a proposed database schema. Source files contain the exact types and initial values. When recreating the demo, keep fixture arrays labeled as fixtures. Never import them as real patient records.

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

M owns native view state. `W/types.ts` and `W/store.tsx` define the separate browser model. Similar names do not establish shared IDs, account ownership or sync.

Many fixture entities generate UUIDs at initialization. Bills use explicit stable paid keys for persistence across launches. There is no migration layer guaranteeing stable references for other saved or generated IDs.

## Persistence and account boundaries

### Native

`N/Services/PersistenceService.swift` writes `sano_demo_<pathway>.json` in Documents using ISO-8601 dates and atomic writes. A matching legacy `sano_user_data.json` is read as fallback and left intact. Saved scenarios no longer overwrite one another. This is limited prototype scenario preservation, not account/mode isolation, a complete migration system or remote sync. Save failure is not shown to the patient. A failed decode returns nil, which can cause startup to reseed fixtures.

| Storage | Contents / actual boundary |
|---|---|
| UserDefaults | Onboarding flag/date, tone, epsilon, era warmth, sound, music, appearance, looking-ahead opt-out, pathway, profile and per-pathway result acknowledgment. Profile includes names, optional birthday, Health Boolean and provider-name list. |
| JSON snapshot | Pathway, entries, logs, memories, guideItems, memoryNotes, threads, requests, documents, paidBillKeys, derivedJourneyGoals, optional messageDrafts. |
| Separate local files | User-selected held photos; temporary microphone audio; lifted-image PNG cache. These are not deleted by `wipe`. |
| Session/view only | Chat, moments, insights, full journeys/habit dates, program enrollment/declines, medication adherence/supply changes, appointments, savings, wallet/connections, agent toggles/tasks/actions, report-sent keys, Currents bookmarks/taste, notification classes/quiet hours, most consent ledger state and send/export confirmation Booleans. |

Native defaults: not onboarded; Straight talk; epsilon false; era warmth Subtle; touch sound true and background music false; Auto appearance; looking-ahead opt-out false; metabolic demo pathway. Existing saved preference values remain unchanged. Missing onboarding time falls back to 60 days ago. These are source facts, not recommended privacy defaults.

M.`persistUserData:258–271` runs after entry, log, memory, Guide, message, request, document, paid-bill and derived-goal operations. It does not run after every model write. Thread-read state and reply drafts now save directly. A later snapshot can still incidentally save enrollment memory.

`M.init` now restores saved collections even when empty, preserving deletion of the last item. The optional new draft field keeps earlier snapshots decodable. Missing/corrupt snapshots still require a stronger recovery boundary before regular use.

`switchPathway` saves the outgoing supported collections, clears session paths/drafts, seeds the new scenario and restores its matching saved collections, including drafts. Unpersisted arrays still reseed; some shared source/program/profile information remains. This does not satisfy full unified-record or account isolation requirements.

Derived-goal keys can survive without their Journey objects. The retained key can then prevent recreating the missing journey. Export and deletion have the limitations described above.

### Web

`W/store.tsx:122–127,152–207,225–233` reads/writes active `localStorage` snapshot `sano.web.v1` plus a saved snapshot for each visited demo scenario at `sano.web.v1.demo.<pathway>`. The payload is:

```text
hasOnboarded, pathway, profile, tone, appearance, musicOn, soundOn,
epsilon, eraWarmth, notifs, justBloomed,
entries, logs, memories, guideItems, memory, threads, requests, documents, messageDrafts
```

Web has no schema validation, migration, account scope or server sync. Storage failures are ignored. It does not persist bills/paid state, derived-goal keys, habits, appointments, programs/declines, agents/connections, report sent state, saved Currents, insights, result acknowledgment, quiet hours or chat. The two platforms differ even when their interfaces both appear to save an action.

Pathway switching saves the outgoing supported collections and restores the matching incoming scenario, including unsent reply drafts. `cost` remains the initial bundle because it has no setter; some shared memory/program/profile fields remain. Wipe removes the active key and four scenario keys and reloads: browser reset, not cloud/account deletion. Existing platform storage protections should not be confused with an audited app encryption/retention policy.

## Web implementation and parity

### Routes and complete screen-file map

`web/src/App.tsx:14–26` has **only `/` and wildcard `*`**. `/` renders Index → SanoProvider → SanoApp. The wildcard is NotFound with a home link. `W/SanoApp.tsx:33–87` constrains the product to a maximum 440px column and switches local tabs. Browser Back does not operate the internal stack. React Query provider presence does not establish server-backed care state.

All 13 files under `W/screens/` are covered here; they are not 13 URL routes.

| File | Rendered surfaces and flows |
|---|---|
| `Onboarding.tsx` | Welcome → aboutYou → path → shaping → connect → health → two-question talk → epsilon. Provider picker/sign-in/match are local; declared found phase is not entered. No working social/phone authentication. Provider text fields have empty controlled values/no-op change handlers. Health waits 900ms then appends a label; any connection can incorrectly imply Health connected. |
| `Today.tsx` | Settings, condition→retained Conditions route, orb→chat, consolidated updates, proposed action, helper link with waiting count, moments, Life shortcut, Quick Log. Life/Conditions destinations no longer depend on mount-time events; insight opens Insights. |
| `Care.tsx` | Four-workspace Care hub plus separate Messages root using the shared renderer; Messages→thread/requests; appointments→detail/prep; carePlan; meds/detail; records/category/lab; bills/detail/payment; documents/detail; reports/review; wallet; connections/network; Savings renderer without incoming UI. Requests lacks composition; documents lacks add/confirm/remove UI despite store functions. The visitPrep route renders an appointment-scoped GuideScreen rather than native's separate sample changes/packing-list brief. Missing IDs do not silently substitute another visit. |
| `You.tsx` | Story/Insights; direct Journeys, Currents, Life and Connections; Settings control. Clinical aliases remain. `appointmentDetail` now opens the selected AppointmentDetail, not another team list. Embedded Journeys/Currents use a device-frame overlay portal for viewers/readers. |
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

Web's sent, paid, booked and connected states come from local changes, not external care or payment providers. See `W/store.tsx:569–598,639–679`. Fixtures supply the clinical and agent data. No account or patient-data service connects the two platforms.

### Parity contract currently not met

Native has richer onboarding identity/tone, real held-photo selection, subject lifting, a Privacy Center, request composition, document metadata creation/confirmation/removal, reschedule/Trip views, conflict sheet and inspectable garden. Web has separate navigation/state and weaker media. Both still have simulated clinical operations, unsaved habits and incomplete privacy. Native does not become production-ready merely because web lacks a corresponding screen.

## Design and construction reference

This section records existing design and construction. The change specification describes how to reuse or alter it. These measurements and implementation details belong here, outside the functional requirements file. No current Figma file was supplied or checked.

### Tokens and typography

`N/Utilities/Theme.swift` now supplies warm-paper and espresso day/night colors with amber, clay and olive accents, based on the supplied Platform Flows. `W/theme.ts` and `web/src/index.css` retain the previous palette; this refinement changes native only.

| Token | Light | Dark |
|---|---|---|
| base | `#FAF7F1` | `#1C1915` |
| surface | `#FFFDFA` | `#29241E` |
| raised | `#F4EBDB` | `#352D23` |
| ink | `#30281F` | `#F6EEE1` |
| inkMuted | `#766958` | `#C2B39E` |
| edge | `#E8DFD1` | `#4B4032` |
| shadow | `#AA8555` | `#000000` |
| warm | `#98621C` | `#E2AD60` |
| life | `#68734C` | `#B2C28D` |
| sky | `#61796F` | `#ACC6B8` |
| gold | `#A36A1E` | `#E9B76E` |
| rose | `#AC6D56` | `#D9A18A` |
| attention | `#A35325` | `#EAB17E` |
| dockTint | `#FFFAED` at 0.25 | `#493A26` at 0.25 |

Gold stays amber at night. Background variation is restrained warm paper by day and espresso at night; conversation uses a slightly deeper amber wash. Warm attention is an aesthetic choice, not a substitute for clear urgent meaning.

`N/Utilities/NudgeType.swift:10–59` uses HermioneFREE for display and Fraunces 400/500/600/700 plus 400 italic for editorial text. Functional text uses system rounded. Numbers use monospaced digits. Kicker is 11pt semibold. Native registers six bundled fonts at launch. Web declares six font faces.

The helper accepts sizes from each call site. It does not define one named heading/body scale or explicit `relativeTo` roles. Custom font and system-size APIs differ in scaling behavior. Dynamic Type, text wrapping and control layout still require device evaluation.

`N/Utilities/NudgeSpring.swift` defines UI response/damping 0.42/0.82, gentle 0.55/0.86 and delight 0.38/0.66. The comment that only springs are used is not literal: other animations exist. `Glossary.swift` contains vocabulary constants/commented bans, not a runtime filter.

### Current sizes and layout

These values come from source, not screenshots. Native dimensions are points. Web values are CSS pixels, except rem-based Tailwind spacing. Values below that translate Tailwind spacing assume a 16px root size.

| Element | Native source value | Browser source value |
|---|---|---|
| Today greeting/status | Fraunces 28 / rounded 14. | Fraunces 27 / rounded 14. |
| Care hub title/subtitle | Fraunces 32 / rounded 14. | Fraunces 32 / rounded 14. |
| Moment title/body/action | Rounded 15 semibold / 13.5 / 13 semibold. | Fraunces 17 / rounded 13 / 12.5 semibold. |
| Proposed action title/detail | Fraunces 17 / rounded 13. | Fraunces 17 / rounded 13. |
| Care tile title/status | Rounded 15 semibold / rounded 12. | Fraunces 16 / rounded 11.5. |
| Conversation wordmark/input | Hermione 24 / rounded 15. | Hermione 24 / rounded 15. |
| Dock label/icon | Rounded 11 medium / icon 17. | Rounded 9.5 semibold / icon 20. |
| Kicker tracking | 1.6pt. | 0.16em. |
| Main Today composition | Concentric mark 66. Main horizontal margins 20. Moment gap 13. Bottom spacer 150. | Independent Today implementation inside a 440px maximum-width shell. |
| Today Log | Labeled capsule, height 50, trailing 22, bottom 96. No pulsing ring. | Separate floating control in browser Today. |
| Native dock | Outer horizontal margins 18. Interior horizontal padding 8, vertical 7. Equal flexible items, no fixed dock height. Root bottom padding 6. | Buttons 58 × 50, gap 4, interior padding 8, bottom padding 12. |
| Mini-orb outside Today | Concentric mark 38 with padding 3, trailing 20. | Orb 36 with padding 4, top 12, right 16, plus glass border. |
| Acknowledgment | Bottom 112, card radius 30, inner padding 16, side margins 24. | Bottom 112, radius 28, inner padding 16, outer side margins 24. |
| Organic card default | Radius 22, opaque surface, semantic edge 0.7, shadow opacity 0.07/radius 12/y 4. | Radius 28, 160° surface-to-raised gradient, edge 1. |
| Press feedback | Scale 0.96, opacity 0.88, `NudgeSpring.ui`. | Scale 0.955, opacity 0.9, transition 0.18 seconds. |

Sources: `V/Today/TodayCanvasView.swift`, `MomentCard.swift`, `V/Care/CareHubView.swift`, `V/Conversation/ConversationView.swift`, `V/RootView.swift`, `V/Components/NudgeDock.swift`, `GlassSurface.swift`, `Chips.swift`. Browser: `W/screens/Today.tsx`, `Care.tsx`, `Conversation.tsx`, `nav.tsx`, `W/ui/Dock.tsx`, `Glass.tsx`, `W/SanoApp.tsx`, `web/src/index.css`.

Native `NudgeType.serif` defaults to semibold. Browser serif headings do not all set a weight. Cards vary by use: native attention 26, Care tiles 22, messages 20, metrics 18, moments/actions/default surfaces 22; older detail screens retain their individual radii. There is no universal card radius.

The native dock uses a warm tinted glass capsule on iOS 26. Older versions use the material fallback. The web dock uses CSS glass with a surface-based background, not the exact native dock tint. Its blur is 26px with saturation 180%, or 40px/200% for strong glass. These are visual approximations, not native refraction.

### Existing copy and meaning

The table records exact excerpts from native source. Preserve these as evidence, not as approved production wording. Proposed replacements are in [the change specification](RUMI_RESCOPE.md#copy-and-status-language).

| Source | Existing excerpt | What the code supports |
|---|---|---|
| `TodayCanvasView.threadResolved` | "You're set for now — I'll keep watch." | No moments remain. No monitoring worker exists. |
| `TodayCanvasView.lifeStrip` | "Today at your table" | Strip includes meals, activity and medication entries. |
| `TodayCanvasView.plusButton` | "Log something — a symptom, a meal, a move, a med" | Accessibility label still says move while other surfaces display Activity. |
| `ConnectionsView` | "A family of specialized agents working quietly behind Rumi. Tap any one to see what it's doing." | Agent detail is inspectable, but tasks and connected accounts are local fixtures/state. |
| `ReportsView` | "Nothing sends without you" | A confirmation exists. Sending does not contact a recipient. Other chat/voice requests can transmit data without this report confirmation. |
| `PrivacyCenterView` | "Export everything" | Sets a view-local confirmation. No export artifact is created. |
| `PrivacyCenterView` | "Nothing here is used to advertise to you. Ever." | This is a copy claim. Source alone does not verify downstream data-use policy. |
| `Glossary.swift` | Comments ban "streak", "goal", "compliance", "failed", "missed", "don't forget". | Constants/comments do not enforce a runtime vocabulary filter. |

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
| `NudgeDock.swift` | Four native buttons, cool-tinted glass capsule and warm selection; Messages dot counts unread threads and Care dot indicates a new result. Paths are retained separately in AppModel. |
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

These counts come from repository files. They do not establish remote asset-library contents or binary equality between platforms. The native catalog has 67 imagesets, one colorset and one appiconset: 69 child directories. Its 138 files comprise 70 JSON, 57 PNG and 11 JPG. Imagesets contain 56 PNG and 11 JPG. The extra PNG is the app icon.

Web `public/img` has 46 images: 35 PNG and 11 JPG. The 21 native-only image names are the new activity illustrations.

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

Native images live in `ios/Nudge/Assets.xcassets/<name>.imageset/`. Each Contents.json gives the filename. Web uses `web/public/img`.

The 24 native activity choices use 21 illustrations. Walk variants share shoes, and Bike ride/Cycling share the bicycle. Web's 24 choices still reuse four legacy images. Native Quick Log's activity-category chooser still uses `yoga_mat_rolled`.

`LifeLibrary.moveTable` checks specific keywords first and uses `walking_shoes_stride` as its input-matching fallback. Stored entries keep their image keys. Legacy fact mappings support those old keys. This is neither image recognition nor clinical nutrition analysis.

Visual inspection of `currents_kidney.jpg` shows textured sage/ochre anatomy within layered terracotta and cream forms. `walking_shoes_stride.png` shows dimensional cream-and-terracotta shoes in a softly lit scene. The images are not all transparent objects. Native subject lifting supplies some of that treatment at runtime.

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

No live chargeable calls were made in this audit. This document records environment names, not values. Client configuration does not prove that a secret is deployed, a provider is connected or a request succeeds.

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

The Worker has no caller authentication, authorization, rate limits or app-level upload/text limits. Runtime schema validation and top-level upstream-error handling are missing. A non-string text value can throw at trim.

Proxied responses strip set-cookie and add allow-origin. They do not consistently include the full CORS headers. The provider key stays server-side, but endpoint access is not protected. That is the limit of the "private proxy" description.

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

The priorities below are audit recommendations, not approved implementation scope. "Before real users" means before processing real patient data or claiming external clinical or financial outcomes. Each row states the evidence needed to close the gap.

| Area / priority | Source-backed gap | Completion evidence needed |
|---|---|---|
| Identity — before real users | Native Welcome explicitly blocks unconnected sign-in; legacy provider flows simulate connection; web forms cannot accept credentials. | Verified identity/session, recovery/linking policy, expiry/revocation and account isolation; demo explicitly separated. |
| Consent — before real users | Ledger is not an enforcement layer; audio privacy wording contradicts transport. | Versioned purpose-specific consent, revocation effects, permitted data selection and accurate disclosures. |
| Clinical truth — before real users | Fixture scenarios can be sent as real context; shared Marcus records across pathways. | Source/date/patient provenance, missing/conflict handling and separation of demo/user/clinician/AI information. |
| Crisis/clinical safety — before real users | Prompt-only controls, no verified crisis handoff, stale fixed clinical dates. | Clinician-approved rules/content/precedence, localized escalation, service-unavailable fallback and safety evaluation. |
| Chat correctness — high | Web omits latest typed prompt; action parser not semantically validated; fallback undisclosed. | Correct request history, safe malformed-tag handling, explicit degraded mode and action/response evaluation. |
| Voice — high | Multipart forwarding defect; permission-grant cancellation race and other lifecycle/error/temporary-audio gaps; post-record transcript animated to resemble live transcription. | Successful consented STT/TTS contracts, cancellation/error recovery, retention cleanup, truthful transcript behavior. |
| Service security — before public endpoint use | Voice proxy unauthenticated/unbounded; unhandled upstream failures. | Authorized/rate-limited requests, validated inputs, bounded cost, sanitized monitoring and operational runbook. |
| Persistence — high | Habits/journeys/appointments/declines remain unsaved; source/account boundaries and corruption/save-failure recovery remain incomplete. Saved empty collections and separate scenario snapshots are implemented. | Round-trip/migration/recovery checks, stable ownership and honest save failure/retry; delete-empty stays empty. |
| Account rights — before real users | Export/deletion are cosmetic/partial. | Usable export artifact; complete scoped deletion/session clearing, declared legal exceptions and provider retention handling. |
| Messaging/requests — high | Local sent/submitted flags; Guide/Prep/support separate dead ends. | Actual reviewed payload/recipient, receipt/error/retry/history; portal draft handoff never reported as sent. |
| Appointments — high | Local confirmation/reschedule, stale trip and placeholder join remain. Selected prep context and web recursive team route are repaired. | Provider-confirmed status, selected-visit context, timezone/window rules and real join/logistics handoffs. |
| Results — high | Acknowledgment method unwired; invalid metric IDs can blank destination. | Attention deep link to exact result, durable acknowledgment distinct from clinical resolution, unavailable-data exit. |
| Actions/network — high | Approval creates done state; inactive/disconnected agents can approve; no background work. | Authorized execution with idempotent result reconciliation, durable decline/cancel/failure/receipt and true pause state. |
| Reports — high | Range filters only some data; persona names; future data; no PDF/delivery/version. | Correct patient/range/provenance, review snapshot, artifact/version and verified recipient delivery. |
| Payments — before real charges | Paid locally; insurance card selectable; placeholder provider page. | Payment-provider confirmation, eligible tender, exact amount/recipient approval, duplicate prevention and receipt/refund boundaries. |
| Documents — high | Typed metadata only; no field correction/record merge; web mutations unreachable. | Actual source artifact, reviewable extraction/correction, provenance-preserving updates and consistent delete behavior. |
| Savings/sponsorship — before real offers | Savings route unreachable; local application flag; no durable decline/ranking. | Reachable neutral alternatives, eligibility/PII approval, outcome tracking and disclosure/governance evidence. |
| Connections — integration gate | Toggles manufacture accounts. | Approved provider access/scopes/revocation/sync health; unsupported channels disclosed rather than faked. |
| Navigation — high | Today Life/Conditions event race and tab-path loss are repaired. Native Back visibility still needs UI validation; browser internal routes remain non-addressable; exact insight/result/refill focus remains incomplete. | Stable destination identity, correct return/restoration, direct/back navigation, empty/unavailable escape. |
| Tracking — high | No history/editing; estimated facts presented with specific numbers; med logs don't update tide. | Correctable timestamps/units/entries, provenance and truthful computed versus estimated summaries. |
| Content — medium | Static Currents; save-to-story no-op beyond flag; timer-only web players. | Actual content/media availability, durable saves/taste, honest media controls and finite-set refresh policy. |
| Accessibility/parity — high | Partial motion/text/semantic support; 21 activity-art gap; modal/voice differences. | Device/assistive-tech evaluation and explicit platform support contract, not just matching screenshots. |
| Notifications — integration gate | Local toggles/no scheduling or push. | OS permission + app preference handling, quiet hours, delivery/privacy rules and failure behavior. |
| Operations — before production | No clinical backend, execution audit, evaluated prediction service or runtime evidence. | Chosen supported services, data retention/security operations, incident response and monitored end-to-end verification. |

## Recreation and verification boundaries

### What a faithful recreation requires

1. Preserve the four-destination shell, omnipresent companion, bounded Today moments, conditional onboarding and independently retained Care/Messages/You paths described above. Recreating current defects deliberately is different from remedying them; label that choice.
2. Carry the native and browser data models/fixture bundles and **their differences**. Preserve persisted raw values, stable bill keys and legacy image aliases. Do not replace fixtures with assumed real data sources.
3. Reuse the recorded fonts, images, videos, audio, design tokens, shader/component construction and cache behavior. Native glass/Metal effects and browser CSS approximations are not interchangeable implementations.
4. Configure chat/voice through managed public client configuration and private server configuration. Provider keys, entitlements, service contracts and authorizations are separate prerequisites; source alone is insufficient to recreate a working production integration.
5. Reproduce only actual local behavior when demonstrating the baseline, with explicit simulation labeling. Do not claim transactions, monitoring, delivery, export or authentication based on existing success text.
6. Use the gap register to decide what must change before real use. Re-scope approval is not implied by this reference.

### Existing validation assets

Native `NudgeTests` now declares seven behavior tests covering tab ownership, selected/missing appointments, route preservation, old snapshot compatibility, draft round-trip and separate scenario storage. The unchanged UI tests remain launch-only/performance/screenshot templates. Source: `ios/NudgeTests/NudgeTests.swift`, `ios/NudgeUITests/NudgeUITests.swift`, `ios/NudgeUITests/NudgeUITestsLaunchTests.swift`. They do not establish clinical, persistence, AI, consent, action or integration correctness.

Web has twelve test cases: ten navigation/continuity tests in `web/src/test/navigation.test.tsx`, the original trivial example and the generic calendar smoke case. The new tests cover tab ownership, retained contextual routes, unmounted tab restoration, durable unsent drafts, scenario round-trip, duplicate-route prevention, appointment selection/unavailability and truthful unavailable EHR delivery.

For the first implementation stage, `runChecks(ios)` passed with a simulator build; `swiftTest(ios, NudgeTests)` executed seven passing tests. Device/release builds and native UI journeys were not verified. `runChecks(web)` passed static checks and a production build with preview at https://8bj7q7lzrlxpwebjl7tla-web.rork.live. `bun run test` passed all twelve web tests. An initial new web test used an unprepared fixture appointment and failed; the test now selects an eligible prepared visit. No clinical service connectivity or outbound outcomes were verified.

Documentation checks cover feature coverage, source accuracy, links and the repository diff. They do not verify executable behavior.

The source baseline was inspected with read-only Git commands. Rork handles repository synchronization automatically; writing these files is not proof of a remote GitHub commit/push. Final repository status should be reported from observed evidence, without a fabricated commit or deployment claim.
