# Dojo Contracts for Dominion

## Setup

### Install

```bash
curl -L https://install.dojoengine.org | bash
dojoup --version v1.0.12
sudo cp ~/.dojo/bin/sozo /usr/local/bin
```

*Note, you may need to restart your shell or source `.bashrc` to have access to the `dojoup` command.*

### Build \[sepolia\]

Release:
```bash
sozo build --profile sepolia
```

Debug:
```bash
sozo build --profile sepolia --stats.by-tag
```

### Migrate \[sepolia\]


Release:
```bash
sozo migrate --profile sepolia --fee ETH
```

Debug:
```bash
sozo migrate -vvv --profile sepolia --fee ETH
```

### Inspect Deployment \[sepolia\]
```bash
sozo inspect --profile sepolia
```
