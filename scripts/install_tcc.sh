#!/bin/bash
# Instalación simple de TCC para Trinity Cortex

echo "🔱 Instalando TCC (Trinity Cortex CLI)..."

# 1. Hacer ejecutable
chmod +x /home/claude/tcc

# 2. Copiar a un lugar accesible
mkdir -p ~/bin
cp /home/claude/tcc ~/bin/tcc

# 3. Agregar al PATH si no está
if ! grep -q "$HOME/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

# 4. Crear alias directo
if ! grep -q "alias tcc=" ~/.bashrc; then
    echo 'alias tcc="python3 ~/bin/tcc"' >> ~/.bashrc
fi

# 5. Verificar si Trinity está corriendo
echo ""
echo "Verificando Trinity Cortex..."
if curl -s http://localhost:7777/health > /dev/null 2>&1; then
    echo "✅ Trinity Cortex detectado en puerto 7777 (8K docs)"
elif curl -s http://localhost:7778/health > /dev/null 2>&1; then
    echo "✅ Trinity Cortex detectado en puerto 7778"
else
    echo "⚠️  Trinity Cortex no está corriendo"
    echo "   Inicialo con: cd /mnt/ssd/trinity_cortex && ./start_trinity.sh"
fi

echo ""
echo "✅ TCC instalado!"
echo ""
echo "Para usarlo:"
echo "1. source ~/.bashrc  (o abrí una terminal nueva)"
echo "2. tcc 'tu búsqueda'"
echo ""
echo "Ejemplo: tcc 'estado proyecto fintech'"
echo ""
echo "En Claude Code simplemente escribí:"
echo '   "Ejecuta: tcc gt intelligence"'
