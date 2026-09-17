# nudge — Full System Writeup

A behaviour-change companion. This document describes the system as the code implements it. Every number, threshold, and name below comes from the working repository. Where a part is designed but not built, the document says so.

---

## 1. What the system is

nudge is an ongoing conversation with a person who wants to change a behaviour. The conversation is the product. Behind it, the system builds a psychological model of the person, works out what stops them and what moves them, and maps those into personalised interventions.

Three properties separate it from a chatbot.

**It remembers.** The system holds a typed profile of the person. Each fact carries a confidence score and the quote that supports it. The profile persists across sessions and drives every reply.

**It forms and tests theories.** The system writes low-confidence guesses about a person, then tests them in conversation. A guess that holds up climbs. A guess the person contradicts is closed and superseded.

**It reaches out.** The companion opens every session itself. Between sessions it can send a message when a plan cue comes due or a dated event approaches. Silence is a first-class choice and the common one.

The engine is general purpose. Everything condition-specific lives in a domain folder. Today one domain exists: type 2 diabetes.

---

## 2. The prime directive and the design principles

**The prime directive: be someone a person wants to talk to.** Warmth comes first. The behavioural machinery stays behind the curtain. At most one deliberate move per turn, and often none. When warmth and the agenda conflict, warmth wins.

Seven principles follow from it.

0. Be someone a person wants to talk to. This outranks everything. Nobody keeps talking to a system that makes them feel managed.
1. The agenda is internal. The person is never managed. Honour what they raise first and fully. Only then, if a door opens, connect back.
2. At most one move per turn, often none. The machinery earns its way in only when a door is open, trust allows it, and it would help now.
3. Directiveness is earned, not given. A new or guarded person gets patience and curiosity only.
4. An intervention is a specific prescription, not generic advice. It pairs this person's barrier with something that moves them, shrunk to the smallest action that will fire.
5. A slip is a data point, not a verdict. The most dangerous moment is right after a failure.
6. Safety overrides everything. The crisis screen runs before every reply.

Two engineering rules carry the same weight.

**Code does the crisp things. The model does the fuzzy things.** Move selection, safety, guardrails, salience windows, and dosage gates are deterministic and unit-tested. Classification, extraction, and generation go to the model. Date arithmetic and timing rules never live in a prompt.

**Nothing heavy runs on the hot path.** If a computation is not needed for this reply, a background loop does it.

---

## 3. Architecture: three loops over four stores

### The three loops

**Loop 1, the conversation.** Fast and synchronous. It reads a pre-compiled snapshot of the person, classifies the message, selects one move in code, generates the reply, checks it, and returns. It emits cheap signals for the slower loops and does no heavy analysis.

**Loop 2, reflection.** Background. It re-reads the recent conversation and consolidates the profile: beliefs, barriers, motivators, plans, events, threads, corrections, and a stage reading. It runs every fifth user turn and at session close.

**Loop 3, learning.** Background. It joins each logged decision to its outcome and refits the selection policy. Promotion is gated by off-policy evaluation.

A fourth pass runs between sessions: the journey meta-planner rewrites the multi-session plan and authors the aim for the next session.

### The four shared state stores

| Store | Holds | Read by |
|---|---|---|
| 1 — Values and identity | Core values, identity statements, action votes | Designed, not populated |
| 2 — Goal hierarchy | Goals with level, statement, and status | The plan writer |
| 3 — If-then plans | Cue, response, status, mental-contrasting fields | Move selection, proactivity, the agenda |
| 4 — Belief and affect | Every profile fact with confidence and evidence, plus the affect log | Everything |

Store 4 is the model of the person and the busiest part of the system.

### Memory backbone

The typed profile lives in PostgreSQL with pgvector. The system owns it, because confidence and provenance are the properties no off-the-shelf memory product supplies.

Episodic and temporal recall is delegated to Graphiti over Neo4j. Episodic writes are best-effort. PostgreSQL stays the system of record, so a failed episodic write never blocks consolidation. Graphiti runs on its own event loop on a dedicated thread, because the client and the Neo4j driver bind to the loop that creates them.

All memory access goes through one interface, so a backend can be swapped without touching the engine.

---

## 4. Onboarding and cold start

Onboarding collects six answers.

1. **The reason.** Why they came, free text, in their own words. The full sentence is kept.
2. **Name.**
3. **Age.**
4. **Location.**
5. **Profession.**
6. **Engagement mode.** Two choices: go slow and get to know me first, or help with my goal sooner. This maps to the internal modes `companion` and `change`. A choice made here is pinned and inference never overwrites it.

The reason does two jobs. Keyword matching against it selects the domain, so a reason that mentions diabetes or blood sugar makes the type 2 diabetes playbook and technique shelf available from the first turn. The reason also becomes the first item on the first agenda, held as context the companion carries rather than a topic it raises.

### Cold start

Before the first message, one model call turns the sign-up details into three to five tentative reads. These exist only to warm up tone.

Hard rules apply.

- Confidence is capped at 0.30. The prompt asks for it and code enforces it.
- The source is recorded as demographic inference, which excludes these reads from anything that gates an intervention.
- They stay private. The companion may only turn one into a genuine first-time question. It may never assert one as a known fact.
- Stereotypes are banned. Anything about health, weight, habits, or how well the person is coping is banned.
- An obvious restatement of a demographic is rejected as useless.
- If the metadata is too thin, the correct output is an empty list.

The cap holds only because the writer skips a repeated attribute inside one run. A repeat would take the reinforcement path and lift the value past the cap.

Two of the seeded reads are then placed on the agenda as things to test in conversation. Two, not more, because three or four turn the conversation into an interview.

---

## 5. The inferred profile

The profile is the core of the system. It is not a form. It is a set of separate, dated, evidenced statements about one person, each with a confidence score.

### 5.1 What one fact holds

- **The attribute.** A short name for what the fact is about. Free text, normalised on the way in.
- **The value.** Free text, a number, or one of a fixed set, depending on the attribute.
- **Confidence.** A number from 0 to 1. Also called precision.
- **The prior.** The confidence this fact held before the last update.
- **Status.** Derived from confidence. Confirmed at 0.80 and above. Rejected at 0.20 and below. Inferred between.
- **Source.** Either conversation or demographic inference.
- **Valid from, and valid to.** A fact is never deleted. Contradiction closes it with an end date and opens a new one.
- **Evidence.** One or more rows, each holding a verbatim quote, a weight, and a source. Every reinforcement appends another quote.

### 5.2 Everyday life

Nineteen canonical attribute names cover the ordinary facts a friend would remember. Values are free text, so the value carries the nuance.

Work context. Work schedule. Communication styles. Humor style. Hobby. Likes. Dislikes. Morning routine. Evening routine. Sleep pattern. Exercise pattern. Food preferences. Drink preferences. Family context. Social context. Living situation. Health context. Stress response. Coping style.

