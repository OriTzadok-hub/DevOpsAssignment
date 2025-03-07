# Root Terraform Configuration

This Terraform configuration sets up the **AWS infrastructure** for a microservices-based architecture. The deployment includes **networking (VPC), compute resources (ECS), a load balancer (ALB), security (IAM), a message queue (SQS), and a CDN (CloudFront)**.

---

## **Infrastructure Overview**

1. **Networking (VPC Module)**
   - Creates a **Virtual Private Cloud (VPC)** with **public and private subnets**.
   - Provides **internet access** via **Internet Gateway & NAT Gateway**.
   
2. **Security & Access Management (IAM Module)**
   - Defines **IAM roles and policies** for ECS tasks.
   - Grants permissions for **ECS services** to interact with **SQS, CloudWatch, and other AWS services**.

3. **Compute Services (ECS Module)**
   - Deploys an **ECS cluster with Fargate** for containerized services.
   - Defines ECS **task definitions and services** for:
     - **Frontend** (React/Next.js, served via ALB & CloudFront)
     - **Service A** (gRPC-based microservice)
     - **Service B** (SQS consumer for background processing)
   - Implements **autoscaling** based on CPU utilization, response time, and SQS queue depth.
   
4. **Application Load Balancer (ALB Module)**
   - Routes traffic from **CloudFront** to the frontend service running on ECS.
   - Handles **SSL termination**, security rules, and health checks.
   
5. **Message Queue (SQS Module)**
   - Creates an **SQS queue** for Service B to process background jobs.

6. **Content Delivery Network (CloudFront Module)**
   - Caches frontend assets globally to **reduce latency** and **improve performance**.
   - Adds **DDoS protection** and **TLS encryption**.

---

## **Terraform Modules Used**

### **1️⃣ VPC Module** (`modules/vpc`)
- Creates a **VPC** with **public and private subnets**.
- Provides **internet access** for public services via **Internet Gateway**.
- Private subnets use a **NAT Gateway** for outbound access.

### **2️⃣ IAM Module** (`modules/iam`)
- Defines **IAM roles and policies** for ECS tasks.
- Grants required permissions for **ECS services to access SQS, CloudWatch, and other AWS services**.

### **3️⃣ ALB Module** (`modules/alb`)
- Creates an **Application Load Balancer (ALB)**.
- Configures **target groups, security groups, and listeners**.
- **Routes CloudFront traffic** to the ECS frontend service.

### **4️⃣ ECS Module** (`modules/ecs`)
- Defines **ECS cluster, task definitions, and services**.
- **Frontend Service:** Connects to ALB & CloudFront.
- **Service A:** gRPC backend service.
- **Service B:** Background job processor (connected to SQS).
- Implements **autoscaling** based on CPU, latency, and SQS queue depth.

### **5️⃣ SQS Module** (`modules/sqs`)
- Creates an **SQS queue** for processing background jobs in Service B.

### **6️⃣ CloudFront Module** (`modules/cloudfront`)
- Creates a **CloudFront distribution** to cache frontend assets globally.
- Improves **performance, security, and scalability**.

---

## **Flow Diagram**

```
(User) --> [CloudFront (CDN)] --> [ALB (Load Balancer)] --> [ECS Frontend Service]
                                     |--> [ECS Service A (gRPC API)]
                                     |--> [ECS Service B (SQS Consumer)] --> [SQS Queue]
```

- CloudFront **caches static assets** and **forwards dynamic requests** to ALB.
- ALB **routes traffic** to **Frontend (React/Next.js)** hosted in ECS.
- Service A **handles gRPC API requests**.
- Service B **consumes messages from SQS** for background processing.

---

## **Usage**

To deploy this infrastructure, use Terraform:

### **1. Initialize Terraform**
```sh
terraform init
```

### **2. Plan the Deployment**
```sh
terraform plan
```

### **3. Apply the Deployment**
```sh
terraform apply -auto-approve
```

---

## **Inputs & Outputs**

### **📌 Inputs (Variables)**
| Variable Name | Description | Type |
|--------------|-------------|------|
| `vpc_cidr` | CIDR block for VPC | `string` |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `list(string)` |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `list(string)` |
| `ssl_certificate_arn` | SSL certificate ARN for HTTPS | `string` |
| `cluster_name` | Name of ECS cluster | `string` |
| `frontend_image` | Docker image for frontend | `string` |
| `service_a_image` | Docker image for Service A | `string` |
| `service_b_image` | Docker image for Service B | `string` |
| `queue_name` | Name of SQS queue | `string` |

### **📌 Outputs**
| Output Name | Description |
|------------|-------------|
| `vpc_id` | VPC ID |
| `alb_dns_name` | DNS name of ALB |
| `ecs_cluster_id` | ECS Cluster ID |
| `sqs_queue_url` | URL of SQS queue |
| `cloudfront_distribution_domain_name` | CloudFront domain |

---

## **Key Benefits**
✅ **Scalability** – ECS scales frontend and backend services automatically.  
✅ **Security** – ALB enforces HTTPS, and CloudFront provides DDoS protection.  
✅ **Performance** – CloudFront caches frontend assets, reducing latency.  
✅ **Cost Efficiency** – CloudFront minimizes ALB traffic, reducing costs.  

---

## **Conclusion**
This Terraform project **deploys a scalable AWS infrastructure** for a modern **microservices-based application** using ECS, CloudFront, ALB, and SQS. The architecture provides **high availability, security, and performance optimizations**.

To destroy the infrastructure, use:
```sh
terraform destroy -auto-approve
```

