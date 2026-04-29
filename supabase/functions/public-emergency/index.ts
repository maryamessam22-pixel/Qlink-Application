/// <reference path="./edge.d.ts" />
// Deno / Supabase Edge — HTTPS URL opens in the phone browser after scanning the QR barcode.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

/** Blob sets Content-Type reliably; some clients showed raw markup when using string + Headers only. */
function htmlResponse(html: string, status: number): Response {
  const blob = new Blob([html], { type: "text/html;charset=utf-8" });
  const headers = new Headers({
    "Cache-Control": "private, max-age=0, no-store",
    "Pragma": "no-cache",
  });
  return new Response(blob, { status, headers });
}

function escHtml(s: unknown): string {
  if (s === null || s === undefined) return "";
  const t = String(s);
  return t
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function asRecord(v: unknown): Record<string, unknown> | null {
  if (v && typeof v === "object" && !Array.isArray(v)) return v as Record<string, unknown>;
  return null;
}

/** `emergency_contacts` may be jsonb object or a JSON string from older rows. */
function parseEmergencyContacts(raw: unknown): Record<string, unknown> | null {
  if (raw === null || raw === undefined) return null;
  if (typeof raw === "string") {
    const t = raw.trim();
    if (!t) return null;
    try {
      const o = JSON.parse(t) as unknown;
      return asRecord(o);
    } catch {
      return null;
    }
  }
  return asRecord(raw);
}

function buildContactsUl(ecRaw: unknown): string {
  const ec = parseEmergencyContacts(ecRaw);
  if (!ec) return "";

  const entries = Object.values(ec);
  const rows = entries.filter((v) => v != null && typeof v === "object") as Record<string, unknown>[];

  if (rows.length === 0) return "";

  const lis = rows.slice(0, 8).map((row) => {
    const nm = typeof row.name === "string" ? escHtml(row.name.trim()) : "";
    let ph = "";
    if (typeof row.phone === "string" && row.phone.trim() !== "") {
      const raw = row.phone.trim();
      const href = raw.replace(/[^\d+]/g, "");
      if (href.length >= 6) {
        ph = `<a href="tel:${href}">${escHtml(raw)}</a>`;
      } else ph = escHtml(raw);
    }
    if (nm && ph) return `<li>${nm} · ${ph}</li>`;
    return `<li>${nm || ph}</li>`;
  }).join("");

  return lis ? `<ul>${lis}</ul>` : "";
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
      },
    });
  }

  if (req.method !== "GET") {
    return new Response("Method not allowed", { status: 405 });
  }

  const url = new URL(req.url);
  const token = url.searchParams.get("t")?.trim() ?? "";

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  if (!supabaseUrl || !serviceKey || !token) {
    return htmlResponse(
      "<!DOCTYPE html><html><head><meta charset=\"utf-8\"/></head><body><p>Missing token or configuration.</p></body></html>",
      400,
    );
  }

  const supabase = createClient(supabaseUrl, serviceKey);

  const { data: rawRpc, error } = await supabase.rpc("record_qr_scan_and_fetch_emergency", {
    p_qr_payload: `qlink://qr/${token}`,
  });

  let data: Record<string, unknown> | null = null;
  if (typeof rawRpc === "string") {
    try {
      data = JSON.parse(rawRpc) as Record<string, unknown>;
    } catch {
      data = null;
    }
  } else if (rawRpc && typeof rawRpc === "object") {
    data = rawRpc as Record<string, unknown>;
  }

  if (error || data === null || data.ok !== true) {
    const msg = error ? String((error as { message?: string }).message ?? error) : "";
    const body404 =
      "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"/><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"/></head>" +
      "<body style=\"font-family:system-ui;padding:24px;background:#131a2a;color:#eee\">" +
      "<p>Profile not found or link invalid.</p>" +
      (msg ? `<p style=\"opacity:.65;font-size:12px\">${escHtml(msg)}</p>` : "") +
      "</body></html>";
    return htmlResponse(body404, 404);
  }

  const profile = data.profile as Record<string, unknown> | undefined;
  if (!profile || typeof profile !== "object") {
    return htmlResponse(
      "<!DOCTYPE html><html><head><meta charset=\"utf-8\"/></head><body><p>Invalid server response.</p></body></html>",
      500,
    );
  }

  const guardianId = profile.guardian_id != null ? String(profile.guardian_id) : "";
  const profileId = profile.id != null ? String(profile.id) : "";
  if (guardianId && profileId) {
    const { error: notifyErr } = await supabase.from("notifications").insert({
      id: crypto.randomUUID(),
      guardian_id: guardianId,
      profile_id: profileId,
      title: "Bracelet scanned",
      body: `Emergency link opened for ${String(profile.profile_name ?? "profile")}`,
      type: "qr_scan",
      is_read: false,
    });
    if (notifyErr) {
      // Table / RLS may differ per project; page still works without notification.
      console.warn("[public-emergency] notification insert:", notifyErr);
    }
  }

  const name = escHtml(profile["profile_name"]);
  const blood = escHtml(profile["blood_type"]);
  const allergies = escHtml(profile["allergies_en"]);
  const med = String(profile["medical_notes_en"] ?? "").trim();
  const safe = String(profile["safety_notes_en"] ?? "").trim();
  const notes = escHtml(med || safe || "");
  const relation = escHtml(profile["relationship_to_guardian"]);
  const birthYear = profile["birth_year"];
  let ageLine = "";
  if (typeof birthYear === "number" && birthYear >= 1900 && birthYear <= new Date().getFullYear()) {
    const age = new Date().getFullYear() - birthYear;
    if (age >= 0 && age <= 130) {
      ageLine = `<p class="muted">Birth year: ${escHtml(birthYear)} (age ~${age})</p>`;
    }
  }

  const contactsUl = buildContactsUl(profile["emergency_contacts"]);

  const html =
    `<!DOCTYPE html><html lang="en"><head>` +
    `<meta charset="utf-8"/>` +
    `<meta name="viewport" content="width=device-width,initial-scale=1"/>` +
    `<title>${name} · Emergency · QLink</title>` +
    `<style>body{font-family:system-ui,sans-serif;background:#131a2a;color:#eee;padding:24px;max-width:520px;margin:0 auto;line-height:1.45}` +
    `a{color:#93c5fd}.card{border-radius:16px;padding:16px;margin:14px 0;background:#1e293b}` +
    `.muted{color:#94a3b8;font-size:.9rem}h1{font-size:1.35rem;margin:8px 0 4px;color:#fff}ul{padding-left:1.1rem}</style>` +
    `</head><body>` +
    `<header><span class="muted">QLink · Emergency</span><h1>${name}</h1>` +
    (relation ? `<p class="muted">${relation}</p>` : "") +
    `${ageLine}</header>` +
    `<div class="card"><strong>Blood type</strong><p>${blood || "—"}</p></div>` +
    `<div class="card"><strong>Allergies</strong><p>${allergies || "—"}</p></div>` +
    `<div class="card"><strong>Medical notes</strong><p>${notes || "—"}</p></div>` +
    (contactsUl ? `<div class="card"><strong>Emergency contacts</strong>${contactsUl}</div>` : "") +
    `<p class="muted">Scan this QR with the QLink app for the full emergency screen and dial buttons.</p>` +
    `</body></html>`;

  return htmlResponse(html, 200);
});