The extraction prompt bans wording variants of these names. The name stays canonical and the value carries the detail.

These facts change five things.

- A fact above 0.80 confidence enters the prompt as something already known, so the companion stops asking and uses it as a way in.
- Hobbies, likes, and interests become the hooks for the opening message of the next session.
- A dislike becomes a hard constraint on the opening message.
- Communication style, humor style, and processing style go in as an instruction to match the person's register.
- Routine, schedule, and sleep are what let a plan fit a real week. On a rotating schedule the plan attaches to an event in the day rather than a clock time.

### 5.3 Personality

**The Big Five.** Openness, conscientiousness, extraversion, agreeableness, and neuroticism. Each is read separately and scored from 0 to 1.

Two of the five drive a rule. Neuroticism at 0.60 and above lowers the directiveness ceiling one level and adds an instruction to lead with grounding and reassurance. Openness at 0.60 and above allows ideas and abstract threads. The other three are recorded and shown to the companion, and no rule reads them.

**Attachment style.** Secure, anxious, avoidant, or disorganized.

Avoidant lowers the directiveness ceiling one level and adds an instruction to give space and let the person set the pace. Anxious adds an instruction to be extra consistent and to show that the companion remembers, and to reassure rather than going brief. Disorganized asks for predictability and gentle consistency.

**Dominant social need.** One of six: importance, approval, acceptance, security, control, connection. Each value maps to its own instruction.

| Need | The instruction |
|---|---|
| Connection | Genuine connection lands. Relationship over task. |
| Control | They value agency. Offer choices. Never dictate or take over. |
| Importance | They want to feel seen. Acknowledge their experience and competence. |
| Approval | Affirm sincerely. Never make them feel judged. |
| Acceptance | They fear being an outsider. Normalise and include, with no pressure to conform. |
| Security | They value predictability. Be steady and clear, and reduce uncertainty. |

**DISC style.** Dominance, influence, steadiness, or conscientiousness. Recorded and passed to the session planner. No rule reads it.

### 5.4 Thinking patterns

Six cognitive distortions, each rated none, mild, moderate, or strong.

Catastrophizing. All-or-nothing thinking. Overgeneralization. Mind reading. Emotional reasoning. Mental filter.

Three constraints apply. A pattern is recorded only when it repeats or the person is explicit, so one bad day stays one bad day. Confidence is capped at 0.50 unless the evidence is unmistakable. These are private clinical hypotheses and are never named to the person.

One standing instruction covers all six: if the companion notices the pattern, it offers a middle ground without diagnosing or labelling. It may wonder aloud whether something sits between total failure and perfect. It may never name the distortion.

### 5.5 Character strengths

Twenty strengths are available: humor, perseverance, curiosity, kindness, courage, creativity, honesty, gratitude, fairness, leadership, social intelligence, hope, spirituality, self-regulation, love of learning, perspective, teamwork, bravery, forgiveness, prudence.

They exist so that praise can be specific. The companion works an observed strength into an affirmation naturally, and never reads the list out.

### 5.6 Coping and capacity

| What it reads | Values |
|---|---|
| Coping style | Humor, isolation, support seeking, problem solving, avoidance, rationalization, self-compassion |
| Stress response | Short free text |
| Narrative self-concept | Caretaker, fighter, perfectionist, survivor, people pleaser, helper, achiever, seeker, provider, outsider |
| Emotional regulation style | Suppression, expression, rumination, reappraisal, avoidance |
| Window of tolerance | Narrow, moderate, wide |
| Hope level | Low, medium, high |
| Social isolation risk | Low, medium, high |
| Dependency risk | Low, medium, high |
| Disclosure stage | Reserved, cautious, opening, open |
| Circadian pattern | Morning, evening, irregular. Recorded only when stated plainly. |
| Seasonal pattern | Short free text |

Each read reaches the companion as one standing instruction. Coping through humor lets it stay light on a heavy topic. Isolation asks it to name the loneliness softly. Avoidance asks it to open a door and wait. A caretaker story often means the person neglects themselves. A perfectionist story asks for lower stakes. A fighter story asks the companion to honour the resilience and watch for burnout. A narrow window keeps the session lighter. Low hope bans projected optimism. Elevated isolation or dependency asks the companion to celebrate any mention of other people and never to become the person's only outlet. Suppression means feelings get intellectualised, so the companion gently names what the person skirts. Rumination asks it to ground the spiral.

One hard rule sits over the whole psychological layer: the profile is a map, not a script. If the live conversation contradicts the profile, the companion trusts the conversation.

Across the entire psychological layer, four reads drive a deterministic rule: attachment style, neuroticism, openness, and the dominant social need. The rest reach the model as guidance.

### 5.7 How confidence moves

The update rule runs only when the incoming value matches the stored value.

```
posterior = prior + 0.5 × evidence_confidence × (target − prior)
```

The learning rate is 0.5 and the result is clamped between 0 and 1. Each new piece of evidence closes part of the remaining distance to certainty, so a fact rises quickly at first and then slowly. Five steady mentions carry a starting guess of 0.30 past the confirmed line.

Four cases exist.

| Case | Effect |
|---|---|
| No live fact for the attribute | Insert. Confidence equals the extraction confidence. |
| Same value again | Reinforce by the rule above. |
| A different value | Close the old fact with an end date. Open a new one at the extraction confidence. |
| Demographic inference | Confidence capped at 0.30. |

Confidence then decides use.

| Confidence | Use |
|---|---|
| 0.80 and above | Treated as known. Enters the prompt as a fact the companion already has. Never re-asked. |
| 0.60 to 0.80 | Solid. Counts toward knowing the person well enough to stop generic discovery. |
| 0.20 to 0.60 | A hypothesis. Becomes something to test as light curiosity, never a statement. |
| Below 0.20 | Out of play. Reaches no part of the conversation. |

### 5.8 Attribute canonicalisation

An extractor invents wording variants of the same concept. Three tiers fold a new name into an existing one.

1. **Exact match** after normalisation. Lower case, and spaces and hyphens become underscores.
2. **Core-token match.** The name is split, plurals are trimmed, and filler and generic descriptor tokens are dropped. Two names with the same remaining core are the same concept. The tier is deliberately conservative, so two names that differ by a meaningful token stay apart.
3. **Embedding similarity** at cosine 0.85 or above. This tier runs in the background loop only, and only when an embedder is available. A missing or failing embedder leaves the first two tiers standing alone.

Without this guard, live data produced separate facts for the same thing under several names.

### 5.9 Lifespan

A daily pass keeps the profile a current picture rather than accumulated sediment.

