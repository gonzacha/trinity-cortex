#!/usr/bin/env python3
"""
🎯 LEAD GENERATOR AUTOMÁTICO
Encuentra y califica prospectos de manera inteligente
"""

import json
import csv
import requests
from datetime import datetime
from typing import List, Dict
import re
import time

class LeadGenerator:
    def __init__(self):
        self.leads = []
        self.qualified_leads = []
        
    def search_linkedin_companies(self, industry: str, city: str, size: str) -> List[Dict]:
        """
        Simula búsqueda de empresas en LinkedIn
        En producción, usar LinkedIn API o scraping ético
        """
        # Template de empresas por industria
        company_templates = {
            "inmobiliaria": [
                {"name": "Inmobiliaria del Centro", "size": "10-50", "pain": "Sin CRM"},
                {"name": "Propiedades Premium", "size": "5-20", "pain": "Gestión manual"},
                {"name": "Bienes Raíces Plus", "size": "20-100", "pain": "Sin automatización"},
            ],
            "gastronomia": [
                {"name": "Restaurante Don José", "size": "10-30", "pain": "Sin delivery propio"},
                {"name": "Café Cultural", "size": "5-15", "pain": "Sin reservas online"},
                {"name": "Parrilla La Esquina", "size": "15-40", "pain": "Control de stock manual"},
            ],
            "salud": [
                {"name": "Clínica San Martín", "size": "20-100", "pain": "Turnos por teléfono"},
                {"name": "Centro Médico Integral", "size": "10-50", "pain": "Sin historia clínica digital"},
                {"name": "Consultorio Dr. García", "size": "1-10", "pain": "Agenda en papel"},
            ],
            "educacion": [
                {"name": "Instituto Superior", "size": "50-200", "pain": "Sin plataforma online"},
                {"name": "Academia de Idiomas", "size": "10-30", "pain": "Gestión manual de cursos"},
                {"name": "Centro de Capacitación", "size": "5-20", "pain": "Sin LMS propio"},
            ],
            "manufactura": [
                {"name": "Metalúrgica Industrial", "size": "30-100", "pain": "Sin control de inventario"},
                {"name": "Fábrica de Muebles", "size": "20-50", "pain": "Producción no optimizada"},
                {"name": "Textil del Norte", "size": "50-150", "pain": "Sin trazabilidad"},
            ]
        }
        
        companies = company_templates.get(industry.lower(), [])
        
        for company in companies:
            company.update({
                "city": city,
                "industry": industry,
                "website": f"www.{company['name'].lower().replace(' ', '')}.com.ar",
                "score": 0
            })
            
        return companies
    
    def find_decision_makers(self, company: Dict) -> List[Dict]:
        """
        Encuentra decision makers en la empresa
        """
        # Simulación - en producción usar herramientas reales
        decision_makers = [
            {
                "name": f"Juan Pérez",
                "position": "CEO",
                "email": f"juan@{company['website']}",
                "linkedin": f"linkedin.com/in/juanperez",
                "phone": "+54 9 11 1234-5678"
            },
            {
                "name": f"María González",
                "position": "Gerente General",
                "email": f"maria@{company['website']}",
                "linkedin": f"linkedin.com/in/mariagonzalez",
                "phone": "+54 9 11 8765-4321"
            }
        ]
        
        return decision_makers
    
    def qualify_lead(self, company: Dict) -> int:
        """
        Califica el lead del 1 al 10
        """
        score = 5  # Base score
        
        # Tamaño ideal (10-50 empleados)
        if "10-50" in company['size'] or "20-100" in company['size']:
            score += 2
        elif "5-20" in company['size']:
            score += 1
            
        # Pain point claro
        if company.get('pain'):
            if 'manual' in company['pain'].lower() or 'sin' in company['pain'].lower():
                score += 2
                
        # Industria prioritaria
        priority_industries = ['inmobiliaria', 'gastronomia', 'salud']
        if company['industry'].lower() in priority_industries:
            score += 1
            
        company['score'] = min(score, 10)
        return score
    
    def generate_approach(self, company: Dict, decision_maker: Dict) -> Dict:
        """
        Genera estrategia de approach personalizada
        """
        templates = {
            "email_subject": f"¿{company['pain']}? Solución en 48hs para {company['name']}",
            "email_opening": f"Hola {decision_maker['name'].split()[0]}, vi que {company['name']} está en {company['city']} y probablemente enfrentan el desafío de {company['pain']}.",
            "value_prop": f"Ayudamos a empresas de {company['industry']} a resolver esto con una solución que implementamos en 48 horas.",
            "social_proof": f"Ya trabajamos con 3 empresas similares en {company['city']} con resultados en la primera semana.",
            "cta": "¿Tienes 15 minutos esta semana para una llamada rápida?",
            "follow_up_sequence": [
                {"day": 3, "channel": "email", "message": "Reenvío con caso de éxito adjunto"},
                {"day": 7, "channel": "linkedin", "message": "Conexión + mensaje personalizado"},
                {"day": 10, "channel": "whatsapp", "message": "Audio de 30 segundos con propuesta"}
            ]
        }
        
        return templates
    
    def export_leads(self, filename: str = "leads.csv"):
        """
        Exporta leads a CSV
        """
        if not self.qualified_leads:
            print("No hay leads calificados para exportar")
            return
            
        with open(filename, 'w', newline='', encoding='utf-8') as file:
            fieldnames = ['company', 'industry', 'city', 'size', 'pain', 'score', 
                         'contact_name', 'contact_position', 'contact_email', 
                         'contact_phone', 'approach_strategy']
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            writer.writeheader()
            
            for lead in self.qualified_leads:
                writer.writerow(lead)
                
        print(f"✅ Leads exportados a {filename}")
    
    def run(self, industries: List[str], city: str, min_score: int = 6):
        """
        Ejecuta el proceso completo de generación de leads
        """
        print("🎯 INICIANDO BÚSQUEDA DE LEADS")
        print("=" * 50)
        
        all_companies = []
        
        # Buscar empresas por industria
        for industry in industries:
            print(f"\n📍 Buscando en industria: {industry}")
            companies = self.search_linkedin_companies(industry, city, "10-50")
            all_companies.extend(companies)
            print(f"   Encontradas: {len(companies)} empresas")
            time.sleep(1)  # Rate limiting
        
        print(f"\n📊 Total empresas encontradas: {len(all_companies)}")
        
        # Calificar y buscar decision makers
        print("\n🔍 Calificando leads y buscando contactos...")
        
        for company in all_companies:
            # Calificar
            score = self.qualify_lead(company)
            
            if score >= min_score:
                # Buscar decision makers
                decision_makers = self.find_decision_makers(company)
                
                for dm in decision_makers:
                    # Generar estrategia
                    approach = self.generate_approach(company, dm)
                    
                    # Crear lead calificado
                    qualified_lead = {
                        'company': company['name'],
                        'industry': company['industry'],
                        'city': company['city'],
                        'size': company['size'],
                        'pain': company['pain'],
                        'score': score,
                        'contact_name': dm['name'],
                        'contact_position': dm['position'],
                        'contact_email': dm['email'],
                        'contact_phone': dm['phone'],
                        'approach_strategy': json.dumps(approach, ensure_ascii=False)
                    }
                    
                    self.qualified_leads.append(qualified_lead)
        
        # Resumen
        print("\n" + "=" * 50)
        print("📈 RESUMEN DE RESULTADOS")
        print("=" * 50)
        print(f"✅ Leads calificados (score >= {min_score}): {len(self.qualified_leads)}")
        
        # Top 10 leads
        sorted_leads = sorted(self.qualified_leads, key=lambda x: x['score'], reverse=True)[:10]
        
        print("\n🏆 TOP 10 MEJORES LEADS:")
        for i, lead in enumerate(sorted_leads, 1):
            print(f"{i}. {lead['company']} ({lead['industry']}) - Score: {lead['score']}/10")
            print(f"   Contacto: {lead['contact_name']} ({lead['contact_position']})")
            print(f"   Pain: {lead['pain']}")
            print()
        
        # Exportar
        self.export_leads(f"leads_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv")
        
        # Generar script de emails
        self.generate_email_templates(sorted_leads[:5])
        
        return self.qualified_leads
    
    def generate_email_templates(self, top_leads: List[Dict]):
        """
        Genera templates de email para los mejores leads
        """
        print("\n📧 GENERANDO TEMPLATES DE EMAIL")
        print("=" * 50)
        
        with open("email_templates.md", "w", encoding='utf-8') as f:
            f.write("# EMAIL TEMPLATES PARA TOP LEADS\n\n")
            
            for i, lead in enumerate(top_leads, 1):
                approach = json.loads(lead['approach_strategy'])
                
                f.write(f"## Lead #{i}: {lead['company']}\n")
                f.write(f"**Para:** {lead['contact_email']}\n")
                f.write(f"**Asunto:** {approach['email_subject']}\n\n")
                f.write("```\n")
                f.write(f"{approach['email_opening']}\n\n")
                f.write(f"{approach['value_prop']}\n\n")
                f.write(f"{approach['social_proof']}\n\n")
                f.write(f"{approach['cta']}\n\n")
                f.write("Saludos,\n")
                f.write("[Tu nombre]\n")
                f.write("```\n\n")
                f.write("**Secuencia de follow-up:**\n")
                for followup in approach['follow_up_sequence']:
                    f.write(f"- Día {followup['day']}: {followup['channel']} - {followup['message']}\n")
                f.write("\n---\n\n")
        
        print("✅ Templates guardados en email_templates.md")


def main():
    """
    Función principal
    """
    print("""
    ╔════════════════════════════════════════╗
    ║   LEAD GENERATOR PRO v1.0             ║
    ║   Encuentra clientes donde está el    ║
    ║   pique 🎣                            ║
    ╚════════════════════════════════════════╝
    """)
    
    # Configuración
    industries = ['inmobiliaria', 'gastronomia', 'salud', 'educacion', 'manufactura']
    city = "Santa Fe"
    min_score = 6
    
    # Ejecutar
    generator = LeadGenerator()
    leads = generator.run(industries, city, min_score)
    
    print(f"\n✨ Proceso completado. {len(leads)} leads listos para contactar.")
    print("📁 Revisa los archivos generados:")
    print("   - leads_*.csv: Lista completa de leads")
    print("   - email_templates.md: Templates de email personalizados")
    print("\n💡 Siguiente paso: Importar CSV a tu CRM o Google Sheets")
    

if __name__ == "__main__":
    main()
