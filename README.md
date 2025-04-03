# Dominion on Starknet (Dojo Smart Contracts)

## 🚀 Getting Started  

### Prerequisites  
Make sure the following tools are installed:  
- **Node.js**: Version 16 or higher  
- **Yarn**: Version 1.22.10 or higher  
- **Scarb**: Version 2.9.2 or higher
- **Dojo**: 1.0.0 or higher

### Setup Instructions  

1. **Clone the Repository**:  
   ```bash  
   git clone https://github.com/webisoftSoftware/dominion-starknet.git 
   cd dominion-starknet  
   ```  

2. **Install Frontend Dependencies**:  
   ```bash  
   cd frontend  
   yarn install  
   ```  

3. **Run the Frontend Development Server**:  
   ```bash  
   yarn dev  
   ```  

4. **Build and Deploy Contracts**:
   ```bash
   cd contracts
   scarb build
   ```
   
   Follow the instructions in `contracts/README.md` for detailed deployment steps.

5. **Set Up Torii**:  
   - Configure **Torii** to index on-chain data.  
   - Set up the **Torii client** in the frontend to handle blockchain events dynamically.  

---

## 📚 Resources  

- **Website**: [Dominion Poker Game](https://dominion.fun/)  
- **Documentation**: Refer to the `contracts/README.md` and `frontend/README.md` for detailed setup and usage instructions.  
- **Dojo Framework**: [Documentation](https://book.dojoengine.org/)
- **Starknet**: [Developer Resources](https://www.starknet.io/en/developers)

---
