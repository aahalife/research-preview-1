import { useEffect, useRef } from "react";
import { ArrowLeft, ArrowUp, Check, Settings2, Square, X } from "lucide-react";
import { usePrivia } from "./store";
import { evidence, nowISO, uid, type Suggestion } from "./model";
import { Action, Card, Eyebrow, inputClass, Note, RumiMark, TextLink } from "./ui";

export function SuggestionView({ suggestion, turnId }: { suggestion: Suggestion; turnId: string }) {
  const { state, commit, setSurface, setChatOpen, setNotice } = usePrivia();
  const text = suggestion.text;
  const setText = (value: string) => commit(s => { const turn = s.turns.find(t => t.id === turnId); if (turn?.suggestion) turn.suggestion.text = value; });
  const permitted = suggestion.sourceIds.every(id => id === "calendar" ? state.sources.calendar : evidence(state).some(e => e.id === id && state.sources[e.source]) || (state.sources.records && state.logs.some(l => l.id === id)));
  const apply = () => {
    if (!permitted) { setNotice("A source was removed. Ask for a new suggestion before using it."); return; }
    if (suggestion.kind === "message" && state.lab.message.trim() && !window.confirm("Replace your current message draft? Cancel keeps your words.")) return;
    if (suggestion.kind === "support" && state.support.goal.trim() && !window.confirm("Replace your current personal step?")) return;
    const saved = commit(s => {
      if (suggestion.kind === "memory") s.memories.push({ id: uid(), text, at: nowISO() });
      if (suggestion.kind === "question") { s.guide.questions.push({ id: uid(), text }); s.guide.reviewed = null; }
      if (suggestion.kind === "message") { s.lab.message = text; s.lab.approval = null; }
      if (suggestion.kind === "support") s.support.goal = text;
      const turn = s.turns.find(t => t.id === turnId); if (turn) turn.dismissed = true;
    });
    if (!saved) return;
    if (suggestion.kind !== "memory") {
      setChatOpen(false);
      setSurface(suggestion.kind === "question" ? "guide" : suggestion.kind === "message" ? "message" : suggestion.kind === "support" ? "support" : suggestion.surface ?? "lab");
    } else setNotice("Remembered with your confirmation. You can edit or forget this in You.");
  };
  return <Card className="mt-4 border-[#b7dacb]"><Eyebrow>Optional next step</Eyebrow><p className="my-2 font-medium">{suggestion.title}</p>{suggestion.kind !== "surface" ? <textarea className={inputClass} aria-label="Edit Rumi suggestion" value={text} onChange={e => setText(e.target.value)} maxLength={2000} /> : <Note>{text}</Note>}<div className="mt-3 flex gap-2"><Action secondary className="flex-1" disabled={!permitted || (!text.trim() && suggestion.kind !== "surface")} onClick={apply}>{suggestion.kind === "memory" ? "Remember this" : suggestion.kind === "surface" ? "Open" : "Use editable draft"}</Action><button className="min-h-11 px-3 text-sm" onClick={() => commit(s => { const turn = s.turns.find(t => t.id === turnId); if (turn) turn.dismissed = true; })}>Not now</button></div>{!permitted && <Note>Supporting source is no longer available.</Note>}</Card>;
}

