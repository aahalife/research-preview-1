import { useRef, useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Edit3, Trash2 } from "lucide-react";
import { usePrivia } from "./store";
import { observationSchema, parseBP, uid, nowISO, type DemoState, type Observation } from "./model";
import { Action, Card, Eyebrow, inputClass, Note, TextLink } from "./ui";

const logFormSchema = z.object({ kind: observationSchema.shape.kind, value: z.string().trim().min(1, "Enter a value or description.").max(1500), at: z.string().min(1, "Choose a date and time."), note: z.string().max(1500) }).superRefine((data, ctx) => {
  if (!Number.isFinite(Date.parse(data.at))) ctx.addIssue({ code: "custom", path: ["at"], message: "Choose a valid date and time." });
  if (data.kind === "Blood pressure" && !parseBP(`${data.value} ${data.at.replace("T", " ")}`)) ctx.addIssue({ code: "custom", path: ["value"], message: "Enter a plausible pair such as 138/84. This checks entry format, not health status." });
});
type LogFields = z.infer<typeof logFormSchema>;
const imageFor: Record<Observation["kind"], string | null> = { "Blood pressure": null, Symptom: "/img/soft_editorial_3d.png", Medication: "/img/medicine_bottle_tablets.png", Meal: "/img/oatmeal_bowl_blueberries.png", Activity: "/img/terracotta_cream_sneakers.png" };

export function LogForm() {
  const { state, commit, setLogOpen, setNotice } = usePrivia();
  const form = useForm<LogFields>({ resolver: zodResolver(logFormSchema), defaultValues: state.logDraft });
  const kind = form.watch("kind");
  const submission = useRef<string>(uid());
  const submitted = useRef<boolean>(false);
  const saveDraft = () => { const values = form.getValues(); commit(s => { Object.assign(s.logDraft, values); }); };
  return <form className="space-y-5" onChange={saveDraft} onSubmit={form.handleSubmit(values => {
    const parsed = values.kind === "Blood pressure" ? parseBP(`${values.value} ${values.at.replace("T", " ")}`) : null;
    if (submitted.current) return;
    submitted.current = true;
    const id = state.logDraft.editingId ?? submission.current;
    if (commit(s => {
      const log: Observation = { ...values, value: parsed?.value ?? values.value, id, source: "Patient entry" };
      const exists = s.logs.findIndex(l => l.id === id); if (exists >= 0) s.logs[exists] = log; else s.logs.push(log);
      s.guide.reviewed = null; s.logDraft.value = ""; s.logDraft.note = ""; s.logDraft.editingId = null;
    })) { setLogOpen(false); setNotice("Entry saved. You can correct or remove it in Your logs."); } else submitted.current = false;
  })}>
    <label className="block space-y-2 text-sm"><span>What are you logging?</span><select {...form.register("kind")} className={inputClass}>{observationSchema.shape.kind.options.map(v => <option key={v}>{v}</option>)}</select></label>
    {imageFor[kind] && <div className="flex items-center gap-4 rounded-2xl bg-white px-3 py-2"><img src={imageFor[kind]!} className="h-16 w-16 rounded-xl object-cover" alt="" /><Note>Illustration only. Describe what you actually took, ate, felt or did; no values are estimated from this image.</Note></div>}
    <label className="block space-y-2 text-sm"><span>{kind === "Blood pressure" ? "Blood pressure · mmHg" : "Description"}</span><input {...form.register("value")} className={inputClass} placeholder={kind === "Blood pressure" ? "138/84" : "In your own words"} />{form.formState.errors.value && <span className="block text-[#96421f]" role="alert">{form.formState.errors.value.message}</span>}</label>
    <label className="block space-y-2 text-sm"><span>Date and time · your local entry</span><input type="datetime-local" {...form.register("at")} className={inputClass} />{form.formState.errors.at && <span role="alert">{form.formState.errors.at.message}</span>}</label><label className="block space-y-2 text-sm"><span>Note · optional</span><textarea {...form.register("note")} className={inputClass} /></label><Action type="submit" className="w-full">{state.logDraft.editingId ? "Save correction" : "Save entry"}</Action><Note>Recorded, not medically assessed. Rumi does not monitor these entries. For urgent symptoms, seek appropriate medical help.</Note></form>;
}

