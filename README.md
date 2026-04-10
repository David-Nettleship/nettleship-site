# nettleship-site

A static family history website. No build step — open any `.html` file directly in a browser.

## Pages

| File | Description |
|------|-------------|
| `webpages/index.html` | Home page — links and previews for all pages |
| `webpages/nettleship-mems.html` | Personal memoirs written in 2014 by Pat Nettleship, covering life in Rotherham from the war years through to retirement |
| `webpages/photos.html` | Gallery of galleries — links to all photo galleries |
| `webpages/photos/engagement.html` | Photo gallery — David & Kathryn engagement shoot (90 photos) |
| `webpages/photos/wedding.html` | Photo gallery — David & Kathryn wedding (634 photos) |
| `webpages/photos/honeymoon.html` | Photo gallery — David & Kathryn honeymoon, September 2021 (38 photos) |
| `webpages/photos/holidays/greece-2019.html` | Photo gallery — Greece 2019 (197 photos) |
| `webpages/photos/holidays/florence-2017.html` | Photo gallery — Florence 2017 (16 photos) |
| `webpages/photos/holidays/copenhagen-2016.html` | Photo gallery — Copenhagen 2016 (11 photos) |
| `webpages/photos/holidays/prague-2023.html` | Photo gallery — Prague 2023 (48 photos) |
| `webpages/photos/holidays/northumberland-2023.html` | Photo gallery — Northumberland 2023 (WIP) |
| `webpages/photos/holidays/wales-2022.html` | Photo gallery — Wales 2022 (31 photos) |
| `webpages/photos/holidays/wales-2023.html` | Photo gallery — Wales 2023 (35 photos) |
| `webpages/photomap.html` | Photo map — geotagged holiday photos on an interactive map |
| `webpages/photos/holidays/cotswolds-2024.html` | Photo gallery — Cotswolds 2024 (60 photos) |
| `webpages/photos/holidays/new-forest-2025.html` | Photo gallery — New Forest 2025 (WIP) |
| `webpages/photos/holidays/cornwall-2025.html` | Photo gallery — Cornwall 2025 (72 photos) |
| `webpages/myheritage/ethnicity.html` | DNA ethnicity pie charts for David and Kathryn (MyHeritage data, December 2025) |

## Data

| File | Description |
|------|-------------|
| `webpages/myheritage/ethnicity.json` | Source ethnicity percentages for both individuals |

## Structure

```
nettleship-site/
├── webpages/
│   ├── index.html
│   ├── nettleship-mems.html
│   ├── photos.html
│   ├── photos/
│   │   ├── gallery.css              # Shared styles for all gallery pages
│   │   ├── engagement.html
│   │   ├── wedding.html
│   │   ├── honeymoon.html
│   │   └── holidays/
│   │       ├── greece-2019.html
│   │       ├── prague-2023.html
│   │       ├── cotswolds-2024.html
│   │       └── new-forest-2025.html
│   └── myheritage/
│       ├── ethnicity.html
│       └── ethnicity.json
└── infra/
    ├── main.tf
    ├── backend.tf
    ├── s3.tf
    ├── cloudfront.tf
    └── outputs.tf
```

## Infrastructure

Photo hosting is managed via Terraform in the `infra/` directory, using AWS S3 + CloudFront.

### Resources

| Resource | Name/ID | Description |
|----------|---------|-------------|
| S3 bucket | `nettleship-photos` | Private photo storage — `eu-west-2` |
| CloudFront distribution | `E309FJ8CWXBZ9` | CDN — serves photos over HTTPS |
| CloudFront domain | `d1mdd4q3n2hv7r.cloudfront.net` | Base URL for all photo references |

The bucket is private with all public access blocked. CloudFront accesses it via Origin Access Control (OAC), so photos are only reachable through the CDN.

Photos should be referenced in HTML as:
```
https://d1mdd4q3n2hv7r.cloudfront.net/<path/to/photo.jpg>
```

### Photo folders

