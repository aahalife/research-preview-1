import { z } from "zod";

/** A deliberately separate demo identity; never migrate legacy Sano snapshots here. */
export const PATIENT_ID = "privia-elena-52-synthetic";
export const STORAGE_KEY = "rumi.privia.elena.v1";
export const DEMO_ENABLED = import.meta.env.VITE_RUMI_DEMO_ENABLED !== "false";
export const DEMO_DATE = "2026-09-17";
const text = z.string().max(12000);
export class DemoActionError extends Error {}
const dateTime = z.string().refine(v => Number.isFinite(Date.parse(v)), "Invalid date");
export const surfaceSchema = z.enum(["lab", "guide", "support", "message", "connections", "logs"]);
export type Surface = z.infer<typeof surfaceSchema>;
export const suggestionSchema = z.object({
  kind: z.enum(["surface", "memory", "question", "message", "support"]),
  title: z.string().max(140), text: z.string().max(2000),
  surface: surfaceSchema.optional(), sourceIds: z.array(z.string()).max(12).default([]),
});
export type Suggestion = z.infer<typeof suggestionSchema>;
const turnSchema = z.object({
  id: z.string(), role: z.enum(["user", "assistant"]), text,
  channel: z.enum(["app", "sms", "call"]), at: z.string(),
  status: z.enum(["complete", "interrupted", "failed"]),
  origin: z.enum(["live-ai", "patient", "sample-channel"]),
  suggestion: suggestionSchema.optional(), dismissed: z.boolean().default(false),
});
export type Turn = z.infer<typeof turnSchema>;
export const observationSchema = z.object({
  id: z.string(), kind: z.enum(["Blood pressure", "Symptom", "Medication", "Meal", "Activity"]),
  value: z.string().min(1).max(1500), at: z.string().min(1), note: z.string().max(1500),
  source: z.enum(["Patient entry", "Sample record", "Sample SMS"]),
});
export type Observation = z.infer<typeof observationSchema>;
export const stateSchema = z.object({
  version: z.literal(1), patientId: z.literal(PATIENT_ID), revision: z.number().int(),
  stage: z.enum(["before", "after"]), aiConsent: z.boolean(),
  sources: z.object({ gmail: z.boolean(), calendar: z.boolean(), records: z.boolean() }),
  preferences: z.object({ pace: z.enum(["brief", "balanced", "detailed", "practical"]), paused: z.boolean() }),
  memories: z.array(z.object({ id: z.string(), text: z.string().max(2000), at: z.string() })),
  historyFrom: z.number().int(), turns: z.array(turnSchema), composer: text,
  contextIds: z.array(z.string()), excludedContextIds: z.array(z.string()).default([]),
  pendingQuestion: z.object({ text, channel: z.enum(["app", "sms", "call"]) }).nullable().default(null),
  memoryDraft: text.default(""), visitDraft: z.string().default(""),
  visit: z.object({ id: z.literal("elena-visit-2026-09"), at: dateTime, revision: z.number().int() }),
  orderAvailable: z.boolean(), practiceReply: z.boolean(),
  lab: z.object({ slot: z.string(), recipient: z.string(), message: text, useEmail: z.boolean(), messageApproval: z.string().nullable().default(null), approval: z.string().nullable() }),
  calendarEvents: z.array(z.object({ id: z.string(), start: z.string(), end: z.string(), title: z.literal("Personal appointment"), visitRevision: z.number() })),
  messages: z.array(z.object({ id: z.string(), recipient: z.string(), text, at: z.string(), status: z.literal("Simulated · not sent"), fingerprint: z.string() })),
  guide: z.object({ draftQuestion: z.string().max(2000).default(""), questions: z.array(z.object({ id: z.string(), text: z.string().max(2000) })), selectedLogIds: z.array(z.string()), note: text, reviewed: z.string().nullable() }),
  logs: z.array(observationSchema),
  logDraft: z.object({ kind: observationSchema.shape.kind, value: text, at: z.string(), note: text, editingId: z.string().nullable() }),
  support: z.object({ goal: text, reason: text, cue: text, barrier: text, fallback: text, paused: z.boolean(), reminder: z.string(), checkIn: z.string() }),
  channel: z.object({ sms: z.boolean(), call: z.boolean(), stopped: z.boolean(), quietStart: z.number().min(0).max(23), quietEnd: z.number().min(0).max(23), lastOutreach: z.string().nullable(), smsDraft: text, callDraft: text }),
});
export type DemoState = z.infer<typeof stateSchema>;
export type Channel = Turn["channel"];
export const nowISO = (): string => new Date().toISOString();
export const uid = (): string => crypto.randomUUID();