export function Logs() {
  const { state, commit, setLogOpen, openChat, setSurface, setNotice } = usePrivia();
  const [removed, setRemoved] = useState<Observation | null>(null);
  return <><Action secondary onClick={() => setLogOpen(true)}>Add an entry</Action>{[...state.logs].reverse().map(l => <Card key={l.id}><Eyebrow>{l.kind} · {l.source}</Eyebrow><p className="mt-2 font-fields text-2xl">{l.value}</p><Note>{l.at.replace("T", " · ")}</Note>{l.note && <p className="mt-3 text-sm">{l.note}</p>}<div className="mt-2 flex items-center justify-between"><TextLink onClick={() => { setSurface(null); openChat(l.id); }}>Ask about this entry</TextLink><div className="flex"><button aria-label={`Correct ${l.kind} entry`} className="grid h-11 w-11 place-items-center" onClick={() => { if (state.logDraft.value.trim() && state.logDraft.editingId !== l.id && !window.confirm("Replace your unfinished log draft to correct this entry? Cancel keeps it.")) return; if (commit(s => { s.logDraft = { kind: l.kind, value: l.value, at: l.at, note: l.note, editingId: l.id }; })) setLogOpen(true); }}><Edit3 size={17} /></button><button aria-label={`Remove ${l.kind} entry`} className="grid h-11 w-11 place-items-center" onClick={() => { if (commit(s => { s.logs = s.logs.filter(x => x.id !== l.id); s.guide.selectedLogIds = s.guide.selectedLogIds.filter(id => id !== l.id); s.guide.reviewed = null; })) setRemoved(l); }}><Trash2 size={17} /></button></div></div></Card>)}{removed && <Action secondary onClick={() => { if (commit(s => { if (!s.logs.some(l => l.id === removed.id)) s.logs.push(removed); })) { setRemoved(null); setNotice("Entry restored."); } }}>Undo removal</Action>}{!state.logs.length && <Note>No entries. Deleted collections stay empty when you return.</Note>}</>;
}

export function Preferences() {
  const { state, commit, privateEdit, setNotice, exportSnapshot } = usePrivia();
  const memory = state.memoryDraft;
  const setMemory = (text: string) => commit(s => { s.memoryDraft = text; });
  return <><Card><Eyebrow>How Rumi helps</Eyebrow><label className="mt-3 block space-y-2 text-sm"><span>Response style</span><select className={inputClass} value={state.preferences.pace} onChange={e => privateEdit(s => { s.preferences.pace = e.target.value as DemoState["preferences"]["pace"]; })}><option value="balanced">A little context</option><option value="brief">Keep it brief</option><option value="practical">Practical help only</option><option value="detailed">Explain the details</option></select></label><label className="mt-3 flex min-h-11 items-center gap-3 text-sm"><input type="checkbox" className="h-5 w-5 accent-[#287d66]" checked={state.preferences.paused} onChange={e => privateEdit(s => { s.preferences.paused = e.target.checked; })} />Pause suggestions and outreach</label><Note>You can still chat and use every direct tool. No reminders are sent in the background.</Note></Card>
    <Card><Eyebrow>What you’ve asked Rumi to remember</Eyebrow><Note>Only confirmed words—not a personality profile. Editing or forgetting excludes earlier conversation from future AI requests; your visible history stays on this device.</Note>{state.memories.map(m => <div className="mt-4" key={m.id}><textarea aria-label="Remembered preference" className={inputClass} value={m.text} maxLength={2000} onChange={e => privateEdit(s => { const item = s.memories.find(x => x.id === m.id); if (item) item.text = e.target.value; })} /><TextLink onClick={() => privateEdit(s => { s.memories = s.memories.filter(x => x.id !== m.id); })}>Forget this</TextLink></div>)}<label className="mt-4 block space-y-2 text-sm"><span>Something you want remembered</span><input className={inputClass} value={memory} onChange={e => setMemory(e.target.value)} maxLength={2000} placeholder="For example, one decision at a time" /></label><Action secondary className="mt-3" disabled={!memory.trim()} onClick={() => { if (commit(s => { s.memories.push({ id: uid(), text: memory.trim(), at: nowISO() }); })) setMemory(""); }}>Remember my words</Action></Card>
    <Card><Eyebrow>Temporary AI</Eyebrow><label className="my-3 flex min-h-11 items-center gap-3 text-sm"><input type="checkbox" className="h-5 w-5 accent-[#287d66]" checked={state.aiConsent} onChange={e => privateEdit(s => { s.aiConsent = e.target.checked; })} />Use temporary AI for synthetic conversations</label><Note>Your chat, confirmed preferences and permitted synthetic sources are processed by Rork Toolkit / Claude Sonnet 4.6. Do not enter real health information. This is not the dedicated Rumi backend.</Note></Card><Action secondary onClick={exportSnapshot}>Export this demo’s saved work</Action><TextLink onClick={() => { if (window.confirm("Clear visible conversation history? Saved questions, messages and preferences stay.")) privateEdit(s => { s.turns = []; s.historyFrom = 0; s.composer = ""; setNotice("Conversation history cleared from this browser."); }); }}>Clear conversation history</TextLink></>;
}

