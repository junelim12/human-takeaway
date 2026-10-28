// Vercel serverless function: POST /api/transcribe
// Body: raw audio bytes. Headers: Content-Type (audio/*), X-Filename (URI-encoded).
// Env:  OPENAI_API_KEY (Whisper speech-to-text). Swap in Deepgram/AssemblyAI here if preferred.
// Note: Vercel limits request bodies to about 4.5 MB. For longer recordings, upload
// straight to storage (e.g. Vercel Blob / S3) and transcribe from the URL instead.

export const config = { api: { bodyParser: false } };

async function readBody(req) {
  const chunks = [];
  for await (const c of req) chunks.push(c);
  return Buffer.concat(chunks);
}

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "POST only" });
  if (!process.env.OPENAI_API_KEY) return res.status(500).json({ error: "OPENAI_API_KEY is not set" });

  const buf = await readBody(req);
  if (!buf.length) return res.status(400).json({ error: "empty file" });
  if (buf.length > 25 * 1024 * 1024) return res.status(413).json({ error: "file too large" });

  const name = decodeURIComponent(req.headers["x-filename"] || "audio.m4a");
  const type = req.headers["content-type"] || "application/octet-stream";

  const form = new FormData();
  form.append("file", new Blob([buf], { type }), name);
  form.append("model", process.env.STT_MODEL || "whisper-1");
  form.append("response_format", "text");

  try {
    const r = await fetch("https://api.openai.com/v1/audio/transcriptions", {
      method: "POST",
      headers: { Authorization: `Bearer ${process.env.OPENAI_API_KEY}` },
      body: form,
    });
    if (!r.ok) return res.status(502).json({ error: "transcription failed", status: r.status });
    const text = (await r.text()).trim();
    return res.status(200).json({ text });
  } catch (e) {
    return res.status(502).json({ error: String(e.message || e) });
  }
}
