# ALB Module

This Terraform module provisions an **Application Load Balancer (ALB)** to handle traffic for the frontend service. The ALB is secured to accept traffic **only from CloudFront** and forwards requests to the frontend ECS service.

## Resources

### 1. ALB Security Group

**Resource:** `aws_security_group.alb_sg`

- **Purpose:** Restricts access to the ALB **only from CloudFront**.
- **Inbound Rules (Ingress):**
  - **Port 80 (HTTP):** Allowed **only from CloudFront**.
  - **Port 443 (HTTPS):** Allowed **only from CloudFront**.
- **Outbound Rules (Egress):**
  - Allows all outgoing traffic.

### 2. Application Load Balancer (ALB)

**Resource:** `aws_lb.application_lb`

- **Type:** Public-facing **Application Load Balancer (ALB)**.
- **Security Group:** Uses the ALB security group (`alb_sg`).
- **Subnets:** Deploys in the **public subnets**.
- **Traffic Routing:** Routes requests to the **frontend ECS service**.

### 3. Target Group (Frontend)

**Resource:** `aws_lb_target_group.frontend_tg`

- **Purpose:** Directs traffic to the frontend service.
- **Protocol:** HTTP (port **3000**).
- **Target Type:** `ip` (used for ECS tasks).
- **Health Check:** Monitors endpoint `/` to determine service availability.

### 4. Listener for HTTP (Redirect to HTTPS)

**Resource:** `aws_lb_listener.http_listener`

- **Port 80 (HTTP):** Redirects all HTTP requests to HTTPS (port 443).
- **Ensures:** Secure communication by enforcing HTTPS-only access.

### 5. Listener for HTTPS (Frontend Service)

**Resource:** `aws_lb_listener.https_listener`

- **Port 443 (HTTPS):** Routes secure traffic to the **frontend target group**.
- **SSL Certificate:** Uses an SSL certificate via `var.ssl_certificate_arn`.

---

## Variables

| Variable Name           | Description                                      | Type         |
|-------------------------|--------------------------------------------------|-------------|
| `vpc_id`               | The ID of the VPC                               | string      |
| `public_subnet_ids`    | A list of public subnet IDs for ALB deployment  | list(string) |
| `ssl_certificate_arn`  | ARN of the SSL certificate for HTTPS listener   | string      |
| `cloudfront_cidr`      | CIDR block to restrict ALB access to CloudFront | string      |

---

## Outputs

| Output Name            | Description                                      |
|------------------------|--------------------------------------------------|
| `alb_arn`             | The ARN of the Application Load Balancer        |
| `alb_dns_name`        | The DNS name of the ALB                         |
| `alb_sg_id`          | The Security Group ID associated with the ALB   |
| `frontend_tg_arn`     | The ARN of the frontend target group            |
| `alb_origin_id`       | The unique identifier for CloudFront referencing ALB |
| `alb_arn_suffix`      | The ARN suffix of the ALB                       |

---

## Usage

This module can be called from the root Terraform configuration using:

```hcl
module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  ssl_certificate_arn = var.ssl_certificate_arn
  cloudfront_cidr     = "0.0.0.0/0" # Replace with actual CloudFront CIDR
}
```

## Summary

- **The ALB** routes external traffic securely to the frontend service.
- **CloudFront Restriction:** Ensures only CloudFront can access ALB.
- **HTTPS-Only Access:** Redirects all HTTP requests to HTTPS.
- **Health Checks:** ALB verifies service availability before routing traffic.

This setup ensures **scalability, security, and efficient traffic handling** for the frontend application.


