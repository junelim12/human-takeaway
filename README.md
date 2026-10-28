# Human Takeaway

**You write the takeaway. AI spreads it.**

Upload a recording or transcript of a talk, panel or meeting, type the one line that stayed with you, and get an X post and a LinkedIn post built around your own words. Every line you write is kept and tagged by industry and function, so over time it becomes a record of what you have learned.

Built for people in the Bay Area startup scene (job seekers, marketers, founders) who go to a lot of events and want to post about them consistently without sounding like AI.

## How it works

1. **Upload** audio (.m4a, .mp3, .wav) or a transcript (.txt, .srt, .vtt). Pasting text also works. Subtitle timestamps are stripped automatically.
2. **Pick who you're writing as**: Job seeker, Marketer or Founder. This changes the angle of the posts, never the facts.
3. **Type your one line** (up to 140 characters). Pasting is disabled in this field on purpose: the line has to be written by you, and everything else is built around it.
4. **Tag the event**: event name, industry and function are suggested from the transcript and can be changed.
5. **Get your posts** in two tabs:
   - **X**: one short post, your line polished to sound native to X (ideally under 140 characters). "Copy & open X" opens the composer with it filled in.
   - **LinkedIn**: one post with a preview of what shows before "see more" and a character count.
   - Rewrites: Shorter / Punchier / Drier / Another take on X; Shorter / Sharper opening / More personal / More casual on LinkedIn.
6. **My lines**: every line you have written, with date, event and tags. Filter by industry or function, see where your thinking concentrates, and reopen the posts made from any line.

Design: monochrome, one large stage panel with a column of cards on the right. Light and dark themes.

## Project structure

```
src/app.html         The whole app (HTML/CSS/JS in one file). Can be published as-is as a claude.ai Artifact.
public/index.html    Standalone page for your own site (build.sh wraps src/app.html in a full HTML document).
api/generate.js      Post generation via the Anthropic API (ANTHROPIC_API_KEY).
api/transcribe.js    Speech-to-text via the OpenAI Whisper API (OPENAI_API_KEY).
build.sh             Builds public/index.html.
```

The app detects where it is running:

- **Inside a claude.ai Artifact**: posts are written with the viewer's own Claude account. Audio files show a waveform and duration, but transcription is not available there, so the app asks for a transcript instead.
- **On your own site**: it calls the `/api/generate` and `/api/transcribe` serverless functions.

## Deploying to your site (Vercel)

```bash
./build.sh
vercel                             # or import the GitHub repo in the Vercel dashboard
vercel env add ANTHROPIC_API_KEY
vercel env add OPENAI_API_KEY      # only needed for audio transcription
```

Optional environment variables: `ANTHROPIC_MODEL` (default `claude-sonnet-5-5`), `ANTHROPIC_MODEL_QUICK` (default `claude-haiku-5-5`), `STT_MODEL` (default `whisper-1`).

Notes:

- Vercel limits serverless request bodies to about 4.5 MB. For longer recordings, upload to storage first (Vercel Blob, S3) and transcribe from the URL.
- `api/generate.js` has a simple per-IP limit (30 requests per hour). For a public demo, also set monthly spend limits in the Anthropic and OpenAI consoles.

## Current limitations

- Data lives only in the browser's localStorage. There is no login or sync, so clearing browser data or switching devices loses your lines.
- Paste blocking stops paste and drag-and-drop, but not voice dictation or browser extensions.
- No usage analytics yet.

## Next steps

1. Test with about 10 people: completion rate from upload to posts, copy/open rate, which rewrite buttons get used.
2. Log usage events to a server.
3. Accounts and server-side storage for the line library.
4. Learn each person's writing voice from their past posts.
5. Bring back the proactive check-in after events (SMS or email).