export function Conversation() {
  const { state, commit, privateEdit, setChatOpen, setSurface, send, stop, work, isPending, notice, setNotice } = usePrivia();
  const end = useRef<HTMLDivElement | null>(null);
  const unanswered = state.pendingQuestion;
  useEffect(() => { end.current?.scrollIntoView({ behavior: "auto" }); }, [state.turns.length, work]);
  const selected = [...evidence(state).filter(e => state.contextIds.includes(e.id)).map(e => ({ id: e.id, title: e.title, permitted: state.sources[e.source] })), ...state.logs.filter(l => state.contextIds.includes(l.id)).map(l => ({ id: l.id, title: `${l.kind}: ${l.value}`, permitted: state.sources.records }))];
  if (state.contextIds.includes("guide")) selected.push({ id: "guide", title: "This visit’s questions and selected observations", permitted: true });
  if (state.contextIds.includes("message-draft")) selected.push({ id: "message-draft", title: "Current practice-message draft", permitted: true });
  return <section className="absolute inset-0 z-30 flex flex-col bg-[#f5f9f4]" aria-label="Rumi conversation"><header className="flex shrink-0 items-center gap-3 border-b border-[#00211a]/10 px-4 py-3"><button aria-label="Return to app" onClick={() => setChatOpen(false)} className="grid h-11 w-11 place-items-center"><ArrowLeft size={21} /></button><RumiMark busy={isPending} /><div className="flex-1"><h1 className="font-fields text-2xl">Rumi</h1><p className="text-xs text-[#53685f]">Temporary AI · synthetic demo</p></div><button aria-label="Conversation preferences" className="grid h-11 w-11 place-items-center" onClick={() => setSurface("preferences")}><Settings2 size={20} /></button></header>
    <div className="flex-1 space-y-5 overflow-y-auto px-5 py-6">
      {!state.aiConsent && <Card><h2 className="font-fields text-2xl">Before we talk</h2><p className="my-3 text-sm leading-relaxed">Rumi uses Claude Sonnet 4.6 through Rork Toolkit. Your words, confirmed preferences and permitted sample information are sent for a reply. Please use synthetic information only.</p><Action onClick={() => privateEdit(s => { s.aiConsent = true; })}>Enable temporary AI</Action><TextLink onClick={() => { setChatOpen(false); setSurface("guide"); }}>Prepare directly without AI</TextLink></Card>}
      {!state.turns.length && state.aiConsent && <div className="py-8"><Eyebrow>No agenda required</Eyebrow><h2 className="mt-3 font-fields text-[32px] leading-tight">What’s on your mind?</h2><p className="mt-4 text-sm leading-relaxed text-[#53685f]">A question, a practical detail, or something you want to talk through.</p></div>}
      {state.turns.map((turn, index) => <div key={turn.id} className={turn.role === "user" ? "ml-8" : "mr-2"}><div className={turn.role === "user" ? "rounded-[22px] rounded-br-md bg-[#dfefe6] px-4 py-3" : "py-1"}><p className="mb-2 text-[10px] uppercase tracking-[0.12em] text-[#53685f]">{turn.role === "user" ? "You" : turn.origin === "sample-channel" ? "Sample channel acknowledgment" : "Rumi"}{turn.channel !== "app" && ` · ${turn.channel} preview`}</p><p className="whitespace-pre-wrap text-[15px] leading-[1.65]">{turn.text}</p></div>{turn.suggestion && !turn.dismissed && index >= state.historyFrom && !state.preferences.paused && <SuggestionView suggestion={turn.suggestion} turnId={turn.id} />}{turn.suggestion && turn.dismissed && <p className="mt-2 flex items-center gap-1 text-xs text-[#53685f]"><Check size={12} />Proposal closed</p>}</div>)}
      {isPending && <div className="flex items-center gap-3" role="status"><RumiMark busy className="h-7 w-7" /><span className="text-sm text-[#53685f]">{work}</span></div>}
      {notice && <Card><p className="text-sm" role="status">{notice}</p><button aria-label="Dismiss conversation notice" className="ml-3 h-11 w-11" onClick={() => setNotice(null)}><X size={15} /></button></Card>}
      {unanswered && !isPending && <TextLink onClick={() => send(unanswered.text, "app", true)}>Retry saved question</TextLink>}
      <div ref={end} />
    </div>
    <footer className="shrink-0 border-t border-[#00211a]/10 bg-[#fffefa] px-4 pb-[max(16px,env(safe-area-inset-bottom))] pt-3">
      {selected.length > 0 && <details className="mb-3 rounded-xl bg-[#edf5ef] p-3"><summary className="min-h-8 cursor-pointer text-sm">{selected.length} selected source{selected.length > 1 ? "s" : ""} · inspect before sending</summary>{selected.map(s => <div className="flex items-center justify-between gap-2 py-2 text-xs" key={s.id}><span>{s.title}{!s.permitted && " · excluded (permission off)"}</span><button aria-label={`Remove context ${s.title}`} className="grid h-11 w-11 shrink-0 place-items-center" onClick={() => commit(d => { d.contextIds = d.contextIds.filter(id => id !== s.id); d.excludedContextIds.push(s.id); })}><X size={15} /></button></div>)}</details>}
      <form className="flex items-end gap-2" onSubmit={e => { e.preventDefault(); send(state.composer); }}><textarea aria-label="Message Rumi" className="max-h-32 min-h-12 flex-1 resize-y rounded-2xl border border-[#00211a]/15 bg-white px-4 py-3 text-[16px] outline-none focus:ring-2 focus:ring-[#287d66]" rows={1} maxLength={4000} placeholder="Tell Rumi…" value={state.composer} onChange={e => commit(s => { s.composer = e.target.value; })} onKeyDown={e => { if (e.key === "Enter" && !e.shiftKey && !e.nativeEvent.isComposing) { e.preventDefault(); send(state.composer); } }} />{isPending ? <button type="button" aria-label="Stop reply" className="grid h-12 w-12 place-items-center rounded-full bg-[#00211a] text-white" onClick={stop}><Square size={17} /></button> : <button aria-label="Send to Rumi" className="grid h-12 w-12 place-items-center rounded-full bg-[#00211a] text-white disabled:opacity-35" disabled={!state.aiConsent || !state.composer.trim()}><ArrowUp size={21} /></button>}</form><p className="mt-2 text-center text-[10px] text-[#53685f]">AI can make mistakes. No messages, orders or bookings leave this demo.</p>
    </footer></section>;
}
