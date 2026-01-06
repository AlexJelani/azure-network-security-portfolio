# Azure Network Security Portfolio - AZ-500 Labs

## Project Description

This repository contains multiple Azure security labs implemented with Bicep templates, designed to demonstrate key concepts for the AZ-500 Microsoft Azure Security Engineer certification. Each lab focuses on specific security domains and follows Infrastructure as Code (IaC) best practices.

## Labs Overview

### 📁 [Lab 01: Network Security Group Rules](./labs/01-nsg-rules/)
- **Focus**: NSG configuration and network traffic control
- **Resources**: VNet, NSG, Windows VM with IIS
- **Skills**: Inbound security rules, least privilege access
- **Duration**: ~15 minutes

### 📁 [Lab 02: Configure Network Access to VM](./labs/02-network-access/)
- **Focus**: Linux VM network access and web server setup
- **Resources**: VNet, NSG, Ubuntu VM with Nginx
- **Skills**: SSH/HTTP rules, automated software installation
- **Duration**: ~10 minutes

### 📁 [Lab 03: Storage Security with Service Endpoints](./labs/03-storage-security/)
- **Focus**: Azure Storage security with VNet service endpoints
- **Resources**: VNet, Storage Account, Windows VMs
- **Skills**: Service endpoints, storage network ACLs, secure connectivity
- **Duration**: ~20 minutes

### 📁 [Lab 04: Traffic Manager with Subnet Routing](./labs/04-traffic-manager/)
- **Focus**: DNS-based load balancing and subnet-based traffic routing
- **Resources**: Multi-region VMs, Traffic Manager profile, IIS web servers
- **Skills**: Traffic routing methods, endpoint health monitoring, multi-region deployment
- **Duration**: ~90 minutes

### 🚧 More Labs Coming Soon
- Application Security Groups (ASGs)
- Azure Firewall implementation
- Key Vault integration
- Just-in-Time VM access
- Network monitoring with Network Watcher

## Prerequisites

- Azure CLI installed and configured
- Active Azure subscription with contributor access
- Logged into Azure CLI (`az login`)

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone <repository-url>
   cd azure-network-security-portfolio
   ```

2. **Navigate to desired lab**:
   ```bash
   cd labs/01-nsg-rules
   ```

3. **Follow lab-specific README** for deployment instructions

## Learning Objectives

### Network Security (25-30% of AZ-500)
- ✅ Network Security Groups (NSGs) configuration
- 🚧 Application Security Groups (ASGs)
- 🚧 Azure Firewall implementation
- 🚧 Network monitoring and diagnostics

### Identity and Access Management (30-35%)
- 🚧 Azure AD integration
- 🚧 Role-based access control (RBAC)
- 🚧 Just-in-Time VM access

### Data and Application Security (20-25%)
- 🚧 Key Vault integration
- 🚧 Storage account security
- 🚧 Application security best practices

## Repository Structure

```
azure-network-security-portfolio/
├── labs/
│   ├── 01-nsg-rules/           # Network Security Group rules
│   ├── 02-network-access/      # VM network access configuration
│   ├── 03-storage-security/    # Storage security with service endpoints
│   ├── 04-traffic-manager/     # Traffic Manager subnet routing
│   ├── 05-asg-implementation/  # Application Security Groups (planned)
│   ├── 06-azure-firewall/      # Azure Firewall setup (planned)
│   └── 07-keyvault-integration/ # Key Vault integration (planned)
├── .gitignore
└── README.md
```

## Contributing

Each lab is self-contained with its own Bicep templates and documentation. Labs follow consistent naming and structure for easy navigation.

## Cost Management

All labs use cost-optimized resources (Basic SKUs, Standard SSDs, B-series VMs). Remember to clean up resources after testing to avoid charges.