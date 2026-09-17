# Rumi: re-scope and change specification

## Privia web implementation and verified handoff — September 17

The approved web-first extension is implemented in a separate Elena workspace, preserving earlier patient data and native source. Entry routes `/`, `/care`, `/messages`, `/you` use `PriviaProvider`; `/legacy` explicitly mounts the earlier prototype separately. The new navigation centers Log as a sheet action and keeps a separate floating Rumi. The supplied Linden 02 image guided opaque warm-white cards, diffuse mint/blush/butter light, forest text and Fields demo headings; production font rights remain unresolved.

The app now connects patient-confirmed memory/pacing, bounded read-only AI proposals, actual local sample inbox/calendar searches, review-first messages/calendar events, the selected visit guide, direct corrected logs, personal support and SMS/call transcript previews. AI cannot place orders, approve drafts or execute external actions. Privacy-sensitive outbound sample text/calendar content is allowlisted. Calls are transcript simulations, not speech or telephony. Current live integrations and native feature parity remain outside this stage.

The complete one-page Agentic Flows PDF was extracted (16 pre-visit, 10 during-visit, 12 post-visit steps); see `tmp/agentic-flows-extracted.txt`. Its automatic writeback/monitoring/quality closure/ride/refill/caregiver flows remain reference scope, not implemented services.

The [standalone Word handoff](handoff/Rumi_Developer_Handoff.docx) and [reproducible source](handoff/RUMI_DEVELOPER_HANDOFF.md) replace raw historical-doc conversion as the developer starting point. They identify native/web differences, current/proposed system ownership, endpoint contracts, 174 packaged asset/reference files, all 43 scope rows and exact production migration/release boundaries. [Verification artifacts](handoff/verification.json) identify checks actually run; Rork manages repository synchronization, with no manual commit/push claim.

Web validation: managed static checks/build and 68 tests passed. Browser walkthrough, reload and four viewport checks passed; native and Functions source remained unchanged. Twelve new key web captures are separate from the accepted native ledger; supplementary live AI evidence is separately labeled. Production claims still require owned clinical/Google/channel access, security/privacy/legal/clinical review and device/Release checks.

## Switchable AI connection — September 17