export function Support() {
  const { state, commit, setSurface, openChat } = usePrivia();
  const [details, setDetails] = useState<boolean>(false);
  const fields = [ ["goal", "A step you choose", "Something practical you want to try"], ["cue", "When it fits", "A moment in your existing routine"], ["reason", "Why it matters to you", "Optional"], ["barrier", "What gets in the way", "Only what you choose to share"], ["fallback", "An easier nonclinical step", "For example, put the notebook somewhere handy"] ] as const;
  const shown = details || state.preferences.pace === "detailed" ? fields : fields.slice(0, 2);
  return <>{state.stage === "after" ? <Card><Eyebrow>After the sample visit</Eyebrow><p className="mt-3 text-sm leading-relaxed">Bring your home blood-pressure readings and medication questions to follow-up. The sample plan does not provide a monitoring schedule or new treatment instructions.</p><TextLink onClick={() => setSurface("records")}>Read the source plan</TextLink></Card> : <Note>You can make a personal plan now. The after-visit care plan appears only after the staged sample visit.</Note>}<h2 className="font-fields text-2xl">Make room for a small step</h2><Note>This is your optional support plan, not a change to prescribed care.</Note>{shown.map(([key, label, placeholder]) => <label key={key} className="block space-y-2 text-sm"><span>{label}</span><input className={inputClass} maxLength={1500} value={state.support[key]} placeholder={placeholder} onChange={e => commit(s => { s.support[key] = e.target.value; })} /></label>)}{!details && state.preferences.pace !== "detailed" && <TextLink onClick={() => setDetails(true)}>Add a reason, obstacle or fallback</TextLink>}
    <label className="block space-y-2 text-sm"><span>In-app reminder time · optional</span><input type="time" className={inputClass} value={state.support.reminder} onChange={e => commit(s => { s.support.reminder = e.target.value; })} /></label><Note>A saved time is shown in Today. No notification, text or call is scheduled.</Note><label className="flex min-h-11 items-center gap-3 text-sm"><input type="checkbox" className="h-5 w-5 accent-[#287d66]" checked={state.support.paused} onChange={e => commit(s => { s.support.paused = e.target.checked; })} />Pause this personal plan</label>
    {state.support.goal && !state.support.paused && <Card><Eyebrow>Your check-in · optional</Eyebrow><div className="mt-3 flex flex-wrap gap-2">{["Tried it", "Not today", "Make it smaller"].map(v => <Action key={v} secondary={state.support.checkIn !== v} onClick={() => commit(s => { s.support.checkIn = v; })}>{v}</Action>)}</div>{state.support.checkIn === "Make it smaller" && <p className="mt-3 text-sm">{state.support.fallback || "You can choose a smaller practical step above, or leave this for now."}</p>}{state.support.checkIn && <TextLink onClick={() => commit(s => { s.support.checkIn = ""; })}>Undo check-in</TextLink>}</Card>}
    <TextLink onClick={() => { setSurface(null); openChat(); }}>Talk it through with Rumi</TextLink></>;
}
