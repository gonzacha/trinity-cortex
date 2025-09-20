#!/bin/bash
# 🔱 TCC - TRINITY COMMAND CENTER
# Orquestador central para Claude, Codex y Gemini
# Version: 2.0

# Configuración
TRINITY_HOME="$HOME/.trinity-cortex"
MEMORY_DIR="$TRINITY_HOME/memory"
LOG_DIR="$TRINITY_HOME/logs"
SESSION_FILE="$MEMORY_DIR/session_$(date +%Y%m%d_%H%M%S).json"

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

# Inicializar Trinity
init_trinity() {
    mkdir -p "$MEMORY_DIR" "$LOG_DIR"
    
    # Crear archivo de sesión
    cat > "$SESSION_FILE" << EOF
{
    "session_id": "$(uuidgen 2>/dev/null || date +%s)",
    "start_time": "$(date -Iseconds)",
    "interactions": [],
    "context": {}
}
EOF
}

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════╗
    ║      🔱 TRINITY CORTEX v2.0 🔱      ║
    ║   Multi-AI Orchestration System      ║
    ╚══════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${GREEN}Connected AIs:${NC}"
    echo -e "  ${MAGENTA}◆${NC} Claude (Anthropic) - Strategy & Architecture"
    echo -e "  ${YELLOW}◆${NC} Codex (OpenAI) - Code Generation"
    echo -e "  ${CYAN}◆${NC} Gemini (Google) - Analysis & Research"
    echo ""
}

# Función para logging
log_interaction() {
    local ai="$1"
    local query="$2"
    local response="$3"
    
    # Guardar en JSON
    timestamp=$(date -Iseconds)
    jq --arg ai "$ai" \
       --arg query "$query" \
       --arg response "$response" \
       --arg ts "$timestamp" \
       '.interactions += [{
           "timestamp": $ts,
           "ai": $ai,
           "query": $query,
           "response": $response
       }]' "$SESSION_FILE" > "$SESSION_FILE.tmp" && mv "$SESSION_FILE.tmp" "$SESSION_FILE"
    
    # Log simple
    echo "[$timestamp] $ai: $query" >> "$LOG_DIR/trinity.log"
}

# Ejecutar con Claude
run_claude() {
    local query="$1"
    echo -e "${MAGENTA}[Claude]${NC} Processing..."
    
    if command -v claude &> /dev/null; then
        response=$(claude "$query" 2>/dev/null)
        echo -e "${MAGENTA}[Claude Response]${NC}"
        echo "$response"
        log_interaction "claude" "$query" "$response"
        return 0
    else
        # Fallback a API directa si CLI no está disponible
        if [ ! -z "$ANTHROPIC_API_KEY" ]; then
            response=$(curl -s https://api.anthropic.com/v1/messages \
                -H "x-api-key: $ANTHROPIC_API_KEY" \
                -H "anthropic-version: 2023-06-01" \
                -H "content-type: application/json" \
                -d "{
                    \"model\": \"claude-3-sonnet-20240229\",
                    \"max_tokens\": 1024,
                    \"messages\": [{\"role\": \"user\", \"content\": \"$query\"}]
                }" | jq -r '.content[0].text' 2>/dev/null)
            
            echo -e "${MAGENTA}[Claude Response]${NC}"
            echo "$response"
            log_interaction "claude" "$query" "$response"
            return 0
        else
            echo -e "${RED}Claude not available${NC}"
            return 1
        fi
    fi
}

# Ejecutar con OpenAI/Codex
run_codex() {
    local query="$1"
    echo -e "${YELLOW}[Codex]${NC} Processing..."
    
    if [ ! -z "$OPENAI_API_KEY" ]; then
        response=$(curl -s https://api.openai.com/v1/chat/completions \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -H "Content-Type: application/json" \
            -d "{
                \"model\": \"gpt-4\",
                \"messages\": [{\"role\": \"system\", \"content\": \"You are Codex, specialized in code generation.\"}, {\"role\": \"user\", \"content\": \"$query\"}],
                \"max_tokens\": 1024
            }" | jq -r '.choices[0].message.content' 2>/dev/null)
        
        echo -e "${YELLOW}[Codex Response]${NC}"
        echo "$response"
        log_interaction "codex" "$query" "$response"
        return 0
    else
        echo -e "${RED}Codex not available${NC}"
        return 1
    fi
}

