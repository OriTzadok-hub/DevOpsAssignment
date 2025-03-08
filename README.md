# DevOps Candidate Assignment

This repository contains the solution for the DevOps candidate assignment.

## Overview
The assignment involves setting up an AWS-based infrastructure using Terraform, provisioning an ECS Fargate cluster, configuring networking and security, setting up auto-scaling, integrating with SQS, and automating the deployment process using GitHub Actions.

## Structure
- **Architecture Diagram**: The high-level infrastructure design is illustrated in [`Diagram.png`](./Diagram.png).
- **Terraform Configuration**: Located in the `terraform` folder, including infrastructure as code to provision AWS resources, More details about the Terraform setup can be found in the `terraform/README.md`.
- **GitHub Actions Workflow**: Automates the Terraform deployment process.

## Notes
This setup was tested using `terraform plan`, but no actual resources were deployed since real AWS credentials were not used.