- A fact whose last update is more than 30 days old loses confidence by a factor of 0.98 per pass, down to a floor of 0.05. Nothing is deleted. The pass never touches the update timestamp, so decay cannot reset its own clock.
- A dated event more than 14 days past its date stops surfacing.
- An active barrier with no new evidence for 45 days becomes dormant.

---

## 6. Barriers

A barrier is what stops this person, in their words. Barriers are the most operational part of the profile, because they select the technique. Nothing else in the profile does that job.

Each barrier holds a description, the quote behind it, a confidence, a status, the date it was last evidenced, and one label from the COM-B model. COM-B explains behaviour as capability, opportunity, and motivation. The six sources are a closed set, enforced as a fixed type so the extractor cannot return anything else.

| COM-B source | What it means |
|---|---|
| Physical capability | Their body cannot do it yet |
| Psychological capability | They do not know how, or cannot hold it in mind |
| Physical opportunity | Time, money, or the environment blocks it |
| Social opportunity | The people around them block it |
| Reflective motivation | They have considered it and are not persuaded |
| Automatic motivation | Habit and impulse pull the other way |

The label matters because it decides the answer. A fear needs a different response from a forgotten dose.

### Lifecycle

| Event | Rule | Result |
|---|---|---|
| New extraction | Token overlap below 0.5 against every active and dormant barrier | Insert as active |
| Re-mention | Token overlap at or above 0.5 | Refresh the evidence date. Revive a dormant barrier. No duplicate row. |
| Daily pass | No new evidence for 45 days | Becomes dormant and stops selecting techniques |
| The person pushes back | Token overlap at or above 0.4 against the correction | Retired |

The token comparison drops words shorter than three characters and a stopword list. The list also drops two words too common in this domain to separate two barriers.

### What an active barrier drives

- It selects the approach. The barrier text is matched against the strategy shelf, and at most two approaches reach the companion.
- It unlocks plan making. One real barrier proves the system knows the person's situation, so a plan will be specific rather than a template.
- It answers what is blocking progress in the journey plan.

---

## 7. Motivators

A motivator is what genuinely moves or delights the person. It is stored as a psychological need plus the specific delight, because the need alone is too abstract to use and the delight alone does not explain why it lands.

The needs come from self-determination theory: autonomy, competence, and relatedness.

Each motivator holds a category string, an optional description, and a confidence. Deduplication is exact on the lower-cased category. A motivator has no status column, no decay pass, and no correction path. Once written, it stands.

### What a motivator drives

- It unlocks plan making, in the same way a barrier does.
- It answers why the change matters to this person in the journey plan, and steers what the next session leads with.

The design pairs a barrier with a motivator to select a technique. That pairing is not in the selection code. Today the barrier selects alone, and a motivator never changes the current reply.

---

## 8. Stages of change

The stage answers one question: how ready is this person now. It comes from the transtheoretical model, and it is the difference between a plan that lands and a plan that creates resistance.

The reflection loop reads the stage from the conversation and records a row only when the reading changes. The history is therefore a list of real transitions, each keeping the stage it came from. The stage can move backwards, and a slip is treated as its own state with its own response.

| Stage | How the companion carries itself |
|---|---|
| Precontemplation | Do not push toward anything. As far as the person is concerned there is no problem, so information, warnings, and suggestions all read as pressure. Expect this stage to last a long time. |
| Contemplation | They want it and do not want it. Help them hear both sides in their own words. Never argue for change, because taking that side hands them the other one. No plan here. |
| Preparation | The decision is roughly made, so the work is the method, made small. Guard against their own ambition, because people here over-commit. |
| Action | Name what is working, specifically. Treat obstacles as logistics rather than character. Do not raise the bar the moment something works. |
| Maintenance | Keep the identity alive and defuse the occasional slip before it happens. Boredom is the real risk, so keep the relationship interesting beyond the goal. |
| Relapse | A lapse is a data point, not a verdict. The hours after one are when people disappear. No disappointment in the tone. The step back is the smallest one, and it happens tonight rather than next week. |

### What the stage drives

- Precontemplation caps the directiveness ceiling at low, whatever the trust score says.
- Contemplation, or no stage reading at all, caps the ceiling at medium.
- The stage selects which of the six postures above enters the prompt.
- Once trust passes 0.4, the stage sets the top agenda item. Contemplation aims at surfacing a value. Preparation aims at shaping one concrete step. Action and maintenance aim at reinforcing what works.
- Preparation or beyond marks the goal as committed, which advances the journey phase.

The stage string is free text from the model and is not restricted to the six names. Every rule compares it against a fixed list, so an unrecognised reading switches the stage logic off rather than raising an error.

---

## 9. Goals, plans, and habits

### The goal

The goal starts as the sign-up reason, in the person's words. The system holds it as context, not as a topic. The companion waits for the person to open that door, and the prompt says so explicitly.

A goal is marked committed only when an active plan exists, or the stage reaches preparation or beyond. Filling in a form commits nothing.

A goal node holds a level, a statement, and a status. The plan writer creates one at the program level when a plan needs a parent, and reuses an existing node when the statement matches. The control-theory fields on the node are designed and unused.

### The habit

A habit is stored as an if-then plan: one cue and one tiny action, in the implementation-intention form. The action is deliberately shrunk to the point where it is almost too small to fail.

Each plan holds three structured parts.

- **The mental-contrasting fields.** Wish, outcome, obstacle.
- **The cue.** A type of event or time, a trigger phrase, and an optional date. Event cues are preferred, because an event travels with a changing schedule and a clock time does not.
- **The response.** One action.

Commitment is earned, not extracted.

- A plan requires a non-empty action. The cue phrase may be empty, because a person can commit without naming a formal trigger.
- A plan becomes active only when the extractor marks it confirmed and the uptake quote verifiably comes from the person's own words. Everything else lands as proposed.
- Deduplication is fuzzy: token overlap at or above 0.6 on the joined cue and action. Re-worded versions of one commitment fold together instead of accumulating.
- Later genuine uptake promotes the same proposed plan to active. It does not write a second plan.
- Push-back retires a plan.
- Every downstream reader filters for active, so a proposed plan changes nothing.

An active plan unlocks the check-in move at a high ceiling, adds a light check to the agenda, and becomes a candidate for a proactive message when its cue comes due.

### The confirmed-action record

The design includes a record that the person actually did the thing, which is the reward the learning loop needs. That record has no writer today. The consequence appears in section 21.

---

## 10. Dated events and open threads

Two kinds of item share one dated store.

**A real dated event** is something in the person's life with a calendar date, extracted from their own words with a salience score from 0 to 1. Salience scales how long the event stays referenceable.

Two windows open around each event.

```
anticipation window = round(1 + 4 × salience) days before the date
follow-up window    = round(3 + 11 × salience) days after the date
score               = salience × recency
```

