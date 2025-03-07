module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "sqs" {
  source             = "./modules/sqs"
  queue_name         = var.queue_name
  fifo_queue         = var.fifo_queue
}

module "iam" {
  source        = "./modules/iam"
  sqs_queue_arn = module.sqs.queue_arn
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  ssl_certificate_arn = var.ssl_certificate_arn
  cloudfront_cidr     = "0.0.0.0/0" # Replace with actual CloudFront CIDR
}

module "ecs" {
  source = "./modules/ecs"

  # Cluster Configuration
  cluster_name = var.cluster_name
  environment  = var.environment
  mongodb_uri  = var.mongodb_uri

  # Networking & Security
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id

  # IAM Roles for ECS Tasks
  ecs_execution_role_arn  = module.iam.ecs_execution_role_arn
  frontend_task_role_arn  = module.iam.frontend_role_arn
  service_a_task_role_arn = module.iam.service_a_role_arn
  service_b_task_role_arn = module.iam.service_b_role_arn

  # ALB & Target Groups
  alb_target_group_arn = module.alb.frontend_tg_arn

  # Container Images
  frontend_image  = var.frontend_image
  service_a_image = var.service_a_image
  service_b_image = var.service_b_image

  service_a_max_capacity      = var.service_a_max_capacity
  service_a_min_capacity      = var.service_a_min_capacity
  service_a_latency_threshold = var.service_a_latency_threshold

  # ECS Service Scaling
  frontend_desired_count  = var.frontend_desired_count
  service_a_desired_count = var.service_a_desired_count
  service_b_desired_count = var.service_b_desired_count

  # SQS Configuration for Service B
  sqs_queue_arn = module.sqs.queue_arn
  sqs_queue_url = module.sqs.queue_url
}

module "cloudfront" {
  source              = "./modules/cloudfront"
  alb_dns_name        = module.alb.alb_dns_name
  alb_origin_id       = module.alb.alb_origin_id
  ssl_certificate_arn = var.ssl_certificate_arn
}


