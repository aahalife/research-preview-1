import createContextHook from "@nkzw/create-context-hook";
import { useCallback, useEffect, useRef, useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { askRumi } from "./ai";
import { DemoActionError, labFingerprint, messageFingerprint, DEMO_ENABLED, STORAGE_KEY, stateSchema, initialState, uid, nowISO, channelCopy, parseBP, type DemoState, type Channel, type Turn, type Surface } from "./model";

type Edit = (draft: DemoState) => void;
function load(): { state: DemoState; error: string | null } {
  if (!DEMO_ENABLED) return { state: initialState(), error: "The demonstration is disabled." };
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return { state: raw ? stateSchema.parse(JSON.parse(raw)) : initialState(), error: null };
  } catch { return { state: initialState(), error: "Saved work could not be opened. It has not been replaced. Export the saved snapshot before resetting this demo." }; }
}

/** Owns all persistence and continuing client state; never accesses legacy patient keys. */
export const [PriviaProvider, usePrivia] = createContextHook(() => {
  const [loaded] = useState(load);
  const [state, setState] = useState<DemoState>(loaded.state);
  const ref = useRef<DemoState>(loaded.state);
  const locked = useRef<boolean>(!!loaded.error);
  const [error, setError] = useState<string | null>(loaded.error);
  const [notice, setNotice] = useState<string | null>(null);
  const [surface, setSurface] = useState<Surface | "records" | "visit" | "preferences" | "demo" | null>(null);
  const [chatOpen, setChatOpen] = useState<boolean>(false);
  const [logOpen, setLogOpen] = useState<boolean>(false);
  const [work, setWork] = useState<string>("");
  const active = useRef<{ id: string; controller: AbortController } | null>(null);
  const callVerified = useRef<boolean>(false);
  const setCallVerified = (value: boolean): void => { callVerified.current = value && ref.current.channel.call && !ref.current.channel.stopped; };

  const commit = useCallback((edit: Edit): boolean => {
    if (locked.current || !DEMO_ENABLED) return false;
    try {
      const draft = structuredClone(ref.current); edit(draft); draft.revision++;
      if (messageFingerprint(draft) !== messageFingerprint(ref.current)) draft.lab.messageApproval = null;
      if (labFingerprint(draft) !== labFingerprint(ref.current)) draft.lab.approval = null;
      const observationsChanged = JSON.stringify(draft.logs) !== JSON.stringify(ref.current.logs);
      const contextRemoved = ref.current.contextIds.some(id => !draft.contextIds.includes(id));
      if (observationsChanged || contextRemoved) {
        draft.historyFrom = draft.turns.length;
        draft.turns.forEach(t => { if (t.suggestion) t.dismissed = true; });
        active.current?.controller.abort(); active.current = null; setWork("");
      }
      if (!draft.channel.call || draft.channel.stopped) callVerified.current = false;
      const next = stateSchema.parse(draft);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
      ref.current = next; setState(next); setError(null); return true;
    } catch (failure) {
      if (failure instanceof DemoActionError) { setNotice(failure.message); return false; }
      setError("This change could not be saved. Your previous saved work is intact. Free browser storage and try again."); setNotice("Change not saved. Check browser storage and retry; no action was applied."); return false;
    }
  }, []);
  const stop = useCallback(() => {
    if (active.current) setNotice("Reply stopped. Your question is saved; nothing was applied.");
    active.current?.controller.abort(); active.current = null; setWork("");
  }, []);
  const privateEdit = useCallback((edit: Edit): boolean => {
    stop();
    return commit(s => {
      const previous = structuredClone(s); edit(s);
      const revoked = (Object.keys(s.sources) as (keyof DemoState["sources"])[]).some(key => previous.sources[key] && !s.sources[key]);
      if (revoked || (previous.aiConsent && !s.aiConsent) || JSON.stringify(previous.memories) !== JSON.stringify(s.memories) || s.turns.length < previous.turns.length) s.historyFrom = s.turns.length;
      s.lab.approval = null; s.lab.messageApproval = null;
      s.turns.forEach(t => { if (t.suggestion) t.dismissed = true; });
      if (revoked) s.contextIds = [];
    });
  }, [commit, stop]);
  useEffect(() => {
    const background = () => { if (document.hidden) { callVerified.current = false; stop(); } };
    const changed = (event: StorageEvent) => { if (event.key === STORAGE_KEY) { stop(); locked.current = true; setError("This demo changed in another tab. Reload to use that saved version; this tab will not overwrite it."); } };
    document.addEventListener("visibilitychange", background); window.addEventListener("storage", changed);
    return () => { stop(); document.removeEventListener("visibilitychange", background); window.removeEventListener("storage", changed); };
  }, [stop]);

  const mutation = useMutation({
    mutationKey: ["privia", "conversation"], retry: false,
    mutationFn: async ({ id, snapshot, turns, controller }: { id: string; snapshot: DemoState; turns: Turn[]; controller: AbortController }) => {
      const timeout = setTimeout(() => controller.abort(), 45000);
      try { return { id, result: await askRumi(snapshot, turns, controller.signal, label => { if (active.current?.id === id) setWork(label); }) }; }
      finally { clearTimeout(timeout); }
    },
    onSuccess: ({ id, result }, variables) => {
      if (active.current?.id !== id) return;
      const channel = variables.turns.at(-1)?.channel ?? "app";
      commit(s => { s.pendingQuestion = null; s.turns.push({ id: uid(), role: "assistant", text: result.reply, channel, at: nowISO(), status: "complete", origin: "live-ai", dismissed: false, suggestion: result.suggestion }); if (result.pace) s.preferences.pace = result.pace; });
      active.current = null; setWork("");
    },
    onError: (_failure, variables) => {
      if (active.current?.id !== variables.id) return;
      active.current = null; setWork(""); setNotice("Rumi could not finish. Your question is saved. Retry when ready; nothing was applied.");
    },
  });
  const send = (text: string, channel: Channel = "app", retry = false): void => {
    if (!text.trim() || active.current || locked.current) return;
    if (channel === "call" && (!callVerified.current || !ref.current.channel.call || ref.current.channel.stopped)) { setNotice("The call is not verified or permission was removed. Continue in the app."); return; }
    if (!ref.current.aiConsent) { setNotice("Enable temporary AI in this conversation first. Direct care tools work without it."); return; }
    const turn: Turn = { id: uid(), role: "user", text: text.trim(), channel, at: nowISO(), status: "complete", origin: "patient", dismissed: false };
    if (!commit(s => { s.pendingQuestion = { text: turn.text, channel }; if (!retry) s.turns.push(turn); if (channel === "call") s.channel.callDraft = ""; else s.composer = ""; })) return;
    const controller = new AbortController(); const id = uid(); active.current = { id, controller }; setWork("Preparing a reply"); setNotice(null);
    const snapshot = structuredClone(ref.current);
    const turns = retry ? [...snapshot.turns, turn] : snapshot.turns;
    mutation.mutate({ id, snapshot, turns, controller });
  };
  const openChat = (contextId?: string): void => {
    if (contextId) commit(s => { s.excludedContextIds = s.excludedContextIds.filter(id => id !== contextId); if (!s.contextIds.includes(contextId)) s.contextIds.push(contextId); });
    setChatOpen(true);
  };
  const sms = (input: string): void => {
    const value = input.trim(); if (!value) return;
    stop();
    const bp = parseBP(value);
    const isStop = /^(stop|pause|unsubscribe)$/i.test(value);
    const isBP = /^(bp\b|\d{2,3}(?:\s*\/|\s*$))/i.test(value);
    commit(s => {
      s.channel.smsDraft = "";
      s.turns.push({ id: uid(), role: "user", text: value, channel: "sms", at: nowISO(), status: "complete", origin: "patient", dismissed: false });
      if (isStop) { s.channel.stopped = true; s.channel.sms = false; s.channel.call = false; }
      if (bp && !s.logs.some(l => l.kind === "Blood pressure" && l.value === bp.value && l.at === bp.at)) s.logs.push({ id: uid(), kind: "Blood pressure", value: bp.value, at: bp.at, note: "", source: "Sample SMS" });
      s.turns.push({ id: uid(), role: "assistant", text: isStop ? channelCopy.stop : bp ? channelCopy.saved : isBP ? channelCopy.clarify : channelCopy.continue, channel: "sms", at: nowISO(), status: "complete", origin: "sample-channel", dismissed: false });
    });
    if (isStop) stop();
  };
  const reset = (): void => {
    stop();
    try { const next = initialState(); localStorage.setItem(STORAGE_KEY, JSON.stringify(next)); locked.current = false; ref.current = next; setState(next); setError(null); setNotice("Only Elena’s demo was reset. Legacy scenarios were not changed."); }
    catch { setError("The demo could not be reset. Your saved snapshot has not been changed."); }
  };
  const exportSnapshot = (): void => {
    try {
      const blob = new Blob([localStorage.getItem(STORAGE_KEY) ?? JSON.stringify(ref.current)], { type: "application/json" });
      const url = URL.createObjectURL(blob); const a = document.createElement("a"); a.href = url; a.download = "rumi-elena-demo.json"; a.click(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch { setNotice("The snapshot could not be exported in this browser."); }
  };
  return { state, commit, privateEdit, error, notice, setNotice, surface, setSurface, chatOpen, setChatOpen, logOpen, setLogOpen, work, isPending: mutation.isPending && !!work, send, stop, openChat, sms, reset, exportSnapshot, setCallVerified };
});