# Ejecutar con Gemini
run_gemini() {
    local query="$1"
    echo -e "${CYAN}[Gemini]${NC} Processing..."
    
    if [ ! -z "$GEMINI_API_KEY" ] || [ ! -z "$GOOGLE_API_KEY" ]; then
        api_key=${GEMINI_API_KEY:-$GOOGLE_API_KEY}
        response=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$api_key" \
            -H 'Content-Type: application/json' \
            -d "{
                \"contents\": [{
                    \"parts\": [{\"text\": \"$query\"}]
                }]
            }" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
        
        echo -e "${CYAN}[Gemini Response]${NC}"
        echo "$response"
        log_interaction "gemini" "$query" "$response"
        return 0
    else
        echo -e "${RED}Gemini not available${NC}"
        return 1
    fi
}

# Modo Orchestration - todas las IAs trabajan juntas
orchestrate() {
    local query="$1"
    echo -e "${GREEN}═══ ORCHESTRATION MODE ═══${NC}"
    echo -e "${GREEN}Query: $query${NC}"
    echo ""
    
    # Fase 1: Claude analiza y estructura
    echo -e "${MAGENTA}▶ Phase 1: Strategic Analysis (Claude)${NC}"
    claude_response=$(run_claude "Analyze this request and create a structured plan: $query")
    
    # Fase 2: Codex genera código si es necesario
    echo -e "\n${YELLOW}▶ Phase 2: Implementation (Codex)${NC}"
    codex_response=$(run_codex "Based on this plan, generate implementation: $claude_response")
    
    # Fase 3: Gemini valida y optimiza
    echo -e "\n${CYAN}▶ Phase 3: Optimization & Validation (Gemini)${NC}"
    gemini_response=$(run_gemini "Review and optimize this solution: $codex_response")
    
    # Resumen final
    echo -e "\n${GREEN}═══ ORCHESTRATION COMPLETE ═══${NC}"
    echo -e "${GREEN}✅ All three AIs have processed your request${NC}"
}

# Modo interactivo
interactive_mode() {
    show_banner
    init_trinity
    
    echo -e "${GREEN}TCC Ready. Commands:${NC}"
    echo "  'claude <query>'  - Ask Claude"
    echo "  'codex <query>'   - Ask Codex"
    echo "  'gemini <query>'  - Ask Gemini"
    echo "  'all <query>'     - Ask all three (orchestration)"
    echo "  'memory'          - Show session memory"
    echo "  'clear'           - Clear screen"
    echo "  'exit'            - Exit TCC"
    echo ""
    
    while true; do
        echo -ne "${GREEN}tcc> ${NC}"
        read -r input
        
        case "$input" in
            claude\ *)
                query="${input#claude }"
                run_claude "$query"
                ;;
            codex\ *)
                query="${input#codex }"
                run_codex "$query"
                ;;
            gemini\ *)
                query="${input#gemini }"
                run_gemini "$query"
                ;;
            all\ *)
                query="${input#all }"
                orchestrate "$query"
                ;;
            memory)
                echo -e "${GREEN}Session Memory:${NC}"
                jq '.' "$SESSION_FILE"
                ;;
            clear)
                clear
                show_banner
                ;;
            exit|quit)
                echo -e "${GREEN}Trinity Cortex shutting down...${NC}"
                exit 0
                ;;
            *)
                echo "Unknown command. Type 'help' for commands."
                ;;
        esac
        echo ""
    done
}

# Modo comando único
if [ $# -gt 0 ]; then
    # Uso: tcc "your query here"
    init_trinity
    orchestrate "$*"
else
    # Modo interactivo
    interactive_mode
fi
