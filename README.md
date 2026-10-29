# Human Takeaway

**You write the takeaway. AI spreads it.**

Upload a recording or transcript of a talk, panel or meeting, type the one line that stayed with you, and get an X post and a LinkedIn post built around your own words. Every line you write is kept and tagged by industry and function, so over time it becomes a record of what you have learned.

Built for people in the Bay Area startup scene (job seekers, marketers, founders, builders) who go to a lot of events and want to post about them consistently without sounding like AI.

## How it works

1. **Upload** audio (.m4a, .mp3, .wav) or a transcript (.txt, .srt, .vtt). Pasting text also works. Subtitle timestamps are stripped automatically.
2. **Pick who you're writing as**:
   - **Job seeker**: shows how you think, so hiring managers notice.
   - **Marketer**: puts the spotlight on the company or product behind the event (most Bay Area events exist to promote the host or the companies it features). Names the product and shows one concrete thing it does.
   - **Founder**: takes a clear position tied to what they are building, earning trust from customers, hires and investors, without pitching the product.
   - **Builder**: for engineers, designers and indie hackers. Connects the line to the craft: what it changes about how you build, ship or pick tools.
   - For Marketer, you can name the company or product to spotlight. Left blank, the host or the most-discussed company in the transcript is used.
3. **Type your one line** (up to 140 characters). Pasting is disabled in this field on purpose: the line has to be written by you, and everything else is built around it.
4. **Name the event and tag it**: type the event name however you call it. The posts judge how to use it: a recognizable public name may be mentioned once, while a private label (dates, abbreviations) is turned into a natural description instead of being copied. Industry and function tags are suggested from the transcript and can be changed.
5. **Choose how posts end**: the "End with a suggestion" switch is off by default, so posts end on your own thought with no ask. Turn it on for one short call to action that fits your role (try the product, talk with people working on this, join people who care about the problem). Flipping it on the results screen rewrites the current post.
6. **Get your posts** in two tabs:
   - **X**: one short post, your line polished to sound native to X (ideally under 140 characters). "Copy & open X" opens the composer with it filled in.
   - **LinkedIn**: one post with a preview of what shows before "see more" and a character count.
   - Rewrites: Shorter / Punchier / Drier / Another take on X; Shorter / Sharper opening / More personal / More casual on LinkedIn.
7. **My lines**: every line you have written, with date, event and tags. Filter by industry or function, see where your thinking concentrates, and reopen the posts made from any line. Each line is Private by default; switch it to Public to share it (public lines will power per-event pages and the host view next).

How posts are written: a planning pass first restates what your line claims and picks at most two details from the transcript that directly prove it (rejecting vivid but off-topic or contradictory ones, and anything that may be a transcription error). The writers only see that plan, not the raw transcript. Each writer drafts, checks every sentence against the thesis, and returns the edited version.

Design: monochrome, one large stage panel with a column of cards on the right. Light and dark themes.

## Project structure

```
src/app.html         The whole app (HTML/CSS/JS in one file). Can be published as-is as a claude.ai Artifact.
public/index.html    Standalone page for your own site (build.sh wraps src/app.html in a full HTML document).
api/generate.js      Post generation via the Anthropic API (ANTHROPIC_API_KEY).
api/transcribe.js    Speech-to-text via the OpenAI Whisper API (OPENAI_API_KEY).
supabase/schema.sql  Database table and row-level security.
vercel.json          Build command and output folder for Vercel.
build.sh             Builds public/index.html.
```

The app detects where it is running:

- **Inside a claude.ai Artifact**: posts are written with the viewer's own Claude account. Audio files show a waveform and duration, but transcription is not available there, so the app asks for a transcript instead.
- **On your own site**: it calls the `/api/generate` and `/api/transcribe` serverless functions.

## Accounts and storage

Lines are saved to the signed-in user's account:

- **Inside a claude.ai Artifact**: the viewer's Claude account, in the artifact's private per-user storage. Nothing to set up.
- **On your own site**: Google sign-in and a Postgres table through [Supabase](https://supabase.com). Signed-out visitors can still use the app; their lines stay in the browser and move to their account when they sign in.

The Supabase project is already set up with the `lines` table and row-level security (`supabase/schema.sql`), and `build.sh` points at it by default. One step is left, in the dashboard:

1. **Google sign-in.** Google Cloud Console → APIs & Services → Credentials → Create OAuth client ID (type "Web application"), with this authorized redirect URI:
   `https://rzgxfjlkfngamtkxwtwb.supabase.co/auth/v1/callback`
   Then Supabase → Authentication → Providers → Google: enable it and paste the client ID and secret.
2. **Your domain.** Once the site has a URL, add it under Authentication → URL Configuration (Site URL and redirect allow list).

To use a different Supabase project, run `supabase/schema.sql` there and set `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Deploying to your site (Vercel)

```bash
vercel                             # or import the GitHub repo in the Vercel dashboard
vercel env add ANTHROPIC_API_KEY
vercel env add OPENAI_API_KEY      # only needed for audio transcription
```

`vercel.json` runs `./build.sh`, which builds `public/index.html` and writes `public/config.js` with the Supabase URL and public key.

Optional environment variables: `ANTHROPIC_MODEL` (default `claude-sonnet-5-5`), `ANTHROPIC_MODEL_QUICK` (default `claude-haiku-5-5`), `ANTHROPIC_MODEL_COMPLEX` (default `claude-opus-5-5`, used for the final writing pass), `STT_MODEL` (default `whisper-1`).

Notes:

- Vercel limits serverless request bodies to about 4.5 MB. For longer recordings, upload to storage first (Vercel Blob, S3) and transcribe from the URL.
- `api/generate.js` has a simple per-IP limit (30 requests per hour). For a public demo, also set monthly spend limits in the Anthropic and OpenAI consoles.

## Current limitations

- Paste blocking stops paste and drag-and-drop, but not voice dictation or browser extensions.
- No usage analytics yet.

## Next steps

1. Test with about 10 people: completion rate from upload to posts, copy/open rate, which rewrite buttons get used.
2. Log usage events to a server.
4. Learn each person's writing voice from their past posts.
5. Bring back the proactive check-in after events (SMS or email).
