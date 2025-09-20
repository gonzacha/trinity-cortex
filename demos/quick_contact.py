#!/usr/bin/env python3
"""
🚀 QUICK CONTACT - Automatizador de Primeros Contactos
Genera mensajes personalizados para WhatsApp/LinkedIn
"""

import json
from datetime import datetime

# TEMPLATES DE MENSAJES QUE FUNCIONAN
templates = {
    "inmobiliaria": {
        "whatsapp": """Hola {nombre}, soy {tu_nombre}, desarrollador especializado en inmobiliarias.

Vi que {empresa} está en {ciudad} y noté que podrían estar perdiendo ventas por no tener seguimiento automático de clientes.

Desarrollé un CRM simple que:
✓ Avisa por WhatsApp cuando entra un lead
✓ Gestiona propiedades con fotos
✓ Funciona en celular y PC

¿Te puedo mandar un video de 2 min?

PD: Primer mes gratis para probar sin compromiso.""",
        
        "linkedin": """Hola {nombre},

Vi que trabajás en {empresa} como {cargo}.

Ayudo a inmobiliarias de {ciudad} a no perder ventas con un CRM simple que se implementa en 48hs.

¿Te interesa una charla de 15 minutos para ver si les puede servir?

Primer mes gratis, sin tarjeta de crédito.""",
        
        "email": """Asunto: ¿Perdiendo ventas por falta de seguimiento? - {empresa}

Hola {nombre},

El 73% de las inmobiliarias pierden al menos 2 ventas mensuales por no hacer seguimiento de sus leads.

Por eso desarrollé un CRM específico para inmobiliarias de Santa Fe que:
• Notifica por WhatsApp cada lead nuevo
• Organiza propiedades y clientes
• Se implementa en 48 horas

{empresa} podría estar perdiendo AR$ 300.000 mensuales en comisiones.

¿Te interesa ver una demo de 5 minutos?

Link al video: [URL]

Saludos,
{tu_nombre}

PD: 30 días gratis. Si no les sirve, no pagan nada."""
    },
    
    "consultorio": {
        "whatsapp": """Hola Dr./Dra. {nombre},

Soy {tu_nombre}, desarrollador de sistemas médicos.

Creé un sistema de turnos online que reduce 80% las llamadas telefónicas. Los pacientes sacan turno solos, 24/7.

Sistema funcionando en 48hs.
Primer mes gratis para probar.

¿Le mando un video mostrando cómo funciona?""",
        
        "linkedin": """Dr./Dra. {nombre},

Vi que maneja {empresa} en {ciudad}.

¿Cuántas horas semanales pierden atendiendo teléfono para turnos?

Tengo un sistema que lo automatiza completamente. 

¿15 minutos para mostrárselo esta semana?""",
    },
    
    "gastronomia": {
        "whatsapp": """Hola {nombre}, 

Vi que {empresa} está pagando 30% de comisión en apps de delivery.

Armé un sistema de pedidos propio, sin comisiones, solo para ustedes.

Recuperan la inversión en 2 meses.

¿Te muestro cómo funciona? Video de 3 minutos.""",
        
        "linkedin": """Hola {nombre},

Las apps de delivery se quedan con 30% de cada pedido de {empresa}.

¿Sabías que podés tener tu propio sistema sin comisiones?

Me especializo en esto. ¿Charlamos 15 minutos?"""
    }
}

# PROSPECTOS DE EJEMPLO (Reemplazar con datos reales)
prospectos_ejemplo = [
    {
        "nombre": "Juan Pérez",
        "empresa": "Inmobiliaria Centro",
        "cargo": "Gerente General",
        "ciudad": "Santa Fe",
        "telefono": "+54 9 342 XXX-XXXX",
        "email": "juan@inmobiliariacentro.com",
        "linkedin": "linkedin.com/in/juanperez",
        "tipo": "inmobiliaria"
    },
    {
        "nombre": "María González",
        "empresa": "Propiedades MG",
        "cargo": "Dueña",
        "ciudad": "Cañada de Gómez",
        "telefono": "+54 9 341 XXX-XXXX",
        "tipo": "inmobiliaria"
    },
    {
        "nombre": "Dr. Carlos López",
        "empresa": "Consultorio Médico López",
        "cargo": "Director",
        "ciudad": "Santa Fe",
        "tipo": "consultorio"
    }
]

def generar_mensajes(prospecto, tu_nombre="Tu Nombre"):
    """Genera mensajes personalizados para un prospecto"""
    
    tipo = prospecto.get('tipo', 'inmobiliaria')
    mensajes = {}
    
    # Datos para personalización
    datos = {
        "nombre": prospecto.get('nombre', 'Estimado/a'),
        "empresa": prospecto.get('empresa', 'su empresa'),
        "cargo": prospecto.get('cargo', 'Gerente'),
        "ciudad": prospecto.get('ciudad', 'Santa Fe'),
        "tu_nombre": tu_nombre
    }
    
    # Generar mensaje para cada canal
    for canal in ['whatsapp', 'linkedin', 'email']:
        if canal in templates.get(tipo, {}):
            mensajes[canal] = templates[tipo][canal].format(**datos)
    
    return mensajes