/** New synthetic fixture. Absence of data is preserved rather than filled from Marcus. */
export function initialState(): DemoState {
  return {
    version: 1, patientId: PATIENT_ID, revision: 0, stage: "before", aiConsent: false,
    sources: { gmail: false, calendar: false, records: false }, preferences: { pace: "balanced", paused: false },
    memories: [], historyFrom: 0, turns: [], composer: "", contextIds: [], excludedContextIds: [], pendingQuestion: null, memoryDraft: "", visitDraft: "",
    visit: { id: "elena-visit-2026-09", at: "2026-09-29T10:00:00-04:00", revision: 0 },
    orderAvailable: false, practiceReply: false,
    lab: { slot: "", recipient: "Sample primary care team", message: "", useEmail: false, messageApproval: null, approval: null }, calendarEvents: [], messages: [],
    guide: { draftQuestion: "", questions: [], selectedLogIds: [], note: "", reviewed: null },
    logs: [{ id: "elena-bp-1", kind: "Blood pressure", value: "138/84 mmHg", at: "2026-09-16T08:00", note: "", source: "Sample record" }],
    logDraft: { kind: "Blood pressure", value: "", at: "2026-09-17T08:00", note: "", editingId: null },
    support: { goal: "", reason: "", cue: "", barrier: "", fallback: "", paused: false, reminder: "", checkIn: "" },
    channel: { sms: false, call: false, stopped: false, quietStart: 20, quietEnd: 8, lastOutreach: null, smsDraft: "", callDraft: "" },
  };
}

