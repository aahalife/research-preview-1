import { SanoApp } from "../sano/SanoApp";
import { SanoProvider } from "../sano/store";
import { DEMO_ENABLED } from "../privia/model";
import { DemoUnavailable } from "../privia/PriviaApp";

/** Retains earlier fixtures without mounting their provider inside Elena's workspace. */
export default function Legacy() {
  if (!DEMO_ENABLED) return <DemoUnavailable />;
  return <><a href="/" className="fixed left-2 top-2 z-[100] max-w-44 rounded-xl bg-white p-3 text-xs text-black shadow">Earlier synthetic scenarios · return to Privia demo</a><SanoProvider><SanoApp /></SanoProvider></>;
}
