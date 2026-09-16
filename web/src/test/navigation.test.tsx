import React from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, cleanup, fireEvent, render, renderHook, screen } from "@testing-library/react";
import { SanoProvider, useSano } from "../sano/store";
import { CareHub, AppointmentDetail } from "../sano/screens/Care";
import { GuideScreen } from "../sano/screens/shared";
import { Dock } from "../sano/ui/Dock";
import { useStack } from "../sano/screens/nav";
import { destinationHome, primaryTabs, selectedAppointment } from "../sano/navigation";
import type { Appointment } from "../sano/types";

vi.mock("../sano/sound", () => ({
  SoundEngine: { glass: vi.fn(), tick: vi.fn(), send: vi.fn(), setMusicEnabled: vi.fn(), playBed: vi.fn(), enabled: false },
  Haptics: { tick: vi.fn(), success: vi.fn() },
}));

beforeEach(() => {
  localStorage.clear();
  HTMLElement.prototype.scrollIntoView = vi.fn();
});
afterEach(cleanup);

const wrapper = ({ children }: { children: React.ReactNode }) => <SanoProvider>{children}</SanoProvider>;
const visits: Appointment[] = [
  { id: "first", with: "First practice", date: 1800000000000, location: "First location", kind: "inPerson", status: "confirmed", prepReady: true, joinLink: null, planGoalHint: null, trip: null },
  { id: "selected", with: "Selected practice", date: 1800100000000, location: "Selected location", kind: "inPerson", status: "confirmed", prepReady: true, joinLink: null, planGoalHint: null, trip: null },
];

describe("focused navigation", () => {
  it("has four primary destinations and separates messages from results", () => {
    expect(primaryTabs.map((tab) => tab.id)).toEqual(["today", "care", "messages", "you"]);
    expect(destinationHome("thread")).toBe("messages");
    expect(destinationHome("requests")).toBe("messages");
    expect(destinationHome("records")).toBe("care");
    render(<Dock />, { wrapper });
    expect(screen.getAllByRole("button")).toHaveLength(4);
    expect(screen.queryByRole("button", { name: "Journeys" })).not.toBeInTheDocument();
  });

  it("keeps four Care workspaces and retains contextual billing and visit reports", () => {
    render(<CareHub />, { wrapper });
    for (const title of ["Appointments", "Care plan", "Meds & refills", "Records & results"]) {
      expect(screen.getByRole("button", { name: new RegExp(title) })).toBeInTheDocument();
    }
    expect(screen.queryByRole("button", { name: /^Messages/ })).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "Bills & wallet" }));
    expect(screen.getByRole("button", { name: "Wallet" })).toBeInTheDocument();
    fireEvent.click(screen.getByRole("button", { name: "Care" }));
    fireEvent.click(screen.getByRole("button", { name: /^Appointments/ }));
    expect(screen.getByRole("button", { name: "Visit reports" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Discussion guide" })).toBeInTheDocument();
  });

  it("restores a tab path after that screen unmounts", () => {
    function Probe() {
      const nav = useStack({ name: "hub" }, "care");
      return <button onClick={() => nav.push({ name: "appointmentDetail", params: { id: "selected" } })}>{nav.top.name}</button>;
    }
    function Harness() {
      const [visible, setVisible] = React.useState<boolean>(true);
      return <><button onClick={() => setVisible(!visible)}>Switch</button>{visible && <Probe />}</>;
    }
    render(<Harness />, { wrapper });
    fireEvent.click(screen.getByRole("button", { name: "hub" }));
    fireEvent.click(screen.getByRole("button", { name: "Switch" }));
    fireEvent.click(screen.getByRole("button", { name: "Switch" }));
    expect(screen.getByRole("button", { name: "appointmentDetail" })).toBeInTheDocument();
  });

  it("keeps reply drafts after provider remount without sending them", () => {
    const first = renderHook(() => useSano(), { wrapper });
    const id = first.result.current.threads[0].id;
    const messageCount = first.result.current.threads[0].messages.length;
    act(() => first.result.current.updateMessageDraft(id, "My unsent question"));
    first.unmount();
    const second = renderHook(() => useSano(), { wrapper });
    expect(second.result.current.messageDrafts[id]).toBe("My unsent question");
    expect(second.result.current.threads[0].messages).toHaveLength(messageCount);
    act(() => second.result.current.updateMessageDraft(id, ""));
    expect(second.result.current.messageDrafts[id]).toBeUndefined();
  });

  it("restores drafts across demo scenario switches and relaunch", () => {
    const first = renderHook(() => useSano(), { wrapper });
    const original = first.result.current.threads[0].id;
    act(() => first.result.current.updateMessageDraft(original, "Metabolic draft"));
    act(() => first.result.current.switchPathway("oncology"));
    expect(first.result.current.messageDrafts[original]).toBeUndefined();
    act(() => first.result.current.switchPathway("metabolic"));
    expect(first.result.current.messageDrafts[original]).toBe("Metabolic draft");
    first.unmount();
    const second = renderHook(() => useSano(), { wrapper });
    expect(second.result.current.messageDrafts[original]).toBe("Metabolic draft");
  });

  it("does not duplicate an already open external destination", () => {
    const { result } = renderHook(() => useStack({ name: "hub" }, "care"), { wrapper });
    act(() => result.current.push({ name: "billDetail", params: { id: "same-bill" } }));
    act(() => result.current.push({ name: "billDetail", params: { id: "same-bill" } }));
    expect(result.current.stack).toHaveLength(2);
    act(() => result.current.pop());
    expect(result.current.top.name).toBe("hub");
  });

  it("does not substitute the first appointment for a missing selection", () => {
    expect(selectedAppointment(visits, "selected")).toBe(visits[1]);
    expect(selectedAppointment(visits, "missing")).toBeUndefined();
    expect(selectedAppointment(visits, undefined)).toBeUndefined();
  });

  it("carries the selected visit into preparation", () => {
    const push = vi.fn();
    function Visit() {
      const s = useSano();
      const prepared = s.appointments.find((appointment) => appointment.prepReady)!;
      return <AppointmentDetail id={prepared.id} push={(name, params) => push(name, params, prepared.id)} />;
    }
    render(<Visit />, { wrapper });
    fireEvent.click(screen.getByRole("button", { name: "See your visit prep" }));
    expect(push).toHaveBeenCalledWith("visitPrep", { id: expect.any(String) }, expect.any(String));
    expect(push.mock.calls[0][1].id).toBe(push.mock.calls[0][2]);
  });

  it("shows unavailable preparation instead of another visit", () => {
    render(<GuideScreen appointmentID="deleted-visit" />, { wrapper });
    expect(screen.getByText(/This appointment isn't available/)).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "Send to care team" })).not.toBeInTheDocument();
  });

  it("does not claim EHR delivery when it is not connected", () => {
    render(<GuideScreen />, { wrapper });
    fireEvent.click(screen.getByRole("button", { name: "Send to care team" }));
    expect(screen.getByRole("status")).toHaveTextContent("Nothing has been sent");
    expect(screen.queryByText("Sent ahead")).not.toBeInTheDocument();
  });
});
