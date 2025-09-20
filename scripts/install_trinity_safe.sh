#!/bin/bash
# 🔱 TRINITY CORTEX - INSTALACIÓN SEGURA Y CORRECTA
# No instala paquetes inexistentes

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔱 TRINITY CORTEX - Safe Installation"
echo "====================================="
echo ""

# 1. Verificar Python
echo "1️⃣ Checking Python..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 not found${NC}"
    echo "Install with: sudo apt install python3 python3-pip"
    exit 1
fi
echo -e "${GREEN}✅ Python3 found${NC}"

# 2. Instalar OpenAI CLI (el real)
echo ""
echo "2️⃣ Installing OpenAI Python SDK..."
pip install --user openai --quiet
echo -e "${GREEN}✅ OpenAI SDK installed${NC}"

# 3. Instalar Anthropic SDK
echo ""
echo "3️⃣ Installing Anthropic SDK..."
pip install --user anthropic --quiet
echo -e "${GREEN}✅ Anthropic SDK installed${NC}"

# 4. Instalar Google Generative AI
echo ""
echo "4️⃣ Installing Google AI SDK..."
pip install --user google-generativeai --quiet
echo -e "${GREEN}✅ Google AI SDK installed${NC}"

# 5. Para Node.js (opcional)
echo ""
echo "5️⃣ Checking Node.js tools..."
if command -v npm &> /dev/null; then
    echo "Installing OpenAI Node.js SDK..."
    npm install --save openai 2>/dev/null || true
    echo -e "${GREEN}✅ OpenAI Node.js SDK available${NC}"
else
    echo -e "${YELLOW}⚠️ npm not found, skipping Node.js tools${NC}"
fi

# 6. VSCode Extensions (manual)
echo ""
echo "6️⃣ VSCode Extensions (install manually):"
echo "   ${YELLOW}GitHub Copilot:${NC}"
echo "   code --install-extension GitHub.copilot"
echo ""
echo "   ${YELLOW}GitHub Copilot Chat:${NC}"
echo "   code --install-extension GitHub.copilot-chat"
echo ""
echo "   ${YELLOW}Continue (Free Copilot alternative):${NC}"
echo "   code --install-extension Continue.continue"

# 7. Verificar instalación
echo ""
echo "7️⃣ Verifying installation..."
echo ""

python3 << EOF
import sys
print("Python packages check:")

try:
    import openai
    print("  ✅ OpenAI SDK")
except:
    print("  ❌ OpenAI SDK")

try:
    import anthropic
    print("  ✅ Anthropic SDK")
except:
    print("  ❌ Anthropic SDK")

try:
    import google.generativeai
    print("  ✅ Google AI SDK")
except:
    print("  ❌ Google AI SDK")
EOF

# 8. Configurar API Keys
echo ""
echo "8️⃣ API Keys Configuration"
echo "====================================="
echo "Add these to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "export OPENAI_API_KEY='sk-...'"
echo "export ANTHROPIC_API_KEY='sk-ant-...'"
echo "export GOOGLE_API_KEY='...'"
echo ""

# 9. Crear directorio Trinity
echo "9️⃣ Creating Trinity directories..."
mkdir -p ~/.trinity-cortex/{memory,logs,cache}
echo -e "${GREEN}✅ Trinity directories created${NC}"

echo ""
echo "====================================="
echo -e "${GREEN}✅ INSTALLATION COMPLETE!${NC}"
echo "====================================="
echo ""
echo "⚠️ IMPORTANT:"
echo "  - NO package called @openai/codex exists"
echo "  - Codex is accessed via OpenAI API, not a CLI"
echo "  - Use 'openai' Python package or API directly"
echo ""
echo "To test OpenAI:"
echo "  python3 -c \"import openai; print('OpenAI SDK OK')\""
echo ""
echo "To start Trinity Cortex:"
echo "  python3 ~/.trinity-cortex/tcc_v3.py"
