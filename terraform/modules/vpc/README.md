# VPC Module

This Terraform module provisions the networking infrastructure for the AWS environment, including a VPC, public and private subnets, and routing components.

## Resources

### 1. Virtual Private Cloud (VPC)

**Resource:** `aws_vpc.main`

- Creates the main VPC for the infrastructure.
- Enables DNS support and hostnames.
- Configurable CIDR block via `var.vpc_cidr`.
- Tagged with `Name=main-vpc` and `Environment=production`.

### 2. Public Subnets

**Resource:** `aws_subnet.public`

- Creates multiple public subnets based on the CIDR blocks in `var.public_subnet_cidrs`.
- Assigned to availability zones `us-east-1a` and `us-east-1b`.
- Used for internet-facing resources like NAT gateways or public instances.
- Tagged appropriately for identification.

### 3. Private Subnets

**Resource:** `aws_subnet.private`

- Creates multiple private subnets using `var.private_subnet_cidrs`.
- Assigned to the same availability zones as the public subnets.
- Used for internal resources like ECS tasks and databases.

### 4. Internet Gateway

**Resource:** `aws_internet_gateway.gw`

- Provides internet access to the public subnets.
- Associated with the VPC.
- Required for outbound traffic to the internet.

### 5. NAT Gateway

**Resources:** `aws_eip.nat`, `aws_nat_gateway.nat`

- Creates an Elastic IP (EIP) for the NAT Gateway.
- The NAT Gateway is placed in the first public subnet to allow outbound internet traffic for private subnets.

### 6. Route Tables

**Resources:** `aws_route_table.public`, `aws_route_table.private`

- **Public Route Table:**
  - Routes internet traffic (`0.0.0.0/0`) through the Internet Gateway.
  - Associated with public subnets.
- **Private Route Table:**
  - Routes internet traffic (`0.0.0.0/0`) via the NAT Gateway.
  - Associated with private subnets.

### 7. Route Table Associations

**Resources:** `aws_route_table_association.public_assoc`, `aws_route_table_association.private_assoc`

- Associates each public subnet with the public route table.
- Associates each private subnet with the private route table.

---

## Variables

| Variable Name          | Description                             | Type         | Default                            |
| ---------------------- | --------------------------------------- | ------------ | ---------------------------------- |
| `vpc_cidr`             | CIDR block for the main VPC             | string       | `10.0.0.0/16`                      |
| `public_subnet_cidrs`  | List of CIDR blocks for public subnets  | list(string) | `["10.0.1.0/24", "10.0.2.0/24"]`   |
| `private_subnet_cidrs` | List of CIDR blocks for private subnets | list(string) | `["10.0.10.0/24", "10.0.11.0/24"]` |

---

## Outputs

| Output Name          | Description                    |
| -------------------- | ------------------------------ |
| `vpc_id`             | The ID of the created VPC.     |
| `public_subnet_ids`  | List of public subnet IDs.     |
| `private_subnet_ids` | List of private subnet IDs.    |
| `nat_gateway_id`     | ID of the created NAT Gateway. |

---

## Usage

This module can be called from the root Terraform configuration using:

```hcl
module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}
