# VPC Architecture

This document explains the proposed architecture for the laboratory:

- A main VPC with configurable CIDR (e.g., `10.0.0.0/16`).
- Public and private subnets distributed across at least 2 AZs.
- Internet Gateway for public access.
- NAT Gateway or NAT Instance to allow outbound traffic from private subnets.
- Separate route tables for public and private routes.
- Minimum Security Groups: `bastion-sg`, `web-sg`, `db-sg`.

See the diagram in `architecture-diagram.png`.
