# CloudFront Module

This Terraform module provisions an **Amazon CloudFront distribution** to serve the frontend application with low latency and improved security.

---

## Resources

### 1. CloudFront Distribution

**Resource:** `aws_cloudfront_distribution.frontend_cdn`

- **Acts as a CDN** for the frontend application.
- Uses **ALB (Application Load Balancer)** as its origin.
- Forces HTTPS communication.
- Implements **caching** and **compression** for better performance.

#### **Origin Configuration**
- The **ALB's DNS name** (`var.alb_dns_name`) is used as the origin.
- Uses **HTTPS-only** communication between CloudFront and ALB.
- **Supports TLS 1.2** for secure encryption.

#### **Default Cache Behavior**
- **Allowed methods:** `GET`, `HEAD`, `OPTIONS`
- **Cached methods:** `GET`, `HEAD`
- **Query strings are not forwarded** for better caching.
- **Cookies are not forwarded** to avoid unnecessary cache invalidation.

#### **Restrictions**
- **Geo-restrictions are disabled** (`restriction_type = "none"`).
- Can be modified to **restrict access based on country** if needed.

#### **Viewer Certificate (HTTPS)**
- Uses **ACM (AWS Certificate Manager) SSL Certificate** (`var.ssl_certificate_arn`).
- **TLS 1.2** is enforced for security.
- **SNI-only SSL support** is used to optimize cost.

---

## Variables

| Variable Name         | Description                                       | Type   |
|----------------------|---------------------------------------------------|--------|
| `alb_dns_name`      | The **DNS name** of the ALB                       | string |
| `alb_origin_id`     | The **origin ID** used by CloudFront for ALB      | string |
| `ssl_certificate_arn` | ARN of the **SSL certificate** for CloudFront    | string |

---

## Outputs

| Output Name                            | Description                                    |
|----------------------------------------|------------------------------------------------|
| `cloudfront_distribution_id`           | ID of the CloudFront distribution             |
| `cloudfront_distribution_domain_name`  | The CloudFront **public URL** for the frontend |

---

## Usage

This module can be called from the root Terraform configuration using:

```hcl
module "cloudfront" {
  source              = "./modules/cloudfront"
  alb_dns_name        = module.alb.alb_dns_name
  alb_origin_id       = module.alb.alb_origin_id
  ssl_certificate_arn = var.ssl_certificate_arn
}
