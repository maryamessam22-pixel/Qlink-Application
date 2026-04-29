// Deno Deploy / Supabase Edge Function — opens in any mobile browser after camera scan.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

/** Use a UTF-8 string body + explicit MIME; some stacks default `Content-Type` to text/plain otherwise. */
function htmlUtf8(html: string, status: number): Response {
  const headers = new Headers();
  headers.set("Content-Type", "text/html; charset=utf-8");
  headers.set("Cache-Control", "private, max-age=0, no-store");
  headers.set("Pragma", "no-cache");
  return new Response(html, { status, headers });
}

function escHtml(s: string | number | boolean | null | undefined): string {
  if (s === null || s === undefined) return "";
  const t = String(s);
  return t
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
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
    return htmlUtf8("<!DOCTYPE html><html><body><p>Missing token or configuration.</p></body></html>", 400);
  }

  const supabase = createClient(supabaseUrl, serviceKey);

  const { data: rawRpc, error } = await supabase.rpc("record_qr_scan_and_fetch_emergency", {
    p_qr_payload: `qlink://qr/${token}`,
  });

  // PostgREST may return jsonb already parsed OR as JSON string depending on runtime.
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

  const ok = data?.ok === true;

  if (error || !ok) {
    const msg = error ? String((error as { message?: string }).message ?? error) : "";
    const body404 =
      "<!DOCTYPE html><html><body style=\"font-family:system-ui;padding:24px;background:#131a2a;color:#eee\">" +
      "<p>Profile not found or link invalid.</p>" +
      (msg ? `<p style=\"opacity:.65;font-size:12px\">${escHtml(msg)}</p>` : "") +
      "</body></html>";
    return htmlUtf8(body404, 404);
  }

  const profile = data.profile as Record<string, unknown> | undefined;
  if (!profile) {
    return htmlUtf8(
      "<!DOCTYPE html><html><body style=\"padding:24px\"><p>Invalid server response.</p></body></html>",
      500,
    );
  }

  const name = escHtml(profile.profile_name);
  const blood = escHtml(profile.blood_type);
  const allergies = escHtml(profile.allergies_en);
  const notes = escHtml(profile.medical_notes_en);
  let contactsUl = "";

  const ec = profile.emergency_contacts;
  if (ec && typeof ec === "object" && ec !== null) {
    const entries = Object.values(ec as Record<string, unknown>);
    const rows = entries.filter((v) => v != null && typeof v === "object") as Record<
      string,
      unknown
    >[];
    contactsUl =
      "<ul>" +
      rows.slice(0, 8).map((row) => {
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
      }).join("") +
      "</ul>";
  }

  const html =
    `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/><title>${name} · Emergency · QLink</title>
<style>body{font-family:system-ui,sans-serif;background:#131a2a;color:#eee;padding:24px;max-width:480px;margin:0 auto;line-height:1.45}a{color:#93c5fd}.card{border-radius:16px;padding:16px;margin:16px 0;background:#1e293b}.muted{color:#94a3b8;font-size:.9rem}h1{font-size:1.35rem;margin:8px 0 4px;color:#fff}</style></head><body>` +
    `<header><span class="muted">QLink emergency</span><h1>${name}</h1></header>` +
    `<div class="card"><strong>Blood type</strong><p>${blood || "—"}</p></div>` +
    `<div class="card"><strong>Allergies</strong><p>${allergies || "—"}</p></div>` +
    `<div class="card"><strong>Medical notes</strong><p>${notes || "—"}</p></div>` +
    (contactsUl ? `<div class="card"><strong>Emergency contacts</strong>${contactsUl}</div>` : "") +
    `<p class="muted">If you use the QLink app, you can scan the same QR with the in-app scanner for the full experience.</p></body></html>`;

  return htmlUtf8(html, 200);
});
