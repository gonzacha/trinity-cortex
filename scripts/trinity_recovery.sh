#!/bin/bash
# 🔱 TRINITY CORTEX - QUICK RECOVERY & SETUP
# Para recuperar el sistema después del corte de luz

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
    ╔══════════════════════════════════════╗
    ║   🔱 TRINITY CORTEX RECOVERY 🔱     ║
    ║        Quick Setup & Repair          ║
    ╚══════════════════════════════════════╝
EOF
echo -e "${NC}"

# 1. Verificar Python
echo -e "${YELLOW}[1/7] Checking Python...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 not found. Installing...${NC}"
    sudo apt-get update && sudo apt-get install -y python3 python3-pip
fi
echo -e "${GREEN}✓ Python3 ready${NC}"

# 2. Instalar/Actualizar pip packages
echo -e "${YELLOW}[2/7] Installing AI CLIs...${NC}"

# OpenAI CLI
if ! pip show openai &> /dev/null; then
    echo "Installing OpenAI..."
    pip install --user openai
fi

# Anthropic Claude
if ! pip show anthropic &> /dev/null; then
    echo "Installing Anthropic..."
    pip install --user anthropic
fi

# Google Gemini
if ! pip show google-generativeai &> /dev/null; then
    echo "Installing Google GenerativeAI..."
    pip install --user google-generativeai
fi

echo -e "${GREEN}✓ AI packages installed${NC}"

# 3. Completar instalación de Codex en VSCode
echo -e "${YELLOW}[3/7] Fixing Codex VSCode extension...${NC}"
if command -v code &> /dev/null; then
    # Desinstalar si está corrupto
    code --uninstall-extension openai.chatgpt 2>/dev/null || true
    
    # Reinstalar limpio
    code --install-extension openai.chatgpt
    echo -e "${GREEN}✓ Codex VSCode extension reinstalled${NC}"
else
    echo -e "${YELLOW}⚠ VSCode not found, skipping Codex extension${NC}"
fi

# 4. Crear estructura de directorios
echo -e "${YELLOW}[4/7] Creating Trinity directories...${NC}"
TRINITY_HOME="$HOME/.trinity-cortex"
mkdir -p "$TRINITY_HOME"/{memory,logs,cache,scripts}
echo -e "${GREEN}✓ Directory structure created${NC}"

# 5. Instalar TCC
echo -e "${YELLOW}[5/7] Installing TCC (Trinity Command Center)...${NC}"
if [ -f "/home/claude/tcc.sh" ]; then
    cp /home/claude/tcc.sh "$TRINITY_HOME/scripts/tcc.sh"
    chmod +x "$TRINITY_HOME/scripts/tcc.sh"
    
    # Crear symlink para acceso global
    sudo ln -sf "$TRINITY_HOME/scripts/tcc.sh" /usr/local/bin/tcc
    echo -e "${GREEN}✓ TCC installed globally${NC}"
else
    echo -e "${YELLOW}⚠ TCC script not found, create it manually${NC}"
fi

# 6. Configurar API Keys
echo -e "${YELLOW}[6/7] Configuring API Keys...${NC}"
ENV_FILE="$HOME/.bashrc"

setup_api_key() {
    local key_name=$1
    local key_var=$2
    
    if [ -z "${!key_var}" ]; then
        echo -ne "Enter your $key_name API Key (or press Enter to skip): "
        read -s api_key
        echo
        
        if [ ! -z "$api_key" ]; then
            # Agregar al .bashrc si no existe
            if ! grep -q "export $key_var=" "$ENV_FILE"; then
                echo "export $key_var='$api_key'" >> "$ENV_FILE"
                export "$key_var=$api_key"
                echo -e "${GREEN}✓ $key_name API key configured${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ $key_name API key skipped${NC}"
        fi
    else
        echo -e "${GREEN}✓ $key_name API key already configured${NC}"
    fi
}

setup_api_key "OpenAI" "OPENAI_API_KEY"
setup_api_key "Anthropic" "ANTHROPIC_API_KEY"
setup_api_key "Google/Gemini" "GEMINI_API_KEY"

# 7. Test rápido
echo -e "${YELLOW}[7/7] Running system test...${NC}"

# Crear script de test
cat > /tmp/trinity_test.py << 'EOF'
#!/usr/bin/env python3
import sys

print("Testing Trinity components...")

components = []

# Test OpenAI
try:
    import openai
    components.append("✓ OpenAI module")
except:
    components.append("✗ OpenAI module")

# Test Anthropic
try:
    import anthropic
    components.append("✓ Anthropic module")
except:
    components.append("✗ Anthropic module")

# Test Google
try:
    import google.generativeai
    components.append("✓ Google GenerativeAI module")
except:
    components.append("✗ Google GenerativeAI module")

for c in components:
    print(f"  {c}")

if all("✓" in c for c in components):
    print("\n✅ All Python modules working!")
    sys.exit(0)
else:
    print("\n⚠️  Some modules missing")
    sys.exit(1)
EOF

chmod +x /tmp/trinity_test.py
python3 /tmp/trinity_test.py

# Resumen final
echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}       TRINITY CORTEX STATUS${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"

# Ejecutar auditoría
if [ -f "/home/claude/trinity_audit.sh" ]; then
    bash /home/claude/trinity_audit.sh
fi

echo ""
echo -e "${GREEN}Recovery complete!${NC}"
echo ""
echo -e "${CYAN}To start using Trinity Cortex:${NC}"
echo "  tcc                    # Interactive mode"
echo "  tcc 'your query'       # Direct orchestration"
echo ""
echo -e "${CYAN}Examples:${NC}"
echo "  tcc 'Create a REST API for user management'"
echo "  tcc claude 'Explain quantum computing'"
echo "  tcc all 'Design a microservices architecture'"
echo ""

# Recargar bashrc para las nuevas variables
source ~/.bashrc 2>/dev/null || true

echo -e "${GREEN}🔱 Trinity Cortex is ready!${NC}"
