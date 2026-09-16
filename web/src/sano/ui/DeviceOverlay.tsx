import React from "react";
import { createPortal } from "react-dom";

/** Keeps overlays anchored to the device frame rather than a nested scrolling page. */
export function DeviceOverlay({ children }: { children: React.ReactNode }) {
  const host = document.getElementById("rumi-device-overlays");
  return host ? createPortal(children, host) : <>{children}</>;
}
