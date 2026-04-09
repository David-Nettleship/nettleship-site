resource "aws_cloudfront_origin_access_control" "photos" {
  name                              = "nettleship-photos-oac"
  description                       = "OAC for nettleship photos S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "photos" {
  enabled     = true
  comment     = "Nettleship family photos"
  price_class = "PriceClass_100" # US, Canada, Europe — cheapest tier

  origin {
    domain_name              = aws_s3_bucket.photos.bucket_regional_domain_name
    origin_id                = "S3-nettleship-photos"
    origin_access_control_id = aws_cloudfront_origin_access_control.photos.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-nettleship-photos"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400    # 1 day
    max_ttl     = 31536000 # 1 year
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
