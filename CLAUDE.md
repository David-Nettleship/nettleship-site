# nettleship-site

A static family history website. No build step, no framework — plain HTML/CSS/JS, opened directly in a browser.

## Project structure

```
nettleship-site/
├── webpages/
│   ├── index.html                      # Home page
│   ├── nettleship-mems.html            # Pat's memoirs
│   ├── photos.html                     # Gallery of galleries
│   ├── photomap.html                   # Interactive photo map (Leaflet.js)
│   ├── site.css                        # Shared base styles for all pages (reset, variables, nav, header)
│   ├── photos/
│   │   ├── gallery.css                 # Gallery-specific styles (grid, lightbox, header override)
│   │   ├── gallery.js                  # Shared JS for all gallery pages — call initGallery(BASE, photos, label)
│   │   ├── engagement.html             # Engagement photo gallery (90 photos)
│   │   ├── wedding.html                # Wedding photo gallery (634 photos)
│   │   ├── honeymoon.html              # Honeymoon photo gallery (38 photos)
│   │   ├── alex-year-one.html          # Alex Year One (176 photos)
│   │   ├── alex-is-two.html            # Alex Age Two (195 photos)
│   │   └── holidays/
│   │       ├── greece-2019.html        # Greece 2019 (197 photos)
│   │       ├── florence-2017.html      # Florence 2017 (16 photos)
│   │       ├── copenhagen-2016.html    # Copenhagen 2016 (11 photos)
│   │       ├── prague-2023.html        # Prague 2023 (48 photos)
│   │       ├── northumberland-2023.html  # Northumberland 2023 (WIP)
│   │       ├── wales-2023.html         # Wales 2023 (35 photos)
│   │       ├── wales-2022.html         # Wales 2022 (31 photos)
│   │       ├── cotswolds-2024.html     # Cotswolds 2024 (60 photos)
│   │       ├── cornwall-2025.html      # Cornwall 2025 (72 photos)
│   │       └── new-forest-2025.html    # New Forest 2025 (WIP)
│   └── myheritage/
│       ├── ethnicity.html              # DNA pie charts
│       └── ethnicity.json              # Source ethnicity data
└── infra/                              # Terraform — S3 + CloudFront + Lambda@Edge
    ├── backend.tf                      # Remote state (S3)
    ├── providers.tf                    # AWS (eu-west-2 + us-east-1 alias) + archive
    ├── s3.tf                           # Photos S3 bucket + OAC policy
    ├── cloudfront.tf                   # Photos CloudFront distribution
    ├── site_s3.tf                      # Site HTML/CSS/JS S3 bucket + OAC policy
    ├── site_cloudfront.tf              # Site CloudFront distribution (with auth)
    ├── site_lambda.tf                  # Lambda@Edge Basic Auth + IAM role
    ├── lambda/
    │   └── auth.js.tpl                 # Auth Lambda template (password injected at plan time)
    └── outputs.tf                      # Exports: photo CDN domain, site URL
```

## Gallery pages

All pages link `site.css` for shared base styles (reset, variables, nav, header). Link it with a relative path:
- From `webpages/`: `<link rel="stylesheet" href="site.css">`
- From `webpages/photos/`: `<link rel="stylesheet" href="../site.css">`
- From `webpages/photos/holidays/`: `<link rel="stylesheet" href="../../site.css">`
- From `webpages/myheritage/`: `<link rel="stylesheet" href="../site.css">`

All gallery pages also link `gallery.css` for grid/lightbox styles. Link it after `site.css`:
- From `webpages/photos/`: `<link rel="stylesheet" href="gallery.css">`
- From `webpages/photos/holidays/`: `<link rel="stylesheet" href="../gallery.css">`

Photos are served from CloudFront: `https://d1mdd4q3n2hv7r.cloudfront.net/<folder>/<filename>`. All filenames use `encodeURIComponent()` (this handles `+` characters too, so no special case needed for wedding/engagement).

All gallery pages load `gallery.js` for shared lightbox/grid logic. Each page's inline `<script>` just defines `BASE` and `photos`, then calls `initGallery(BASE, photos, 'Label')`. Load the script with a relative path:
- From `webpages/photos/`: `<script src="gallery.js"></script>`
- From `webpages/photos/holidays/`: `<script src="../gallery.js"></script>`

When adding a new gallery page, follow the pattern in an existing holiday page. Complete all of these steps — do not skip any:

1. Create the gallery HTML file in `webpages/photos/holidays/`
2. Add a card in `photos.html` (live card, not a todo placeholder)
3. Resize photos: `sips -Z 2000 --setProperty formatOptions 85` into a `web/` subfolder
4. Upload: `aws s3 sync web/ s3://nettleship-photos/holidays/<folder>/ --content-type "image/jpeg"`
5. Update `README.md`: add a row to the Pages table, the Photo folders table, the storage breakdown table, and revise the totals (photo count, GB, monthly cost)
6. Update `CLAUDE.md`: add the file to the structure tree
7. **For galleries from 2024 onwards**: extract GPS coordinates from the photos (use `mdls` for local files, or download from S3 and use Pillow if originals aren't available) and add the gallery as a new entry in the `galleries` array in `webpages/photomap.html`. Use `encodeURIComponent()` on the filename only (not the folder path). If photos have no GPS data, skip this step. Also convert the corresponding `placeholder` entry (if one exists) to a live gallery entry, or remove it.

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

Every page has a `<nav class="site-nav">` above its `<header>` with a back link (use relative paths). Gallery pages link back to `photos.html`; top-level pages link back to `index.html`.

## Data

`webpages/myheritage/ethnicity.json` is the source of truth for DNA percentages. Edit that file if figures need updating, then reflect changes in `ethnicity.html`.

## Infrastructure

The site is hosted on AWS. Two separate CloudFront distributions:

| Distribution | Bucket | Purpose |
|---|---|---|
| `d1mdd4q3n2hv7r.cloudfront.net` | `nettleship-photos` | Photo CDN |
| see `site_url` Terraform output | `nettleship-site` | Site HTML/CSS/JS |

The site distribution is protected by HTTP Basic Auth via Lambda@Edge (username: `nettleship`). The password is stored in SSM Parameter Store at `/nettleship/site/auth-password` (eu-west-2) and baked into the Lambda at `terraform apply` time. Lambda@Edge must be deployed in `us-east-1` — the `providers.tf` alias handles this.

To deploy site changes:
```bash
./deploy.sh
```
This checks Terraform is up to date, syncs `webpages/` to S3, and invalidates the CloudFront cache (required every deploy — without it the CDN serves stale content). If Terraform has unapplied changes it will warn and prompt before continuing.

To rotate the password:
```bash
aws ssm put-parameter \
  --name "/nettleship/site/auth-password" \
  --value "newpassword" \
  --type String \
  --overwrite \
  --region eu-west-2
cd infra && terraform apply
```

## Content notes

- `webpages/nettleship-mems.html` is a hand-authored HTML version of `nettleship-mems.md` — if the markdown is edited, the HTML should be kept in sync.
- The memoir was written in 2014 by Pat Nettleship. Preserve her voice; only fix clear errors.
- New Forest 2025 gallery is a work in progress — more photos will be added.
- Cornwall 2025 gallery: 71 photos, June 2025.
