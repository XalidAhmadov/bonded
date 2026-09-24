// Seeds 4 demo users + a 1:1 chat between the calling user and each demo user.
// Idempotent: re-running won't duplicate users or chats.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.74.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const DEMOS = [
  {
    email: "emma.demo@bonded.app",
    first_name: "Emma",
    last_name: "Wilson",
    university: "Stanford University",
    major: "Computer Science",
    year: "Junior",
    intro: "Hey! How was the lecture today?",
  },
  {
    email: "james.demo@bonded.app",
    first_name: "James",
    last_name: "Chen",
    university: "Stanford University",
    major: "Mathematics",
    year: "Senior",
    intro: "Thanks for the notes! Lifesaver 🙏",
  },
  {
    email: "sofia.demo@bonded.app",
    first_name: "Sofia",
    last_name: "Rodriguez",
    university: "Stanford University",
    major: "Design",
    year: "Sophomore",
    intro: "See you at the library at 4?",
  },
  {
    email: "marcus.demo@bonded.app",
    first_name: "Marcus",
    last_name: "Johnson",
    university: "Stanford University",
    major: "Electrical Engineering",
    year: "Junior",
    intro: "Just submitted the assignment 🎉",
  },
];

const DEMO_PASSWORD = "demo-password-1234!";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const auth = req.headers.get("Authorization");
    if (!auth) {
      return new Response(JSON.stringify({ error: "Missing auth" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ??
      Deno.env.get("SUPABASE_PUBLISHABLE_KEY")!;

    // who is calling?
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: auth } },
    });
    const { data: userData, error: uerr } = await userClient.auth.getUser();
    if (uerr || !userData.user) {
      return new Response(JSON.stringify({ error: "Not authenticated" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const callerId = userData.user.id;

    const admin = createClient(supabaseUrl, serviceKey);

    const created: Array<{ id: string; first_name: string; chat_id: string }> = [];

    for (const demo of DEMOS) {
      // 1) Find or create the demo user
      let demoId: string | null = null;

      const { data: list } = await admin.auth.admin.listUsers({
        page: 1,
        perPage: 200,
      });
      const existing = list?.users.find((u) => u.email === demo.email);
      if (existing) {
        demoId = existing.id;
      } else {
        const { data: newUser, error: cerr } = await admin.auth.admin.createUser({
          email: demo.email,
          password: DEMO_PASSWORD,
          email_confirm: true,
          user_metadata: {
            first_name: demo.first_name,
            last_name: demo.last_name,
            university: demo.university,
          },
        });
        if (cerr || !newUser.user) {
          console.error("createUser failed", demo.email, cerr);
          continue;
        }
        demoId = newUser.user.id;
      }

      // 2) Make sure profile is up to date
      await admin.from("profiles").upsert({
        id: demoId,
        first_name: demo.first_name,
        last_name: demo.last_name,
        university: demo.university,
        major: demo.major,
        year: demo.year,
        avatar_url: `https://api.dicebear.com/7.x/avataaars/svg?seed=${demo.first_name}&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf`,
      });

      // 3) Find existing 1:1 chat between caller and demo
      const { data: callerChats } = await admin
        .from("chat_participants")
        .select("chat_id")
        .eq("user_id", callerId);
      const callerChatIds = (callerChats ?? []).map((c) => c.chat_id);

      let chatId: string | null = null;
      if (callerChatIds.length > 0) {
        const { data: shared } = await admin
          .from("chat_participants")
          .select("chat_id")
          .eq("user_id", demoId)
          .in("chat_id", callerChatIds);
        if (shared && shared.length > 0) chatId = shared[0].chat_id;
      }

      if (!chatId) {
        const { data: newChat, error: chatErr } = await admin
          .from("chats")
          .insert({})
          .select("id")
          .single();
        if (chatErr || !newChat) {
          console.error("chat insert failed", chatErr);
          continue;
        }
        chatId = newChat.id;

        await admin.from("chat_participants").insert([
          { chat_id: chatId, user_id: callerId },
          { chat_id: chatId, user_id: demoId },
        ]);

        await admin.from("messages").insert({
          chat_id: chatId,
          sender_id: demoId,
          body: demo.intro,
        });
      }

      created.push({ id: demoId!, first_name: demo.first_name, chat_id: chatId! });
    }

    return new Response(
      JSON.stringify({ ok: true, demos: created, password: DEMO_PASSWORD }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