Inside the anticipation window the companion may acknowledge the coming event. Inside the follow-up window it may ask how it went, and sooner scores higher. Outside both windows the event is suppressed, because a warm callback two weeks late is worse than none. An event already followed up never reopens.

**An internal thread** is stored in the same place but its date is an expiry rather than a real-world date. Three kinds exist: an unresolved thread from the last session, a return hook written at session close, and a safety check-in. A thread gets pick-the-thread-back-up wording rather than upcoming or how-did-it-go wording, and threads are excluded from proactive messages entirely. Nudging on a thread once leaked internal agenda prose to a live person.

An unresolved thread is written only when its salience reaches 0.45, is classified as emotional, situational, social, or goal, and expires seven days out. A near-duplicate of an open thread is skipped at token overlap 0.45.

---

## 11. Profile integrity

Four mechanisms keep the profile honest. All four exist because of failures observed in live conversation.

### The provenance gate

Every candidate belief, barrier, event, and correction must carry a quote, and the quote must appear in something the person wrote in that window. The check is a normalised substring match, then a token-containment fallback at 0.70, because models trim and lightly reword quotes. Anything that fails is dropped outright, since a profile row without provenance is contamination rather than signal. The gate is pure code and unit-tested.

### The extraction critic

A second, cheaper model call reads the numbered candidates and names only the problems. It never re-extracts and never rewrites.

It rejects a candidate in five cases.

- It came from the companion's own words, suggestions, plans, or check-in intentions.
- The person was being hypothetical, sarcastic, joking, or quoting someone else.
- It describes someone other than the person.
- It duplicates another candidate or something already known.
- For a plan, the person never actually took it up. A maybe, a shrug, or a change of subject is not a plan.

It downgrades a candidate that is plausibly real but over-claimed: a one-off remark stored as a stable trait, high confidence on thin evidence, or a salience that does not match how much the thing seemed to matter. A downgrade halves the confidence and the salience, and clears the confirmed flag on a plan, so the plan can only land as proposed.

The critic is best-effort. No candidates, no critic on the provider, or a critic error all leave the extraction unchanged. A background quality step never blocks consolidation.

### Corrections

When the person pushes back on something the companion asserted, the matching rows stop driving behaviour. A correction holds a kind, a short target, and the person's correcting words, and it passes the same provenance gate.

Beliefs are superseded with an end date rather than deleted. Events stop surfacing. Barriers and plans retire. Matching is loose, at token overlap 0.4 against the short target. The blast radius is one person's rows, every change is recoverable, and a missed match only means the row waits for natural decay.

### The watermark

Consolidation processes only messages newer than a stored marker, and the marker advances to the last message the window actually read. The extraction also receives the current beliefs and active barriers, so it merges rather than re-extracting. Without both, repeated consolidation multiplies the counts. The whole consolidation is one transaction, so a failure rolls back without advancing the marker and the next run reads the same window again.

---

## 12. The conversational turn, end to end

Each step can override the ones after it.

### 12.1 Safety

A crisis screen reads the message before anything else and overrides the reply completely. It is tuned for recall. It accepts false alarms, because a missed crisis is not acceptable.

It matches five families of pattern.

- Direct statements about ending their life or hurting themselves.
- Quiet hopelessness, in generalised-scope phrasing only, so a narrow complaint does not fire.
- Escape and overdose language, including crushing tablets.
- Threats toward other people.
- For a person under 18, also risky substance use and self-harm-adjacent disclosure.

The quiet-hopelessness patterns were added after a live case where two sessions of such language triggered nothing.

When the screen fires, the agenda, the move, and the technique all stop. The reply is a supportive message that names a crisis line and stays present. It is never split into several bubbles. A person under 18 is routed to a parent, guardian, or other trusted adult, and to a doctor, and never receives a permissive answer about their own body. The next session opens with a gentle check-in rather than resetting to small talk.

This screen matches words and phrases and has a seam for a model check. It needs clinical review before production use.

### 12.2 Emotional state

One classifier reads three values on every message: valence from −1 to 1, arousal from −1 to 1, and a detector confidence from 0 to 1.

The third value stops the system inventing a mood. A short, factual, or terse message scores low, so a correction stays a correction rather than becoming distress. The prompt states this directly and carries calibration cases.

Distress has two forms. A point read is this message, clearly negative and activated, with detector confidence at 0.35 or above. A trajectory is a session valence trend at or below −0.25, which catches a quiet multi-turn slide that any single-message read misses. The trend needs at least three readings. Either form forces the be-present move and drops the ceiling to none.

Every reading is written to the affect log against the message, so the trend can be computed live and reviewed later.

### 12.3 Change talk

A second classifier reads the message for movement toward or away from change, in motivational-interviewing terms. Both classifiers receive recent turns, so they classify a reply rather than a fragment.

| Read | Values |
|---|---|
| Direction | Change, sustain, or neutral. Sustain includes deflecting away from the topic. |
| Preparatory subtype | Desire, ability, reason, need |
| Mobilising subtype | Commitment, activation, taking steps |
| Strength | 0 to 1 |
| Opened a door | True only when the person volunteers something meaningful and personal, or asks for help directly. A hobby or an opinion is not a door. |
| Farewell | Whether the person is finished with the conversation. Judged over context, never by keyword. |

The prompt states that most ordinary messages are neutral with no door opened, and instructs against over-detection.

### 12.4 The context snapshot

One read builds everything the turn needs: the trust level, the current stage, every live belief at 0.20 confidence or above, the active plan identifiers, and the agenda.

### 12.5 Cross-session recall

The verbatim window covers recent turns and the running recap covers this session, but a returning person references things from weeks ago. A deterministic search scores the person's older messages against the current message by token overlap with a mild recency boost.

The caps are strict. The current message needs at least two meaningful tokens before a search runs. A snippet needs at least two shared meaningful tokens to qualify. At most three snippets reach the companion, drawn from the newest 600 older messages, and the current session is excluded. The prompt presents them as optional context recalled by search and tells the companion never to force a callback.

### 12.6 Trust and the directiveness ceiling

Trust is one number per person from 0 to 1, capped at 0.9. It is earned from behaviour rather than granted, and it decides how much the companion may push.

| Signal | Change |
|---|---|
| A rapport moment: the move was affirm, be present, or follow up an event | +0.05 |
| The person opened a door | +0.03 |
| A new session starts within 7 days of the last conversation | +0.03 |
| The first reply to a proactive opener runs to at least 60 characters | +0.02 |
| Message length against the person's own baseline from other sessions | up to ±0.02, tanh-squashed on the log ratio |
| Three or more consecutive sustain turns, with no positive change this turn | −0.02 |

Trust, current affect, and the stage set the ceiling, which is computed before the move is chosen and caps whatever the move wanted to do.

