#!/bin/bash
# 🔱 TRINITY CORTEX SYSTEM AUDIT
# Verifica el estado de las 3 patas del tridente

echo "════════════════════════════════════════"
echo "    🔱 TRINITY CORTEX SYSTEM AUDIT"
echo "════════════════════════════════════════"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. CLAUDE CLI
echo "1️⃣ CLAUDE CLI STATUS:"
if command -v claude &> /dev/null; then
    echo -e "   ${GREEN}✓ Claude CLI installed${NC}"
    claude_version=$(claude --version 2>/dev/null || echo "version unknown")
    echo "   Version: $claude_version"
else
    echo -e "   ${RED}✗ Claude CLI not found${NC}"
    echo "   Install: pip install claude-cli"
fi
echo ""

# 2. CODEX / OPENAI CLI
echo "2️⃣ CODEX/OPENAI STATUS:"
# Verificar extensión de VSCode
if code --list-extensions 2>/dev/null | grep -q "openai.chatgpt"; then
    echo -e "   ${GREEN}✓ Codex VSCode extension installed${NC}"
else
    echo -e "   ${YELLOW}⚠ Codex VSCode extension not found or incomplete${NC}"
fi

# Verificar OpenAI CLI
if command -v openai &> /dev/null; then
    echo -e "   ${GREEN}✓ OpenAI CLI installed${NC}"
    openai_version=$(openai --version 2>/dev/null || echo "version unknown")
    echo "   Version: $openai_version"
else
    echo -e "   ${RED}✗ OpenAI CLI not found${NC}"
    echo "   Install: pip install openai"
fi
echo ""

# 3. GEMINI CLI
echo "3️⃣ GEMINI CLI STATUS:"
if command -v gemini &> /dev/null; then
    echo -e "   ${GREEN}✓ Gemini CLI installed${NC}"
elif command -v gcloud &> /dev/null; then
    echo -e "   ${YELLOW}⚠ Using gcloud AI platform${NC}"
else
    echo -e "   ${RED}✗ Gemini CLI not found${NC}"
    echo "   Install: pip install google-generativeai"
fi
echo ""

# 4. TCC (Trinity Command Center)
echo "4️⃣ TRINITY COMMAND CENTER (TCC):"
if [ -f ~/trinity-cortex/tcc.sh ] || [ -f /usr/local/bin/tcc ]; then
    echo -e "   ${GREEN}✓ TCC script found${NC}"
else
    echo -e "   ${RED}✗ TCC not configured${NC}"
    echo "   Creating TCC..."
fi
echo ""

# 5. MEMORY SYSTEM
echo "5️⃣ MEMORY SYSTEM:"
trinity_dir="$HOME/.trinity-cortex"
if [ -d "$trinity_dir" ]; then
    echo -e "   ${GREEN}✓ Trinity memory directory exists${NC}"
    # Contar archivos de memoria
    memory_files=$(find "$trinity_dir" -name "*.json" -o -name "*.log" 2>/dev/null | wc -l)
    echo "   Memory files: $memory_files"
else
    echo -e "   ${YELLOW}⚠ Creating memory directory${NC}"
    mkdir -p "$trinity_dir/memory"
    mkdir -p "$trinity_dir/logs"
    mkdir -p "$trinity_dir/cache"
fi
echo ""

# 6. API KEYS CHECK
echo "6️⃣ API KEYS STATUS:"
api_keys_found=0

if [ ! -z "$OPENAI_API_KEY" ]; then
    echo -e "   ${GREEN}✓ OpenAI API key configured${NC}"
    ((api_keys_found++))
else
    echo -e "   ${RED}✗ OpenAI API key missing${NC}"
fi

if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "   ${GREEN}✓ Anthropic API key configured${NC}"
    ((api_keys_found++))
else
    echo -e "   ${RED}✗ Anthropic API key missing${NC}"
fi

if [ ! -z "$GOOGLE_API_KEY" ] || [ ! -z "$GEMINI_API_KEY" ]; then
    echo -e "   ${GREEN}✓ Google/Gemini API key configured${NC}"
    ((api_keys_found++))
else
    echo -e "   ${RED}✗ Google/Gemini API key missing${NC}"
fi
echo ""

# 7. SYSTEM RESOURCES
echo "7️⃣ SYSTEM RESOURCES:"
echo -n "   RAM Available: "
free -h | grep Mem | awk '{print $7}'
echo -n "   Disk Space: "
df -h / | tail -1 | awk '{print $4 " free"}'
echo -n "   CPU Load: "
uptime | awk -F'load average:' '{print $2}'
echo ""

# SUMMARY
echo "════════════════════════════════════════"
echo "         📊 AUDIT SUMMARY"
echo "════════════════════════════════════════"

total_components=0
working_components=0

# Contar componentes funcionales
[ -x "$(command -v claude)" ] && ((working_components++))
[ -x "$(command -v openai)" ] && ((working_components++))
[ -x "$(command -v gemini)" ] || [ -x "$(command -v gcloud)" ] && ((working_components++))

echo "Trinity Status: $working_components/3 components operational"
echo "API Keys: $api_keys_found/3 configured"

if [ $working_components -eq 3 ] && [ $api_keys_found -eq 3 ]; then
    echo -e "${GREEN}✅ TRINITY CORTEX FULLY OPERATIONAL${NC}"
else
    echo -e "${YELLOW}⚠️  TRINITY CORTEX PARTIALLY OPERATIONAL${NC}"
    echo ""
    echo "To complete setup:"
    [ ! -x "$(command -v claude)" ] && echo "  - Install Claude CLI"
    [ ! -x "$(command -v openai)" ] && echo "  - Install OpenAI CLI"
    [ ! -x "$(command -v gemini)" ] && echo "  - Install Gemini CLI"
    [ $api_keys_found -lt 3 ] && echo "  - Configure missing API keys"
fi

echo "════════════════════════════════════════"
