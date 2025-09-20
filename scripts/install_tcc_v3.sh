#!/bin/bash
# 🔱 TCC v3 - QUICK INSTALL
# Trinity Cortex con micro-conversaciones y aprendizaje distribuido

echo "🔱 Installing Trinity Cortex v3.0..."

# Instalar dependencias Python
pip install --user aiohttp sqlite3 asyncio

# Crear estructura
mkdir -p ~/.trinity-cortex/{memories,learnings,cache}

# Copiar TCC v3
if [ -f "tcc_v3.py" ]; then
    cp tcc_v3.py ~/.trinity-cortex/
    chmod +x ~/.trinity-cortex/tcc_v3.py
    
    # Crear wrapper script
    cat > ~/.trinity-cortex/tcc << 'EOF'
#!/bin/bash
python3 ~/.trinity-cortex/tcc_v3.py "$@"
EOF
    chmod +x ~/.trinity-cortex/tcc
    
    # Link global
    sudo ln -sf ~/.trinity-cortex/tcc /usr/local/bin/tcc
    
    echo "✅ TCC v3 installed!"
else
    echo "⚠️  tcc_v3.py not found"
fi

# Configurar API keys si no existen
if [ -z "$OPENAI_API_KEY" ]; then
    echo ""
    echo "Configure your API keys in ~/.bashrc:"
    echo "export OPENAI_API_KEY='your-key'"
    echo "export ANTHROPIC_API_KEY='your-key'"
    echo "export GEMINI_API_KEY='your-key'"
fi

echo ""
echo "🔱 To start Trinity Cortex:"
echo "   tcc                    # Interactive mode"
echo ""
echo "Orchestration modes:"
echo "   'your query'          # Parallel (default)"
echo "   'seq: query'          # Sequential"
echo "   'consensus: query'    # Consensus building"
echo "   'spec: query'         # Specialized"
