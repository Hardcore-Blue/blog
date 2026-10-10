#!/usr/bin/env bash
# Rebuilds tradecraft.html from the PDFs in tradecraft/
# Run from the site folder: bash make-tradecraft.sh
# PDF names may use letters, numbers, dot, dash and underscore only (no spaces).

shopt -s nullglob

if [[ ! -d tradecraft ]]; then
    printf 'No tradecraft/ folder here. Run this from the site folder.\n' >&2
    exit 1
fi

# Friendly titles. Add one line per PDF; anything missing uses the file name.
declare -A nice=(
    [Pragmatic.pdf]="The Pragmatic Programmer"
    [RTFM.pdf]="Red Team Field Manual v2"
)

out=tradecraft.html
count=0

{
cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tradecraft - Hardcore Blue Forensic Dev</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="article-top">
    <a href="index.html">HARDCORE BLUE</a>
    <a href="index.html">← Home</a>
  </div>
  <div class="article-shell">
    <div class="article-meta">Tradecraft</div>
    <article>
      <h1>Tradecraft</h1>
      <p><strong>by j4ck13</strong></p>
      <p>Cheat sheets and reference books. Open one to read it here, or download a copy.</p>
HEAD

for f in tradecraft/*.pdf; do
    name=${f##*/}
    if [[ ! $name =~ ^[A-Za-z0-9._-]+$ ]]; then
        printf 'Skipping (use only letters, numbers, . - _ in the name): %s\n' "$name" >&2
        continue
    fi
    title=${nice[$name]:-}
    if [[ -z $title ]]; then
        title=${name%.pdf}
        title=${title//[-_]/ }
    fi
    size=$(du -h --apparent-size "$f" | cut -f1)
    count=$((count + 1))
    cat <<ENTRY
      <details class="pdf">
        <summary><span>$title</span><span class="size">$size</span></summary>
        <p>
          <a class="btn" href="tradecraft/$name" download>Download</a>
          <a class="btn" href="tradecraft/$name" target="_blank" rel="noopener">Open in new tab</a>
        </p>
        <iframe class="pdf-frame" src="tradecraft/$name" title="$title" loading="lazy"></iframe>
      </details>
ENTRY
done

if [[ $count -eq 0 ]]; then
    printf '      <p>No PDFs yet.</p>\n'
fi

cat <<'TAIL'
    </article>
  </div>
</body>
</html>
TAIL
} > "$out"

printf 'Built %s with %s PDF(s).\n' "$out" "$count"
