#!/bin/bash
# Push Trinity Cortex to GitHub

echo "=== TRINITY CORTEX - Push to GitHub ==="
echo ""
echo "PASO 1: Primero creá el repositorio en GitHub:"
echo "  1. Andá a https://github.com/new"
echo "  2. Nombre: trinity-cortex"
echo "  3. Descripción: Multi-LLM Orchestration System - Reduces AI costs by 90%"
echo "  4. Público (para que IV.AI pueda verlo)"
echo "  5. NO inicialices con README"
echo ""
read -p "Presioná ENTER cuando hayas creado el repo en GitHub..."

echo ""
echo "PASO 2: Configurando remote..."
git remote add origin https://github.com/gonzalohaedo/trinity-cortex.git 2>/dev/null || git remote set-url origin https://github.com/gonzalohaedo/trinity-cortex.git

echo "PASO 3: Pusheando al repositorio..."
git branch -M main
git push -u origin main

echo ""
echo "✅ LISTO! Tu proyecto está en GitHub"
echo ""
echo "📎 Link para compartir con IV.AI:"
echo "   https://github.com/gonzalohaedo/trinity-cortex"
echo ""
echo "📊 También podés compartir el demo online:"
echo "   - Opción 1: Repl.it (importar desde GitHub)"
echo "   - Opción 2: GitHub Codespaces"
echo "   - Opción 3: Grabar video con Loom"
echo ""
