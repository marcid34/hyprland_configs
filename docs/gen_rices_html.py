"""Generate RICES.html -- the feel-and-tone overview of every rice.

Self-contained: no external fonts, scripts or stylesheets, so it renders the
same opened from disk, served from GitHub Pages, or dropped in an issue.
Thumbnails and palette strips are read from docs/ next to it.
"""
import json, os, sys, html

rices = json.load(open(sys.argv[1]))
tags = json.load(open(sys.argv[2]))
OUT = os.path.expanduser("~/.config/rices/hyprland_configs/RICES.html")

GROUPS = [
    ("Signature", "The one this repo was built around.", ["kib-custom"]),
    ("Showcase",
     "Built to be looked at and read: a single Quickshell/QML codebase driving "
     "bar, dashboard and controls, with every figure on screen live.",
     ["qshell"]),
    ("Switchable",
     "One shape, more than one palette, swapped live from a control the rice "
     "puts on the desktop itself.",
     ["calamity"]),
    ("Designed atmospheres",
     "Rices where the layout changes, not just the colours — different bar "
     "shape, different launcher, different amount of chrome.",
     ["tokyonight", "rosepine", "kanagawa", "oxocarbon", "everforest",
      "amber", "outrun", "mono", "blueprint"]),
    ("Palette classics",
     "Faithful takes on palettes you already know, applied across every app.",
     ["nord", "dracula", "duskfox", "abyss", "sakura", "emerald", "mercury",
      "plum", "solarized"]),
    ("Deep &amp; moody",
     "Low light, high restraint. Built for a dark room and an OLED panel.",
     ["obsidian", "crimson", "moss", "ultraviolet", "midnight", "noir", "matrix"]),
    ("Light",
     "Genuinely light, not a dark theme with the brightness turned up. "
     "Readable in daylight.",
     ["dawn", "eink", "arctic", "porcelain"]),
    ("Desktop homage",
     "Deliberate impersonations, down to the bar geometry and dock behaviour.",
     ["win11", "macos"]),
]

by_id = {r["id"]: r for r in rices}


def swatches(r, limit=12):
    out = []
    for c in r["palette"][:limit]:
        out.append(
            '<i style="background:%s" title="%s %s"></i>'
            % (html.escape(c["hex"]), html.escape(c["name"]), html.escape(c["hex"])))
    return "".join(out)


def card(r):
    t = tags.get(r["id"], [])
    chips = "".join('<span class="tag">%s</span>' % html.escape(x) for x in t)
    meta = [("shell", r["shell"]), ("launcher", r["launcher"])]
    if r["transition"]:
        meta.append(("transition", r["transition"]))
    metahtml = "".join(
        '<div><dt>%s</dt><dd>%s</dd></div>' % (html.escape(k), html.escape(v))
        for k, v in meta if v)
    thumb = "docs/thumbs/%s.jpg" % r["id"]
    return f"""
      <article class="card{' light' if r['light'] else ''}" data-tags="{html.escape(' '.join(t))} {'light' if r['light'] else 'dark'}" id="{html.escape(r['id'])}">
        <a class="shot" href="{thumb}"><img src="{thumb}" alt="{html.escape(r['label'])} wallpaper" loading="lazy"></a>
        <div class="body">
          <header>
            <h3>{html.escape(r['label'])}</h3>
            <code>{html.escape(r['id'])}</code>
          </header>
          <p>{html.escape(r['desc'])}</p>
          <div class="swatches">{swatches(r)}</div>
          <dl class="meta">{metahtml}</dl>
          <div class="tags">{chips}<span class="tag mode">{'light' if r['light'] else 'dark'}</span></div>
        </div>
      </article>"""


sections = []
for title, blurb, ids in GROUPS:
    cards = "".join(card(by_id[i]) for i in ids if i in by_id)
    sections.append(f"""
    <section class="group">
      <div class="grouphead">
        <h2>{title}</h2>
        <p>{blurb}</p>
        <span class="count">{len([i for i in ids if i in by_id])}</span>
      </div>
      <div class="grid">{cards}</div>
    </section>""")

ALL_TAGS = ["light", "dark", "monochrome", "one-hue", "muted", "vivid",
            "neon", "deep", "warm", "cool", "classic", "terminal", "pixel",
            "two-mode", "clean", "showcase", "homage"]
filters = "".join(
    '<button class="chip" data-f="%s">%s</button>' % (t, t) for t in ALL_TAGS)