| Condition | Ceiling | Meaning |
|---|---|---|
| Distress detected | None | Be present. No agenda, no question, nothing else. |
| Trust below 0.2, or precontemplation | Low | Reflect and affirm only. No question, even on an open door. |
| Trust below 0.5, or contemplation or no stage | Medium | One gentle open question is allowed. |
| Trust 0.5 and above | High | May suggest a step, or check an existing one. |

One profile rule modifies the result. Avoidant attachment, or neuroticism at 0.60 or above, lowers the ceiling exactly one level. High becomes medium. Medium becomes low. The companion is mechanically gentler with that person, whatever the plan wanted.

### 12.7 The session agenda

The agenda is a short, private, ranked list of intents for this conversation. The person never sees it and is never forced through it. It exists so that a stalled conversation has something real to reach for.

It is built deterministically from the profile with no extra model call. Ranking runs by priority.

- **Priority 0.** The journey planner's objective for this session, when one exists. Also the stage-matched intent once trust reaches 0.4: tip the balance at contemplation, shape a step at preparation, reinforce at action or maintenance.
- **Priority 1.** In companion or private mode, be good company and nothing else. In change mode without enough profile, learn one concrete thing before any plan. Otherwise the sign-up reason as the long arc, and a discovery item when fewer than two confirmed facts exist.
- **Priority 2.** A probe about their profession. A light check on an active plan.
- **Priority 3.** Up to two hypothesis tests drawn from facts between 0.20 and 0.60 confidence, phrased as light curiosity rather than statements.
- **Priority 5.** A warm catch-up, so the agenda is never empty.

The system tracks which item types it already tried this session and moves to the next untried one. When the person leads, by opening a door or expressing change talk, the agenda is suspended and the companion follows them.

### 12.8 Move selection

Code selects exactly one move per turn from twelve options. The order of the checks is the priority. The model never chooses the move.

| Move | Trigger |
|---|---|
| Be present | Distress, point or trajectory. Overrides everything below. |
| Sign off | The farewell read is true. |
| Affirm | Mobilising change talk of the taking-steps kind, or commitment when a plan is already active. |
| Forge a plan | Commitment or activation, no active plan, ceiling at medium or high, and the profile holds enough to be specific. |
| Open question | The same conditions with an insufficient profile. Also a door opened at medium or high ceiling. |
| Follow up an event | Session start with a dated item inside its window. |
| Evoke | A sustain streak of 2 or more, on every third resistant turn, with the ceiling above none. |
| Roll with resistance | Any other sustain turn. |
| Reflect | Preparatory change talk. Also a door opened at a low ceiling. |
| Check the action | An active plan and a high ceiling. |
| Advance the agenda | A neutral streak at the stall threshold, or five consecutive lateral turns. Both need four prior user turns and a ceiling above none. |
| Just respond | The default, and the most common outcome. No technique. |

Two guards sit over the table.

**An opened door is followed at any ceiling above none.** Following a door the person held open is warmth, not the righting reflex. At medium or above the companion may ask. At low it deepens what they shared with a reflection and no question.

**The patience budget.** A run of five purely lateral turns triggers a forward move even when nothing has stalled. Warm chat that never moves is passivity rather than patience, and it was the dominant failure in live testing. The same pacing floor and ceiling guards apply. A reply that is empty or filler does not count as forward motion.

### 12.9 Prompt assembly

The system prompt is assembled from templates and split at a caching boundary. All prompt prose lives in markdown templates. Code only assembles them with live context.

The stable half leads and carries the cache breakpoint: the base persona, the companion character, and the domain playbook. These are identical across turns and shared across every person in the same domain.

The volatile half follows, and contains everything that varies per turn.

- How much of the companion's own character to show, in three depths. Listener-first on the first conversation. More personality on the second. Fully itself from the third, once the rapport phase is behind them.
- The selected move's guidance, from its own template.
- The tone line for the ceiling.
- The strategy shelf, but only for the three plan-shaped moves.
- The stage posture.
- The journey phase instruction. During rapport this states plainly that the companion must not steer toward any goal.
- A gather-before-plan instruction when the person asks for a plan too early.
- The how-to-relate lines derived from attachment style, the two Big Five reads, and the social need.
- An anti-interrogation rule. After two consecutive questions the next turn may not ask one. After one, the prompt leans against asking.
- The live register-mirroring brief.
- The running recap of this session.
- Recalled snippets from older sessions.
- The known-facts line, with an explicit exception: the reason they came is context the companion holds, never a topic it raises.
- The opener instruction, or the agenda intent, depending on the move.
- The standing session aim: one owed gentle attempt at forward motion sometime this session, subordinate to warmth and to the person's own thread.
- The person's local time.
- A lead-with-warmth line when valence is low.

Every prompt family carries contrast-pair examples, with an explicit rule against copying their phrasing.

### 12.10 Generation and quality checks

The model generates the reply, then the engine checks it and regenerates once when a check fails.

- **Self-repetition.** The reply's content-word set is compared against the last three companion turns. Overlap at 0.55 or above flags a reworded repeat.
- **Same opening.** The first two words repeating a recent turn flags.
- **Consecutive questions.** Two question-ending turns in a row flags.

Blank lines are collapsed inside a bubble so replies read like messages rather than a short line followed by a paragraph.

### 12.11 Reply shaping

One model turn renders as a few sequential message bubbles, split on the blank-line beats the model itself produced, capped at four with the overflow folded in. One turn stays one stored message, with the joined text as the system of record and the split kept alongside it so the interface can re-render bubbles on reload without changing turn semantics. A crisis reply is never split.

### 12.12 Concurrency

The composer never blocks. If the person sends another message while a reply is in flight, the client aborts the stale request and resends the full ordered list under the same turn key. The companion answers them together, and they are stored as separate messages and separate bubbles.

Server-side, an advisory transaction lock on the session and turn key serialises concurrent submissions of the same turn. A longer resend supersedes the shorter in-flight one. A duplicate submission replays the stored reply. History is read before the new messages are persisted, so the engine sees only prior turns.

### 12.13 What the turn writes

- One message row per user message, and one for the reply.
- The signals on the user row: the change-talk read, the affect read, the move, and any of the flags for a reported action, a possible lapse, a rapport moment, a session end, and forward motion.
- The signals on the reply row: the move, the crisis flag, and the bubble split.
- One affect log row.
- One turn trace: the verbatim system prompt, the exact history sent, the user text, the reply, and the full decision block.
- One intervention row for the move, with its context features and a logged propensity.
- The updated trust level and conversation counters.

---

## 13. Session lifecycle

**The companion opens every session, not only the first.** It reaches out rather than waiting to be greeted. The opener is stored as the first turn of the session, so the companion sees its own opening in context and does not re-ask what it just asked.

