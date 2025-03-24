# Dojo Contracts for Dominion

# Dominion on Starknet (Dojo Smart Contracts)

## 🚀 Getting Started

### Prerequisites
Make sure the following tools are installed:
- **Node.js**: Version 16 or higher
- **Scarb**: Version 2.9.2 or higher
- **Dojo**: Latest version

### Setup

1. **Clone the Repository**:
   ```bash  
   git clone https://github.com/webisoftSoftware/dominion-starknet.git 
   cd dominion-starknet  
   ```  

#### Build \[sepolia\]

Release:
```bash
sozo build --profile sepolia
```

Debug:
```bash
sozo build --profile sepolia --stats.by-tag
```

#### Migrate \[sepolia\]

Release:
```bash
sozo migrate --profile sepolia --fee ETH
```

Debug:
```bash
sozo migrate -vvv --profile sepolia --fee ETH
```

#### Inspect Deployment \[sepolia\]
```bash
sozo inspect --profile sepolia
```
