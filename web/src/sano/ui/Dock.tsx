import React from "react";
import { cn } from "@/lib/utils";
import { Icon } from "./Icon";
import { useSano } from "../store";
import { primaryTabs } from "../navigation";
import { SoundEngine, Haptics } from "../sound";

const tabs = primaryTabs;

export const Dock: React.FC = () => {
  const { tab, setTab, messageUnreadCount, recordUpdateCount } = useSano();
  return (
    <div className="absolute inset-x-0 bottom-0 pb-3 flex justify-center pointer-events-none z-40">
      {/* A cool/bright tint + crisper edge lifts the glass off the warm ground
          so its refraction reads instead of blending in. */}
      <div
        className="glass-strong pointer-events-auto flex items-center gap-1 px-2 py-2"
        style={{
          borderRadius: 30,
          background: "rgb(var(--surface) / 0.34)",
          boxShadow: "inset 0 1px 0 0 rgb(255 255 255 / 0.4), 0 22px 50px -20px rgb(var(--shadow) / 0.6)",
          border: "1px solid rgb(255 255 255 / 0.22)",
        }}
      >
        {tabs.map((t) => {
          const active = tab === t.id;
          const badge = t.id === "messages" ? messageUnreadCount : t.id === "care" ? recordUpdateCount : 0;
          return (
            <button
              key={t.id}
              onClick={() => { Haptics.tick(); setTab(t.id); }}
              className="press relative grid h-[50px] w-[72px] place-items-center rounded-full"
              aria-label={badge ? `${t.label}, ${badge} new` : t.label}
              aria-current={active ? "page" : undefined}
              data-testid={`tab.${t.id}`}
            >
              {active && (
                <span
                  className="absolute inset-x-1.5 inset-y-1 rounded-full"
                  style={{ background: "rgb(var(--warm) / 0.18)", boxShadow: "inset 0 0 0 1px rgb(var(--warm) / 0.28)" }}
                />
              )}
              <span className={cn("relative flex flex-col items-center gap-0.5", active ? "text-warm" : "text-ink-muted")}>
                <span className="relative">
                  <Icon name={t.glyph} size={20} strokeWidth={active ? 2.3 : 1.9} />
                  {badge > 0 && (
                    <span
                      className="absolute -top-0.5 -right-1 size-2 rounded-full"
                      style={{ background: "rgb(var(--warm))", boxShadow: "0 0 0 1.5px rgb(var(--surface))" }}
                    />
                  )}
                </span>
                <span className="text-[9.5px] font-rounded font-semibold tracking-tight">{t.label}</span>
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
};