The opener prompt is built with hard constraints. Keep it light and low-stakes. Open on something specific the companion genuinely knows, so the message reads as meant for this person. Never state a guess as a fact, and never use phrasing that implies a hunch is already part of their life. Never invent a life event. On a first message, never raise the goal, health, or the reason they signed up. Do not reuse the greeting, hook, or phrasing of the last three openers. Acknowledge a gap naturally without making it a thing or inducing guilt. One or two lines, ending with a gentle opening rather than several questions.

Any topic read as a dislike or a do-not-ask becomes a hard constraint on the opener.

**A session ends two ways.** The model judges a farewell, which sets the sign-off move and closes the session. Or the session goes cold after 30 minutes of silence, which is the normal ending, because most people close the application rather than saying goodbye. Staleness is evaluated on the request path, so returning closes a cold prior session, and a scheduled sweep is only a backstop.

**Closing does three things.** It stamps the end, writes a return hook so the next opener can pick the thread up, and publishes a state change so the interface resets to start the next session rather than appending the next opener to a dead thread. A return hook is written only for agenda types with a clean topic map, never from intent prose.

**Before any new opener is composed,** consolidation and journey planning run synchronously if the ended session holds unprocessed messages. This exists because a short session that ended by timeout once left the profile empty, and the next opener re-asked the person's profession.

An ended session cannot be resumed. The next message starts a new one.

---

## 14. Memory of the conversation

Three layers, each covering what the layer above drops.

**The live window.** The last twenty turns go to the model verbatim.

**The running recap.** Once a session passes the window plus four messages, a background task folds the scrolled-out turns into a recap held on the session and fed back through the prompt. The recap is recomputed from the full older set each refresh rather than carried forward, to avoid double counting.

**Search over old sessions.** Described in section 12.5.

Episodic writes to the temporal graph happen at consolidation and are best-effort.

---

## 15. The journey meta-planner

The journey is the multi-session plan from the sign-up reason to a sustained behaviour. It runs at session end, reads the freshly consolidated profile, and authors the aim for the next session.

### Phase rails

Four phases, computed deterministically and counted in sessions rather than days.

| Phase | Rule | Purpose |
|---|---|---|
| Rapport | The first two sessions | Be someone worth talking to. No steering. A plan would land too early. |
| Discover | No stage read, or no committed goal | Find what is actually in the way. Fill the profile gaps. |
| Progress | A stage and a committed goal | Work on one small thing the person chose. |
| Maintain | Stage is maintenance | Keep it steady. Lighter, still present. |

A person in change mode who stated a reason skips the rapport floor, so a goal-sooner person can talk about why they came from the first session. Plan forging is gated separately on profile richness, so skipping rapport does not produce a generic plan.

### Engagement mode

Four values: unknown, change, companion, private. A mode chosen at onboarding is pinned and never overwritten. Otherwise it is inferred from session count, whether a goal is committed, and how many facts exist, and a known mode is never reset to unknown.

Companion and private mode suppress goal probing entirely. The agenda's job becomes being worth talking to.

### The journey document

The stored plan has four parts.

1. **The goal.** The real problem behind the stated one, what life looks like when it is solved, and why it matters, rooted in the person's motivators.
2. **The journey.** Three to five milestones, each with a title, an observable success criterion, a timeline, dependencies, a completion flag, and a progress percentage. Plus an estimated duration.
3. **Current status.** The current milestone, overall progress, what is working, what is blocking, a motivation level, and a dropout risk.
4. **Deviation analysis.** Whether the person is on track, what deviated, the timeline impact, and recovery actions.

A full rewrite runs when the profile grows by five new facts, which is the point at which the whole plan is worth rethinking. Otherwise a deterministic status-only update runs every two sessions and touches parts three and four alone. The goal and the milestones stay stable between rewrites.

The current milestone becomes a synthetic week, from which one session objective is authored. That objective becomes the top agenda item for the next session. The last twelve objectives are kept, and the three most recent are shown to the author so it does not repeat itself.

The planner also records profile gaps: a missing stage, and any of communication style, Big Five, or attachment style that the profile still lacks.

Every part of the planner has a deterministic fallback, so an unavailable model produces a skeleton plan rather than nothing.

---

## 16. Techniques

Three layers. Code picks the technique. The model picks the words.

### Layer one: the move

Twelve moves, described in section 12.8. Each carries its own guidance template, which states the craft and the failure mode it avoids.

### Layer two: the strategy shelf

Ten approaches, each keyed to a kind of barrier. Each holds an identifier, match keywords, a named mechanism, the taxonomy codes it operationalises, and guidance.

Selection is deterministic. The active barrier descriptions are lower-cased and joined, each approach is scored by how many of its keywords appear, and at most two approaches survive. The shelf reaches the prompt only on the three plan-shaped moves: forge a plan, evoke, and check the action. Everywhere else it would pull the conversation toward intervention when the move says be a friend.

The prompt presents the shelf as raw material. The companion may use at most one, only if the moment genuinely calls for it, and must reshape it in the person's own language. It may never recite, never list options, and never stack two.

| Barrier kind | Mechanism |
|---|---|
| Side effects | Problem solving, then routing to the prescriber |
| Forgetting | Habit stacking and implementation intentions |
| Feeling fine | Motivational evocation through the person's own values |
| Cost | Barrier removal in physical opportunity |
| Fear of a low | Acknowledging the fear, then clinician routing |
| Food and culture | Substitution and addition rather than restriction |
| Monitoring burnout | Dose reduction and self-compassion |
| Sedentary | A tiny anchored habit with an immediate feedback loop |
| Changing schedule | Event-anchored rather than clock-anchored intentions |
| Low mood | Behavioural activation, kept micro |

### Layer three: the technique library

Seventeen techniques from the Michie behaviour change taxonomy, each written up for this condition rather than left as a textbook definition, and each naming the COM-B deficits it addresses so selection is traceable.

| Cluster | Techniques |
|---|---|
| Goals and planning | Goal setting for behaviour, problem solving, action planning |
| Feedback and monitoring | Self-monitoring of behaviour, self-monitoring of outcome |
| Social support | Social support |
| Natural consequences | Information about health consequences, information about emotional consequences |
| Associations | Prompts and cues |
| Repetition and substitution | Behaviour substitution, habit formation, graded tasks |
| Comparison of outcomes | Credible source |
| Reward and threat | Social reward |
| Regulation | Reduce negative emotions |
| Antecedents | Restructuring the physical environment |
| Self-belief | Verbal persuasion about capability |

The write-up carries the guard rails the taxonomy does not.

