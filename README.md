# Terraform AWS ALB Private Architecture

This repository contains Terraform configuration for deploying an AWS Application Load Balancer architecture with private subnets.

## Architecture Overview
- VPC with public and private subnets in two availability zones
- NAT Gateways for private subnet internet access
- Application Load Balancer in public subnets
- EC2 instances in private subnets
- Secure routing and network access control