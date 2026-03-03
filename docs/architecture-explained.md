# Arquitectura de la VPC

Este documento explica la arquitectura propuesta para el laboratorio:

- Una VPC principal con CIDR configurable (ej. `10.0.0.0/16`).
- Subredes públicas y privadas distribuidas en al menos 2 AZ.
- Internet Gateway para acceso público.
- NAT Gateway o NAT Instance para permitir salidas desde subredes privadas.
- Tablas de ruteo separadas para rutas públicas y privadas.
- Security Groups mínimo: `bastion-sg`, `web-sg`, `db-sg`.

Ver el diagrama en `architecture-diagram.png`.