| S3 prefix | Gallery page | Photos |
|-----------|-------------|--------|
| `engagement/` | `engagement.html` | 90 |
| `wedding/` | `wedding.html` | 634 |
| `honeymoon/` | `honeymoon.html` | 38 |
| `holidays/greece-2019/` | `greece-2019.html` | 197 |
| `holidays/florence-2017/` | `florence-2017.html` | 16 |
| `holidays/copenhagen-2016/` | `copenhagen-2016.html` | 11 |
| `holidays/wales-2022/` | `wales-2022.html` | 31 |
| `holidays/prague-2023/` | `prague-2023.html` | 48 |
| `holidays/cotswolds-2024/` | `cotswolds-2024.html` | 60 |
| `holidays/new-forest-2025/` | `new-forest-2025.html` | 25+ (WIP) |
| `holidays/cornwall-2025/` | `cornwall-2025.html` | 71 |

### Adding photos

Before uploading, resize originals to 2000px max / 85% JPEG quality using `sips` on macOS:

```bash
mkdir web
for f in *.jpg; do
  sips -Z 2000 --setProperty formatOptions 85 "$f" --out "web/$f" > /dev/null
done
# For .png files, convert to JPEG first:
for f in *.png; do
  sips -Z 2000 -s format jpeg --setProperty formatOptions 85 "$f" --out "web/${f%.png}.jpg" > /dev/null
done
aws s3 sync web/ s3://nettleship-photos/<folder>/ --content-type "image/jpeg"
```

### Terraform state

Remote state is stored in S3:
- **Bucket:** `terraform-state-304707804854`
- **Key:** `nettleship-site/infra.tfstate`
- **Region:** `eu-west-2`

### Deploying infra changes

```bash
cd infra
terraform init
terraform plan
terraform apply
```

## Cost expectations

All costs are in USD (AWS bills in USD).

### Current storage

The site currently holds roughly 1,264 photos, all resized to 2000px / 85% JPEG quality — approximately 1 MB each on average.

| Folder | Photos | Approx. size |
|--------|--------|-------------|
| `wedding/` | 634 | ~634 MB |
| `engagement/` | 90 | ~90 MB |
| `honeymoon/` | 38 | ~40 MB |
| `holidays/greece-2019/` | 197 | ~197 MB |
| `holidays/prague-2023/` | 48 | ~48 MB |
| `holidays/cotswolds-2024/` | 60 | ~60 MB |
| `holidays/cornwall-2025/` | 71 | ~71 MB |
| `holidays/northumberland-2023/` | 8 (WIP) | ~8 MB |
| `holidays/wales-2022/` | 31 | ~31 MB |
| `holidays/wales-2023/` | 35 | ~35 MB |
| `holidays/new-forest-2025/` | 25+ | ~25 MB |
| `holidays/florence-2017/` | 16 | ~13 MB |
| `holidays/copenhagen-2016/` | 11 | ~8 MB |
| **Total** | **~1,264** | **~1.26 GB** |

### S3 storage cost

S3 in eu-west-2 costs **$0.023 per GB per month**.

| Now (~1.25 GB) | At 2 GB | At 5 GB |
|--------------|---------|---------|
| ~$0.03/mo | ~$0.05/mo | ~$0.12/mo |

The first 5 GB is free for the first 12 months of an AWS account.

### CloudFront delivery

CloudFront has a **permanent free tier** of 1 TB data transfer and 10 million HTTP requests per month. A family photo site will never approach these limits — delivery cost is effectively **$0**.

### S3 request costs

S3 charges $0.00043 per 1,000 GET requests. Even if every photo is loaded by 10 people, that's ~10,000 requests — less than **$0.01**.

### Summary

| Cost component | Monthly cost |
|---------------|-------------|
| S3 storage (~1.2 GB today) | ~$0.03 |
| CloudFront delivery | $0.00 (free tier) |
| S3 GET requests | < $0.01 |
| **Total** | **~$0.02–$0.05** |

The only cost that grows over time is S3 storage as more galleries are added. At the current rate of ~1 MB per photo, adding another 500 photos adds roughly $0.01/month.
