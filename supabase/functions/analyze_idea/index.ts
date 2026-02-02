// import { createClient } from "@supabase/supabase-js";

// const corsHeaders = {
//     "Access-Control-Allow-Origin": "*",
//     "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
//     "Access-Control-Allow-Methods": "POST, OPTIONS",
// };

// Deno.serve(async (req: Request) => {
//     if (req.method === "OPTIONS") {
//         return new Response("ok", { headers: corsHeaders });
//     }

//     try {
//         let body;
//         try {
//             body = await req.json();
//         } catch {
//             throw new Error("Invalid JSON body");
//         }

//         const { ideaId } = body;
//         if (!ideaId) throw new Error("Missing ideaId");

//         const supabaseUrl = Deno.env.get("SUPABASE_URL");
//         const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

//         if (!supabaseUrl || !serviceKey) {
//             throw new Error("Supabase environment variables are missing");
//         }

//         const supabaseAdmin = createClient(supabaseUrl, serviceKey);

//         const { data: idea, error } = await supabaseAdmin
//             .from("ideas")
//             .select("title, description, problem_statement, target_market, current_stage, tags")
//             .eq("id", ideaId)
//             .single();

//         if (error || !idea) throw new Error("Idea not found");

//         const prompt = `
// Analyze this startup idea for an investor report.
// Return strictly valid JSON only.

// Title: ${idea.title}
// Description: ${idea.description}
// Problem: ${idea.problem_statement}
// Target Market: ${idea.target_market}
// Stage: ${idea.current_stage}
// Tags: ${Array.isArray(idea.tags) ? idea.tags.join(", ") : idea.tags}

// JSON FORMAT:
// {
//   "investment_summary": "string",
//   "market_potential": "Low|Medium|High",
//   "execution_risk": "Low|Medium|High",
//   "strengths": ["string"],
//   "risks": ["string"],
//   "ai_score": number
// }
// `;

//         let finalResult = {
//             investment_summary: `Strong potential in ${idea.target_market}.`,
//             market_potential: "High",
//             execution_risk: "Medium",
//             strengths: ["Clear value proposition"],
//             risks: ["Market competition"],
//             ai_score: 80,
//         };

//         // Use provided key or env var fallback
//         const apiKey = Deno.env.get("GEMINI_API_KEY");

//         if (apiKey) {
//             const response = await fetch(
//                 `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
//                 {
//                     method: "POST",
//                     headers: { "Content-Type": "application/json" },
//                     body: JSON.stringify({
//                         contents: [{ parts: [{ text: prompt }] }],
//                         generationConfig: { response_mime_type: "application/json" },
//                     }),
//                 }
//             );

//             if (response.ok) {
//                 const data = await response.json();
//                 const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
//                 if (text) {
//                     const cleaned = text.replace(/```json|```/g, "").trim();
//                     finalResult = JSON.parse(cleaned);
//                 }
//             }
//         }

//         const { error: updateError } = await supabaseAdmin
//             .from("ideas")
//             .update({
//                 ai_investment_summary: finalResult.investment_summary,
//                 ai_market_potential: finalResult.market_potential,
//                 ai_execution_risk: finalResult.execution_risk,
//                 ai_strengths: finalResult.strengths,
//                 ai_risks: finalResult.risks,
//                 ai_score: finalResult.ai_score,
//                 ai_last_analyzed_at: new Date().toISOString(),
//             })
//             .eq("id", ideaId);

//         if (updateError) throw updateError;

//         return new Response(
//             JSON.stringify({ success: true, data: finalResult }),
//             { headers: { ...corsHeaders, "Content-Type": "application/json" } }
//         );
//     } catch (err: any) {
//         return new Response(
//             JSON.stringify({ error: err.message ?? "Unknown error" }),
//             { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
//         );
//     }
// });
