#!/bin/bash
# 🚀 SCRIPT MAESTRO DE OPTIMIZACIÓN DEL SISTEMA
# Objetivo: Liberar máxima RAM para desarrollo intensivo
# Autor: Sistema automatizado
# Fecha: Enero 2025

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   OPTIMIZADOR DE SISTEMA v2.0         ║${NC}"
echo -e "${BLUE}║   Liberando recursos para desarrollo   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Función para mostrar uso de memoria
show_memory() {
    echo -e "${YELLOW}📊 USO DE MEMORIA ACTUAL:${NC}"
    free -h | grep -E "^Mem|^Swap"
    echo ""
}

# Función para calcular memoria liberada
calculate_freed() {
    local before=$1
    local after=$2
    local freed=$((before - after))
    local freed_mb=$((freed / 1024))
    echo -e "${GREEN}✅ Memoria liberada: ${freed_mb} MB${NC}"
}

# Estado inicial
echo -e "${BLUE}[1/10] Analizando estado inicial...${NC}"
INITIAL_MEM=$(free -m | grep Mem | awk '{print $3}')
show_memory

# 1. Limpiar cache del sistema
echo -e "${BLUE}[2/10] Limpiando cache del sistema...${NC}"
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
sudo swapoff -a && sudo swapon -a
echo -e "${GREEN}✓ Cache limpiado${NC}"

# 2. Detener servicios innecesarios
echo -e "${BLUE}[3/10] Deteniendo servicios innecesarios...${NC}"
services_to_stop=(
    "snapd"
    "cups"
    "bluetooth"
    "avahi-daemon"
    "ModemManager"
    "networkd-dispatcher"
    "unattended-upgrades"
    "apparmor"
    "apport"
)

for service in "${services_to_stop[@]}"; do
    if systemctl is-active --quiet $service; then
        sudo systemctl stop $service 2>/dev/null || true
        echo -e "  ${YELLOW}→ Detenido: $service${NC}"
    fi
done

# 3. Limpiar logs antiguos
echo -e "${BLUE}[4/10] Limpiando logs del sistema...${NC}"
sudo journalctl --vacuum-time=2d 2>/dev/null
sudo find /var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
sudo apt-get clean 2>/dev/null || true
echo -e "${GREEN}✓ Logs limpiados${NC}"

# 4. Optimizar Chrome/Chromium si está corriendo
echo -e "${BLUE}[5/10] Verificando procesos Chrome...${NC}"
if pgrep -x "chrome" > /dev/null || pgrep -x "chromium" > /dev/null; then
    echo -e "${YELLOW}⚠️  Chrome detectado. Considera usar la netbook para navegación${NC}"
    echo -e "${YELLOW}   Esto liberaría ~2-3 GB de RAM${NC}"
    
    # Preguntar si cerrar Chrome
    read -p "¿Cerrar Chrome ahora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        pkill -f chrome || true
        pkill -f chromium || true
        echo -e "${GREEN}✓ Chrome cerrado${NC}"
    fi
else
    echo -e "${GREEN}✓ Chrome no está ejecutándose${NC}"
fi

# 5. Limpiar Docker si existe
echo -e "${BLUE}[6/10] Optimizando Docker...${NC}"
if command -v docker &> /dev/null; then
    docker system prune -f 2>/dev/null || true
    docker volume prune -f 2>/dev/null || true
    echo -e "${GREEN}✓ Docker optimizado${NC}"
else
    echo -e "${YELLOW}→ Docker no instalado${NC}"
fi

# 6. Limpiar npm cache
echo -e "${BLUE}[7/10] Limpiando cache de npm...${NC}"
if command -v npm &> /dev/null; then
    npm cache clean --force 2>/dev/null || true
    echo -e "${GREEN}✓ npm cache limpiado${NC}"
else
    echo -e "${YELLOW}→ npm no instalado${NC}"
fi

# 7. Limpiar archivos temporales
echo -e "${BLUE}[8/10] Eliminando archivos temporales...${NC}"
rm -rf /tmp/* 2>/dev/null || true
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
rm -rf ~/.local/share/Trash/* 2>/dev/null || true
echo -e "${GREEN}✓ Archivos temporales eliminados${NC}"

# 8. Optimizar base de datos de paquetes
echo -e "${BLUE}[9/10] Optimizando sistema de paquetes...${NC}"
sudo apt-get autoremove -y 2>/dev/null || true
sudo apt-get autoclean -y 2>/dev/null || true
echo -e "${GREEN}✓ Sistema de paquetes optimizado${NC}"

# 9. Configurar swappiness para desarrollo
echo -e "${BLUE}[10/10] Ajustando swappiness para desarrollo...${NC}"
echo 10 | sudo tee /proc/sys/vm/swappiness > /dev/null
echo -e "${GREEN}✓ Swappiness configurado a 10${NC}"

# Resultado final
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 OPTIMIZACIÓN COMPLETADA${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"

# Mostrar memoria final
FINAL_MEM=$(free -m | grep Mem | awk '{print $3}')
show_memory
calculate_freed $INITIAL_MEM $FINAL_MEM

# Mostrar procesos que más consumen
echo -e "${YELLOW}📈 TOP 5 PROCESOS POR USO DE RAM:${NC}"
ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-20s %s\n", $11, $4"%"}'

echo ""
echo -e "${GREEN}💡 RECOMENDACIONES:${NC}"
echo -e "  1. Usa la netbook para Chrome y comunicaciones"
echo -e "  2. Mantén máximo 3 MVPs activos simultáneamente"
echo -e "  3. Ejecuta este script semanalmente"
echo -e "  4. Considera reiniciar si la RAM libre < 1GB"
echo ""

# Guardar estado en log
echo "$(date '+%Y-%m-%d %H:%M:%S') - Freed: $((INITIAL_MEM - FINAL_MEM)) MB" >> ~/optimization_log.txt

# Check si Trinity Cortex está corriendo
if lsof -i:7777 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Trinity Cortex activo en puerto 7777${NC}"
else
    echo -e "${YELLOW}⚠️  Trinity Cortex no detectado. Ejecuta: ./start_trinity.sh${NC}"
fi

exit 0
