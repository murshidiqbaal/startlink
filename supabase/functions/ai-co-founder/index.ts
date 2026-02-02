import { createClient } from "@supabase/supabase-js";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const { message, context_id, mode } = await req.json();

        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabase = createClient(supabaseUrl, serviceKey);

        let contextData = "";
        if (context_id) {
            const { data: idea, error } = await supabase
                .from("ideas")
                .select("title, description, problem_statement, target_market, current_stage")
                .eq("id", context_id)
                .single();

            if (idea && !error) {
                contextData = `
Context (The user's startup idea):
- Title: ${idea.title}
- Problem: ${idea.problem_statement}
- Solution: ${idea.description}
- Target Market: ${idea.target_market}
- Stage: ${idea.current_stage}
`;
            }
        }

        const systemPrompt = `
You are an AI Co-Founder for the user's startup.
Persona/Mode: ${mode || 'Supportive & Critical'}.

Your role is to help the user refine their idea, point out blind spots, and suggest actionable next steps.
Be concise (under 150 words usually), direct, and conversational.
Do not be overly formal. Treat this as a brainstorming session between co-founders.

${contextData}

User: ${message}
AI Co-Founder:
`;

        const apiKey = Deno.env.get("GEMINI_API_KEY");
        if (!apiKey) {
            throw new Error("GEMINI_API_KEY is not set");
        }

        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: systemPrompt }] }],
                    generationConfig: {
                        response_mime_type: "text/plain",
                        maxOutputTokens: 500,
                    },
                }),
            }
        );

        if (!response.ok) {
            const errText = await response.text();
            throw new Error(`Gemini API Error: ${response.status} ${errText}`);
        }

        const data = await response.json();
        const replyText = data.candidates?.[0]?.content?.parts?.[0]?.text || "I'm pondering that... (No response)";

        return new Response(
            JSON.stringify({ reply: replyText }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );

    } catch (err: any) {
        return new Response(
            JSON.stringify({ error: err.message ?? "Unknown error" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
