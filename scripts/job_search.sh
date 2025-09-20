#!/bin/bash
# Script de búsqueda laboral con TCC + Gemini
# Para rol: AI Integration Engineer

echo "🔍 INVESTIGACIÓN DE MERCADO: AI Integration Engineer"
echo "=================================================="
echo ""

# Guardar contexto en TCC
echo "💾 Guardando contexto en Trinity Cortex..."
echo "{
  \"timestamp\": \"$(date -Iseconds)\",
  \"search\": \"AI Integration Engineer\",
  \"objective\": \"Remote job in 30-60 days\",
  \"context\": \"Experience with Trinity Cortex, Claude, GPT-4, Gemini orchestration\"
}" >> ~/.tcc_cache.json

# Prompt para Gemini
PROMPT="Investiga el mercado laboral para 'AI Integration Engineer' y roles similares. 

NECESITO DATOS ESPECÍFICOS:
1. Ofertas laborales ACTIVAS hoy (con enlaces directos)
2. Salarios REALES (USD) por región (LATAM, USA, Europa)  
3. Top 10 skills técnicos más pedidos
4. 20 empresas contratando AHORA este rol
5. Cantidad de profesionales con este título en LinkedIn
6. Certificaciones o cursos que agreguen valor real
7. ¿Emergente (poca competencia) o saturado?
8. 3 casos de éxito verificables (personas reales)
9. Estrategia específica para aplicar desde Argentina
10. ¿Especialización urgente o hay tiempo?

Contexto: Experiencia real orquestando múltiples LLMs.
Formato: Datos duros con fuentes. Nada de generalidades."

# Si Gemini CLI está instalado
if command -v gemini &> /dev/null; then
    echo "🤖 Ejecutando Gemini CLI..."
    gemini "$PROMPT" | tee ~/ai_integration_engineer_research.txt
    
# Si no, usar alternativa o mostrar instrucciones
else
    echo "⚠️  Gemini CLI no encontrado."
    echo ""
    echo "Para instalar:"
    echo "  pip install google-generativeai"
    echo ""
    echo "O copia este prompt para usar en web:"
    echo ""
    echo "$PROMPT"
    echo ""
    echo "Guardado en: ~/gemini_prompt.txt"
    echo "$PROMPT" > ~/gemini_prompt.txt
fi

# Guardar timestamp de búsqueda
echo ""
echo "✅ Búsqueda completada: $(date)"
echo "📁 Resultados guardados en:"
echo "   - ~/ai_integration_engineer_research.txt"
echo "   - ~/.tcc_cache.json (contexto)"
echo ""
echo "🎯 Próximo paso: Analizar resultados con Claude"
echo "   tcc 'claude: analizar resultados de búsqueda laboral'"