def guardar_mensajes(prospectos, tu_nombre):
    """Guarda todos los mensajes en un archivo"""
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"mensajes_{timestamp}.md"
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(f"# MENSAJES PERSONALIZADOS - {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n")
        f.write(f"**Generados para:** {tu_nombre}\n\n")
        f.write("---\n\n")
        
        for i, prospecto in enumerate(prospectos, 1):
            mensajes = generar_mensajes(prospecto, tu_nombre)
            
            f.write(f"## {i}. {prospecto.get('nombre', 'Prospecto')} - {prospecto.get('empresa', 'Empresa')}\n\n")
            f.write(f"**Tipo:** {prospecto.get('tipo', 'general')}\n")
            f.write(f"**Ciudad:** {prospecto.get('ciudad', 'No especificada')}\n")
            
            if prospecto.get('telefono'):
                f.write(f"**WhatsApp:** {prospecto['telefono']}\n")
            if prospecto.get('linkedin'):
                f.write(f"**LinkedIn:** {prospecto['linkedin']}\n")
            if prospecto.get('email'):
                f.write(f"**Email:** {prospecto['email']}\n")
            
            f.write("\n")
            
            for canal, mensaje in mensajes.items():
                f.write(f"### 📱 Mensaje para {canal.upper()}:\n\n")
                f.write("```\n")
                f.write(mensaje)
                f.write("\n```\n\n")
            
            f.write("**Status:** ⏳ Pendiente de envío\n")
            f.write("**Notas:** _____________________\n\n")
            f.write("---\n\n")
        
        # Agregar estadísticas
        f.write("## 📊 RESUMEN\n\n")
        f.write(f"- Total prospectos: {len(prospectos)}\n")
        f.write(f"- Mensajes generados: {len(prospectos) * 3}\n")
        f.write("- Canales: WhatsApp, LinkedIn, Email\n\n")
        
        # Agregar checklist de seguimiento
        f.write("## ✅ CHECKLIST DE SEGUIMIENTO\n\n")
        f.write("### Día 1 (Hoy):\n")
        for p in prospectos:
            f.write(f"- [ ] Enviar WhatsApp a {p.get('nombre', 'Prospecto')}\n")
        
        f.write("\n### Día 3 (Follow-up):\n")
        for p in prospectos:
            f.write(f"- [ ] Follow-up a {p.get('nombre', 'Prospecto')} si no respondió\n")
        
        f.write("\n### Día 7 (LinkedIn):\n")
        for p in prospectos:
            f.write(f"- [ ] Conectar en LinkedIn con {p.get('nombre', 'Prospecto')}\n")
        
        f.write("\n### Día 10 (Último intento):\n")
        for p in prospectos:
            f.write(f"- [ ] Llamada telefónica a {p.get('nombre', 'Prospecto')}\n")
    
    print(f"✅ Mensajes guardados en: {filename}")
    return filename

def main():
    print("""
    ╔══════════════════════════════════════════╗
    ║    GENERADOR DE MENSAJES DE VENTA       ║
    ║         Contacto Rápido v1.0            ║
    ╚══════════════════════════════════════════╝
    """)
    
    # Solicitar nombre del usuario
    tu_nombre = input("\n👤 Tu nombre completo: ").strip()
    if not tu_nombre:
        tu_nombre = "Desarrollador"
    
    print(f"\n¡Hola {tu_nombre}! Vamos a generar mensajes personalizados.\n")
    
    # Opción de usar ejemplos o ingresar datos
    print("¿Qué querés hacer?")
    print("1. Usar prospectos de ejemplo")
    print("2. Ingresar mis propios prospectos")
    print("3. Cargar desde CSV (próximamente)")
    
    opcion = input("\nOpción (1-3): ").strip()
    
    if opcion == "1":
        prospectos = prospectos_ejemplo
        print(f"\n📋 Usando {len(prospectos)} prospectos de ejemplo")
    
    elif opcion == "2":
        prospectos = []
        print("\n📝 Ingresá los datos de tus prospectos (vacío para terminar):\n")
        
        while True:
            print(f"--- Prospecto #{len(prospectos) + 1} ---")
            nombre = input("Nombre: ").strip()
            if not nombre:
                break
            
            empresa = input("Empresa: ").strip()
            ciudad = input("Ciudad: ").strip()
            telefono = input("WhatsApp (opcional): ").strip()
            
            print("Tipo: 1) Inmobiliaria 2) Consultorio 3) Gastronomía")
            tipo_num = input("Tipo (1-3): ").strip()
            
            tipo_map = {"1": "inmobiliaria", "2": "consultorio", "3": "gastronomia"}
            tipo = tipo_map.get(tipo_num, "inmobiliaria")
            
            prospectos.append({
                "nombre": nombre,
                "empresa": empresa,
                "ciudad": ciudad,
                "telefono": telefono,
                "tipo": tipo
            })
            
            print(f"✅ {nombre} agregado\n")
    
    else:
        print("❌ Opción no válida")
        return
    
    if not prospectos:
        print("\n⚠️ No hay prospectos para procesar")
        return
    
    # Generar y guardar mensajes
    print(f"\n🚀 Generando mensajes para {len(prospectos)} prospectos...")
    archivo = guardar_mensajes(prospectos, tu_nombre)
    
    # Mostrar primer mensaje como ejemplo
    if prospectos:
        primer_mensaje = generar_mensajes(prospectos[0], tu_nombre)
        print("\n📱 EJEMPLO DE MENSAJE GENERADO:")
        print("=" * 50)
        print(primer_mensaje.get('whatsapp', 'No disponible'))
        print("=" * 50)
    
    print(f"\n✨ LISTO! Todos los mensajes están en: {archivo}")
    print("\n💡 PRÓXIMOS PASOS:")
    print("1. Abrí el archivo y copiá cada mensaje")
    print("2. Pegalo en WhatsApp/LinkedIn/Email")
    print("3. Personalizá si hace falta algún detalle")
    print("4. Enviá entre 10-11 AM o 15-16 PM (mejor horario)")
    print("5. Marcá como ✅ en el checklist cuando envíes")
    print("\n🎯 Con 50 mensajes, conseguís 2-3 clientes seguros!")

if __name__ == "__main__":
    main()