doc = f"""<title>Rices — feel &amp; tone</title>
<style>
  :root {{
    --bg:#0e1013; --panel:#15181d; --panel2:#1b1f26; --line:#262b34;
    --fg:#e6e9ef; --dim:#98a1b0; --faint:#6b7484; --ac:#7aa2f7;
    --radius:14px;
    color-scheme: dark light;
  }}
  @media (prefers-color-scheme: light) {{
    :root {{
      --bg:#f6f7f9; --panel:#ffffff; --panel2:#f0f2f5; --line:#dfe3ea;
      --fg:#161a20; --dim:#525c6b; --faint:#7b8492; --ac:#2f6feb;
    }}
  }}
  :root[data-theme="dark"] {{
    --bg:#0e1013; --panel:#15181d; --panel2:#1b1f26; --line:#262b34;
    --fg:#e6e9ef; --dim:#98a1b0; --faint:#6b7484; --ac:#7aa2f7;
  }}
  :root[data-theme="light"] {{
    --bg:#f6f7f9; --panel:#ffffff; --panel2:#f0f2f5; --line:#dfe3ea;
    --fg:#161a20; --dim:#525c6b; --faint:#7b8492; --ac:#2f6feb;
  }}

  * {{ box-sizing:border-box; }}
  body {{
    margin:0; background:var(--bg); color:var(--fg);
    font:15px/1.6 ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto,
         "Helvetica Neue", Arial, sans-serif;
    -webkit-font-smoothing:antialiased;
  }}
  .wrap {{ max-width:1180px; margin:0 auto; padding:0 20px 80px; }}

  header.top {{ padding:64px 0 32px; border-bottom:1px solid var(--line); margin-bottom:8px; }}
  header.top h1 {{
    margin:0 0 10px; font-size:clamp(28px,5vw,44px); line-height:1.1;
    letter-spacing:-.02em; font-weight:650;
  }}
  header.top p {{ margin:0; color:var(--dim); max-width:62ch; font-size:16px; }}
  .stats {{ display:flex; flex-wrap:wrap; gap:26px; margin-top:26px; }}
  .stat b {{ display:block; font-size:22px; font-weight:650; letter-spacing:-.01em; }}
  .stat span {{ color:var(--faint); font-size:12.5px; text-transform:uppercase; letter-spacing:.08em; }}

  .filters {{
    position:sticky; top:0; z-index:5; background:var(--bg);
    padding:16px 0; border-bottom:1px solid var(--line);
    display:flex; flex-wrap:wrap; gap:7px; align-items:center;
  }}
  .chip {{
    font:inherit; font-size:12.5px; color:var(--dim); cursor:pointer;
    background:var(--panel2); border:1px solid var(--line);
    padding:5px 11px; border-radius:999px; transition:.13s;
  }}
  .chip:hover {{ color:var(--fg); border-color:var(--faint); }}
  .chip.on {{ background:var(--ac); border-color:var(--ac); color:#fff; }}
  .filters .lbl {{ font-size:12.5px; color:var(--faint); margin-right:4px;
                   text-transform:uppercase; letter-spacing:.08em; }}

  .group {{ margin-top:52px; }}
  .grouphead {{ position:relative; margin-bottom:20px; padding-right:52px; }}
  .grouphead h2 {{ margin:0 0 5px; font-size:20px; letter-spacing:-.01em; font-weight:620; }}
  .grouphead p {{ margin:0; color:var(--dim); max-width:70ch; font-size:14px; }}
  .grouphead .count {{
    position:absolute; right:0; top:0; color:var(--faint);
    font-variant-numeric:tabular-nums; font-size:13px;
    border:1px solid var(--line); border-radius:999px; padding:2px 10px;
  }}

  .grid {{ display:grid; grid-template-columns:repeat(auto-fill,minmax(310px,1fr)); gap:18px; }}

  .card {{
    background:var(--panel); border:1px solid var(--line);
    border-radius:var(--radius); overflow:hidden;
    display:flex; flex-direction:column; transition:.16s;
  }}
  .card:hover {{ border-color:var(--faint); transform:translateY(-2px); }}
  .card.hide {{ display:none; }}
  .shot {{ display:block; aspect-ratio:3/2; overflow:hidden; background:var(--panel2); }}
  .shot img {{ width:100%; height:100%; object-fit:cover; display:block; }}
  .body {{ padding:15px 16px 16px; display:flex; flex-direction:column; gap:11px; flex:1; }}
  .body header {{ display:flex; align-items:baseline; gap:9px; flex-wrap:wrap; }}
  .body h3 {{ margin:0; font-size:16.5px; font-weight:620; letter-spacing:-.01em; }}
  .body code {{
    font:12px/1 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    color:var(--faint); background:var(--panel2);
    padding:3px 6px; border-radius:5px;
  }}
  .body p {{ margin:0; color:var(--dim); font-size:13.6px; line-height:1.55; flex:1; }}

  .swatches {{ display:flex; border-radius:6px; overflow:hidden; height:20px; }}
  .swatches i {{ flex:1; display:block; }}

  .meta {{ display:flex; flex-wrap:wrap; gap:14px; margin:0; }}
  .meta div {{ display:flex; gap:6px; align-items:baseline; }}
  .meta dt {{ color:var(--faint); font-size:11px; text-transform:uppercase; letter-spacing:.07em; }}
  .meta dd {{ margin:0; font:12px/1 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; color:var(--dim); }}

  .tags {{ display:flex; flex-wrap:wrap; gap:5px; }}
  .tag {{
    font-size:11px; letter-spacing:.03em; color:var(--faint);
    border:1px solid var(--line); border-radius:999px; padding:2px 8px;
  }}
  .tag.mode {{ color:var(--ac); border-color:color-mix(in srgb, var(--ac) 40%, transparent); }}

  footer {{ margin-top:64px; padding-top:24px; border-top:1px solid var(--line);
            color:var(--faint); font-size:13px; }}
  footer code {{ font-family:ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }}
  a {{ color:inherit; }}
  .empty {{ color:var(--faint); padding:40px 0; display:none; }}
</style>

<div class="wrap">
  <header class="top">
    <h1>Rices &mdash; feel &amp; tone</h1>
    <p>Every profile in this repo, and what each one is actually <em>for</em>.
       A rice here is not a colour swap: it sets the bar, the launcher, the
       lock screen, the terminal, the editor and the wallpaper together, and
       some of them change what the desktop <em>is</em> &mdash; waybar, a dock,
       conky, yambar, or nothing at all.</p>
    <div class="stats">
      <div class="stat"><b>{len(rices)}</b><span>rices</span></div>
      <div class="stat"><b>{sum(1 for r in rices if r['light'])}</b><span>light</span></div>
      <div class="stat"><b>{len({r['launcher'] for r in rices})}</b><span>launcher styles</span></div>
      <div class="stat"><b>{len({r['shell'] for r in rices})}</b><span>shell layouts</span></div>
    </div>
  </header>

  <div class="filters">
    <span class="lbl">filter</span>
    <button class="chip on" data-f="*">all</button>
    {filters}
  </div>

  <p class="empty">Nothing matches that combination.</p>
  {''.join(sections)}

  <footer>
    Generated from each rice's own files &mdash; the descriptions are the
    header comments in <code>themes/&lt;rice&gt;/waybar.css</code>, the swatches
    are the palette declared in <code>themes/&lt;rice&gt;/rofi.rasi</code>.
    Apply one with <code>themes/switch.sh &lt;rice&gt;</code> or press
    <code>Super&nbsp;+&nbsp;T</code>.
  </footer>
</div>

<script>
  var active = new Set();
  var chips = document.querySelectorAll('.chip');
  var cards = document.querySelectorAll('.card');

  function apply() {{
    var shown = 0;
    cards.forEach(function (c) {{
      var t = (c.dataset.tags || '').split(/\\s+/);
      var ok = active.size === 0 || [...active].every(function (f) {{ return t.includes(f); }});
      c.classList.toggle('hide', !ok);
      if (ok) shown++;
    }});
    document.querySelectorAll('.group').forEach(function (g) {{
      var any = g.querySelectorAll('.card:not(.hide)').length;
      g.style.display = any ? '' : 'none';
    }});
    document.querySelector('.empty').style.display = shown ? 'none' : 'block';
  }}

  chips.forEach(function (ch) {{
    ch.addEventListener('click', function () {{
      var f = ch.dataset.f;
      if (f === '*') {{ active.clear(); }}
      else if (active.has(f)) {{ active.delete(f); }}
      else {{ active.add(f); }}
      chips.forEach(function (c) {{
        c.classList.toggle('on', c.dataset.f === '*' ? active.size === 0
                                                     : active.has(c.dataset.f));
      }});
      apply();
    }});
  }});
</script>
"""

open(OUT, "w", encoding="utf-8").write(doc)
print("wrote", OUT, len(doc), "bytes")
