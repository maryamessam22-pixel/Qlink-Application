/// <reference path="./edge.d.ts" />
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
    },
  });
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return jsonResponse({ ok: true });
  if (req.method !== "POST") return jsonResponse({ ok: false, error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();

  if (!supabaseUrl || !serviceKey || !jwt) {
    return jsonResponse({ ok: false, error: "Missing authorization" }, 401);
  }

  const supabase = createClient(supabaseUrl, serviceKey);
  const { data: userData, error: userError } = await supabase.auth.getUser(jwt);
  const wearer = userData?.user;
  if (userError || !wearer) {
    return jsonResponse({ ok: false, error: "Invalid user" }, 401);
  }

  const body = await req.json().catch(() => ({})) as Record<string, unknown>;
  const title = String(body.title ?? "QLink Alert").slice(0, 120);
  const message = String(body.body ?? "").slice(0, 500);
  const type = String(body.type ?? "wearer_alert").slice(0, 80);

  const { data: links, error: linksError } = await supabase
    .from("wearer_link_requests")
    .select("guardian_id")
    .eq("wearer_id", wearer.id)
    .eq("status", "accepted");

  if (linksError) return jsonResponse({ ok: false, error: linksError.message }, 500);

  const guardianIds = Array.from(
    new Set((links ?? []).map((row) => String(row.guardian_id ?? "")).filter(Boolean)),
  );
  if (guardianIds.length === 0) return jsonResponse({ ok: true, count: 0 });

  const { data: profileRows } = await supabase
    .from("patient_profiles")
    .select("id, guardian_id, relationship_to_guardian")
    .in("guardian_id", guardianIds);

  const notifications = guardianIds.map((guardianId) => {
    const patientProfile = (profileRows ?? []).find((row) =>
      String(row.guardian_id ?? "") === guardianId &&
      String(row.relationship_to_guardian ?? "").toLowerCase() === "wearer"
    ) ?? (profileRows ?? []).find((row) => String(row.guardian_id ?? "") === guardianId);

    return {
      id: crypto.randomUUID(),
      guardian_id: guardianId,
      profile_id: String(patientProfile?.id ?? wearer.id),
      title,
      body: message,
      type,
      is_read: false,
    };
  });

  const { error: insertError } = await supabase.from("notifications").insert(notifications);
  if (insertError) return jsonResponse({ ok: false, error: insertError.message }, 500);

  return jsonResponse({ ok: true, count: notifications.length });
});
