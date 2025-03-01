# Dominion on Starknet 

Welcome to the **Dominion on Starknet** repository! 
This project is a **decentralized poker game** built using the **Dojo Framework on Starknet** and integrated with **Telegram's Mini-App platform** leveraging **Argent's Telegram Wallet** for blockchain integration. 
The game uses blockchain technology to ensure **provable fairness** and **transparency**, offering a seamless and secure gaming experience.  

---

## 🃏 Project Overview  

Dominion combines blockchain technology with modern app design to create a decentralized poker experience:  

- **Frontend**:  
  - A mobile-friendly interface using **Telegram Mini-App**.  
  - Integration with the **Argent Telegram Wallet** for smooth transactions.  
  - Dynamic updates powered by **Dojo's Torii Client** events.  

- **Backend**:  
  - Smart contracts written in **Cairo** using the **Dojo Framework**.  
  - Design of game models and implementation of **Zero-Knowledge Proofs (ZKP)** for card shuffling and dealing.  
  - **Torii setup** for indexing on-chain data and linking it to the frontend.  

---

## 💻 Team Requirements  

A minimum of **2 developers** is recommended to build this project efficiently:  

### **Frontend Developer** (1):  
- Design and implement the mobile version of the game using **Telegram's Mini-App**.  
- Integrate the **Argent Telegram Wallet** into the Mini-App.  
- Handle real-time updates by processing **Dojo's Torii Client** events.  

### **Backend Developer** (1):  
- Develop smart contracts in **Cairo** using the **Dojo Framework**.  
- Design game models to fit the system's requirements.  
- Implement **Zero-Knowledge Proofs (ZKP)** for secure card operations.  
- Set up **Torii** to index on-chain data.  
- Configure the **Torii client** to integrate with the frontend.  

---

## 🚀 Getting Started  

### Prerequisites  
Make sure the following tools are installed:  
- **Node.js**: Version 16 or higher  
- **Yarn**: Version 1.22.10 or higher  
- **Scarb**: Version 2.8.4 or higher
- **Dojo**: Latest version

### Setup Instructions  

1. **Clone the Repository**:  
   ```bash  
   git clone https://github.com/yourusername/dominion-starknet.git 
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