- **Fear framing is banned.** Complications presented as a threat produce avoidance and dropout, and a person who feels fine doubles down. Consequences may only be gain-framed, and only through a door the person opened.
- **Goals are behaviours, never laboratory numbers.** The behaviour belongs to the person. The blood test belongs to their clinician.
- **The companion is never the medical authority.** Side effects, dosing, lows, and symptoms route to the prescriber or educator, framed so that asking feels like agency rather than failure.
- **Praise names the act.** No grades, no surprise that the person managed it, and no raising the bar in the same breath.
- **Empty encouragement is banned.** A capability reflection must point at something the person actually did.
- **Physical cues beat reminders.** Objects invite. Alarms nag.
- **For a shift worker, anchor to events, never clock times.**

The technique data lives in code, not in the database. The library table has no seeder and no reader. A plan does not record which technique produced it.

---

## 17. Domains

Everything condition-specific is data in one folder per domain: the playbook prose, the technique working set, and the strategy shelf. Adding a condition means adding a folder and registering it, not branching the engine.

A domain is selected per person by keyword match against the sign-up reason, or pinned for a whole deployment by configuration. No match means the general-purpose companion with no playbook and no shelf.

The playbook is appended to the stable half of the system prompt. It carries deep per-condition guidance: knowledge, language rules, and hard medical boundaries. Detection is code. The playbook is not a licence to steer the conversation toward health, because journey-phase pacing still rules.

---

## 18. Prompt architecture

All prompt prose lives in markdown templates and is loaded by name. Code assembles templates with live context and never inlines a large prompt string. Domain playbooks are the one exception, and they live with their domain so a condition is one folder.

The template families are the base persona, the companion character, the domain playbooks, one file per move, one file per stage posture, the nudge persona, the classifier prompts, the consolidation prompt, the critic prompt, the cold-start prompt, and the journey prompts.

Two persona rules are worth naming. The persona forbids foul language, and this is deliberately prompt-level only, with no word list or scrubber in the code. The persona invites multiple bubbles only for genuinely distinct beats, never to pad a reply.

---

## 19. Proactivity and nudges

A nudge is a message sent while the person is away.

### Candidates

Two kinds. A plan cue that is due, and an approaching dated event. A time cue is due on its date. An event cue is eligible daily, and the caller filters out any plan nudged in the last day, which makes it a gentle once-a-day reminder. Internal threads are excluded from candidates entirely.

### Gates

Deterministic gates hard-veto before any selection happens.

- Quiet hours in the person's local time.
- Distress on the last reading.
- At most two nudges a day.
- At most two unanswered nudges since the person's last conversation. Past that the system goes quiet until they return.
- Token-containment deduplication at 0.6 against every nudge sent in the last seven days.

The unanswered cap and the deduplication both come from live logs, where one person received fourteen nudges over six days, many near-identical, with no replies.

### Selection

Among the candidates that survive, a policy chooses one arm or the explicit no-op arm. Sending nothing is a first-class choice. Every decision records the probability with which it was chosen, including the probability of silence. That number cannot be reconstructed later, and without it off-policy evaluation is impossible.

### Delivery

Delivery is a protocol with a factory. A live channel pushes to an open tab over a server-sent-event stream bridged by Redis, which is the first real delivery path. Otherwise a logging channel records the message. There is no external delivery dependency. An out-of-application channel such as push or short message is designed and not built.

---

## 20. The learning loop and off-policy evaluation

### The decision log

Every intervention is logged at decision time with its context features, whether it was a no-op, the propensity, and the policy version. In-conversation moves are logged the same way, with a deterministic policy version and the just-respond move as the no-technique arm.

### The reward

A composite, because a binary confirmed-action signal was too sparse for a system whose best move is usually silence.

| Reward | Condition |
|---|---|
| 1.0 | A confirmed action inside the reward window, preferring one matching the plan the nudge was about |
| 0.3 | No action, but the person returned and talked within 48 hours |
| 0.0 | Neither |

The default reward window is seven days. Shaping is safe to iterate on because promotion is gated.

Because the confirmed-action record has no writer today, the top reward is unreachable. The loop currently learns from the return signal alone.

### Refit and the gate

The policy is a contextual bandit over the same arms, with the arm kind as a feature. Vowpal Wabbit is the default in the container image, with an epsilon-greedy heuristic policy as the fallback. Both log a real propensity.

A refit trains a candidate rather than replacing the live model. The candidate is scored against the logged baseline using clipped inverse-propensity and self-normalised estimates, with an effective-sample-size guard. Promotion requires the self-normalised estimate to clear the logged baseline by a margin, with at least fifty samples and an effective sample size of at least fifteen. The importance weight is clipped at ten to control variance.

Every verdict, promoted or held, is written to an audit table with the estimates that justified it. Promotion without that row does not happen. The serving model lives in versioned files behind a pointer, and the selection path hot-reloads when the pointer moves.

Learning here decides when to speak and when to stay quiet. Technique selection still comes from the person's barriers.

---

## 21. What every call records

Two trace tables exist so that every model call becomes a training record.

- One row per conversation turn: the verbatim system prompt, the exact history, the person's message, the reply, and the full decision block. This is deliberately storage-heavy at roughly ten to fifteen kilobytes a turn.
- One row per auxiliary call: consolidation with the window in and the raw extraction out plus every quality verdict, openers, nudge generation, cold-start inference, and session recaps, each tagged by kind.

An export command emits labelled training data in chat format, joining outcome labels on at export time rather than storing them twice. Any new model call site is expected to add its trace.

---

## 22. Interfaces

**The person's application.** A web application with sign-in by emailed link and a signed session cookie scoped to that person. Onboarding runs cold start and the proactive opener. The main view is a chat with a collapsible behind-the-scenes panel, a session history drawer, hover-to-flag on any companion message, and live nudges over the event stream.

**The internal console.** A single page showing the chat alongside the engine's live reasoning: the move, the ceiling, the affect read, the change-talk read, the inferred profile as facts form, the stage, the plans, the events, and the nudges. It has controls to force a reflection pass and to run a nudge pass. Automatic reflection each turn is on by default here, so the profile grows visibly.

**Voice.** A speech pipeline that calls the same conversation endpoint over HTTP, so voice reuses the whole engine rather than duplicating it. It is an optional install. Prosody to affect and token streaming are designed and not built.

---

## 23. Technology, configuration, and deployment

**Application.** Python with FastAPI. Celery with Redis for background work and scheduled passes. PostgreSQL with pgvector as the system of record. Neo4j behind Graphiti for episodic memory. Schema changes are Alembic revisions.

**Models.** The provider is chosen by configuration behind one interface, so no vendor library is imported outside the provider factory. Options are Anthropic directly, Anthropic through AWS Bedrock using the instance role with no API key, OpenAI, or any OpenAI-compatible endpoint. With no usable key the engine falls back to a labelled heuristic client so the application still runs offline.

The conversation, the extraction, the cold start, and the journey use the main model. The two per-turn classifiers use a smaller, cheaper model, because they are simple, structured, latency-sensitive, and called twice every turn.