Source: [Chat portal internals](https://r2-pub.rork.com/attachments/sci45ty8gxzig2r6hrfkj.pdf), retained at `tmp/chat-portal-internals.pdf` and fully text-extracted. The user says the server artefact is outdated but authentication remains the same. No deployed Rumi host/server URLs, host session contract or current frame traces were supplied. This work does not change Fasten, the Functions deployment, web UI or paused screenshot production.

### Native behavior
- **Settings → AI connection**, also available from the mode label in chat. Temporary AI remains the backward-compatible default; it uses the existing Rork Toolkit `anthropic/claude-sonnet-4.6` chat model for implemented conversation, selected-context explanations, review-first proposals and visit question drafting. This routes current AI surfaces; it does not complete all 43 retained/additional product capabilities.
- Rumi backend is an explicit separate choice. Empty/missing setup keeps Send unavailable; no gateway fallback is attempted. Applying stops active generation, saves outgoing turns/composer/context, restores the selected workspace and aborts on storage failure. Existing records, appointments, local prepared work and direct non-chat paths remain in the chosen synthetic scenario.
- Provider/configuration workspaces and server client IDs are persisted within each scenario snapshot. Old conversation fields migrate only into Temporary AI. Changing endpoint details or supplying a new host session starts a fresh backend workspace; previous backend conversations remain readable under Saved backend conversations, never replayed into the new connection. This is not verified production account isolation.
- All text generation uses one router, including visit prep. Prep uses a separate server conversation so it cannot pollute the main chat. The native dedicated adapter sends only the latest explicit user text/context; it does not send gateway history, the sample-wide system prompt or a fabricated system-policy frame. Backend system policy and supported review-only tags must be configured and evaluated on the actual server.
- Temporary speech retains existing transcription/synthesis services. Backend voice is explicitly unavailable and does not fall back to those services. A delayed microphone permission grant cannot start capture after stop; voice cannot adopt a pending text question's answer. Full native PCM24/16 kHz, VAD/barge-in and MP3 streaming remain separate implementation/verification work.

### Auth and wire boundary
- Native equivalent of `give-token`/`set-token`: authenticated host broker → short-lived JWT → GET `getConfig` with Bearer → WSS `ws/{identifier}-{clientId}` → ordered auth, text flag and turn frames. Tenant API keys remain in the user's host/VPC; this app never calls `generateToken` with a tenant key.
- **Provisional broker profile:** authenticated GET to the configured complete token-broker URL, `Authorization: Bearer <test host session>`, response JSON `{"token":"<JWT>"}`. The PDF does not specify that HTTP method/response envelope/host-session scheme; verify or adapt it against the current host. The developer-only SecureField accepts a host test-session access token, not a tenant API key. Production host login is not implemented.
- Token and host session are held in memory, never encoded into scenario data, URLs or logs; credentials clear on background, provider exit, endpoint change and explicit disconnect. Native HTTPS/WSS only, no URL credentials/query/fragment, no redirects, cookie/cache/credential-store-free sessions, bounded JSON/frame sizes, handshake and response deadlines. Local JWT expiry checks are usability checks, not signature verification or patient ownership.
- **Provisional text envelope:** string-valued `type`/`value`; outbound flag uses top-level `text: "1"`; incoming data uses top-level `text` and `message_id`. `server_processing` chooses the active message ID; matching `server_paused` is required for completion. The PDF names these concepts, not a canonical JSON schema. All assumptions are isolated in `RumiWireProtocol` and must be matched to a current wire trace. Unknown/malformed content never grants a capability or completes a tool action.
- On `session_expired`, request a fresh token, confirm the same configuration identifier, and send auth on the same socket once; do not replay the message. `auth_failed` fails explicitly. Refresh identity/signature validation remains server-owned. A transport handshake is not an authentication receipt.
- Each text operation opens a socket using its workspace's client ID and closes after completion/cancellation. Closing/Stop cannot prove server cancellation. There is no fabricated `cancel` or deduplication frame: the PDF describes `client_adds` on a subsequent edit, but no reliable cancel acknowledgment, resume cursor or request-id contract. The native client does not auto-reconnect/replay; manual retry warns that the backend may have processed the first attempt. Continuous session reuse and stop/edit parity require the current contract.

### Deployment handoff and remaining gates
- Run the current server and token host in the approved AWS/VPC environment; provide a reachable TLS entry point or managed private-network path for real devices. A VPC-only address will not become reachable merely by selecting it in-app. Preserve tenant secrets in server secret storage and redact tokens/content from infrastructure logs.
- Confirm host authentication, tenant/user ownership for the socket conversation, `getConfig`/frame examples, ordering/auth acknowledgments, expiry/refresh, cancellation/replay/receipt behavior, server-side clinical policy and disabled live tools in the synthetic tenant. Do not infer patient association from client IDs or local Demo personas.
- No actual Rumi vendor/production connection, patient data transfer, EHR action, AWS deployment, production host login or backend voice has been verified. The runnable native adapter and fixture tests are implementation evidence, not end-to-end vendor certification. The focused selection `NudgeTests` plus the AI-mode switching UI test passed **39 tests in 59 seconds**. The first run passed 36 unit tests but its UI test hit duplicate accessibility nodes for the alert's Apply button; the selector was corrected, not waived. The first build's unknown surface token was corrected to the existing semantic base color. Final native simulator build passed. Broadened selection `NudgeTests` plus four UI checks (AI mode/draft switching, floating composer preservation, selected medication context and non-mutating welcome preview) passed **42 tests in 86 seconds**. The artifact audit still verifies 20 accepted original/slide pairs, 43 scope rows and the exact QMS closing note. No accepted presentation image changed; device/Release, accessibility breadth, live Rumi interoperability and native backend voice are not certified by these tests.

## Fasten setup continuation — September 17

- Added a separate **Fasten test setup** screen under Records/Connections. It reads non-patient configuration metadata, supports retry and close, and never copies a Demo profile or updates the sample import. It is not a browser authorization flow.
- Added server-only Fasten bindings and setup routes. Deployed backend: `https://research-preview-1-backend.rork.app` (the URL returned by the Functions build, not an assumed project-ID hostname).
- Register this **test Redirect URL** in Fasten: `https://research-preview-1-backend.rork.app/integrations/fasten/test/return`.
- Register this **test Webhook URL** in Fasten: `https://research-preview-1-backend.rork.app/integrations/fasten/test/webhook`. Then retrieve that endpoint's Signing Secret from Developer Logs and provide `FASTEN_TEST_WEBHOOK_SECRET`. After registering the redirect, provide its exact address as `FASTEN_TEST_REDIRECT_URI`; a configured string is not independent portal verification.
- The deployed configuration probe sees both original credential bindings and now accepts their test-mode format. An initial overly restrictive suffix validator was corrected to accept opaque printable characters after the documented test prefixes; the user does not need to replace keys because of that earlier warning. No values were logged or copied into native source. The public organization check remains unavailable/unverified; sanitized deployed diagnostics isolate a request-stage TypeError (not an HTTP rejection or clinical-data error). This needs resolution before calling the tenant recognized. No private-key authorization or record pull has been verified.
- Setup can perform a read-only public organization lookup once the test-key format is valid. This does **not** verify the private key. The bulk catalog export endpoint is not used as an authentication probe because Fasten requests prior support contact.
- The webhook route uses Standard Webhooks verification over the unchanged UTF-8 body, signed timestamp and headers; malformed, unsigned, stale/future and live events fail closed. Valid test events still receive 503 until session ownership, durable deduplication and ingestion are implemented. No clinical payload is persisted, acknowledged as processed or downloaded. GET readiness is not a delivery receipt.
- The return page strips incoming query parameters and reports no import. It does not start Stitch, authorize a patient, bind a connection or claim successful ingestion. Browser launch remains deliberately unavailable rather than exposing an unowned connection flow.
- Native simulator build passed; the full selected native suite passed **33 tests in 126 seconds**. The existing web test runner also covers the server module, including signed-delivery rejection and opaque key-suffix regression cases. Final full runner: **28 tests passed**, including **16 Fasten setup tests**; web static checks/build passed. Functions deployment succeeded. The first native compile needed the URL-validation expression split into guards; the Node-based tests needed an environment guard and explicit Node type reference. These issues were corrected, not waived. Broader production isolation, browser authorization, private-key verification, signed vendor delivery, FHIR ingestion and clinical validation remain open. Screenshot generation remains paused; no accepted images changed.

## Full-feature presentation extension — September 17

Latest source: [rumi re-scope.docx](https://r2-pub.rork.com/attachments/ra176ma71ass9gt2x7vv9.docx), retained at `tmp/rumi-re-scope.docx` and inspected by extracting every paragraph and table. It repeats the 36 retained features and lists the seven connected-care additions. The user explicitly requests screens across the entire set, meaningful contextual AI, and clear useful agentic differentiation—not another selected marketing set.

### Presentation contract
- Organize around the patient's job, not the architecture: entry → evidence/input → optional help → review/choice → outcome/return. Keep the same patient and item throughout each sequence.
- The feature remains the hero. Use a real readable screen and one short caption; add explanatory presenter notes outside the phone. No floating robots, network diagrams or repeated AI badges on clinical facts.
- Explain Rumi's difference through visible work: preserve context so patients do not repeat themselves; help turn observations into questions; prepare editable drafts; adapt a chosen step to a stated barrier; retain the resulting work.
- Use three distinct meanings: **Explain** helps understand selected evidence; **Suggest** offers an optional editable next step; **Prepare** assembles work for patient review. A saved draft is not an executed external action.
- Keep AI absent from sign-in, legal acceptance, permission toggles, simple logging controls and financial confirmation. Direct non-chat paths remain first-class.
- Give every one of the 36 features and seven additions a coverage row. Separate primary feature coverage from success/recovery-state coverage. Missing implementations are not satisfied by unrelated screenshots, stale mockups or fabricated UI.
- Capture all available feature chapters. Do not stop at ten or describe a written inventory as full visual coverage. Raw images, branded slides, source dates and missing variants remain distinguishable.

### Current implementation work
Implemented selected-item snapshots for medication, series, record, insight, Currents and Life handoffs; symptom observations retain entered details. Entry previews before Send; full source details open in a scrolling sheet; edited drafts are protected when switching attached items. Sent turns retain their original evidence snapshot. Replaced false medication refill/delivery and record/symptom sent-note claims with review-first work. Messages now has Prepared work. Agent proposals create persistent drafts instead of instant external success; saved work is primary and illustrative domains are disclosed separately. Context-derived drafts reopen their edited version from the same source. Autosaves are debounced and flushed on close/background; broader background storage optimization remains open.

Record category fixtures existed only for Marcus. They are now shown only in that scenario, not silently relabeled for Elena/Sam/Rosa. Those other scenarios retain their own medication/lab workspaces; their full attributed record-category fixtures remain incomplete. Live record ingestion and comprehensive ownership/reconciliation are not implied.

The records chapter produced ten accepted slides. The visit chapter was cancelled; screenshot generation is paused, not retried. Twenty accepted slides (intro + records) are retained, with ten staged/unaccepted visit originals indexed separately in `screenshots/library-captures.json`. A capture run replaced the prior slide directory; the ten earlier accepted PNGs were recovered byte-for-byte from the existing repository artifact without altering source history. Future chapter runs must archive accepted PNGs and manifests before invoking the single-deck capture tool. Full feature/state visual coverage remains unchecked. Real service access is not a prerequisite for showing useful local patient-controlled work.

### Extension verification and next handoff

- Final native selection `NudgeTests` + `NudgeUITests/NudgeUITests`: **31 passed in 128 seconds**. Final `runChecks(ios)` passed. One intermediate compile error from changing record fixtures during scenario switches was fixed by making the record collection mutable.
- `python screenshots/validate_library.py` verifies 20 accepted original/slide pairs, all local library links, 36 retained + 7 added feature rows and the exact QMS closing note. Presentation slides are PNG; some raw capture files contain original JPEG bytes under the tool's `.png` path and are validated without re-encoding.
- Today no longer promotes seeded delivery/task ideas as current care work; it offers actual saved drafts. The older task cards remain under the disclosed agent examples and now prepare editable drafts rather than reporting completion.
- Next: ask whether to resume screenshot production after the cancelled visit chapter. Do not retry it without confirmation. Then use the remaining chapter list in the screen library, including meaningful AI-output → patient-choice → saved-outcome frames, not just feature entry screens. Archive existing accepted slides and the multi-chapter manifest before any new capture tool call.
- Full visual/state coverage, all 43 capabilities' implementation, live clinical integrations and release readiness remain incomplete. A mapped feature is not an implemented or captured feature.

## Active handoff — September 17, connected onboarding and behavioral support

**Current pass:** native iOS only. The scoped demo/continuity increment is implemented, simulator-built and tested (23 passing tests); ten primary screenshots and presentation slides are captured. Live integration and exhaustive screen/state coverage remain open. This section overrides older visual/onboarding directions below. Keep this file as the living working document, `RUMI_REQUIREMENTS.md` as the behavior contract, and `RUMI_SCREEN_LIBRARY.md` as the presentation/visual journey library. `RUMI_AS_BUILT.md` remains the supporting implementation audit; do not delete its history to meet an obsolete three-file limit.

### Latest request and source precedence
- Apply the supplied [Brand Concepts delivery](https://r2-pub.rork.com/attachments/0a4gmlh6o3bbvk3an03sr.zip): mint, blush, butter yellow, deep green and paper. Retain Rumi naming and four destinations; Linden wordmarks are reference artwork, not a requested rename.
- Use [Fields Display](https://r2-pub.rork.com/attachments/71usmsmz3x1oooaiw23ax.zip) for display/headline typography. Supplied files are FONTSPRING demo OTFs; commercial/production embedding permission is unverified and remains a release gate. Body/data typography stays system sans.
- Keep Rumi accessible near the bottom across the main app, alongside Log; no upper-corner-only companion entry.
- Add optional record connection during onboarding, including a synthetic demonstration of profile prefill → confirm/edit → sharing scopes → import → review. Back, skip and non-mutating Settings preview remain required.
- Continue selected-visit guided preparation, recoverable chat, review-first agent actions and goal-specific habit support. Do not silently assert the separate behavioral backend is implemented in this app.

### Fasten contract, verified from public documentation
Reviewed [home](https://docs.connect.fastenhealth.com/home), [OpenAPI](https://docs.connect.fastenhealth.com/api-reference/openapi.yaml), [Stitch v4](https://docs.connect.fastenhealth.com/stitch/v4/introduction), [test data](https://docs.connect.fastenhealth.com/guides/test-data), [webhook verification](https://docs.connect.fastenhealth.com/webhooks/verification) on September 17.
- Social identity is not medical-record authorization. Only available provider claims may prefill names/email; DOB is normally missing and must remain unset until entered/confirmed. Never infer DOB, legal name, address, sex or patient association from a social account.
- No documented public create-patient-by-demographics API or generic hosted-link creation endpoint was found. Catalog search finds institutions, not patients. TEFCA matching requires identity proofing and consent; portal access requires provider authorization. Never capture portal passwords in native fields.
- Stitch supports public ID, opaque external ID, email prefill, optional TEFCA. A customer-hosted Stitch HTTPS page/browser return is the preferred native bridge; callback alone does not prove ownership or completed ingestion.
- Sensitive API calls use server-side Basic auth `public_id:private_key` at `https://api.connect.fastenhealth.com/v1`; test/live keys select the environment. `GET /bridge/org_connection/{id}` checks authorization. `POST /bridge/fhir/ehi-export` starts an asynchronous export. `GET /bridge/fhir/ehi-export/{taskId}` supplies status, not download links.
- Signed `patient.ehi_export_success` webhooks contain download links. Verify Standard Webhooks against raw bytes and webhook-id/timestamp/signature, deduplicate, correlate to an authenticated owner/attempt, then ingest FHIR NDJSON with patient references and source provenance. Do not merge solely on name/DOB. Revocation stops new collection.
- Update: the test public/private bindings are now present and pass the corrected format check, but vendor authorization is not complete. The endpoint-specific signing secret and registered redirect are still needed; see the latest setup handoff above. Authorized tenant operations and production data-processing agreements remain unverified. Local Demo is not vendor sandbox, and neither is production. The official FooClinic sandbox uses synthetic identities; never send actual demographics from Demo.

### Behavioral context, not blanket implementation approval
Sources: [Patient Journey Optimizer](https://r2-pub.rork.com/attachments/nktnavqjx6ydo1ztb6txi.pdf), [Behavioral Intelligence](https://r2-pub.rork.com/attachments/1o8tf0ub92jiewkafrr2r.pdf), [92-factor catalog](https://r2-pub.rork.com/attachments/z80jas9na2fptn8sqssws.docx), [system writeup](https://r2-pub.rork.com/attachments/d108xirvdqqy1ew2dn5u6.md). Originals are retained under `tmp/`; PDFs were inspected through document extraction summaries, DOCX through paragraph/table extraction, and the writeup directly.
- Adopt patient agency, one optional small step, event-based cue, personal reason, obstacle, smaller fallback and a closed check-in loop. A lapse is information, not failure; declining/pause must work without guilt or losing history.
- Capture deliberate patient statements separately from AI suggestions. Never infer clinical conditions or psychological traits from demographics, and do not turn an assistant suggestion into patient evidence or commitment.
- The writeup describes another backend with conversation/reflection/learning loops, provenance, correction, personality and stage hypotheses, session aims and proactive pacing. It is context for the future WebSocket integration, not evidence these stores/classifiers exist in native code.
- Confidence thresholds, decay, risk scores, crisis logic, population analytics and reinforcement learning require separate clinical/privacy/quality approval. No numeric defaults copied into production policy in this pass. No hidden psychographic scoring added.

### Chat handoff boundary
Current native integration points: `Services/ChatTransport.swift`, `Services/CompanionAI.swift`, `ViewModels/CompanionEngine.swift`. The protocol receives a logical request UUID, system context, ordered messages and main-thread delta callback; it returns the completed text or throws. Engine owns request generation, turn identity and local UI history. The gateway receives an Idempotency-Key, but cross-provider deduplication/resumption is not independently established. No socket endpoint is guessed or persisted in UI settings.

Retain the configured gateway transport for now; place it behind an injectable typed interface. Store local scenario conversation history/composer; associate responses with stable request/turn IDs; preserve interrupted work; explicit stop/retry and decline states; no fabricated offline reply. Future WebSocket adapter must use the user's actual event/auth contract. Needed: wss URL, auth/token refresh method, request/response/event schemas, conversation/session semantics, cancel/resume/duplicate rules, tool proposal and receipt schemas. Do not assume a socket endpoint or send medical records to an arbitrary URL.

### Delivery ledger
- Brand/type, optional onboarding connector demonstration, lower Rumi/Log controls, durable chat, guided prep, habit plans/check-ins, review-first proposals and the screen-library inventory are implemented in native source.
- Simulator build passed after a MainActor default-initializer correction. First combined test run: 19 passed, 3 failed. Corrected selection (all 17 unit tests plus connector UI test) passed 18 tests in 60 seconds. Fixes: disambiguate optional rich `.none`, preserve SSE blank separators via raw-byte framing, prevent profile reinitialization and identify each connector step distinctly. The live synthetic gateway check now succeeds; this is not clinical validation or the user's backend integration.
- Presentation-image preference confirmed: supplied brand, real screen and a short caption. Original captures belong beside the ordered library; slides must preserve Demo/unconnected disclosures. First 10 captures and branded slides were accepted in `screenshots/iphone/en/`; raw source captures are indexed in `screenshots/captures/iphone/captures.json`. Visual inspection caught incorrect Fields Medium/Semibold PostScript names (system fallback in some headings); corrected to `...MediumRegular` and `...SemiBoldRegular`. A font-resolution test passes. All ten images were refreshed and accepted after the correction; originals live in `screenshots/captures/iphone/`, branded slides in `screenshots/iphone/en/`, linked beside the corresponding `RUMI_SCREEN_LIBRARY.md` entries.
- Final combined selection `NudgeTests` + `NudgeUITests/NudgeUITests`: **23 passed in 100 seconds**. Final `runChecks(ios)` succeeded. Device/release and full accessibility/voice/clinical evaluation were not run.
- Blocked external work: real social-account/patient isolation, tenant Fasten pulls/webhooks, Privia/athena writeback, user's WebSocket backend and complete production safety/security validation.
- Next agent: start here, inspect `RUMI_AS_BUILT.md` current-delivery section, then the unchecked approved-plan stages. Do not restart design or present local Fasten import as a vendor integration. The public/private bindings have since been supplied; follow the latest setup handoff above to verify the public-organization lookup and register the return/webhook endpoints. The signing secret is requested after endpoint setup, not invented. Request the user's WebSocket event/auth contract before implementing that adapter.
- Expand the screen library capture coverage in subsequent passes; ten primary screens are not every journey state. Prioritize authorization errors, prep suggestions/review invalidation, habit check-in outcomes and agent draft review. Keep raw screens alongside slides and update only delivered-state claims.

## Contents

- [Purpose and approval boundary](#purpose-and-approval-boundary)
- [Sources and confirmed decisions](#sources-and-confirmed-decisions)
- [Product direction](#product-direction)
- [Complete attachment scope](#complete-attachment-scope)
- [Retained signature experiences](#retained-signature-experiences)
- [Proposed information architecture](#proposed-information-architecture)
- [Signature end-to-end journeys](#signature-end-to-end-journeys)
- [Design specification for the existing app](#design-specification-for-the-existing-app)
- [Assets and content production](#assets-and-content-production)
- [Copy and status language](#copy-and-status-language)
- [Feature-by-feature change instructions](#feature-by-feature-change-instructions)
- [Engineering and backend specification](#engineering-and-backend-specification)
- [Migration and careful removal](#migration-and-careful-removal)
- [Verification and release checks](#verification-and-release-checks)
- [Dependencies and sequencing](#dependencies-and-sequencing)
- [Release boundaries and unresolved decisions](#release-boundaries-and-unresolved-decisions)
- [Review and document ownership](#review-and-document-ownership)

## Purpose and approval boundary

Modify the existing Rumi app around the approved Today, Care, Messages and You destinations. Keep its companion, visual style and useful workflows; preserve saved information when replacing old behavior. The requester approved staged implementation. This specification covers design, copy, assets, backend and engineering work; unresolved specialist policies and live release remain separately gated.

The three review documents have distinct ownership:

- [As-built reference](RUMI_AS_BUILT.md): what the current source actually does, including design/construction, assets, demo wiring, defects and production gaps.
- **This specification:** what to retain, add, change or retire in the existing app, including screen layouts, design values, asset requirements, draft copy, technical contracts, migration and verification.
- [Functional requirements](RUMI_REQUIREMENTS.md): proposed testable behavior, feature by feature, with edge/blocking states and explicit open questions. It does not duplicate the current design specification.

Implementation proceeds in validated stages under the approved connected-care plan. The as-built reference records delivered source changes and validation. The earlier polish plan is historical context; its simulated external actions are not production commitments.

## Sources and confirmed decisions

### Attachment evidence

The original files were downloaded directly and the Word document's paragraph/table text was extracted, rather than relying on a web-reader summary.

- **rumi re-scope.docx:** [original attachment](https://r2-pub.rork.com/attachments/nitdpu5h7tpnl9lddpjk2.docx), 15,230 bytes; SHA-256 `cdabc82c6d9b0d60500fc5d68f51a3e6612d0cb8926f5d416b66ddb0f9862135`.
- **SKILL (1).md:** [original guidance](https://r2-pub.rork.com/attachments/af18ygma9iqe3h088cc6e.md), 22,739 bytes; SHA-256 `65edb9223c812137ff0d8ad683c933c2ec2c6bc6b3643fabafa366d3e534d1db`.
- **Source audit baseline:** `e11670626f181a73c120118d28eb9d09d3a960ac`, September 16, 2026. Detailed evidence is in the as-built reference.

The re-scope begins: “Net new/rescoped features below. But also retain the key features around AI, agentic AI etc from previous build –”. It then lists **36 feature names in one table**. It does not supply detailed rules, thresholds, priorities, integration vendors, launch country, commercial agreements or acceptance criteria. The proposed behavior below is therefore a reasoned draft, not text falsely attributed to the attachment.

### Confirmed in this review

- **September 17 native style refinement:** the supplied [Nudge – Platform Flows](https://r2-pub.rork.com/attachments/dzpsmthuxdnvbfsx0zzbt.zip) now governs the native visual treatment: compact cards, editorial headings, grouped actions and a small concentric companion mark. Use cream, amber, clay and olive instead of the reference's blue/lavender. Keep Today / Care / Messages / You rather than copying the older five-tab reference. The attachment is visual guidance, not evidence of integrations, provider approval, insurance coverage or clinical outcomes.
- **Shorter native onboarding:** welcome → explicit sample-story selection → optional tone/music preferences. Add Back and Skip, no staged chat or timed narration, and no pretend Apple/phone sign-in. Until authentication is implemented, Sign in explains unavailability without advancing. Do not collect identity fields for a sample-data tour. Keep optional connection/personalization controls in their existing homes and leave new-user personalization off. Existing saved preferences are not reset. Provide a non-mutating welcome preview in Settings. This overrides conflicting older onboarding, music-autoplay and palette directions below. The separate web app remains unchanged in this native refinement.

- Historical format decision (superseded by the latest visual-library request): keep three review documents. The requester approved a feature-by-feature requirements compendium instead of separate feature files. Its contents list is the feature index. Reconcile existing Confluence pages before publication.
- “AFB” in Symptom Tracking means **both AI-generated and rules-based feedback** for this scope. No unsupported expansion of the acronym or clinical thresholds is assumed.
- Staged implementation is approved. Retain the existing AI and agent experiences while making status truthful and reducing repeated attention surfaces.
- The revised [Functional Requirements](https://r2-pub.rork.com/attachments/eyefzwv0nyg8igjywk7lx.pdf) supersede the original feature-name-only attachment as the functional starting point. Use [Design Context](https://r2-pub.rork.com/attachments/bulkvip2q33bdwgqr9t0f.pdf) selectively. Seven connected-care additions and isolated Demo/regular modes are approved scope; proposed numerical/clinical defaults are not approved.
- Keep the personal, empathetic tone. Show agent work without crowding the other features. Apply the same approved behavior on iOS and web.

### Which guidance applies where

The attached product-requirements guide applies **only to `RUMI_REQUIREMENTS.md`**. Its rules exclude visual specifications, literal UI strings and prescribed architecture from that file. The as-built reference and this change specification include those details. They are needed to modify Rumi without replacing it with a new app.

This review package keeps three files. The requirements file owns testable behavior. This file owns proposed design and implementation details. The as-built file records current code, including defects. If these disagree, resolve the disagreement before implementation. Do not silently use a design choice to weaken a functional requirement.

All three use [Unslop](https://skillsllm.com/skill/unslop) and the [ASD-STE100 writing skill](https://github.com/danyuchn/asd-ste100-skill) for clarity. The edit uses short, direct sentences, consistent terms and specific source evidence. It preserves clinical caveats, exact code names and quoted source text. It does not claim certified STE compliance. The reference material includes Unslop's manifest, blacklist and prose benchmarks, plus the STE manifest and writing rules.

No Confluence or Figma access was available. Reconcile these files with any existing pages before publication. Until then, this file contains the proposed visual and technical detail for review. Approved decisions must move into the team's chosen design and engineering records without leaving contradictory copies. Greenlight Guru remains the formal regulatory record. No approved legal, consent, marketing or clinical copy was supplied.

## Product direction

### The central experience

A patient should be able to ask about the medication, symptom, result or appointment already on screen. Rumi should use that context and return them to the same place. Records, forms and care-team contact must also work without chat.

Keep conversation inside the existing care experience. Let the patient inspect the source, choose a next step and review any information that will leave Rumi. Show whether that step is a draft, awaiting approval, submitted, completed or unsuccessful.

### Proposed functional principles

- Use the same patient context in conversation and feature screens. Never fill missing records with persona fixtures.
- Show the source and date of clinical facts. Distinguish patient reports from AI explanations.
- Let patients inspect and correct memory. Forgetting must affect future personalization, not just hide an item.
- Use approved clinical and crisis rules, with fallback guidance available when the model fails.
- Separate permission, submission and completion. Claim an external outcome only when the receiving service confirms it.
- Keep local work useful when a service is unavailable. Patients can save a draft, review the Guide, log a symptom or read retained records.
- Disclose sponsorship. Declining an offer must not block ordinary care or safety guidance.
- Use the same behavioral rules on both platforms. Explain platform limitations instead of showing unsupported success.

### Preserve the existing app

Use Today, Care, Messages and You in that order. Journeys and Currents remain directly available from You. Keep the companion near the bottom, the day/night backgrounds, supplied Fields headline typography, glass controls, Life objects and light garden. The current brand delivery supersedes prior color/type choices. Do not scaffold a replacement app, rename the native target or replace the web shell with a dashboard.

The [design specification](#design-specification-for-the-existing-app) gives concrete reuse rules and proposed additions. Existing values are labeled as source facts. New dimensions and layouts are review proposals. Accessibility and truthful status take priority over preserving a defect.

## Complete attachment scope

The table preserves all 36 attachment names and their order, including the stray apostrophe in "Needs You'". Use "Needs you" in the proposed interface. Each feature has a matching section in [the requirements file](RUMI_REQUIREMENTS.md) and change instructions below. Current implementation does not imply release readiness.

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

Use the approved four destinations: **Today, Care, Messages, You**. This supersedes the previous five-tab proposal and its duplicate clinical doors. Keep useful existing routes as compatible aliases to the same record/detail; do not keep every alias visible on every screen. Journeys and Currents move into You, not out of scope.

**Less to process, not less capability.** Every label, fact and control must serve the current task, low-effort delight or trust. Reveal supporting detail when relevant; do not fill quiet screens. Preserve discoverable non-chat completion, meaningful uncertainty, safety and review information. Trust comes from truthful status and reliable behavior, not repeated reassurance or universal provenance badges. Preserve the palette, typography, orb, art and glass navigation; do not apply every treatment to every surface.

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
│   ├── Forms → selected visit / complete / review / status
│   ├── Medications → support / questions / sponsored support / refill
│   ├── Reports → recipient / range / review / share status
│   ├── Records & Results → longitudinal categories / documents / source evidence
│   └── Costs → bills / wallet / savings (quiet, integration-gated)
├── Messages
│   ├── Compose / draft / review / thread / supported portal handoff
│   └── Requests → refill / appointment / records / forms / status
├── You
│   ├── Story and Insights
│   ├── Clinical information
│   │   ├── Conditions
│   │   ├── Medications
│   │   ├── Allergies and agreed other categories
│   │   ├── Immunizations
│   │   ├── Procedures (retained existing category)
│   │   ├── Vitals
│   │   ├── Labs
│   │   ├── Notes
│   │   └── Documents
│   ├── Discussion guide (also available during visit preparation)
│   ├── Life and tracking history → detail / correction
│   ├── Memory → inspect / edit / forget
│   └── Account and preferences → consent / connections / export / delete
│   ├── Journeys → chosen habits / held memories / Sponsored Programs
│   └── Currents → finite content / saved pieces / read / listen / watch
└── Cross-cutting experiences
    ├── Text companion ↔ voice, with preserved origin context
    ├── Agent network / approvals / execution history
    ├── Crisis and clinical escalation handoff
    └── Recap / source explanation / consent checks
```

Care owns clinical workspaces; legacy/contextual You routes open the same records rather than new copies. The four Care entry points are Appointments, Care Plan, Medications & Refills, and Records & Results. Preparation and reports are reached from visits; Documents from Records; Connections from You. Bills/wallet retain a quiet route and savings remain with medications. Discussion Guide is one list with optional visit links. Memory, private notes and clinical records stay separate. Provider systems remain external dependencies. This patient-app scope does not add a clinician or staff portal.

## Signature end-to-end journeys

These sequences show how the retained and new features work together. The requirements file defines their behavior. The later sections in this file specify screens, services and changes to the current implementation.

### A concern becomes support, not a dead end

1. Open tracking from Today or a medication.
2. Enter the symptom, severity, time and relevant context. Review and save it.
3. Show the saved entry. Apply approved rules without waiting for AI.
4. Add AI feedback grounded in that entry and the permitted record. AI cannot weaken the rule's required action.
5. Let the patient correct the entry, continue talking, add a Guide question or review a message to the care team.
6. Keep approved urgent contact options available. Show the actual status of any submitted message.

Clinical must approve thresholds and the treatment of overlapping risks.

### A result becomes understanding and preparation

Open the exact result from Needs you. Show its source, date and status beside the value. A question opens conversation with that result attached as context. The patient can save a question in the shared Guide and include it in a reviewed visit report or message. Acknowledging the result clears only the applicable attention state. It does not resolve the clinical concern.

### A plan becomes one chosen habit

Start from a care-plan goal with an identified author. Rumi can suggest a small habit that fits the patient's routine. The patient reviews and edits it before adding it to Journeys. Save keeps, pauses and corrections. Include observations in a visit summary only after review. A declined proposal creates no habit and shows no success state.

### A visit becomes a prepared and completed handoff

Use the selected appointment throughout preparation, reports, joining and travel details. Let the patient choose the report range and included questions. Before sharing, show the recipient and exact report. Keep the reviewed copy and its delivery status. Changing appointments must never silently replace the visit being prepared.

### Permission becomes a verifiable action

Show the task, recipient, data and any cost before asking for approval. Explain missing access or unsupported operations first. After approval, execute only the reviewed task. If its outcome is unknown, check the service before trying again. Chat, the network and the source screen show the same status and receipt. Pausing an agent prevents new work.

### Personalization remains understandable and reversible

Open a remembered item to see its source and use. Save a correction or forget it. Future replies must stop retrieving the old memory. Clinical records and earlier messages keep their separate ownership and retention rules. Explain which copies a deletion or consent change affects. Provide these controls on iOS and web.

### Education can help without commercial pressure

Carry the selected article or medication into conversation. Keep clinical information separate from sponsored offers. Let the patient inspect neutral alternatives without enrolling or sharing data. Review any application separately. Save declines for the approved interval across all screens. Keep education, care and crisis support available.

## Design specification for the existing app

### Source and change boundaries

Use `ios/Nudge/ContentView.swift` and `Views/RootView.swift` as the native entry and shell. Use `web/src/sano/SanoApp.tsx` as the browser shell. Keep the existing app targets, names, assets and entry points. Add routes and replace data behind current views in small steps.

The original source baseline was recorded at commit `d0f62d427e333e6d0a3219e86170574c7e791ea8`. Staged implementation is now authorized. The as-built reference records completed changes and validation separately; the detailed tables below remain baseline-to-target specifications and do not establish delivery.

In the tables below, **current** means inspected source. **Proposed** means a change for review. Native measurements are points. Browser measurements are CSS pixels unless specified otherwise. Matching numbers across platforms do not guarantee matching rendering.

### Palette and type

Keep the semantic tokens in `ios/Nudge/Utilities/Theme.swift` and `web/src/index.css`. Do not introduce a new palette for authentication, forms or clinical records.

| Token | Current day | Current night | Use in the re-scope |
|---|---|---|---|
| base | `#F6EEE3` | `#0D1126` | App background and sheet base. |
| surface | `#FFFCF7` | `#1E2449` | Readable content cards. |
| raised | `#FFF8EE` | `#2A3160` | Nested fields and selected content. |
| ink | `#2E2418` | `#F4F1EA` | Main text and numbers. |
| inkMuted | `#6F6151` | `#A7ADCE` | Supporting text. Check contrast at the actual size. |
| edge | `#E7D8C4` | `#3A4178` | Card and input boundaries. |
| shadow | `#C59A6E` | `#000000` | Existing soft depth. |
| warm | `#E0764E` | `#FF9E7E` | Primary actions and selected navigation. |
| life | `#7FAE7E` | `#8FEFC0` | Everyday progress and confirmed state, with text. |
| sky | `#6E9CC8` | `#8FC6FF` | Informational accents. |
| gold | `#D9A348` | `#C8B6FF` | Existing highlights. The night value is lavender. |
| rose | `#D8849B` | `#FF9FB2` | Existing editorial accents. |
| attention | `#D98A3D` | `#FFBE8F` | Attention, with a written reason and urgency level. |

Use the updated warm-paper/espresso native palettes with restrained amber washes; the web palette remains its previous treatment until a separate parity pass. Do not add a colored panel behind every section. Clinical urgency needs an explicit message and action. A warm dot alone is insufficient.

`NudgeType.swift` is a set of font helpers, not a universal type scale. Keep HermioneFREE for the wordmark and existing display moments. Keep Fraunces for editorial headings and system rounded text for controls and data. Preserve monospaced digits for values. The browser has the same six font files but uses a system rounded fallback stack.

| Role | Current native example | Current web example | Proposed rule for added screens |
|---|---|---|---|
| Hub title | Care: Fraunces 32 | Care: Fraunces 32 | Reuse the Care header hierarchy. |
| Today greeting | Fraunces 28 | Fraunces 27 | Keep current composition. Do not enlarge it to make room for new features. |
| Moment title | Fraunces 18 | Fraunces 17 | Reuse for Today moments. |
| Action title/detail | Fraunces 17 / rounded 13 | Fraunces 17 / rounded 13 | Keep the hierarchy. Allow more room for approval details. |
| Care tile title | Fraunces 17 | Fraunces 16 | Reuse the existing tile component. |
| Form and clinical body | Existing values vary | Existing values vary | Start new main body/input text at 16. This is a proposed legibility default, not an existing token. |
| Secondary source text | Often 11–14 | Often 11–14 | Start new source/status text at 13. Do not hide essential consent or safety text in a kicker. |
| Kicker | Rounded 11 semibold, tracking 1.6 | 11, weight 600, tracking 0.16em | Keep for short, nonessential section labels. |
| Dock label | Rounded 9.5 medium | Rounded 9.5 semibold | Preserve visual identity. Assess larger-text behavior and hit areas. |

Keep existing font weights where they are explicit. Native `serif` defaults to semibold. Browser serif headings do not all specify that weight. Do not force a global weight change while adding features. New screens must support Dynamic Type or browser text zoom without clipping fields or hiding actions.

### Layout and components

| Area | Current construction | Proposed continuation |
|---|---|---|
| Today | 150pt orb, 20pt main side margins, 13pt gap between moments, maximum three moments, Life strip below. | Keep this order. Route Needs you and task cards to exact items. Do not add a second dashboard above the orb. |
| Quick Log entry | 56pt button, trailing 22pt, bottom 96pt in Today. | Keep the floating entry. Add Vitals within the picker, not another floating button. Recalculate clearance when safe areas or text size change. |
| Scroll clearance | Today ends with 150pt clear space. Dock overlays the content. | Replace fixed clearance only where needed with measured dock/safe-area clearance. Verify drags begun beside and above the dock. |
| Native dock | Four flexible items, 28pt outer side margins, 8pt inner horizontal padding, 7pt inner vertical padding. Root adds 6pt at the bottom. No fixed height. | Today / Care / Messages / You. Keep communication unread counts separate from record attention. |
| Native dock glass | iOS 26 tinted capsule. `dockTint` is day `#F4FBFF` / night `#3C4A86`, opacity 0.30. Older systems use `GlassSurface(radius: 34)`. | Keep the version guard and visible edge. Never put a Metal layer effect over the glass surface. |
| Web shell/dock | Shell max-width 440 and height 100dvh. Dock buttons are 72 × 50, with CSS glass. | Keep the narrow reading column for this scope. Add working browser history and keyboard behavior without replacing the shell. |
| Content cards | Native OrganicSurface defaults to radius 36. Current local radii include 24, 26, 28, 30 and 32. Web OrganicCard defaults to 28. | Reuse the nearest existing component. Proposed new compact clinical rows use radius 26 and 16 inner padding. Multi-section review cards use radius 32 and 20 inner padding. |
| Glass | Native material fallback and guarded glassEffect. Web blur 26px/saturation 180%, strong blur 40px/saturation 200%. | Use for chrome, small controls and existing overlays. Use opaque surface cards behind long forms and clinical text. |
| Forms | Current forms are limited and use several local patterns. | Use one column, persistent field labels, inline error text and a final review step. Start with 20 side margins, 16 section gaps and 12 between related fields. These are proposed defaults. |
| Clinical detail | Lab/medication views already pair a heading with facts, source or explanation and contextual conversation. | Use title → source/status/date → primary facts → history/original → explanation → question/share actions. Reuse charts only for comparable numeric readings. |
| Sheets | Quick Log, Settings and Network already use sheets. | Keep short create/edit/review tasks in sheets. Long clinical histories use pushed detail screens. Add explicit Close/Back controls and unsaved-input protection. |

The new layout values are starting specifications for this app, not measurements of every existing screen. Allow wrapping and vertical growth. At large text sizes, change multi-column pickers to one column when needed. Keep interactive targets at least 44 × 44pt on native and a proposed 44 × 44 CSS pixels on web.

Use SF Symbols in native and the existing browser icon layer. Reuse the established icon meaning. Do not generate icons for ordinary auth, forms, alerts or record categories. For filled images in new SwiftUI grids, anchor layout with a sized Color and overlay the image with hit testing disabled. Clip the anchor, then add interactive overlays.

### Navigation and return paths

Keep Care's current tiles, including Records and Documents. You can expose those same records under You without copying their data or removing the Care doors. Keep Discussion Guide reachable from You and visit preparation. The new Forms route starts from Requests and applicable appointments. It does not require a new top-level tile in the first pass.

Replace event-only Today shortcuts with a stored route intent. The intent includes the tab, destination type, entity ID and origin. Consume it after the destination stack is ready. Preserve the selected Life item, result, insight or appointment. A missing ID opens a useful unavailable state with Back, never an empty background.

Native `CareDestination` and `YouDestination` must carry appointment IDs into preparation. Register each destination in every stack that can open it. Preserve each tab's last valid path and scroll position where possible. Re-selecting a tab can return to its root only under one documented rule, not as an accidental remount.

On web, connect the internal stack to browser history. Back first closes the active route or overlay according to its entry. Direct links pass through authentication and patient authorization. Never put clinical content or names in URL parameters. After an external portal, call or virtual-visit handoff, return to the selected item without claiming that the external task completed.

### Motion, sound and accessibility

Keep `NudgeSpring.ui` response/damping 0.42/0.82, gentle 0.55/0.86 and delight 0.38/0.66 as the native starting presets. Keep the existing soft press response. Native currently scales to 0.96 and opacity 0.88. Browser press uses 0.955 and 0.9 over 0.18 seconds. These are platform implementations, not a reason to rewrite all motion.

Use the existing orb modes only when they match actual state. Listening starts after capture starts. Thinking follows an active request. Speaking follows playback. A declined task must never trigger a success celebration. Keep a static orb and readable status when reduced motion is enabled.

Keep the bundled audio assets. Native onboarding no longer autoplays a bed; new-user background music is off, while existing saved music preferences remain intact. Stone Kintsugi remains optional app music; preserve the recap score and tap recordings. Reserve completion sounds for confirmed local saves or verified action outcomes. Navigation does not need a completion sound. Pause app audio before opening the microphone. Restore the prior bed only if the user's music preference still allows it.

Extend reduced-motion handling to video breathing, memory bob, voice particles and the Today plus pulse. Keep chart values and garden history accessible as text. Add a list alternative to the body map. Browser sheets need focus containment, Escape handling and focus return. VoiceOver and keyboard users must be able to review sources, correct input and decline actions without a drag gesture.

## Assets and content production

### Reuse before generation

The [as-built inventory](RUMI_AS_BUILT.md#assets-and-recreation-inventory) lists every shipped image, font and media filename. It remains the full inventory. Use those files as the starting asset set, not a prompt to regenerate a new visual identity.

There are two related visual treatments. `currents_kidney.jpg` is a textured editorial illustration with muted sage, ochre and terracotta forms. `walking_shoes_stride.png` shows dimensional cream-and-terracotta shoes in a softly lit scene. Keep both uses: editorial scenes for education and clinical overviews, recognizable objects for logging. The source images are not all transparent cutouts. Native subject lifting creates some of the floating-object treatment.

| Asset group | Keep | Required change or production gate |
|---|---|---|
| App identity | Current app icon, Rumi wordmark, six bundled font files. | No new icon, font family or native target name in this scope. Verify commercial rights before release. |
| Orb | Five existing orb videos, procedural small orb, voice glow and day/night mapping. | Keep static/reduced-motion fallback. Do not replace status footage with a new character. |
| Activity | 21 native illustrations mapped to 24 names. | Bring the same mapping to web. Keep legacy images available to old saved entries. |
| Symptoms | 15 existing shared feeling illustrations and current semantic mapping. | Reuse for supported symptoms. If Clinical adds a symptom with no suitable image, commission it after taxonomy approval. Never use a food photo as symptom art. |
| Meals | Six images used by 39 names. | Audit misleading matches, such as vegetarian labels with a salmon or chicken image. Use neutral category art until approved replacements exist. Preserve saved image keys and estimates as historical data. |
| Medication objects | Three existing bottle/blister images. | Fix the web `med:<id>` filename bug. Use the existing medication image lookup. Do not imply a generic image is an exact pill-identification tool. |
| Records and care | Folder, notebook, calendar and current clinical/editorial art. | Reuse for Documents, Notes, Forms and appointments. Dense record rows need text and icons, not new art for every value. |
| Currents | Existing article/recap art and finite feed structure. | Add source, reviewer, revision and expiry metadata. Listen requires real narration. Watch requires matching media and captions. Disable unsupported formats with an explanation. |
| Recap | Existing dawn/garden/path art and score. | Reuse as labeled illustration. Compose only from eligible dated history. Bring the native recap score to web only after rights and playback behavior are confirmed. |
| Held photos | User-selected originals and captions. | Add real web selection, export/delete and cancellation cleanup. A canned image is not an uploaded memory. |
| Sponsor/provider identity | Only existing or supplied authorized marks. | Obtain approved files and claims before publication. Do not generate a real provider's or sponsor's logo. |

### Activity mapping to preserve

Use `ios/Nudge/Models/LifeModels.swift` as the semantic mapping reference. Update the browser's `web/src/sano/lifeLibrary.ts` to match after approval. These are the 24 current choices, not a proposed larger catalogue.

| Activity names | Native image key |
|---|---|
| Walk, Evening walk, Morning walk | `walking_shoes_stride` |
| Hike | `hiking_boots_walking_pole` |
| Bike ride, Cycling | `clay_bicycle` |
| Swim | `water_ripples_goggles` |
| Treadmill | `clay_treadmill` |
| Stairs | `clay_stairs_glow` |
| Yoga | `yoga_mat_bolster` |
| Stretching | `clay_figure_stretching` |
| Pilates | `pilates_ring_and_mat` |
| Tai chi | `clay_figure_tai_chi` |
| Breathing | `glowing_clay_orb` |
| Dance | `clay_figure_dancing` |
| Strength training | `clay_dumbbells` |
| Resistance bands | `resistance_band_clay` |
| Light weights | `kettlebell_clay` |
| Quad sets | `leg_quad_extension` |
| Physical therapy | `hands_supporting_knee` |
| Gardening | `hands_planting_sprout` |
| Yard work | `leaf_rake_with_pile` |
| Housework | `broom_dustpan` |
| Standing desk | `standing_desk_workspace` |

Keep exact-name selection and most-specific-first matching for input. The walking fallback belongs to text matching, not saved-entry decoding. Decode old entries with their stored image keys and legacy fact mappings. Do not match them again. Keep `CareEntry.Kind.move`'s persisted value `"Moves"` while displaying Activity.

New manual entries must not gain invented facts from a fallback image. If legacy estimates move into explicit fields, label them as image-derived estimates. They are not measured activity or nutrition.

### New asset brief and acceptance

Create new art only for a confirmed content gap. For logging objects, use the current cream/terracotta materials, soft directional light and a subject readable at thumbnail size. For editorial scenes, use the current textured palette and restrained anatomy. Do not add text, numbers, provider marks or sponsor claims inside an image.

Before commissioning, record the destination, subject, reference asset and intended crop. Keep the original at enough resolution for the largest approved display size. Export appropriate platform variants after testing that crop. Do not impose a guessed universal aspect ratio on both square objects and editorial scenes.

Each asset needs a semantic key, file path, source, usage rights, revision, dimensions, crop/focal point and alternative text decision. Medical illustrations need clinical review. Decorative images should not repeat adjacent text to a screen reader. Screens must remain usable when an image or extraction cache fails.

Native image sets use `Assets.xcassets/<key>.imageset/Contents.json`. Browser images use `web/public/img`. When replacing a public browser asset, use a new filename and update its reference to avoid stale cached files. Keep old names while saved entries or old clients still reference them. Do not infer nutrition, effort or clinical severity from an asset key in the new model.

No assets were generated or changed for this document.

## Copy and status language

### Voice and terminology

Keep Rumi's direct, warm tone. Use short sentences and the patient's chosen name where useful. Explain the next action without promising an outcome the service cannot verify. Avoid guilt about habits or missed entries. Safety instructions must remain direct even when the rest of the screen is gentle.

Keep Today, Care, You, Journeys, Currents, Life, Story, Insights and Discussion Guide. Use Activity in the interface. Use "Rumi" or "companion" in ordinary conversation, but disclose AI generation and external processing where needed. The current `Glossary.swift` comments must not prevent clear privacy or safety disclosures.

A habit, a clinical plan goal and an external task are different things. Do not rename them all "journeys". A remembered preference is not a clinical note. A message draft is not a sent message.

### Existing copy that needs a decision

These are source excerpts, preserved exactly where quoted. They are not approved future claims.

| Source | Current text or claim | Proposed treatment |
|---|---|---|
| `TodayCanvasView.threadResolved` | "You're set for now — I'll keep watch." | Replace when no monitoring service exists. Draft: "Nothing else needs your attention here right now." |
| `TodayCanvasView.lifeStrip` | "Today at your table" for meals, activity and medications. | Draft replacement: "Your day so far". Keep the same strip and See it all entry. |
| `TodayCanvasView.plusButton` accessibility label | "Log something — a symptom, a meal, a move, a med" | Use the visible Activity term and add vitals only when supported. |
| `ConnectionsView` | "A family of specialized agents working quietly behind Rumi. Tap any one to see what it's doing." | Describe available assistance and actual tasks. Do not imply every listed agent runs. |
| `ReportsView` confirmation | Promises the team will have the report before the visit and that nothing else leaves the phone. | Name the reviewed report, recipient and actual delivery state. Remove the blanket privacy promise. |
| `RecordConnectView.HealthKitAskView` | Says the cuff, watch and scale chat directly with Rumi and the patient never types. | Describe only granted categories and supported imports. Manual entry remains available where supported. |
| `PrivacyCenterView` | "Export everything" and "Nothing here is used to advertise to you. Ever." | Scope export and data-use claims to the approved implementation and policy. Legal/Privacy must review the advertising statement. |
| `project.pbxproj` microphone description | Says words go to the companion "and nowhere else". | Replace with approved text that states actual external speech processing. Do not draft a false on-device claim. |
| `BillsView` | Promises payment and a filed receipt from the selected card. | Show only supported tender and service-confirmed outcomes. A demo must identify itself before approval. |

### Draft interface strings for review

The following strings are proposals for ordinary UI, not supplied legal or clinical copy. Interpolate only verified names, dates and counts. Use localized dates and singular/plural forms. Keep the status meanings identical across iOS and web.

| State | Draft text | Action or condition |
|---|---|---|
| Empty memory | "Nothing saved here yet." | Add a memory. |
| Memory save failed | "We couldn't save that change. Your edit is still here." | Retry or continue editing. |
| Records connected, no data | "This source hasn't returned any records yet." | Retry or connect another supported source. |
| Partially imported records | "Some records are still missing." | Show affected categories and retry scope. |
| Stale record | "Last received on {date}." | Show date from the source's last successful import. |
| Document saved, extraction pending | "Your document is saved. We're still reading it." | Open the original without waiting. |
| Extraction uncertain | "Check this value against the original." | Open the cited page and edit the proposed value. |
| Entry saved, AI unavailable | "Your entry is saved. Rumi can't add a reply right now." | Keep approved rule-based support visible. |
| Voice not permitted | "Microphone access is off. You can type instead." | Type or open supported permission settings. |
| Voice processing | "Turning your recording into text." | Use only for batch transcription, never label it live text. |
| Local draft | "Draft saved. It hasn't been sent." | Edit or review. |
| Portal handoff | "Your draft is ready. Send it in your provider's portal." | Copy/open the supported portal. |
| Awaiting approval | "Review before sending." | Show recipient and selected information. |
| Approved but not submitted | "Approved. Not submitted yet." | Show cancel only if still possible. |
| Service submission accepted | "Submitted. Waiting for confirmation." | Open status history. |
| Unknown outcome | "We can't confirm the result yet. We're checking before trying again." | Use only if reconciliation is actually running. Otherwise say "Check status before trying again." |
| Declined proposal | "Not sent." | Use when no submission occurred. Keep the decline in history. |
| Confirmed delivery | "Delivered to {recipient} on {date}." | Use only when that level of evidence exists. |
| Unsupported action | "This service isn't connected in Rumi." | Offer a verified contact or keep a draft. |
| Old demo action | "Demo action. No request was sent." | Never convert it to a real receipt. |
| Feature moved | "Your {feature} is now in {destination}." | Direct link to the same saved content. |

Do not invent OTP expiry, response times, savings amounts or appointment guarantees to complete a sentence. SMS, push, terms, consent, crisis instructions, clinical feedback and sponsor claims need approved wording. Record the owner, version, locale and approval before release. Keep ordinary draft UI strings here during review, then reconcile them with the approved design and localization files.

## Feature-by-feature change instructions

The headings preserve the attachment's 36 feature names. They are not new requirement IDs. Each section describes where the feature fits and what changes behind it. Apply the shared design, copy, data and migration rules in this file. The corresponding [requirements sections](RUMI_REQUIREMENTS.md#table-of-contents) remain the authority for patient-visible behavior and unresolved domain rules.

Source shorthand in this section: `N/` is `ios/Nudge/`, `V/` is `ios/Nudge/Views/`, `W/` is `web/src/sano/`. `AppModel` is the current native state owner. `store.tsx` is the current web state owner. New service and data names below are proposed, not existing implementations.

### Welcome Router

Keep the Welcome orb, wordmark and background. Add a neutral session-check state before protected content appears. Resume interrupted required steps and preserve an authorized incoming destination. Return fully onboarded patients to that destination or Today.

Replace the Boolean-only branch in `N/ContentView.swift` and `W/SanoApp.tsx`. A local onboarding flag cannot establish identity. Separate session validity, required legal acceptance and patient setup. Clear previous-account views while checking a changed session. Demo entry, if approved, must use separate data and an explicit label.

### Mobile SMS OTP Auth

Add phone entry and code verification within the existing onboarding flow. Use a persistent country label, masked delivery destination and an editable phone number. Keep Back, cancellation and alternative sign-in visible. Code input should support paste and platform one-time-code autofill. Show retry timing only from the approved authentication policy.

Change `V/Onboarding/OnboardingFlowView.swift` and `W/screens/Onboarding.tsx`. Add a server-owned challenge ID, delivery state, expiry and verification result. Never store the code in app analytics or chat. Security must set countries, expiry, attempts, resends, recovery and recycled-number handling. A delivery acceptance does not create a session.

### Apple Auth (SSO)

Keep Apple sign-in in Welcome. Use the approved Apple button treatment rather than a custom generated mark. On success, continue inside the existing onboarding screens. Allow missing name/email fields without inventing persona details.

Replace the current advance-only handler with a verified provider exchange. Configure native capability, callback and server validation. Use account-linking rules before joining identities. Cancellation leaves the current account unchanged. The web flow needs its own supported redirect and recovery path.

### Google Auth (SSO)

Place Google alongside supported sign-in methods using provider-approved branding. It opens authentication, not the Connections mock. Keep profile completion within the existing About You screen.

Add a verified exchange and supported native/web callbacks. Distinguish the sign-in identity from later Gmail and Calendar permissions. Do not merge clinical accounts because email strings match. Product and Security must approve linking and recovery before this branch is enabled.

### Terms & Privacy Consent

Add a readable step after identity verification and before uses that require acceptance. Keep full legal text reachable from that step and Settings. Show required acceptance separately from optional personalization, analytics and external sharing. Use opaque content surfaces for long text.

Replace any use of epsilon as a blanket permission. Store the terms version, decision, patient/account, purpose and time. Enforce the decision at the service boundary and when selecting AI context. Legal supplies the text, jurisdictions, reacceptance and withdrawal rules. Do not preselect optional permissions based on today's epsilon default.

### Analytics Consent

Use a separate optional choice with a later Settings control. Explain what optional analytics covers without implying that it is needed for ordinary care. Keep the choice clear when consent storage fails.

Add a central analytics gate before introducing collection. Events need an approved allowlist, with no clinical text, voice, OTP or identifying payload by default. Withdrawal must stop covered dispatch, including queued events. Separate security operations from optional product analytics under an approved policy.

### Select Care Pathway

Reuse the four existing pathway choices and their visual treatment. Explain whether the choice is patient-reported context or a verified care-team assignment. Keep the entered profile and unrelated history when it changes.

Change `PathChoiceView`, `PathChoice`, `AppModel.switchPathway` and `store.tsx.applyPersona`. Keep Marcus, Elena, Sam and Rosa only in explicit demo mode. Real pathway selection must not call a fixture replacement routine. Clinical/Product must decide single versus multiple pathways and how conflicting assignments are resolved.

### Records Connection

Reuse the provider search, match review and source list. Replace username/password simulation with the selected provider's supported authorization flow. After authorization, show matching and import states separately. Provide readable category permissions, retry and manual alternatives. Apple Health needs its own platform-supported permission path.

Change `V/Onboarding/RecordConnectView.swift`, `W/screens/Onboarding.tsx` and the source rows in Records/Privacy. Replace provider-name arrays and one Health Boolean with connection records, granted scopes and sync state. Show last successful import separately from connection status. Ambiguous patient matching blocks association. Supported sources and contracts remain undecided.

### Notification Consent

Keep the current notification categories in Settings as review inputs. Add a purpose explanation before the system prompt, actual authorization status and a route to platform settings. Make quiet hours editable only when the schedule is enforced.

Separate app preference, OS/browser permission, device registration and delivery state. Push opens the exact authorized item through Welcome Router. No sensitive preview by default without approved policy. Clinical/Privacy must settle urgent exceptions, quiet-hour behavior, expiry and wording.

### Interactive Elements (buttons, cards)

Reuse `GlassSurface`, `ChromeIcon`, `NudgeButtonStyle`, `OrganicCard` and the current dock. Add accessible labels, explicit unavailable states and stable Back/Close controls. Keep forms readable above the keyboard. Use one pending state to prevent duplicate taps without discarding input.

Repair native destination registration, queued Today intents and web history. Replace browser sheet behavior with an accessible dialog implementation while preserving its appearance. Cards must carry the displayed entity ID. Repeated approval must reach the same action, not create another operation.

### Crisis/Self-Harm Handoff

Add a focused safety panel within conversation and symptom support. Keep its actions visible without the orb animation or a completed AI response. Pause sponsored recommendations during the safety flow. Use approved resources and wording for the supported location and population.

Create one safety decision boundary for text, transcribed voice and structured symptom inputs. The model cannot author or suppress emergency policy. Cache approved fallback resources according to policy. Record the resource shown and action taken, not an assumed completed call. Clinical must define triggers, ambiguity handling, medical/crisis overlap and service responsibility before activation.

### Visible Editable Memory

Keep native Privacy Center's memory visualization as an optional browsing view. Add a readable list with source, content and edit/forget actions. Build the same controls on web. Open one item in an edit sheet and preserve the draft on save failure.

Change `PrivacyCenterView`, `AppModel.addMemoryNote/deleteMemory`, the web memory methods and both prompt builders. Add item revisions and deletion markers. Invalidate future retrieval and affected conversation summaries when memory changes. Earlier messages may still contain the same fact, so deletion must explain and enforce its actual scope. Do not change clinical records when editing a memory.

### Agentic Action Cards

Keep action cards in Today, conversation and the network. Expand the review to show recipient, selected data, any cost and the requested commitment. Use distinct approve, decline, pending, failure and receipt states. Long payloads open a review sheet without hiding the essential summary.

Replace `richResolved` and separate local action flags with one action record shared by all three surfaces. Bind approval to a payload revision. Recheck account, permission, source and service capability when executing. Only an executor can submit work. Only verified external evidence can set a corresponding completion state. Preserve declines and unknown outcomes in history.

### Sponsored Responses

Retain sponsor disclosure near the sponsored content and its explanation sheet. Separate ordinary clinical text from the offer. Keep neutral alternatives reachable without joining a program. No sponsor treatment may resemble a clinician's endorsement.

Add content revision, sponsor identity, eligibility basis and approval status outside the prompt. Enforce decline and placement rules across conversation, medication pages and Journeys. Displaying an offer must not send patient data to the sponsor. Commercial, Legal and Clinical must approve claims and ranking policy.

### Relevant Card Stack ("Thread")

Keep a maximum of three current Today moments as the proposed default. Preserve their current art, spacing and dismissal motion. Add a non-swipe dismissal option and an inspectable reason where personal data affects selection. Keep the empty state calm and factual.

Replace generic actions in `V/Today/MomentCard.swift` and `W/screens/Today.tsx` with typed targets. An insight opens that insight, a habit updates that habit, and a task opens its own review. Save dismissals and expiry. Product/Clinical must define ranking and resurfacing when more than three items qualify.

### Needs You' Clinical Alerts

Keep the Care attention section, Today signal and Care dock indicator. Clinical alerts need a reason, source, time and explicit action. Routine bills/messages must remain distinguishable from urgent clinical events. Opening an alert leads to its exact item.

Native `NeedsYouItem` generates new UUIDs when the computed list rebuilds. Web uses entity IDs but a nonspecific `"result"` ID for result attention. Replace these with stable patient/source-event IDs and revisions. Wire acknowledgment on both platforms. Store acknowledgment separately from clinical resolution and action completion. A corrected source can update or retract the alert. Clinical must approve severity, recurrence and overlapping-alert rules.

### Tracking Entry Point

Keep Today's plus, contextual medication logging and Life's add entry. Reuse the illustrated searchable library. Add Vitals only for approved measurement types. Add an editable timestamp and a review step without forcing the patient through chat.

Use a tracking intent containing type, selected entity and return destination. Clear incompatible fields when the type changes. Replace blank/no-match fallback saves with explicit manual entry or a clear limitation. All entry paths must use the same save operation and return the saved record ID.

### Care Plan

Keep `V/Care/CarePlanView.swift` and `W/screens/shared.tsx`'s plan screen. Place author, date and version near the plan title. Keep clinical instructions separate from habit suggestions. A goal opens a small-habit proposal for review before it reaches Journeys.

Separate the clinical plan, plan goal and patient habit records. Replace immediate `deriveJourney` with review and atomic saving of the habit and source link. A withdrawn plan marks linked habits for review. It must not delete recorded progress or silently rewrite instructions.

### Discussion Guide

Keep one Guide reachable from You, looking-ahead, clinical questions and visit preparation. Add text editing and optional appointment assignment. Distinguish questions from observations and discussed from unresolved. Share selected items through the common review sheet.

Extend `GuideItem` with source links and revisions. Replace Guide's view-local sent Boolean with a message or report action. Keep questions when an appointment changes or is cancelled. Whether AI can add a labeled draft automatically remains a Product decision. It may never send it automatically through this path.

### Providers

Reuse the Care team list and provider rows. Show the selected provider's role, practice and supported actions. Use a neutral initial/icon if no approved photo is available. Missing contact information should be visible, not replaced with a fixture number.

Give each provider/practice a stable ID and verified capabilities. Replace global `callOffice` use where a provider-specific number is required. Carry the selected provider into messages, appointments and reports. A changed recipient requires a new sharing review. No staff portal is added.

### Appointments Mgmt

Extend the existing list/detail screens with supported booking and cancellation. Keep the date stone, status chip and reschedule sheet. Show requested and confirmed times distinctly. Prep, reports, joining and Trip must all use the selected visit.

Add appointment IDs to both native prep routes. Replace `appointments.first` in `VisitPrepView`. Repair web You's recursive team route and add the missing management controls. Use provider availability and confirmed revisions. Update reminders and logistics after confirmed changes. Detect slot loss and unknown outcomes without double booking.

### Virtual Visits

Keep Join in the appointment detail. Show the provider service, allowed window and readiness/help actions. Disabled joining must be noninteractive on both platforms. On return, retain the selected appointment.

Replace `.example` URLs with verified visit-specific destinations. Apply provider-approved status/window rules, with a clock update while the page is open. Validate external URLs before opening them. In-app video versus provider handoff remains a scope decision. Opening a URL is not proof of attendance.

### Messaging

Keep the current inbox and thread appearance. Add recipient/category selection, saved drafts and real attachment review. Use the same composer from symptoms, Guide, conflicts, visit preparation and reports. Keep portal drafts visibly distinct from in-app delivery.

Unify `sendMessage`, `startThread`, browser thread sends and all local sent flags behind one communication service. Store recipient IDs, attachment IDs, message revisions and provider receipt IDs. Web symptom messages must attach actual reviewed content. Incoming messages update the correct thread and attention item. Do not generate a care-team reply.

Retain Requests and the four kinds currently exposed on native: refill, appointment, records and form. Keep native `V/Care/RequestsView.swift`'s composition entry and add the missing browser composition. Replace both `submitRequest` local-submitted handlers with a reviewed request action. Add request detail, actual provider status, supported cancellation and recovery. A form request can link to a form response but does not complete the form.

Migrate existing submitted, acknowledged and resolved request records as unverified local/demo history unless external evidence exists. Keep their patient-authored text when ownership can be established. Do not submit them automatically during migration.

Web also declares `referral` in `W/types.ts`, but no working composition flow was found. Preserve that value if a legacy record contains it. Show it as unverified history with no execution capability until Product approves referral scope and an integration exists. Do not drop or convert it to another request kind.

### Forms

Add Forms inside Requests and relevant appointment preparation. A form detail shows its owner, version, due date and progress. Use the shared single-column field layout. Highlight missing required fields and preserve a draft. Finish with a review of answers and destination.

Add form definitions, conditional fields, responses, attachments and submission records. Bind each response to a definition version. AI prefill is proposed content requiring review. Signatures and consent need the provider's approved process. The existing request kind `form` and document type `form` remain useful links, not substitutes for completion.

### AI Companion Atomic Habits & Journeys

Keep the garden, habit rows, held photos and program context. Add a habit detail/edit sheet, pause/resume and a correction path for keeps. Show history as dates and text as well as garden lights. Keep feedback free of guilt.

Accept the actual proposed habit from chat. Do not keep the first existing habit. Persist journeys, kept dates, pauses and source-goal links together. Keep timezone-aware date handling and duplicate protection. A program withdrawal must explain affected habits before changing them.

### Medications (w/ AI support)

Keep medication images, tide treatment and detail layout. Add source/status near the dose and separate taking reports from the prescription. Keep linked symptom logging. Make supported refill and savings paths reachable from the selected medication.

Separate medication records, schedules, taking events, supply evidence and refill requests. Replace fixture adherence with an approved calculation or mark it unavailable. Update the tide only from that result. AI uses the selected medication and permitted evidence. Never let chat, a habit or a payment action change a dose.

### Medications Sponsored Pages

Extend the reachable medication support area using the existing Savings card style. Put sponsor and scope near the heading. Keep clinical information separate from financial estimates and offers. Show neutral support options alongside eligible sponsored content.

Use a medication/program link and versioned approved content. Check expiry and eligibility before enabling an application. Collect and share only reviewed fields. Product/Commercial must decide whether the feature means brand pages, support-program pages or both. Do not create a branded catalogue from the attachment name alone.

### Immunizations (w/ AI support)

Extend the current Records category into a list and detail screen. Show administration date, product and documented series/dose details where available. Use the shared source/status rows and question action. Missing records need a distinct empty state.

Add a structured immunization record linked to its source. Keep patient reports separate. AI may explain the selected record but cannot infer that absent documentation means a missed vaccination. Clinical must approve any schedule or reminder logic before adding it.

### Documents (w/ AI support)

Keep the Documents list and familiar folder art. Replace title-only Add with approved file/photo/import choices. The detail screen shows the original first, then extraction status and proposed values. Tap a value to inspect its source page. Provide correction before confirmation and clear delete scope.

Add artifact storage, upload validation and extraction jobs. Retain the original even if extraction fails. Save reviewed fields with page references and revisions. Clinical-record import is a separate authorized operation. Implement the missing browser add/review/remove controls. Do not treat Vision subject lifting as document OCR.

### Notes (w/ AI support)

Add a Notes list/detail under clinical information, with separate patient and clinical note types. Use the existing notebook imagery only where useful. Patient notes have an editor. Imported notes retain a read-only original plus approved annotation/correction actions.

Create note and revision records distinct from Guide and memory. AI summaries cite the original note. Let the patient choose what becomes a question, memory or shared message. Private-note AI inclusion and restricted clinical notes need approved privacy rules. Search only authorized content.

### Vitals (w/ AI support)

Add a Vitals category and approved types to tracking. Use labeled value/unit/time fields. Paired measurements such as blood pressure need linked component fields. Reuse GlowChart for compatible trends and provide a plain values list.

Add observation records with measurement code, components, units, effective time, source/device and method. Keep imported and patient-entered values distinguishable. Validate types and units without silently converting uncertain data. Clinical must approve supported types, plausible-input handling, thresholds and feedback.

### Labs (w/ AI support)

Keep the lab detail, chart scrub and explanation sheet. Add status, source and per-result units/ranges where needed. Make preliminary, corrected, missing and conflicting results visible. Allow a Guide question or reviewed report inclusion from that result.

Sort by actual dates rather than array position. Preserve result versions and source references. Do not compare incompatible units or ranges without approved normalization. AI explanations cite the selected values. A source correction must mark affected summaries and reports, not quietly leave old claims current.

### Conditions (w/ AI support)

Keep the condition overview, phase and care-plan links. Add a readable condition list for multi-condition patients. Show active/history/self-reported/uncertain status where supported. Keep supporting record and Guide links close to the explanation.

Move real clinical context out of `Persona`. Use patient-linked condition records with source and verification status. A pathway choice cannot create a confirmed diagnosis. Keep relevant conditions available across chat, reports and medication explanations. Predictive content must remain separate from diagnosed conditions.

### Allergies and other clinical information

Add Allergies to Records using the shared clinical detail layout. Show substance, reaction and available severity/status. Distinguish "no information" from a documented negative history. Provide a visible correction or contact path for conflicts.

Create structured allergy records and attributed patient annotations. Do not use an AI guess to settle conflicting allergy evidence. Retain the existing Procedures category and its source records. Use the shared record list/detail and source/correction rules for that category. Retention does not authorize new procedure advice or scheduling.

Clinical/Product must define genuinely new categories before adding routes or database fields. The phrase "other clinical information" does not establish an unlimited clinical-history scope.

### Sponsored Programs

Keep program cards and sponsor explanations in Journeys. Add a review step showing eligibility basis, commitments, cost and data sharing. Display pending, enrolled, declined and ended states distinctly. Keep neutral care and ordinary habits accessible.

Separate content eligibility from enrollment execution. Save the approved program revision and consent with the submission. Persist decline across chat, medication pages and Journeys for the approved interval. Replace local `enroll` success with the actual service result. Do not create a program journey after a decline.

### Symptom Tracking w/ AFB

Keep the illustrated picker, body-region option, severity control and note entry. Add a timestamp, review and history/correction path. Present saved-entry status before feedback. Keep approved urgent guidance visible above optional AI text and ordinary next steps.

Change `AppModel.addLog` and web `addLog` to return a saved log ID/revision. Store rule assessment and AI feedback separately, linked to that revision. Rules run without waiting for generation. AI receives the selected observation and applicable rule outcome. Corrections can trigger reassessment but must not rewrite a message already sent. Clinical must supply taxonomy, scales, thresholds, clarifications and overlapping-risk policy. AFB includes both feedback types.

### Retained experiences outside the 36 attachment rows

| Experience | In-place change and source touchpoints |
|---|---|
| Text and voice companion | Keep `ConversationView`, `VoiceModeView`, `CompanionEngine`, `VoiceSession` and browser Conversation. Fix the missing current typed turn on web, explicit degraded mode, real context selection and cancellation. Keep text usable when speech is unavailable. See the technical contract below. |
| Eight-agent network and connections | Keep Network overview/detail, Today pulse and Connections. Bind every count and task to actual service state. Keep unsupported domains visible as unavailable where useful, with no invented activity. Pause and revoke must reach the executor. |
| Visit preparation and reports | Keep Reports and the existing brief presentation. Pass appointment ID to preparation. Use correct patient, explicit interval and selected questions. Retain an immutable reviewed report and a real export artifact. Send through the common action/communication service. |
| Bills, wallet and savings | Keep the current pages, but separate estimates, patient-reported paid status and processor evidence. Use tokenized eligible tender only. Insurance cards cannot pay bills. Enable real payment only after financial approval and provider integration. |
| Life gallery and held photos | Keep day grouping, object images and detail overlays. Add timestamp/portion/duration corrections where approved. Decouple facts from images. Add real web photo selection and file cleanup. |
| Story and Insights | Keep Story/Insights as You's existing segments. Make Today links select the right insight. Use attributed dated events, save bookmarks and expose evidence. A statistical or predictive claim needs an approved method. |
| Currents and recap | Keep finite content and the existing player/recap presentation. Replace timer-only playback and misleading save-to-Story claims. Provide a saved-content view within Currents. Use real captions/narration and a dated recap basis. |
| Settings, privacy and rights | Keep settings placement and existing appearance/audio/tone choices. Add web profile/memory parity, real consent controls, usable export and scoped deletion. Retire cosmetic confirmations only after replacement and migration checks. |

## Engineering and backend specification

### Extend the current clients

Keep SwiftUI/MVVM on iOS and the existing React/TypeScript app on web. `AppModel` and `SanoProvider` can remain compatibility interfaces while storage and service work moves behind them. Do not rewrite all screens or introduce a second app state store with competing ownership.

Introduce domain repositories for account/consent, clinical records, tracking, Guide/notes/memory, habits, communication, appointments, actions, content and rights. They may share a backend deployment. Separate modules do not require separate microservices. Each domain needs one authoritative writer and adapters to existing view models.

The current `functions/index.ts` Worker handles only speech forwarding. Extending it, or using another managed backend for clinical storage, is an engineering decision requiring security and data-processing review. No database, auth provider, clinical aggregator, payment processor or video provider is selected by this document.

Recommended dependency shape:

```text
Existing iOS views / existing web screens
  -> existing state interfaces, gradually split by domain
  -> authenticated API client + account-scoped local cache
  -> account authorization and purpose-based data checks
  -> domain services and durable records
  -> provider adapters / action executor / import and extraction jobs
  -> approved external systems

Companion request
  -> permitted context + selected entity revision + safety assessment
  -> configured AI gateway
  -> validated text/citations/action proposal
  -> patient review
  -> the same action executor used by ordinary screens
```

A model response has no direct database-write or external-send authority. Read-only explanation may finish even when an action provider is unavailable. The interface must show that distinction.

### Proposed data contracts

These fields define the information needed for implementation review. They are not a committed database schema. Use stable IDs, explicit revisions and account authorization. Do not reuse a display name, array position or pathway as patient identity.

| Record | Minimum proposed fields and relationships |
|---|---|
| Account and session | Auth subject, session reference/expiry, authorized patient IDs, account status. Keep tokens out of clinical records and telemetry. |
| Patient and pathway | Patient ID, editable profile, pathway selections, who selected each and when, source where assigned. No fixture persona fallback in live mode. |
| Consent decision | Account/patient, purpose, version, decision, effective time, withdrawal and applicable policy revision. |
| Source connection | Patient, provider, external account reference, granted scopes, status, last successful sync, cursor, last error category. Keep provider tokens server-side. |
| Clinical source item | Patient, type, source ID/external ID/version, clinical code/system, event/issued/imported times, status, original evidence, superseded item. |
| Clinical interpretation | Source item IDs/revisions, generated text, model/content/rule version where applicable, generation time, review state. Never overwrite the original. |
| Observation or symptom log | Patient, type/code, values/components and units where relevant, time, note/context, body/medication link, source, revision. |
| AFB assessment | Log ID/revision, applicable rule set/version, rule outcome, evidence, required action, assessment time, linked AI feedback and reassessment state. |
| Memory / private note / Guide item | Separate types with content, source links, revision, created/updated/deleted times and purpose. Guide adds discussed state and optional visit links. |
| Journey and habit event | Habit/journey IDs, user-approved content, optional plan/program link, active/paused state, dated keeps and corrections. |
| Appointment | Patient, provider, source/external ID, timezone-aware time, status/revision, location/channel, verified join reference, request history. |
| Message and draft | Patient, thread, recipient/capability, body revision, attachment IDs, authorship, sent/received times, action and external receipt references. |
| Form response | Form ID/version, patient/visit, typed answers, draft revision, validation state, attachments/signature references, submission action. |
| Artifact and extraction | Owner, original storage reference, content type, size/hash, pages, retention class, extraction status, fields with page references and review revisions. |
| Action | Patient, type, source entity, payload revision/hash, permissions, approval scope/time, idempotency key, external operation ID, status and event history. |
| Report snapshot | Patient, recipient, visit if selected, interval/timezone, included source revisions, excluded data, authored/reviewed time, artifact and sharing actions. |
| Content and sponsorship | Piece/program ID, source, revision, reviewer/approval, locale, media/captions, expiry, sponsor, eligibility basis and patient preference/decline state. |
| Export or deletion job | Account/patient, requested scope, confirmation, manifest, per-system status, retention exceptions, completion evidence and recoverable errors. |

Clinical categories need their own fields beyond this common structure. For example, lab reference intervals belong to the specific result. Allergies need reactions and verification status. Vitals may contain multiple linked components. Do not stretch the current `LabSeries` or generic `RecordItem` into every clinical entity.

Native and web formats already differ: UUIDs versus generated strings, ISO dates versus epoch milliseconds, and several enum values. Define one versioned wire contract and explicit adapters. Handle unknown enum values safely. Do not assume the two existing models are interchangeable.

### API operations and failure contract

Operation names below describe proposed capabilities, not deployed URLs. Engineering can choose route names and storage technology after review. Every operation must authorize the account/patient and validate input on the server.

| Operation group | Input and result | Failure or consistency requirement |
|---|---|---|
| Session exchange / challenge verification | Provider proof or OTP challenge response → verified session and permitted patient scope. | Replayed/expired proof fails. Linking requires approved identity verification. |
| Consent read/update | Purpose/version/decision → saved decision revision. | If a required decision cannot be verified, block the dependent use, not unrelated permitted care. |
| Connect / import / disconnect | Source authorization and selected scopes → connection record and import status. | Check patient match. Preserve partial categories and stop revoked access. |
| Clinical list/detail/correction | Patient, filters/cursor, source revision → records or attributed correction result. | Missing, forbidden, stale and conflicting data have separate meanings. |
| Save tracking / assess feedback | Entry/revision → saved ID, then linked rules/AI results. | Saving and generating are separate. Do not lose a saved entry when AI fails. |
| Edit memory/Guide/note/habit | Item ID and expected revision → new saved revision. | Conflicting edits return current state for review. Deleting the last item stays empty. |
| Draft / prepare action / approve | Exact reviewed payload and revision → action ID and authorization state. | Approval for an old payload cannot authorize a changed recipient or amount. |
| Execute / reconcile / cancel action | Authorized action ID → external operation/status events. | Use idempotency. Unknown is not failed. Check the external service before resubmission. |
| Availability / appointment change | Selected provider/visit/time → request or confirmed revision. | Slot loss and provider rejection preserve the draft choice without inventing a booking. |
| Form fetch/save/submit | Definition version and response revision → saved draft or submission action. | Validate conditional fields on the server. Handle superseded forms explicitly. |
| Artifact upload / extract / review | Approved type/size, owner, file → original ID, job, reviewed fields. | Validate content, scan where required, restrict file access and bound extraction cost. |
| Report build / export / share | Patient, recipient, interval, source selections → immutable snapshot/artifact and separate share action. | New content has a new revision. It cannot inherit a previous sent state. |
| Content/preferences/notifications | Approved content revision or category decision → saved preference and eligible deliveries. | Do not dispatch content after revocation or ignore a saved decline on another screen. |
| Rights request / status | Confirmed scope → export/deletion job with manifest. | Report partial completion and retention exceptions. A local reset is a different operation. |

Use a consistent error shape: safe error category, recoverable flag, request ID, relevant current revision and retry timing only when valid. Do not return provider secrets or clinical internals in generic errors. Lists need bounded pagination. Uploads, text and generation need approved limits. Unknown limits are release decisions, not permission for unlimited requests.

Use optimistic concurrency for editable records. A client submits the revision it reviewed. A conflict returns enough authorized current data for reconciliation. External writes use idempotency keys bound to an action and payload. Webhooks need signature verification, replay protection, duplicate handling and patient/action association.

### Companion and voice changes

Keep the current model configuration as the initial integration baseline: `anthropic/claude-sonnet-4.6` via the Rork chat endpoint. Native currently requests temperature 0.75, maximum 700 output tokens and a 45-second timeout. Web does not set the same bounds. Compare behavior before choosing shared limits. No model upgrade is required merely to change the app.

Build each request from the selected entity/revision, current user turn, permitted history, memory revision and applicable safety result. Include the latest user turn exactly once. Replace web's stale-ref sequence. Track one request/session generation so a response from an old patient, pathway or dismissed screen cannot mutate current state.

Move authoritative context permission checks to the backend for live patient use. Minimize transmitted records. Keep the original source IDs for citations without exposing unauthorized data. Retrieved documents and messages are untrusted content. Their text cannot instruct the executor, alter consent or authorize another patient's data.

Replace loose `[[...]]` parsing with a validated rich-content contract. Preserve read-only references such as `trend` as charts when their IDs and patient access are valid. They are not action proposals.

During migration, translate known mutating/action tags into drafts only. Apply the approved Guide-draft policy to `guide` tags. Validate type, IDs, lengths and capability. Unknown or malformed tags must not run actions or leak into patient text. Distinguish source quotations, AI explanations and unavailable-generation fallback.

Keep the current batch voice loop until a separate streaming decision is approved. It records, transcribes, requests a reply, plays speech and listens again. Do not label the animated returned transcript as live partial recognition.

Repair the existing `/voice/stt` and `/voice/tts` paths before changing their client contracts:

- Forward the multipart Content-Type with its boundary when forwarding the raw recording body.
- Validate caller/session, method, input types and approved limits. Restrict caller-controlled speech settings to allowed values.
- Add upstream timeouts, safe errors, rate/cost controls and consistent CORS for approved browser origins. CORS is not authentication.
- Keep `ELEVENLABS_API_KEY` server-only. Client configuration may contain public gateway values, never provider secrets.
- Cancel or invalidate permission, recording, upload, generation, playback and relisten work on Stop, dismissal or account change.
- Recheck session intent after a late microphone permission grant. Stopping must prevent new recording.
- On web, handle recorder state, rejected autoplay, network failure and frame-rate-independent silence timing.
- Remove temporary recordings according to approved retention. Avoid untracked orphan files and app-audio leakage into capture.

Current STT uses `scribe_v2` and `no_verbatim: true`. TTS uses `eleven_turbo_v2_5`. Preserve these as testable starting settings, not a promise of availability or approved clinical transcription accuracy. A transcript used for a consequential action needs the review defined by the approved voice policy.

### Action execution and background work

Use one durable action state machine: proposed, blocked, approved-not-submitted, submitted, accepted, completed, unsuccessful, unknown, declined or cancelled. The exact provider may support fewer delivery distinctions. Never invent a receipt state it does not report.

The executor checks the approved payload revision, current consent, account scope, agent pause state and provider capability. It records the submission ID before reconciling later callbacks. Material changes require new review. Cancellation after provider acceptance may be impossible. Report that limit without deleting the history.

Network cards read this history. They do not create working tasks from fixture cadence strings. Pausing prevents new work and explains already-submitted operations. Risk watch, continuous monitoring and escalation remain unavailable for live claims until their clinical services and operating responsibilities are approved.

Reports, messages, refills, forms, appointments, enrollment and payments share the execution controls but retain domain-specific validation. Automatic actions require a separate, explicit policy for type, scope, expiry and revocation. Do not infer broad permission from one approved card.

### Security, operations and configuration

Use account-scoped authorization for every stored object, file URL and background job. Store native session secrets in Keychain. Use the chosen browser authentication system's secure session pattern and protection against request forgery where applicable. Do not put provider tokens in browser storage or app bundles.

Keep demo and live environments separate. Supply managed public configuration by name and private provider bindings on the server. Replace historical fallback hosts before release with validated environment configuration. Add only capabilities actually used, with accurate permission descriptions and required native entitlements.

Define retention and encryption/key-access policy for clinical data, audio, files and audit history before real data is processed. Protect uploads with authorized access and expiring links. Review document content handling, malicious files and model prompt injection. Payment card entry should use the chosen processor's tokenization. Rumi must not store raw card numbers.

Operational logs should record safe request/action IDs, status categories and timing. Do not log OTPs, tokens, raw audio or full clinical/chat payloads. Metrics need approved purposes and retention. Monitor import failures, stuck actions, delivery failures, transcription errors and deletion jobs. Each live integration needs an owner and a response procedure.

Set measurable latency, availability, retry, recovery and accessibility targets during release planning. This document supplies no invented SLA. Record supported devices/browsers, provider coverage and known limitations before a live rollout.

## Migration and careful removal

### What stays, what is replaced, what may be retired

No requested feature or retained experience is proposed for wholesale removal. Replace misleading implementations and duplicate write paths. Keep useful entry points. Anything integration-gated remains clearly unavailable or explicitly demo-only until it works.

| Current behavior | Proposed disposition | Protection before removal |
|---|---|---|
| Five tabs, orb, fonts, colors, Life art, garden | Keep. | Capture representative screens and compare after each change. |
| Fixture-based patient context | Keep in isolated demo mode. Remove from live account initialization. | Do not upload mixed legacy snapshots as verified records. |
| Shared Care/You entry points | Keep as aliases to the same entities. | Preserve links and return paths. Remove a duplicate only after explicit review. |
| Separate Guide/prep/symptom/conflict send flags and locally submitted Requests | Replace with reviewed communication/request actions. | Preserve attributable text and unverified local/demo history. Never infer delivery or automatically resubmit during migration. |
| `richResolved`, legacy actions and agent task success flags | Replace with typed action state and history. | Mark migrated outcomes as local/demo without an external receipt. |
| Title-only document Add | Replace with real artifact capture plus metadata editing. | Retain old metadata as legacy items with no original attached. |
| Generic clinical record rows | Extend into typed categories/details. | Preserve originals and stable links. Do not infer missing clinical fields. |
| Unreachable Savings | Make reachable from relevant medications if service/content is approved. Otherwise show an honest limitation. | Do not silently remove savings from scope or turn old Apply into a live submission. |
| Timer-only media / false save-to-Story copy | Replace with real supported playback and a saved-content location. | Keep readable articles and old bookmarks. Disable absent media, not the whole content experience. |
| Cosmetic export/delete confirmations | Retire after real rights operations exist. | Audit all storage locations and prevent deleted data from reappearing. |
| Old image aliases, `"Moves"`, stable bill keys | Keep compatibility until migration and old-client support end. | Maintain explicit translation tests and saved-entry rendering. |
| Placeholder payment/telehealth/channel links | Remove from live routes. | Keep a verified alternative or unavailable state. Preserve a labeled demo where appropriate. |
| Fixed clinical dates/thresholds and invented monitoring copy | Remove from live patient guidance. | Replace with approved sourced content. Keep fixture examples isolated for demonstrations. |

### Legacy data migration

Native data is split across UserDefaults, `sano_user_data.json`, photo files, a lifted-image cache and temporary audio. Web stores 19 fields in `sano.web.v1`. Much visible state was never persisted. The [as-built storage tables](RUMI_AS_BUILT.md#persistence-and-account-boundaries) are the source inventory.

1. Detect the legacy format before initializing live data. Read it without overwriting it.
2. Create a recoverable migration snapshot under the approved local retention policy. Do not create an unprotected cloud backup of health information.
3. Classify data as demonstrably user-created, demonstrably fixture or uncertain. Preserve uncertain data for review. Lack of provenance cannot be solved by guessing.
4. Ask the signed-in patient whether to import eligible personal content where identity/ownership can be established. Legal consent must be collected again where no valid decision record exists.
5. Translate IDs, enum values and dates explicitly. Retain an old-to-new reference map for linked symptoms, medications, Guide items and files.
6. Write the new schema with a migration version and completion checkpoint. Migrate related records atomically where needed, such as a journey and its goal link.
7. Read back the result and compare counts, references, dates and file access. Treat an empty array as a valid saved state.
8. Switch the domain's readers and writers together. Keep only one authoritative writer. Retain rollback support for the documented compatibility period.
9. Remove the legacy copy only after verification and the approved retention decision. A later account deletion must include retained migration copies where policy requires.

Do not manufacture habits or appointments that were never saved. Do not turn old paid/sent/done Booleans into real receipts. A title-only document remains title-only until an original is supplied. A legacy accepted program may contain a memory note but no durable enrollment evidence.

Native currently ignores most empty restored arrays. Fix that before migration, or deleted-last-item fixtures can return. Web's nullish restoration already preserves empty arrays, so apply the correct platform-specific fix. A failed decode must offer recovery, not silently reseed a real account.

### Rollout and rollback

Use feature flags per domain and integration capability, with separate flags for reading, creating drafts and executing external work. Keep UI availability tied to service capability. Do not make a button look active because a release flag is enabled while its provider is disconnected.

Run migrations repeatedly in a test environment to prove they are resumable and do not duplicate records. Keep backward-compatible readers during the chosen client support period. For breaking contract changes, maintain a versioned adapter until old clients are retired.

Rollback can disable new execution and restore a compatible view. It cannot unsend a message or reverse an accepted payment. Keep the action history and reconciliation workers running for submitted operations. Do not restore an old data snapshot over newer confirmed work.

If a feature moves, keep the old entry as a direct link for an agreed transition period. Explain the new location once without forcing onboarding again. Preserve the selected entity, drafts and scroll context. Product must approve any later removal and its data-retention treatment.

## Verification and release checks

These are proposed engineering checks, deliberately kept outside the requirements file. None ran during this documentation edit. A build alone will not verify these behaviors.

| Area | Required checks before the affected change ships |
|---|---|
| Visual preservation | Compare Welcome, Today, Care, You, Journeys, Currents, conversation, Quick Log and Life in day/night. Include large text, keyboard and reduced motion. New screens must use the retained components and palette. |
| Navigation | Today → exact Life entry/insight/result. Care and You → selected visit prep. Back/dismiss/browser Back after auth, sheets and external links. Missing/deleted entities always have an exit. |
| Authentication and isolation | New/returning/expired/revoked sessions, OTP overlap rules, cancellation, account linking and account switch while requests are in flight. Verify no prior patient's data flashes or remains cached for the next account. |
| Migration | Each legacy format, empty arrays, corrupt/partial snapshots, interrupted/repeated migration, `"Moves"`, legacy image keys and linked IDs. Compare record counts and file access. Verify rollback does not overwrite newer work. |
| Clinical data | Wrong patient, duplicate import, source correction, conflicting units, missing dates/ranges and revoked sources. Confirm that demo facts never fill live gaps. |
| AFB and crisis | Approved clinical examples, rule/AI disagreement, missing context, overlapping risks, corrected entries and no-network behavior. Clinical reviews the expected outcome before testing. |
| Chat and voice | Current turn exactly once, selected context, validated inline charts, malformed proposals, consent withdrawal, late permission after Stop, dismissal during upload/playback, no speech and service failure. Verify no recording restarts after Stop. |
| External actions | Double tap, repeated callback, changed payload, paused agent, expired authorization, provider rejection, accepted-but-unknown outcome and cancellation limits. Inspect real receipts in an approved sandbox. |
| Reports | Actual patient name, chosen recipient/visit/range, unsorted/future results, corrected sources, excluded sections and immutable shared versions. Open the exported artifact and inspect it. |
| Assets and media | All 24 activity names, old image aliases, web medication thumbnails, failed image load, actual audio/video/captions and audio preference restoration. |
| Rights | Export opens and matches its manifest. Deletion covers the declared files/caches/live state and provider jobs. Ordinary saves and migration recovery cannot resurrect removed data. |
| Accessibility and parity | VoiceOver, browser keyboard/focus, large text/zoom, reduced motion, body-map alternative and readable approval/error states. Record real platform limitations. |
| Operations | Authorized endpoints, upload/text limits, webhook validation, rate/cost limits, safe logs, integration alerts and recovery for stuck jobs. |

Build and test each changed app after implementation. Use the existing native and web test targets for regression coverage. Record device/browser, environment, tested service coverage and failures. Do not treat a simulator build or screenshot as proof of provider delivery, medical safety or payment readiness.

## Dependencies and sequencing

Use the order below to plan delivery. It is not an approved schedule or estimate. All 36 attachment features remain in scope. Assign owners to the unresolved safety, legal and integration decisions before scheduling affected work.

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

The attachment does not answer the domain questions below. Record each approved policy in its requirements section and update dependent design or technical details here. After scope approval, unrelated work can continue. Keep an undecided clinical, legal or financial branch disabled until its owner resolves it.

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
| Other clinical information | Retain existing Procedures. Product + Clinical must name and bound additional categories beyond the retained record set and new Allergies. |
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
- Formal regulatory traceability remains in Greenlight Guru. The technical fields and route names proposed here are implementation concepts, not regulatory requirement IDs.

## Review and document ownership

Update these three files in place. The as-built reference records the current implementation. This file owns proposed changes, including design, copy, assets, engineering and rollout. The requirements file owns proposed functional criteria and follows the attached requirements guide. Only that file excludes design and implementation prescriptions.

The files are not published to Confluence or checked against Figma. Before publication, reconcile any existing pages. If the requirements file is split into feature pages, move each section once and preserve its links. Do not leave two active requirements pages for the same feature.

Review the current-state gaps first. Then decide on the proposed screen changes, technical approach and release coverage. Resolve the clinical, legal and service questions before implementing affected branches. The requirements owner must check the final design and copy against approved behavior. A document approval does not establish a working integration or authorize release.

Rork manages repository synchronization. A local file write is not evidence of a GitHub commit or remote push; only observed repository/remote evidence may support such a claim. No manual commit or push is performed as part of this documentation work.
