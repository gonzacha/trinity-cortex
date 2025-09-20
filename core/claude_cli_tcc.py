#!/usr/bin/env python3
"""
CLAUDE CLI → TCC → GEMINI
Ejecutar directamente desde la terminal de VSCode
"""

import subprocess
import json
import os
from datetime import datetime

def claude_cli_execute_tcc():
    """Claude CLI orquestando TCC con Gemini"""
    
    print("╔════════════════════════════════════════════════╗")
    print("║         CLAUDE CLI ORCHESTRATOR                ║")
    print("║         Ejecutando TCC → Gemini               ║")
    print("╚════════════════════════════════════════════════╝")
    print()
    
    # Query optimizada para el mercado laboral
    query = """gemini: Investigar mercado laboral AI Integration Engineer.
    
DATOS NECESARIOS:
- 10+ ofertas laborales ACTIVAS con enlaces directos
- Salarios en USD: LATAM, USA, Europa  
- Skills más demandados (top 10)
- 20 empresas contratando este rol AHORA
- Cantidad de profesionales con este título en LinkedIn
- ¿Rol emergente o saturado?
- Certificaciones que suman valor real
- 3 casos de éxito (personas reales, verificables)
- Estrategia específica para aplicar desde Argentina
- Timeline: ¿especialización urgente o hay tiempo?

Contexto: Tengo experiencia orquestando Claude + GPT-4 + Gemini
Objetivo: Trabajo remoto en 30-60 días
Formato: Datos verificables con fuentes"""

    # Comando TCC
    print("[Claude CLI] Preparando comando para TCC...")
    print()
    
    # Si TCC está instalado, ejecutarlo
    tcc_installed = subprocess.run(
        ["which", "tcc"], 
        capture_output=True, 
        text=True
    ).returncode == 0
    
    if tcc_installed:
        print("[TCC] ✅ TCC detectado, ejecutando búsqueda...")
        print()
        
        # Ejecutar TCC
        try:
            result = subprocess.run(
                ["tcc", query],
                capture_output=True,
                text=True,
                timeout=30
            )
            print(result.stdout)
            if result.stderr:
                print(f"[TCC] Advertencia: {result.stderr}")
        except subprocess.TimeoutExpired:
            print("[TCC] ⏱️ Timeout - la búsqueda está en proceso...")
        except Exception as e:
            print(f"[TCC] Error: {e}")
    else:
        print("[TCC] ⚠️  TCC no detectado, guardando comando para ejecución manual")
        print()
    
    # Guardar en memoria persistente
    print("[Claude CLI] 💾 Guardando en memoria persistente...")
    
    cache_dir = os.path.expanduser("~/.tcc_cache")
    os.makedirs(cache_dir, exist_ok=True)
    
    session_data = {
        "session_id": f"claude_cli_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        "timestamp": datetime.now().isoformat(),
        "orchestrator": "claude-cli",
        "command": "tcc → gemini",
        "query": query,
        "status": "completed" if tcc_installed else "pending",
        "tcc_available": tcc_installed
    }
    
    # Guardar sesión
    session_file = os.path.join(cache_dir, "claude_sessions.json")
    sessions = []
    
    if os.path.exists(session_file):
        try:
            with open(session_file, 'r') as f:
                sessions = json.load(f)
        except:
            sessions = []
    
    sessions.append(session_data)
    
    with open(session_file, 'w') as f:
        json.dump(sessions, f, indent=2)
    
    print(f"[Claude CLI] ✅ Sesión guardada: {session_data['session_id']}")
    print()
    
    # Instrucciones finales
    print("╔════════════════════════════════════════════════╗")
    print("║              COMANDO COMPLETADO                ║")
    print("╚════════════════════════════════════════════════╝")
    print()
    print("📁 Memoria guardada en: ~/.tcc_cache/claude_sessions.json")
    print()
    
    if not tcc_installed:
        print("⚡ Para instalar TCC:")
        print("   bash install_tcc.sh")
        print()
        print("📋 Query guardada para ejecutar con Gemini:")
        print("-" * 50)
        print(query[:300] + "...")
        print("-" * 50)
    
    print()
    print("🎯 Próximos pasos:")
    print("   1. Ejecutar con Gemini: gemini '<query>'")
    print("   2. Analizar resultados: tcc 'claude: analizar resultados'")
    print("   3. Crear estrategia: tcc 'crear plan 30 días'")
    
    return session_data

if __name__ == "__main__":
    # Ejecutar directamente
    claude_cli_execute_tcc()
