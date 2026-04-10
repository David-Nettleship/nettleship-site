# Adding a custom domain (nettleships.com)

## Prerequisites

Register `nettleships.com` in the AWS console before running Terraform — domain registration
charges your account immediately and is awkward to manage via Terraform state.

**AWS Console → Route 53 → Register domain → nettleships.com (~$15/year)**

---

## Additional cost

| Item | Monthly | Annual |
|------|---------|--------|
| Domain registration | ~$1.25 | ~$15.00 |
| Route 53 hosted zone | $0.50 | $6.00 |
| ACM certificate | $0.00 | $0.00 |
| **Additional total** | **~$1.75** | **~$21.00** |

Full site cost becomes ~$2.18/month (~$26/year).

---

## New Terraform resources needed

### 1. `acm.tf` — TLS certificate (must be in us-east-1)

```hcl
resource "aws_acm_certificate" "site" {
  provider          = aws.us_east_1
  domain_name       = "nettleships.com"
  validation_method = "DNS"

  subject_alternative_names = ["www.nettleships.com"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "site" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
```

### 2. `route53.tf` — hosted zone and DNS records

```hcl
resource "aws_route53_zone" "site" {
  name = "nettleships.com"
}

# DNS validation records for the ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.site.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# A record — apex domain → CloudFront
resource "aws_route53_record" "site_apex" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "nettleships.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# A record — www → CloudFront
resource "aws_route53_record" "site_www" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "www.nettleships.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
```

### 3. Update `site_cloudfront.tf`

Replace the `viewer_certificate` block and add `aliases`:

```hcl
resource "aws_cloudfront_distribution" "site" {
  # ... existing config ...

  aliases = ["nettleships.com", "www.nettleships.com"]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
```

### 4. Update `outputs.tf`

Replace the `site_url` output value:

```hcl
output "site_url" {
  description = "URL of the family site — share this with family"
  value       = "https://nettleships.com"
}
```

---

## Deployment steps

1. Register `nettleships.com` in the AWS console (one-time, ~$15)
2. `terraform apply` — creates the hosted zone, cert, validation records, DNS records, and updates CloudFront
3. In the AWS console, copy the 4 NS records from the new Route 53 hosted zone
4. Go to **Route 53 → Registered domains → nettleships.com → Edit name servers** and paste them in
5. Wait ~5 minutes for the ACM cert to validate via DNS, then CloudFront will serve on the custom domain

> **Note:** Step 4 is only needed if the domain was registered before the hosted zone existed. If you register via Route 53 and let it create a hosted zone automatically, the nameservers are already wired up — delete that auto-created hosted zone before running `terraform apply` to avoid a duplicate.
