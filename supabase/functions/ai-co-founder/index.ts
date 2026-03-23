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
        // Accept history and context_id
        const { message, history, context_id, mode } = await req.json();

        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabase = createClient(supabaseUrl, serviceKey);

        // 1. Fetch Context (Idea Data)
        let contextData = "No specific idea selected.";
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

        // 2. Format History
        let historyText = "";
        if (history && Array.isArray(history)) {
            // Limit to last 10 interactions to avoid token limits
            const recentHistory = history.slice(-10);
            historyText = recentHistory.map((h: any) => `${h.role === 'user' ? 'User' : 'AI'}: ${h.text}`).join("\n");
        }

        // 3. Construct System Prompt
        const systemPrompt = `
You are an AI Co-Founder for the user's startup. 
Mode: ${mode || 'Strategic Advisor'}.

Your goal is to provide actionable, critical, and supportive guidance suitable for a startup founder.
Use the provided Context and Conversation History to ensure your response is relevant and persistent.

Context:
${contextData}

Conversation History:
${historyText}

Current User Message: ${message}

Output Requirement:
You MUST respond in valid JSON format ONLY. Do not include markdown blocks like \`\`\`json.
Structure:
{
  "reply": "Your primary conversational response here (friendly, professional, under 200 words).",
  "insights": ["Key business insight 1", "Key business insight 2"],
  "action_items": ["Action 1", "Action 2"],
  "risks": ["Potential risk 1", "Potential risk 2"]
}
`;

        const apiKey = Deno.env.get("GEMINI_API_KEY");
        if (!apiKey) {
            throw new Error("GEMINI_API_KEY is not set");
        }

        // 4. Call Gemini API
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: systemPrompt }] }],
                    generationConfig: {
                        response_mime_type: "application/json",
                        maxOutputTokens: 1000,
                        temperature: 0.7,
                    },
                }),
            }
        );

        if (!response.ok) {
            const errText = await response.text();
            throw new Error(`Gemini API Error: ${response.status} ${errText}`);
        }

        const data = await response.json();
        let replyJsonString = data.candidates?.[0]?.content?.parts?.[0]?.text || "{}";

        // Cleanup potential markdown
        replyJsonString = replyJsonString.replace(/```json/g, "").replace(/```/g, "").trim();

        let parsedResponse;
        try {
            parsedResponse = JSON.parse(replyJsonString);
        } catch (e) {
            // Fallback if JSON parsing fails
            parsedResponse = {
                reply: replyJsonString,
                insights: [],
                action_items: [],
                risks: []
            };
        }

        return new Response(
            JSON.stringify(parsedResponse),
            { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );

    } catch (err: any) {
        return new Response(
            JSON.stringify({ error: err.message ?? "Unknown error" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
});
