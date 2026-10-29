#!/usr/bin/env bash
# Wrap src/app.html (artifact-style fragment) into a full HTML document for static hosting,
# and write public/config.js from SUPABASE_URL / SUPABASE_ANON_KEY. Defaults point at the
# Human Takeaway project; both values are public by design (row-level security protects the data).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p public
cp assets/favicon.svg assets/app-icon.svg public/
printf 'window.HT_CONFIG = { supabaseUrl: "%s", supabaseAnonKey: "%s" };\n' "${SUPABASE_URL:-https://rzgxfjlkfngamtkxwtwb.supabase.co}" "${SUPABASE_ANON_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6Z3hmamxrZm5nYW10a3h3dHdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMxNjc5OTUsImV4cCI6MjEwODc0Mzk5NX0.xSznE47hlxFN3eAZrZ_TM0Zz74MfKrTXXoYmHVpZH64}" > public/config.js
{
  printf '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
  printf '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%%}[hidden]{display:none!important}</style>\n'
  printf '<link rel="icon" type="image/svg+xml" href="favicon.svg">\n<link rel="apple-touch-icon" href="app-icon.svg">\n<script src="config.js"></script>\n</head>\n<body>\n'
  cat src/app.html
  printf '\n</body>\n</html>\n'
} > public/index.html
echo "built public/index.html"