**Time.** Every time calculation uses the person's own timezone, never server time. The prompt is told the weekday, month, and day, because a live person was once told the wrong month.

**Scheduled passes.** A proactivity sweep, a nightly policy refit, a daily profile decay pass, and a stale-session sweep as a backstop.

**Deployment.** A single cloud instance behind Caddy, with the database as a managed service and Redis and Neo4j as containers. The stack runs under a system service so it starts at boot.

---

## 24. What is designed but not built

| Piece | Intent | State |
|---|---|---|
| Values and identity store | Core values and identity statements, so change becomes durable rather than rule-following | Empty. Values reach the companion only as ordinary profile facts. |
| The confirmed-action record | Proof the person acted, which is the reward the learning loop needs | Empty. The loop learns from the return signal alone, so the top reward is unreachable. |
| Lapse and recovery record | Each slip and how fast the person recovered | Empty. A possible lapse is flagged on the message and goes no further. |
| Barrier paired with motivator | Select the technique from both what stops them and what moves them | The barrier selects alone. A motivator never changes the current reply. |
| Technique provenance on a plan | Record which technique produced each plan, so content is auditable | Not recorded. |
| Goal control fields | Discrepancy and velocity per goal, for control-theory style tracking | Unused. |
| The psychological layer as machinery | Every read drives a rule | Four reads drive a rule. The rest are standing guidance for the model. |
| The safety screen | A clinically reviewed detector with a model check behind the patterns | Pattern matching only, tuned for recall. Review outstanding. |
| Out-of-application delivery | Push or short message | Not built. The seam exists. |
| Voice prosody to affect | Emotional reads from how the person sounds | Not built. |

---

## 25. Case study

The following traces one person through every part of the system in order. It is a composite illustration, not a real patient.

### Sign-up

A 58-year-old delivery driver types one line into the goal box: he has just found out his blood sugars are high and he is on the road all day.

That sentence does two jobs. Keyword matching selects the type 2 diabetes domain, so the playbook and the ten-approach shelf are available from his first turn. The sentence also becomes the first item on his first agenda, held as the long arc rather than a topic to raise.

He adds his name, his age, his city, his job, and his pace. He picks go slow and get to know me first, which pins his engagement mode to companion.

### Cold start

Before he has said anything, one model call writes three tentative reads: that his days are probably long and irregular, that he probably wants things put plainly, and one plausible interest worth asking about. Each is capped at 0.30 and marked as demographic inference. His health, his weight, and how well he is coping are all off limits at this stage, because a guess there would be a stereotype with a number attached.

Two of the three go onto his agenda as hypotheses to test. At 0.30 they are too weak to build on.

### Sessions one and two

The journey planner puts him in the rapport phase, which the first two sessions always are. The phase instruction in his prompt states plainly that the companion must not steer toward any goal. His trust starts at zero, and with no stage reading yet his ceiling sits at low, so the companion may reflect and affirm but may not ask a question even if he opens a door. His pace choice holds the agenda off steering for the first four turns. The companion shows the least of its own character on the first conversation and slightly more on the second.

The companion opens both sessions itself, lightly, hooked on something it actually knows.

He mentions being in the cab by half past five and home whenever. Later he complains about a route that overran. Reflection extracts both as evidence for the irregular-days read, and the confidence climbs from 0.30 to 0.48 to 0.61. Each mention moves it less than the one before.

The plain-speaking read goes the other way. He asks what his actual number was and what the target should be. That contradicts the read, so the old fact is closed with an end date and a new one opens in its place. The interest read is never mentioned again, and after thirty quiet days it decays below the usable line.

### Barriers and a motivator

Reflection finds two quotable barriers in his own words. One is fear of going low at the wheel, with his licence on his mind. The other is that he forgets the morning dose because he is out of the door at five.

They get different labels, and the labels are what make the difference. The fear is automatic motivation, because a feeling is in the way. The forgetting is psychological capability, because it is a memory problem. A fear and a memory lapse need different answers.

A motivator lands too, and it is his licence. That is filed as an autonomy need with the specific delight attached. It outranks anything a clinical chart would have suggested about longevity.

Both barriers pass the provenance gate, because both quotes appear in his own messages. The critic lets both stand.

### The stage moves

He was playing the diagnosis down at first, which reads as precontemplation, so the ceiling stayed at low and the companion held steady. Then he asks what he should actually be doing about the mornings, and gives his own reason: he needs to keep the licence.

A question plus a reason of his own is enough evidence to write a new stage. The row moves to contemplation and keeps the stage it came from, so the transition stays visible. His ceiling lifts off low. His trust has been climbing from returning inside a week, from longer messages against his own baseline, and from rapport moments. Once it passes 0.4 the stage sets his top agenda item, which becomes tipping the balance.

### The technique fires

On a later turn he expresses commitment. The profile now holds two real barriers and a motivator, so the profile-richness gate is satisfied and the move comes out as forge a plan. That is one of the three moves the strategy shelf reaches.

His barrier text is matched against the shelf. Two approaches survive the cap. His forgetting draws the event-anchoring approach, because a clock-based plan collapses on a day whose shape changes every morning. Alongside it comes habit stacking: after an anchor already in his day, one tiny act.

His fear takes a different route entirely. Its approach says to take him at his word and route it to the person who can change his medication, so the fear shapes the conversation rather than producing a step.

The plan that gets offered attaches the tablet to climbing into the cab, next to the thing he always has with him. Every part of that sentence is traceable: a barrier in his own words, a label saying what kind of barrier it is, the approaches that match the label, a move that permits offering something, and a ceiling that allows that much.

### The plan goes live

He says that would probably work, and gives his reason. That uptake quote comes from his own words and passes the gate, so the plan lands as active rather than proposed.

A maybe would have left it proposed, invisible to every opener and every nudge until real uptake arrived. Later uptake would have promoted the same plan rather than writing a second one. A refusal would have retired it.

### The nudge

He stays away. His plan cue comes due. The gates all pass: outside his quiet hours, no distress on his last reading, under two today, none unanswered since he last spoke, and nothing similar in the last seven days. The policy weighs sending against silence, picks send, and records how likely that choice was.

If two go unanswered, the system goes quiet and waits for him.

### What carries over

He comes back two days later. That return inside forty-eight hours scores 0.3, which joins the decision log and trains a candidate policy. The candidate replaces the live one only if it beats the logged baseline on his history and the history of everyone else.

Then he goes quiet for a month.

When he returns, the companion already knows him. His fear, his forgetting, and his licence are each written down with a confidence and a date. So is the step he agreed to, and how ready he was the last time they spoke. Because the session that went cold was drained before the new opener was composed, the opener cannot re-ask something he already answered. It picks up the return hook instead.

His seventh conversation starts far ahead of where his first one could.
