import type { Appointment } from "./types";

/** Primary destinations. Secondary features remain reachable within these homes. */
export type Tab = "today" | "care" | "messages" | "you";
export interface Route { name: string; params?: Record<string, unknown> }

export const primaryTabs: { id: Tab; label: string; glyph: string }[] = [
  { id: "today", label: "Today", glyph: "sun.haze" },
  { id: "care", label: "Care", glyph: "cross.case" },
  { id: "messages", label: "Messages", glyph: "message-circle" },
  { id: "you", label: "You", glyph: "book.closed" },
];

/** Communication intents belong to Messages even when emitted by an older Care entry point. */
export function destinationHome(name: string): "messages" | "care" {
  return ["messages", "thread", "requests"].includes(name) ? "messages" : "care";
}

/** A missing or stale selection never falls back to another patient's visit. */
export function selectedAppointment(appointments: Appointment[], id: string | undefined): Appointment | undefined {
  return id ? appointments.find((appointment) => appointment.id === id) : undefined;
}
