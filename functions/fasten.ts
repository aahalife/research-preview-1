import { Webhook } from "standardwebhooks";

/** Server-only Fasten test configuration. Never serialize these bindings. */
export interface FastenEnv {
  FASTEN_TEST_PUBLIC_ID?: string;
  FASTEN_TEST_PRIVATE_KEY?: string;
  FASTEN_TEST_WEBHOOK_SECRET?: string;
  FASTEN_TEST_REDIRECT_URI?: string;
}

const PREFIX = "/integrations/fasten/test";
const API = "https://api.connect.fastenhealth.com/v1";
const MAX_BODY = 256 * 1024;
const headers = {
  "Cache-Control": "no-store",
  "X-Content-Type-Options": "nosniff",
  "Referrer-Policy": "no-referrer",
};

type OrganizationCheck = "not_checked" | "active" | "inactive" | "rejected" | "unavailable";
let organizationCache: { publicID: string; expires: number; result: Promise<OrganizationCheck> } | undefined;

function json(value: unknown, status = 200): Response {
  return Response.json(value, { status, headers });
}

/** Reject live credentials even when accidentally saved under test variable names. */
export function testCredentials(env: FastenEnv): boolean {
  return /^public_test_[\x21-\x7e]+$/.test(env.FASTEN_TEST_PUBLIC_ID?.trim() ?? "")
    && /^private_test_[\x21-\x7e]+$/.test(env.FASTEN_TEST_PRIVATE_KEY?.trim() ?? "");
}

async function boundedBody(body: ReadableStream<Uint8Array> | null): Promise<string> {
  if (!body) return "";
  const reader = body.getReader();
  const decoder = new TextDecoder("utf-8", { fatal: true });
  let total = 0;
  let text = "";
  try {
    while (true) {
      const part = await reader.read();
      if (part.done) break;
      total += part.value.byteLength;
      if (total > MAX_BODY) {
        await reader.cancel();
        throw new RangeError("Body too large");
      }
      text += decoder.decode(part.value, { stream: true });
    }
    return text + decoder.decode();
  } finally {
    reader.releaseLock();
  }
}

async function lookupOrganization(publicID: string): Promise<OrganizationCheck> {
  let stage: "request" | "decode" = "request";
  try {
    // This endpoint verifies the public credential only. It cannot validate the private key.
    const url = new URL(`${API}/bridge/org`);
    url.searchParams.set("public_id", publicID);
    const response = await fetch(url.toString(), {
      headers: { Accept: "application/json" },
      redirect: "error",
      signal: AbortSignal.timeout(10000),
    });
    if (response.status === 401 || response.status === 403) return "rejected";
    if (!response.ok || !response.headers.get("content-type")?.includes("application/json")) {
      console.warn("Fasten setup public lookup unavailable", { status: response.status, isJSON: response.headers.get("content-type")?.includes("application/json") === true });
      return "unavailable";
    }
    stage = "decode";
    const value = JSON.parse(await boundedBody(response.body)) as { success?: boolean; data?: { status?: string } };
    if (value.success !== true) return "rejected";
    if (value.data?.status === "active") return "active";
    if (value.data?.status === "inactive") return "inactive";
    console.warn("Fasten setup public lookup returned an unrecognized organization status");
    return "unavailable";
  } catch (error) {
    const kind = error instanceof TypeError ? "type" : error instanceof SyntaxError ? "json" : error instanceof RangeError ? "size" : "network";
    console.warn("Fasten setup public lookup failed", { stage, kind });
    return "unavailable";
  }
}

async function organizationStatus(publicID: string): Promise<OrganizationCheck> {
  // Short per-isolate coalescing prevents a refresh from issuing duplicate public lookups.
  // This is not a global rate limiter or a durable verification receipt.
  if (!organizationCache || organizationCache.publicID !== publicID || organizationCache.expires < Date.now()) {
    organizationCache = { publicID, expires: Date.now() + 60000, result: lookupOrganization(publicID) };
  }
  return organizationCache.result;
}

