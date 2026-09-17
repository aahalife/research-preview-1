import React from "react";
import { cleanup, render, screen } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";

vi.mock("../privia/model", async importOriginal => ({ ...await importOriginal<typeof import("../privia/model")>(), DEMO_ENABLED: false }));
import Index from "../pages/Index";
import Legacy from "../pages/Legacy";
afterEach(() => { cleanup(); vi.restoreAllMocks(); });
it("the disabled build mounts neither patient provider nor AI at either entry", () => {
  const storage = vi.spyOn(Storage.prototype, "getItem"); const network = vi.spyOn(globalThis, "fetch");
  const first = render(<Index />); expect(screen.getByRole("heading", { name: "Demo disabled" })).toBeInTheDocument(); first.unmount();
  render(<Legacy />); expect(screen.getByRole("heading", { name: "Demo disabled" })).toBeInTheDocument();
  expect(storage).not.toHaveBeenCalled(); expect(network).not.toHaveBeenCalled();
});
