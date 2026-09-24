// Computes/refreshes a profile's embedding for the recommendation system.
// Uses Gemini's free-tier "text-embedding-004" model (768 dimensions) —
// GEMINI_API_KEY must be set as a Supabase secret, never in frontend code.
//
// POST { user_id: string } -> embeds/updates one profile.
// POST { backfill: true }  -> embeds/updates every student profile
//                             (run manually once after the field migration).
//
// Note: unlike seed-demo-users, this function does NOT check the caller's
// identity via supabase.auth.getUser() — this app uses custom auth (no real
// Supabase Auth sessions), so that check would always fail. Gatekeeping here
// is the same as everywhere else in this schema: the Supabase platform's
// standard JWT check on the anon key, nothing more.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.74.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const GEMINI_MODEL = "text-embedding-004";
const MIN_BIO_LENGTH = 20;
const BACKFILL_PACING_MS = 200; // stay comfortably under the free-tier rate limit

async function sha256Hex(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

// "Major: {specialty}. Fields: IT: {..}; Business: {..}. Bio: {bio}"
// Skips empty parts; skips bio entirely if shorter than MIN_BIO_LENGTH.
async function buildProfileText(supabase: any, userId: string): Promise<string> {
  const [{ data: profile }, { data: fieldRows }] = await Promise.all([
    supabase.from("profiles").select("bio, specialties(name)").eq("id", userId).maybeSingle(),
    supabase
      .from("profile_fields")
      .select("fields(label, category_id, field_categories(label))")
      .eq("user_id", userId),
  ]);

  const parts: string[] = [];

  if (profile?.specialties?.name) {
    parts.push(`Major: ${profile.specialties.name}.`);
  }

  const byCategory = new Map<string, string[]>();
  for (const row of fieldRows ?? []) {
    const label = row.fields?.label;
    const categoryLabel = row.fields?.field_categories?.label ?? row.fields?.category_id;
    if (!label || !categoryLabel) continue;
    if (!byCategory.has(categoryLabel)) byCategory.set(categoryLabel, []);
    byCategory.get(categoryLabel)!.push(label);
  }
  if (byCategory.size > 0) {
    const grouped = Array.from(byCategory.entries())
      .map(([cat, labels]) => `${cat}: ${labels.join(", ")}`)
      .join("; ");
    parts.push(`Fields: ${grouped}.`);
  }

  const bio = (profile?.bio ?? "").trim();
  if (bio.length >= MIN_BIO_LENGTH) {
    parts.push(`Bio: ${bio}`);
  }

  return parts.join(" ").trim();
}

async function embedProfile(supabase: any, geminiKey: string, userId: string) {
  const text = await buildProfileText(supabase, userId);
  if (!text) {
    return { user_id: userId, skipped: true, reason: "no embeddable content" };
  }

  const hash = await sha256Hex(text);

  const { data: existing } = await supabase
    .from("profile_embeddings")
    .select("source_hash")
    .eq("user_id", userId)
    .maybeSingle();

  if (existing?.source_hash === hash) {
    return { user_id: userId, skipped: true, reason: "unchanged" };
  }

  const resp = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:embedContent?key=${geminiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: `models/${GEMINI_MODEL}`,
        content: { parts: [{ text }] },
        taskType: "SEMANTIC_SIMILARITY",
      }),
    },
  );

  if (!resp.ok) {
    throw new Error(`Gemini embedContent failed (${resp.status}): ${await resp.text()}`);
  }

  const json = await resp.json();
  const values = json?.embedding?.values;
  if (!Array.isArray(values)) {
    throw new Error("Gemini response missing embedding.values");
  }

  const { error } = await supabase.from("profile_embeddings").upsert({
    user_id: userId,
    embedding: values,
    source_hash: hash,
    updated_at: new Date().toISOString(),
  });
  if (error) throw error;

  return { user_id: userId, skipped: false };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) {
      return new Response(JSON.stringify({ error: "GEMINI_API_KEY is not configured" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const body = await req.json().catch(() => ({}));

    if (body.backfill) {
      const { data: profiles, error } = await supabase
        .from("profiles")
        .select("id")
        .eq("account_type", "student");
      if (error) throw error;

      const results: any[] = [];
      for (const p of profiles ?? []) {
        try {
          results.push(await embedProfile(supabase, geminiKey, p.id));
        } catch (e) {
          results.push({ user_id: p.id, error: String((e as any)?.message ?? e) });
        }
        await new Promise((r) => setTimeout(r, BACKFILL_PACING_MS));
      }

      return new Response(JSON.stringify({ processed: results.length, results }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!body.user_id) {
      return new Response(JSON.stringify({ error: "user_id is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const result = await embedProfile(supabase, geminiKey, body.user_id);
    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("[embed-profile] error:", err);
    return new Response(JSON.stringify({ error: String((err as any)?.message ?? err) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