export interface Evidence { id: string; title: string; date: string; source: "gmail" | "records"; body: string }
export function evidence(state: DemoState): Evidence[] {
  return [
    { id: "visit", title: "Upcoming primary care visit", date: state.visit.at, source: "records", body: "Elena, 52. Synthetic patient. Type 2 diabetes and high blood pressure. Primary care follow-up at Sample practice, 100 Example Lane, Demo City. No real practice or booking." },
    { id: "instructions", title: "Your pre-visit lab question", date: "2026-09-17T09:00:00-04:00", source: "gmail", body: "From: Sample practice <practice@example.invalid>\nTo: elena@example.invalid\nWe have your question about labs before your visit. An order has not yet been confirmed. Please ask the care team to confirm the required tests and any preparation. Do not change medicines or fast based on this sample email." },
    ...(state.orderAvailable ? [{ id: "order", title: "Lab order available · staged sample", date: "2026-09-18T11:00:00-04:00", source: "records" as const, body: "Demonstration stage: clinician-approved sample order for HbA1c and a basic metabolic panel. Required preparation is not supplied. Confirm preparation with the practice. This is not a real order." }, { id: "lab-email", title: "Lab location and planning details", date: "2026-09-18T11:05:00-04:00", source: "gmail" as const, body: "From: Sample lab <lab@example.invalid>\nTo: elena@example.invalid\nSample lab: 200 Example Lane, Demo City. Planning options: September 23 at 08:00, 09:30 or 11:00 Eastern. No slot is reserved. Confirm required preparation with the practice. Calendar insertion does not book a draw." }] : []),
    ...(state.practiceReply ? [{ id: "practice-response", title: "Practice response · staged sample", date: "2026-09-18T12:00:00-04:00", source: "records" as const, body: "Sample care team: Please tell the lab staff about the concern you raised before the draw. Contact the practice to discuss preparation and available support. No special arrangement has been confirmed." }] : []),
    ...(state.stage === "after" ? [{ id: "care-plan", title: "After-visit plan · staged sample", date: state.visit.at, source: "records" as const, body: "Sample visit completed for demonstration only. Bring your home blood-pressure readings and any medication questions to follow-up. A specific monitoring schedule, medication doses and new treatment instructions are not supplied. Ask the team to clarify; do not infer them." }] : []),
  ];
}
export const slots = [
  { id: "08:00", start: "2026-09-23T08:00:00-04:00", end: "2026-09-23T08:30:00-04:00", label: "8:00–8:30 am" },
  { id: "09:30", start: "2026-09-23T09:30:00-04:00", end: "2026-09-23T10:00:00-04:00", label: "9:30–10:00 am" },
  { id: "11:00", start: "2026-09-23T11:00:00-04:00", end: "2026-09-23T11:30:00-04:00", label: "11:00–11:30 am" },
];
export const busyEvents = [{ id: "busy-1", title: "Existing commitment", start: "2026-09-23T07:45:00-04:00", end: "2026-09-23T09:00:00-04:00" }];
/** Half-open intervals; adjacent appointments do not overlap. No travel-time inference. */
export function overlaps(a: { start: string; end: string }, b: { start: string; end: string }): boolean {
  return Date.parse(a.start) < Date.parse(b.end) && Date.parse(b.start) < Date.parse(a.end);
}
export function labFingerprint(s: DemoState): string {
  return JSON.stringify([s.patientId, s.visit, s.orderAvailable, s.sources, s.lab.slot, s.lab.recipient, s.lab.message, s.lab.useEmail]);
}
export function guideFingerprint(s: DemoState): string {
  return JSON.stringify([s.patientId, s.visit, s.guide.questions, s.guide.note, s.logs.filter(l => s.guide.selectedLogIds.includes(l.id))]);
}
export function labBlocker(s: DemoState): string | null {
  if (!s.sources.calendar || !s.sources.records || (s.lab.useEmail && !s.sources.gmail)) return "Reconnect the selected sample sources and review again.";
  if (!s.orderAvailable) return "The lab order is not confirmed. You can prepare a message to the practice instead.";
  const slot = slots.find(x => x.id === s.lab.slot);
  if (!slot) return "Choose a time to review.";
  if (Date.parse(slot.end) >= Date.parse(s.visit.at)) return "Choose a plan before the selected visit.";
  if (busyEvents.some(b => overlaps(slot, b))) return "This time overlaps an existing commitment.";
  if (s.calendarEvents.some(e => overlaps(slot, e))) return "A sample calendar event already occupies this time.";
  return null;
}
/** Local transaction only. Fingerprints prevent stale approval and duplicate replay. */
export function applyLab(s: DemoState): DemoState {
  const fingerprint = labFingerprint(s);
  if (s.lab.approval !== fingerprint) throw new DemoActionError("The plan changed. Review this version first.");
  const blocker = labBlocker(s); if (blocker) throw new DemoActionError(blocker);
  const slot = slots.find(x => x.id === s.lab.slot)!;
  return { ...s, revision: s.revision + 1, calendarEvents: [...s.calendarEvents, { id: uid(), start: slot.start, end: slot.end, title: "Personal appointment", visitRevision: s.visit.revision }], lab: { ...s.lab, approval: null } };
}
export function messageFingerprint(s: DemoState): string {
  return JSON.stringify([s.patientId, s.visit, s.sources, s.lab.recipient, s.lab.message, s.lab.useEmail, s.practiceReply]);
}
export function applyMessage(s: DemoState, approval: string): DemoState {
  if (approval !== messageFingerprint(s) || s.lab.messageApproval !== approval || !s.lab.message.trim() || !s.lab.recipient.trim()) throw new DemoActionError("Review the current recipient and message first.");
  if (s.lab.useEmail && !s.sources.gmail) throw new DemoActionError("The selected email source was removed.");
  if (s.messages.some(x => x.recipient === s.lab.recipient && x.text === s.lab.message)) throw new DemoActionError("This version is already saved in sample messages.");
  return { ...s, revision: s.revision + 1, messages: [...s.messages, { id: uid(), at: nowISO(), text: s.lab.message, recipient: s.lab.recipient, status: "Simulated · not sent", fingerprint: approval }], lab: { ...s.lab, messageApproval: null } };
}
export function formatVisit(at: string): string {
  return new Intl.DateTimeFormat("en-US", { month: "short", day: "numeric", hour: "numeric", minute: "2-digit", timeZone: "America/New_York" }).format(new Date(at));
}
export function quietNow(s: DemoState, hour: number): boolean {
  const { quietStart: start, quietEnd: end } = s.channel;
  return start === end || (start < end ? hour >= start && hour < end : hour >= start || hour < end);
}
export function outreachBlocker(s: DemoState, channel: "sms" | "call", now: Date): string | null {
  if (!s.channel[channel] || s.channel.stopped || s.preferences.paused) return "Outreach is off or paused.";
  const hour = Number(new Intl.DateTimeFormat("en-US", { hour: "numeric", hourCycle: "h23", timeZone: "America/New_York" }).format(now));
  if (quietNow(s, hour)) return "Quiet hours: no preview outreach now (Eastern time).";
  if (s.channel.lastOutreach && now.getTime() - Date.parse(s.channel.lastOutreach) < 86400000) return "Already invited within 24 hours. No duplicate or cross-channel escalation.";
  return null;
}
/** Deliberately allowlisted nonclinical outbound text; never echo sensitive input. */
export const channelCopy = {
  invite: "Rumi: Would you like to pick up where you left off? Open the app when it suits you. Reply STOP to stop preview outreach.",
  saved: "Your entry is recorded in the demo, not medically assessed. Open the app to review or correct it.",
  clarify: "Please use two numbers separated by a slash, and include the date and time. Nothing has been recorded yet.",
  stop: "Preview outreach is stopped. You can change this in your preferences.",
  continue: "Your note is saved for the app. Open Rumi to continue privately.",
  call: "Hello, this is Rumi, an AI assistant. Is this the right person and a private moment to talk?",
};
export function parseBP(input: string): { value: string; at: string } | null {
  const match = input.match(/^(?:bp\s*)?(\d{2,3})\s*\/\s*(\d{2,3})(?:\s*mmhg)?\s+(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2})$/i);
  if (!match) return null;
  const sys = Number(match[1]), dia = Number(match[2]);
  if (sys < 40 || sys > 300 || dia < 20 || dia > 200 || sys <= dia || !Number.isFinite(Date.parse(`${match[3]}T${match[4]}`))) return null;
  return { value: `${sys}/${dia} mmHg`, at: `${match[3]}T${match[4]}` };
}