async function status(env: FastenEnv, origin: string): Promise<Response> {
  const configured = testCredentials(env);
  const returnURL = `${origin}${PREFIX}/return`;
  const organization: OrganizationCheck = configured
    ? await organizationStatus(env.FASTEN_TEST_PUBLIC_ID!.trim()) : "not_checked";
  return json({
    mode: "test",
    credentialsConfigured: configured,
    publicIDPresent: Boolean(env.FASTEN_TEST_PUBLIC_ID?.trim()),
    privateKeyPresent: Boolean(env.FASTEN_TEST_PRIVATE_KEY?.trim()),
    organization,
    privateKeyVerified: false,
    webhookSecretConfigured: Boolean(env.FASTEN_TEST_WEBHOOK_SECRET?.trim()),
    redirectConfigured: env.FASTEN_TEST_REDIRECT_URI?.trim() === returnURL,
    returnURL,
    webhookURL: `${origin}${PREFIX}/webhook`,
    authorizationEnabled: false,
    importEnabled: false,
  });
}

async function webhook(request: Request, env: FastenEnv): Promise<Response> {
  if (request.method === "GET") return json({ endpoint: "Fasten test webhook", intake: "disabled" });
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
  if (!request.headers.get("content-type")?.toLowerCase().startsWith("application/json")) {
    return json({ error: "Expected JSON" }, 415);
  }
  const signatureHeaders = {
    "webhook-id": request.headers.get("webhook-id") ?? "",
    "webhook-timestamp": request.headers.get("webhook-timestamp") ?? "",
    "webhook-signature": request.headers.get("webhook-signature") ?? "",
  };
  if (Object.values(signatureHeaders).some(value => !value || value.length > 4096)) {
    return json({ error: "Signature required" }, 401);
  }
  if (!testCredentials(env) || !env.FASTEN_TEST_WEBHOOK_SECRET?.trim()) {
    return json({ error: "Test webhook configuration incomplete" }, 503);
  }
  let raw: string;
  try {
    raw = await boundedBody(request.body);
  } catch (error) {
    return json({ error: error instanceof RangeError ? "Payload too large" : "Invalid body" }, error instanceof RangeError ? 413 : 400);
  }
  let verifier: Webhook;
  try {
    verifier = new Webhook(env.FASTEN_TEST_WEBHOOK_SECRET.trim());
  } catch {
    return json({ error: "Test webhook configuration incomplete" }, 503);
  }
  let event: unknown;
  try {
    // Verify the unchanged payload and signed timestamp before inspecting JSON.
    event = verifier.verify(raw, signatureHeaders);
  } catch {
    return json({ error: "Signature invalid or expired" }, 401);
  }
  if (!event || typeof event !== "object" || !("api_mode" in event) || event.api_mode !== "test") {
    return json({ error: "Only explicit test events are supported" }, 422);
  }
  // Fail closed: no clinical receipt is acknowledged or URL downloaded until
  // session ownership, durable deduplication and the ingestion transaction exist.
  return json({ error: "Authorized session and import processing are not enabled" }, 503);
}

function returnPage(request: Request): Response {
  const url = new URL(request.url);
  if (url.search) {
    // Do not echo connection identifiers, errors or arbitrary destinations from the browser.
    return new Response(null, { status: 303, headers: { ...headers, Location: `${PREFIX}/return` } });
  }
  return new Response(`<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Rumi · Fasten test setup</title><style>body{margin:0;background:#f7f8f4;color:#00211a;font:17px/1.6 system-ui,sans-serif}main{max-width:36rem;margin:10vh auto;padding:24px}p{max-width:32rem}small{letter-spacing:.08em}h1{font:500 36px/1.15 Georgia,serif}aside{background:#e6f5ef;border-radius:20px;padding:20px;margin-top:28px}</style></head><body><main><small>RUMI · VENDOR TEST SETUP</small><h1>A place to return to.</h1><p>This address is reserved for Fasten’s test connection flow. Browser authorization and record import are not enabled yet.</p><aside>No records were imported by this page. Returning here is not proof of a completed connection.</aside><p>You can close this browser and return to Rumi. Your local Demo is unchanged.</p></main></body></html>`, {
    headers: { ...headers, "Content-Type": "text/html; charset=utf-8", "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'" },
  });
}

/** Setup-only routes: no patient identifiers, secret values or clinical operations exposed. */
export async function handleFasten(request: Request, env: FastenEnv): Promise<Response> {
  const url = new URL(request.url);
  if (url.pathname === `${PREFIX}/status` && request.method === "GET") return status(env, url.origin);
  if (url.pathname === `${PREFIX}/return` && request.method === "GET") return returnPage(request);
  if (url.pathname === `${PREFIX}/webhook`) return webhook(request, env);
  return json({ error: "Fasten operation unavailable" }, 404);
}
