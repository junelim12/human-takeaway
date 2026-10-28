#!/usr/bin/env bash
# Wrap src/app.html (artifact-style fragment) into a full HTML document for static hosting,
# and write public/config.js from SUPABASE_URL / SUPABASE_ANON_KEY (both safe to expose;
# row-level security in supabase/schema.sql protects the data).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p public
printf 'window.HT_CONFIG = { supabaseUrl: "%s", supabaseAnonKey: "%s" };\n' "${SUPABASE_URL:-}" "${SUPABASE_ANON_KEY:-}" > public/config.js
{
  printf '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
  printf '<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%%}[hidden]{display:none!important}</style>\n'
  printf '<script src="config.js"></script>\n</head>\n<body>\n'
  cat src/app.html
  printf '\n</body>\n</html>\n'
} > public/index.html
echo "built public/index.html"
