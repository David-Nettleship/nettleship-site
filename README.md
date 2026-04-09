# nettleship-site

A static family history website. No build step — open any `.html` file directly in a browser.

## Pages

| File | Description |
|------|-------------|
| `webpages/index.html` | Home page — links and previews for all pages |
| `webpages/nettleship-mems.html` | Personal memoirs written in 2014 by Pat Nettleship, covering life in Rotherham from the war years through to retirement |
| `webpages/photos.html` | Gallery of galleries — links to all photo galleries |
| `webpages/photos/engagement.html` | Photo gallery — David & Kathryn engagement shoot (90 photos) |
| `webpages/photos/wedding.html` | Photo gallery — David & Kathryn wedding (635 photos) |
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
│   │   ├── engagement.html
│   │   └── wedding.html
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
| `wedding/` | `wedding.html` | 635 |

### Adding photos

Before uploading, resize originals to 2000px max / 85% JPEG quality using `sips` on macOS:

```bash
mkdir web
for f in *.jpg; do
  sips -Z 2000 --setProperty formatOptions 85 "$f" --out "web/$f" > /dev/null
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

All costs are in USD (AWS bills in USD). At typical family photo gallery usage these should stay well within free tier or a few pence per month.

### S3 storage

| Scenario | Estimated size | Monthly cost |
|----------|---------------|--------------|
| 500 photos (web-optimised) | ~500 MB | ~$0.01 |
| 1,000 photos | ~1 GB | ~$0.02 |
| 5,000 photos | ~5 GB | ~$0.12 |

S3 pricing: $0.023/GB/month (eu-west-2). First 5 GB is free in the first 12 months.

### CloudFront delivery

CloudFront has a **permanent free tier** of 1 TB data transfer and 10 million requests per month — a family photo gallery will never come close to this. Effectively **free**.

### Overall expectation

| Usage | Estimated monthly cost |
|-------|----------------------|
| Light (occasional family visits) | **< $0.05** |
| Moderate (regular use, ~1 GB photos) | **< $0.10** |
| Heavy (5 GB+, frequent access) | **< $0.50** |

The only meaningful cost at this scale is S3 storage. CloudFront delivery and S3 request costs are negligible.
