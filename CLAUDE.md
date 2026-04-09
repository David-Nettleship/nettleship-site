# nettleship-site

A static family history website. No build step, no framework — plain HTML/CSS/JS, opened directly in a browser.

## Project structure

```
nettleship-site/
├── index.html                  # Home page
├── nettleship-mems.html        # Pat's memoirs
└── myheritage/
    ├── ethnicity.html          # DNA pie charts
    └── ethnicity.json          # Source ethnicity data
```

## Design system

All pages share the same CSS variables and visual style — keep new pages consistent with these.

```css
--bg:        #faf8f3;   /* page background */
--paper:     #fffef9;   /* card/content background */
--ink:       #2c2416;   /* body text */
--muted:     #7a6e5f;   /* secondary text, meta lines */
--rule:      #d9d0c0;   /* borders and dividers */
--accent:    #8b3a2a;   /* headings, links, highlights */

--font-body: Georgia, 'Times New Roman', serif;
--font-ui:   system-ui, -apple-system, sans-serif;
```

- Section headings: small-caps, `0.85–1rem`, `letter-spacing: .1em`, `text-transform: uppercase`, `color: var(--accent)`
- Body text: Georgia serif, `1.05rem`, `line-height: 1.8`
- Cards: `background: var(--paper)`, `border: 1px solid var(--rule)`, `border-radius: 4px`, subtle box-shadow

## Navigation

Every page has a `<nav class="site-nav">` above its `<header>` with a "← Nettleship Family" link back to `index.html` (use relative paths: `../index.html` from subdirectories).

## Data

`myheritage/ethnicity.json` is the source of truth for DNA percentages. Edit that file if figures need updating, then reflect changes in `ethnicity.html`.

## Content notes

- `nettleship-mems.html` is a hand-authored HTML version of `nettleship-mems.md` — if the markdown is edited, the HTML should be kept in sync.
- The memoir was written in 2014 by Pat Nettleship. Preserve her voice; only fix clear errors.
