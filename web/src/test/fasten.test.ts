/// <reference types="node" />
// @vitest-environment node
import { createHmac } from "node:crypto";
import { afterEach, describe, expect, it, vi } from "vitest";
import worker from "../../../functions/index";
import { testCredentials, type FastenEnv } from "../../../functions/fasten";

const origin = "https://rumi-test.example";
const prefix = `${origin}/integrations/fasten/test`;
const testSecret = Buffer.alloc(32, 17).toString("base64");
const env: FastenEnv = {
  FASTEN_TEST_PUBLIC_ID: "public_test_fixture",
  FASTEN_TEST_PRIVATE_KEY: "private_test_fixture",
  FASTEN_TEST_WEBHOOK_SECRET: `whsec_${testSecret}`,
};

function delivery(body: string, timestamp = Math.floor(Date.now() / 1000)): Request {
  const id = "synthetic-delivery-1";
  const signature = createHmac("sha256", Buffer.from(testSecret, "base64"))
    .update(`${id}.${timestamp}.${body}`).digest("base64");
  return new Request(`${prefix}/webhook`, {
    method: "POST", body,
    headers: { "Content-Type": "application/json", "webhook-id": id,
      "webhook-timestamp": String(timestamp), "webhook-signature": `v1,${signature}` },
  });
}

afterEach(() => vi.unstubAllGlobals());

describe("Fasten setup boundary", () => {
  it("accepts printable opaque key suffixes without restricting them to UUID characters", () => {
    expect(testCredentials({ FASTEN_TEST_PUBLIC_ID: "public_test_fixture.value", FASTEN_TEST_PRIVATE_KEY: "private_test_fixture+/=" })).toBe(true);
    expect(testCredentials({ ...env, FASTEN_TEST_PRIVATE_KEY: "private_test_with space" })).toBe(false);
  });

  it("does not use live keys even under test env names", async () => {
    const upstream = vi.fn(); vi.stubGlobal("fetch", upstream);
    const live = { ...env, FASTEN_TEST_PRIVATE_KEY: "private_live_not_allowed" };
    expect(testCredentials(live)).toBe(false);
    const response = await worker.fetch(new Request(`${prefix}/status`), live);
    expect(await response.json()).toMatchObject({ credentialsConfigured: false, organization: "not_checked", authorizationEnabled: false, importEnabled: false });
    expect(upstream).not.toHaveBeenCalled();
  });

  it("only checks the public organization and never reports private-key verification", async () => {
    const upstream = vi.fn().mockResolvedValue(Response.json({ success: true, data: { status: "active", id: "not-for-client" } }));
    vi.stubGlobal("fetch", upstream);
    const response = await worker.fetch(new Request(`${prefix}/status`), { ...env, FASTEN_TEST_PUBLIC_ID: "public_test_active" });
    const text = await response.text();
    expect(JSON.parse(text)).toMatchObject({ credentialsConfigured: true, organization: "active", privateKeyVerified: false, importEnabled: false, redirectConfigured: false });
    expect(text).not.toContain("private_test_fixture");
    expect(text).not.toContain("whsec_");
    expect(text).not.toContain("not-for-client");
    expect(text).not.toContain("public_test_active");
    const [url, init] = upstream.mock.calls[0];
    expect(String(url)).toContain("https://api.connect.fastenhealth.com/v1/bridge/org?");
    expect(init.headers).not.toHaveProperty("Authorization");
    expect(init.redirect).toBe("error");
    expect(response.headers.get("cache-control")).toBe("no-store");
  });

  it("does not reflect upstream error details or mistake an outage for bad keys", async () => {
    vi.stubGlobal("fetch", vi.fn().mockRejectedValue(new Error("private upstream details")));
    const response = await worker.fetch(new Request(`${prefix}/status`), { ...env, FASTEN_TEST_PUBLIC_ID: "public_test_outage" });
    const text = await response.text();
    expect(JSON.parse(text).organization).toBe("unavailable");
    expect(text).not.toContain("private upstream details");
  });

  it("requires exact configured return URL and still leaves authorization off", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(Response.json({ success: true, data: { status: "active" } })));
    const response = await worker.fetch(new Request(`${prefix}/status`), {
      ...env, FASTEN_TEST_PUBLIC_ID: "public_test_redirect", FASTEN_TEST_REDIRECT_URI: `${prefix}/return`,
    });
    expect(await response.json()).toMatchObject({ redirectConfigured: true, authorizationEnabled: false });
  });

  it("rejects unsigned deliveries before inspecting their body", async () => {
    const response = await worker.fetch(new Request(`${prefix}/webhook`, {
      method: "POST", headers: { "Content-Type": "application/json" }, body: "{}",
    }), env);
    expect(response.status).toBe(401);
  });

  it("fails closed without the endpoint-specific signing secret", async () => {
    const response = await worker.fetch(delivery('{"api_mode":"test"}'), { ...env, FASTEN_TEST_WEBHOOK_SECRET: undefined });
    expect(response.status).toBe(503);
  });

  it("rejects tampering with signed raw content", async () => {
    const signed = delivery('{"api_mode":"test"}');
    const request = new Request(signed.url, { method: "POST", headers: signed.headers, body: '{ "api_mode":"test"}' });
    expect((await worker.fetch(request, env)).status).toBe(401);
  });

  it.each([-601, 601])("rejects a signed timestamp outside the allowed window (%i seconds)", async seconds => {
    expect((await worker.fetch(delivery('{"api_mode":"test"}', Math.floor(Date.now() / 1000) + seconds), env)).status).toBe(401);
  });

  it("rejects live deliveries even with a valid signature", async () => {
    expect((await worker.fetch(delivery('{"api_mode":"live"}'), env)).status).toBe(422);
  });

  it("does not acknowledge, fetch or ingest an unowned signed test export", async () => {
    const upstream = vi.fn(); vi.stubGlobal("fetch", upstream);
    const raw = JSON.stringify({ api_mode: "test", event_type: "patient.ehi_export_success", data: { url: "https://untrusted.example/data" } });
    const response = await worker.fetch(delivery(raw), env);
    expect(response.status).toBe(503);
    expect(upstream).not.toHaveBeenCalled();
    expect((await worker.fetch(delivery(raw), env)).status).toBe(503);
  });

  it("enforces a streaming body limit independent of Content-Length", async () => {
    const raw = JSON.stringify({ api_mode: "test", padding: "x".repeat(256 * 1024) });
    expect((await worker.fetch(delivery(raw), env)).status).toBe(413);
  });

  it("strips browser return parameters without declaring connection success", async () => {
    const response = await worker.fetch(new Request(`${prefix}/return?org_connection_id=untrusted&next=https://evil.example`), env);
    expect(response.status).toBe(303);
    expect(response.headers.get("location")).toBe("/integrations/fasten/test/return");
    const page = await worker.fetch(new Request(`${prefix}/return`), env);
    expect(await page.text()).toContain("No records were imported");
    expect(page.headers.get("content-security-policy")).toContain("frame-ancestors 'none'");
  });

  it("does not expose connection lookup or export routes", async () => {
    const upstream = vi.fn(); vi.stubGlobal("fetch", upstream);
    const response = await worker.fetch(new Request(`${prefix}/export`, { method: "POST", body: "{}" }), env);
    expect(response.status).toBe(404);
    expect(upstream).not.toHaveBeenCalled();
  });

  it("keeps the existing backend health route", async () => {
    const response = await worker.fetch(new Request(`${origin}/ping`), {});
    expect(response.status).toBe(200);
    expect(await response.json()).toHaveProperty("ok", true);
  });
});
