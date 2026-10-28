// Vercel serverless function: POST /api/generate
// Body: { prompt: string, json?: boolean, quick?: boolean, tier?: "complex" }
// Env:  ANTHROPIC_API_KEY (required), ANTHROPIC_MODEL / ANTHROPIC_MODEL_QUICK / ANTHROPIC_MODEL_COMPLEX (optional)

const MODEL = process.env.ANTHROPIC_MODEL || "claude-sonnet-5-5";
const MODEL_QUICK = process.env.ANTHROPIC_MODEL_QUICK || "claude-haiku-5-5";
const MODEL_COMPLEX = process.env.ANTHROPIC_MODEL_COMPLEX || "claude-opus-5-5";

// Very small in-memory rate limit per IP (resets when the function cold-starts).
const hits = new Map();
const LIMIT = 30; // requests per hour per IP

function parseJson(text) {
  try { return JSON.parse(text); } catch {}
  const fence = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  if (fence) { try { return JSON.parse(fence[1]); } catch {} }
  const start = text.search(/[\[{]/);
  const end = Math.max(text.lastIndexOf("}"), text.lastIndexOf("]"));
  if (start >= 0 && end > start) return JSON.parse(text.slice(start, end + 1));
  throw new Error("invalid_json");
}

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "POST only" });
  if (!process.env.ANTHROPIC_API_KEY) return res.status(500).json({ error: "ANTHROPIC_API_KEY is not set" });

  const ip = (req.headers["x-forwarded-for"] || "").split(",")[0] || "local";
  const hour = Math.floor(Date.now() / 3600e3);
  const k = ip + ":" + hour;
  hits.set(k, (hits.get(k) || 0) + 1);
  if (hits.get(k) > LIMIT) return res.status(429).json({ error: "rate_limited" });

  const { prompt, json = false, quick = false, tier = null } = req.body || {};
  if (typeof prompt !== "string" || !prompt.trim() || prompt.length > 120000) {
    return res.status(400).json({ error: "bad prompt" });
  }

  try {
    const r = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": process.env.ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: tier === "complex" ? MODEL_COMPLEX : quick ? MODEL_QUICK : MODEL,
        max_tokens: 4000,
        messages: [{ role: "user", content: prompt }],
      }),
    });
    if (!r.ok) return res.status(502).json({ error: "upstream_error", status: r.status });
    const data = await r.json();
    const text = (data.content || []).filter(b => b.type === "text").map(b => b.text).join("");
    const result = json ? parseJson(text) : text;
    return res.status(200).json({ result });
  } catch (e) {
    return res.status(502).json({ error: String(e.message || e) });
  }
}
