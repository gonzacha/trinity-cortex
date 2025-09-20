#!/usr/bin/env python3
"""
🔱 TCC v3.0 - TRINITY COMMAND CORTEX
Sistema de orquestación con micro-conversaciones paralelas y aprendizaje distribuido
Cada LLM aprende de las otras a través de TCC
"""

import asyncio
import json
import os
import sqlite3
import hashlib
from datetime import datetime
from typing import Dict, List, Any, Optional
from concurrent.futures import ThreadPoolExecutor
import aiohttp
import threading
from queue import Queue
import time

# Configuración
TRINITY_HOME = os.path.expanduser("~/.trinity-cortex")
MEMORY_DB = f"{TRINITY_HOME}/trinity_memory.db"
CONTEXT_FILE = f"{TRINITY_HOME}/active_context.json"

# Crear directorios
os.makedirs(TRINITY_HOME, exist_ok=True)
os.makedirs(f"{TRINITY_HOME}/memories", exist_ok=True)
os.makedirs(f"{TRINITY_HOME}/learnings", exist_ok=True)

class MemorySystem:
    """Sistema de memoria persistente y compartida"""
    
    def __init__(self):
        self.conn = sqlite3.connect(MEMORY_DB, check_same_thread=False)
        self.init_db()
        self.context = self.load_context()
        
    def init_db(self):
        """Inicializar base de datos de memoria"""
        cursor = self.conn.cursor()
        
        # Tabla de interacciones
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS interactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                session_id TEXT,
                llm TEXT,
                query TEXT,
                response TEXT,
                tokens_used INTEGER,
                processing_time REAL,
                success BOOLEAN
            )
        ''')
        
        # Tabla de aprendizajes
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS learnings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                pattern TEXT,
                source_llm TEXT,
                learned_by TEXT,
                knowledge TEXT,
                confidence REAL
            )
        ''')
        
        # Tabla de contextos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS contexts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                context_hash TEXT UNIQUE,
                context_data TEXT,
                usage_count INTEGER DEFAULT 0
            )
        ''')
        
        self.conn.commit()
    
    def load_context(self) -> Dict:
        """Cargar contexto activo"""
        if os.path.exists(CONTEXT_FILE):
            with open(CONTEXT_FILE, 'r') as f:
                return json.load(f)
        return {
            "session_id": hashlib.md5(str(time.time()).encode()).hexdigest()[:8],
            "start_time": datetime.now().isoformat(),
            "active_threads": {},
            "shared_knowledge": {},
            "current_objective": None
        }
    
    def save_context(self):
        """Guardar contexto activo"""
        with open(CONTEXT_FILE, 'w') as f:
            json.dump(self.context, f, indent=2)
    
    def record_interaction(self, llm: str, query: str, response: str, 
                          processing_time: float, success: bool = True):
        """Registrar interacción con un LLM"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO interactions 
            (timestamp, session_id, llm, query, response, processing_time, success)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            datetime.now().isoformat(),
            self.context["session_id"],
            llm,
            query,
            response,
            processing_time,
            success
        ))
        self.conn.commit()
        
    def record_learning(self, pattern: str, source_llm: str, 
                       learned_by: str, knowledge: str, confidence: float):
        """Registrar un aprendizaje compartido"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO learnings
            (timestamp, pattern, source_llm, learned_by, knowledge, confidence)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            datetime.now().isoformat(),
            pattern,
            source_llm,
            learned_by,
            knowledge,
            confidence
        ))
        self.conn.commit()
    
    def get_relevant_memories(self, query: str, limit: int = 5) -> List[Dict]:
        """Obtener memorias relevantes para una consulta"""
        cursor = self.conn.cursor()
        
        # Búsqueda simple por similitud de texto
        cursor.execute('''
            SELECT llm, query, response, timestamp
            FROM interactions
            WHERE query LIKE ? OR response LIKE ?
            ORDER BY timestamp DESC
            LIMIT ?
        ''', (f'%{query[:30]}%', f'%{query[:30]}%', limit))
        
        memories = []
        for row in cursor.fetchall():
            memories.append({
                'llm': row[0],
                'query': row[1],
                'response': row[2],
                'timestamp': row[3]
            })
        
        return memories


class LLMConnector:
    """Conector base para LLMs con micro-conversaciones"""
    
    def __init__(self, name: str, memory: MemorySystem):
        self.name = name
        self.memory = memory
        self.conversation_history = []
        self.active = True
        
    async def micro_conversation(self, query: str, context: Dict) -> Dict:
        """Mantener micro-conversación con el LLM"""
        start_time = time.time()
        
        # Enriquecer query con contexto y memorias
        enriched_query = self.enrich_query(query, context)
        
        try:
            # Llamar al LLM específico
            response = await self.call_llm(enriched_query)
            
            # Extraer aprendizajes
            learnings = self.extract_learnings(response)
            
            # Registrar en memoria
            processing_time = time.time() - start_time
            self.memory.record_interaction(
                self.name, query, response, processing_time, True
            )
            
            # Compartir aprendizajes
            for learning in learnings:
                self.memory.record_learning(
                    learning['pattern'],
                    self.name,
                    'TCC',
                    learning['knowledge'],
                    learning.get('confidence', 0.8)
                )
            
            return {
                'llm': self.name,
                'response': response,
                'learnings': learnings,
                'processing_time': processing_time,
                'success': True
            }
            
        except Exception as e:
            return {
                'llm': self.name,
                'error': str(e),
                'processing_time': time.time() - start_time,
                'success': False
            }
    
    def enrich_query(self, query: str, context: Dict) -> str:
        """Enriquecer query con contexto y memorias relevantes"""
        memories = self.memory.get_relevant_memories(query, limit=3)
        
        enriched = f"{query}\n\n"
        
        if context.get('current_objective'):
            enriched += f"Current Objective: {context['current_objective']}\n"
        
        if memories:
            enriched += "Relevant memories:\n"
            for mem in memories:
                enriched += f"- {mem['llm']}: {mem['query'][:100]}...\n"
        
        if context.get('shared_knowledge'):
            enriched += f"\nShared knowledge: {json.dumps(context['shared_knowledge'], indent=2)}\n"
        
        return enriched
    
    def extract_learnings(self, response: str) -> List[Dict]:
        """Extraer patrones y aprendizajes de la respuesta"""
        learnings = []
        
        # Análisis básico de patrones
        if "import" in response or "def " in response or "class " in response:
            learnings.append({
                'pattern': 'code_structure',
                'knowledge': 'Code pattern detected',
                'confidence': 0.9
            })
        
        if "error" in response.lower() or "bug" in response.lower():
            learnings.append({
                'pattern': 'error_handling',
                'knowledge': 'Error or bug mentioned',
                'confidence': 0.8
            })
        
        if "optimize" in response.lower() or "improve" in response.lower():
            learnings.append({
                'pattern': 'optimization',
                'knowledge': 'Optimization suggestion',
                'confidence': 0.85
            })
        
        return learnings
    
    async def call_llm(self, query: str) -> str:
        """Llamada específica al LLM (override en subclases)"""
        raise NotImplementedError


class ClaudeConnector(LLMConnector):
    """Conector para Claude con micro-conversaciones"""
    
    async def call_llm(self, query: str) -> str:
        api_key = os.getenv('ANTHROPIC_API_KEY')
        if not api_key:
            return "Claude API key not configured"
        
        async with aiohttp.ClientSession() as session:
            headers = {
                'x-api-key': api_key,
                'anthropic-version': '2023-06-01',
                'content-type': 'application/json'
            }
            
            payload = {
                'model': 'claude-3-sonnet-20240229',
                'max_tokens': 1024,
                'messages': [{'role': 'user', 'content': query}]
            }
            
            async with session.post(
                'https://api.anthropic.com/v1/messages',
                headers=headers,
                json=payload
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    return data['content'][0]['text']
                else:
                    return f"Claude error: {response.status}"


class CodexConnector(LLMConnector):
    """Conector para OpenAI/Codex con micro-conversaciones"""
    
    async def call_llm(self, query: str) -> str:
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            return "OpenAI API key not configured"
        
        async with aiohttp.ClientSession() as session:
            headers = {
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'model': 'gpt-4',
                'messages': [
                    {'role': 'system', 'content': 'You are Codex, specialized in code generation and technical implementation.'},
                    {'role': 'user', 'content': query}
                ],
                'max_tokens': 1024
            }
            
            async with session.post(
                'https://api.openai.com/v1/chat/completions',
                headers=headers,
                json=payload
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    return data['choices'][0]['message']['content']
                else:
                    return f"Codex error: {response.status}"


class GeminiConnector(LLMConnector):
    """Conector para Gemini con micro-conversaciones"""
    
    async def call_llm(self, query: str) -> str:
        api_key = os.getenv('GEMINI_API_KEY') or os.getenv('GOOGLE_API_KEY')
        if not api_key:
            return "Gemini API key not configured"
        
        async with aiohttp.ClientSession() as session:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={api_key}"
            
            payload = {
                'contents': [{
                    'parts': [{'text': query}]
                }]
            }
            
            async with session.post(url, json=payload) as response:
                if response.status == 200:
                    data = await response.json()
                    return data['candidates'][0]['content']['parts'][0]['text']
                else:
                    return f"Gemini error: {response.status}"


class TrinityCortex:
    """
    TCC - El córtex central que orquesta micro-conversaciones paralelas
    y facilita el aprendizaje distribuido entre LLMs
    """
    
    def __init__(self):
        self.memory = MemorySystem()
        self.llms = {
            'claude': ClaudeConnector('claude', self.memory),
            'codex': CodexConnector('codex', self.memory),
            'gemini': GeminiConnector('gemini', self.memory)
        }
        self.learning_queue = Queue()
        self.active_objective = None
        
        # Iniciar thread de aprendizaje
        self.learning_thread = threading.Thread(target=self.learning_loop, daemon=True)
        self.learning_thread.start()
    
    def learning_loop(self):
        """Loop continuo de aprendizaje y distribución de conocimiento"""
        while True:
            try:
                if not self.learning_queue.empty():
                    learning = self.learning_queue.get()
                    # Distribuir aprendizaje a otros LLMs
                    self.distribute_learning(learning)
                time.sleep(0.1)
            except Exception as e:
                print(f"Learning loop error: {e}")
    
    def distribute_learning(self, learning: Dict):
        """Distribuir aprendizaje a otros LLMs"""
        source_llm = learning.get('source_llm')
        knowledge = learning.get('knowledge')
        
        # Actualizar contexto compartido
        if 'shared_knowledge' not in self.memory.context:
            self.memory.context['shared_knowledge'] = {}
        
        self.memory.context['shared_knowledge'][source_llm] = knowledge
        self.memory.save_context()
    
    async def orchestrate(self, query: str, mode: str = 'parallel') -> Dict:
        """
        Orquestar micro-conversaciones con múltiples LLMs
        
        Modes:
        - parallel: Todos los LLMs procesan simultáneamente
        - sequential: Cada LLM construye sobre el anterior
        - consensus: Los LLMs llegan a un consenso
        - specialized: Cada LLM maneja su especialidad
        """
        
        print(f"\n🔱 TRINITY CORTEX - Orchestration Mode: {mode}")
        print(f"📝 Query: {query}\n")
        
        self.memory.context['current_objective'] = query
        
        if mode == 'parallel':
            return await self.parallel_orchestration(query)
        elif mode == 'sequential':
            return await self.sequential_orchestration(query)
        elif mode == 'consensus':
            return await self.consensus_orchestration(query)
        elif mode == 'specialized':
            return await self.specialized_orchestration(query)
        else:
            return await self.parallel_orchestration(query)
    
    async def parallel_orchestration(self, query: str) -> Dict:
        """Todas las IAs procesan en paralelo"""
        print("🔄 Initiating parallel micro-conversations...")
        
        # Crear tareas paralelas
        tasks = []
        for name, llm in self.llms.items():
            task = llm.micro_conversation(query, self.memory.context)
            tasks.append(task)
        
        # Ejecutar en paralelo
        results = await asyncio.gather(*tasks)
        
        # Consolidar resultados
        consolidated = self.consolidate_results(results)
        
        # Compartir aprendizajes
        for result in results:
            if result.get('success') and result.get('learnings'):
                for learning in result['learnings']:
                    self.learning_queue.put({
                        'source_llm': result['llm'],
                        'knowledge': learning['knowledge']
                    })
        
        return consolidated
    
    async def sequential_orchestration(self, query: str) -> Dict:
        """Cada IA construye sobre la anterior"""
        print("🔗 Initiating sequential micro-conversations...")
        
        results = []
        current_context = self.memory.context.copy()
        
        # Claude analiza primero
        print("  1️⃣ Claude analyzing strategy...")
        claude_result = await self.llms['claude'].micro_conversation(query, current_context)
        results.append(claude_result)
        
        # Actualizar contexto con resultado de Claude
        if claude_result.get('success'):
            current_context['claude_analysis'] = claude_result['response']
            
            # Codex implementa basado en Claude
            print("  2️⃣ Codex implementing based on Claude's analysis...")
            codex_query = f"Based on this analysis: {claude_result['response'][:500]}...\n\nImplement: {query}"
            codex_result = await self.llms['codex'].micro_conversation(codex_query, current_context)
            results.append(codex_result)
            
            if codex_result.get('success'):
                current_context['codex_implementation'] = codex_result['response']
                
                # Gemini optimiza basado en ambos
                print("  3️⃣ Gemini optimizing based on both...")
                gemini_query = f"Optimize and validate this implementation:\n{codex_result['response'][:500]}..."
                gemini_result = await self.llms['gemini'].micro_conversation(gemini_query, current_context)
                results.append(gemini_result)
        
        return self.consolidate_results(results)
    
    async def consensus_orchestration(self, query: str) -> Dict:
        """Las IAs llegan a un consenso"""
        print("🤝 Initiating consensus building...")
        
        # Primera ronda: respuestas independientes
        round1 = await self.parallel_orchestration(query)
        
        # Segunda ronda: cada IA revisa las otras respuestas
        consensus_query = f"Original query: {query}\n\nOther perspectives:\n"
        for result in round1.get('results', []):
            if result.get('success'):
                consensus_query += f"\n{result['llm']}: {result['response'][:200]}...\n"
        
        consensus_query += "\nProvide your refined answer considering all perspectives:"
        
        # Ejecutar segunda ronda
        tasks = []
        for name, llm in self.llms.items():
            task = llm.micro_conversation(consensus_query, self.memory.context)
            tasks.append(task)
        
        round2 = await asyncio.gather(*tasks)
        
        return {
            'mode': 'consensus',
            'round1': round1,
            'consensus': self.consolidate_results(round2),
            'timestamp': datetime.now().isoformat()
        }
    
    async def specialized_orchestration(self, query: str) -> Dict:
        """Cada IA maneja su especialidad"""
        print("🎯 Initiating specialized orchestration...")
        
        # Analizar query para determinar especialidades necesarias
        specialties = self.identify_specialties(query)
        
        results = []
        
        if 'strategy' in specialties or 'analysis' in specialties:
            print("  📊 Claude handling strategy/analysis...")
            claude_query = f"Provide strategic analysis for: {query}"
            result = await self.llms['claude'].micro_conversation(claude_query, self.memory.context)
            results.append(result)
        
        if 'code' in specialties or 'implementation' in specialties:
            print("  💻 Codex handling implementation...")
            codex_query = f"Provide code implementation for: {query}"
            result = await self.llms['codex'].micro_conversation(codex_query, self.memory.context)
            results.append(result)
        
        if 'research' in specialties or 'optimization' in specialties:
            print("  🔬 Gemini handling research/optimization...")
            gemini_query = f"Research and optimize: {query}"
            result = await self.llms['gemini'].micro_conversation(gemini_query, self.memory.context)
            results.append(result)
        
        return self.consolidate_results(results)
    
    def identify_specialties(self, query: str) -> List[str]:
        """Identificar qué especialidades necesita la query"""
        specialties = []
        
        query_lower = query.lower()
        
        # Patterns para detectar necesidades
        if any(word in query_lower for word in ['strategy', 'plan', 'analyze', 'design']):
            specialties.append('strategy')
        
        if any(word in query_lower for word in ['code', 'implement', 'function', 'api', 'script']):
            specialties.append('code')
        
        if any(word in query_lower for word in ['research', 'optimize', 'improve', 'compare']):
            specialties.append('research')
        
        if not specialties:
            specialties = ['strategy', 'code', 'research']
        
        return specialties
    
    def consolidate_results(self, results: List[Dict]) -> Dict:
        """Consolidar resultados de múltiples LLMs"""
        successful = [r for r in results if r.get('success')]
        failed = [r for r in results if not r.get('success')]
        
        consolidated = {
            'success': len(successful) > 0,
            'mode': 'orchestrated',
            'timestamp': datetime.now().isoformat(),
            'session_id': self.memory.context['session_id'],
            'results': results,
            'summary': {
                'successful': len(successful),
                'failed': len(failed),
                'total_processing_time': sum(r.get('processing_time', 0) for r in results),
                'learnings_extracted': sum(len(r.get('learnings', [])) for r in results)
            }
        }
        
        # Crear respuesta unificada
        if successful:
            unified = "\n\n".join([
                f"[{r['llm'].upper()}]:\n{r['response']}" 
                for r in successful
            ])
            consolidated['unified_response'] = unified
        
        return consolidated
    
    def show_memory_stats(self):
        """Mostrar estadísticas de memoria"""
        cursor = self.memory.conn.cursor()
        
        # Total interacciones
        cursor.execute("SELECT COUNT(*) FROM interactions")
        total_interactions = cursor.fetchone()[0]
        
        # Total aprendizajes
        cursor.execute("SELECT COUNT(*) FROM learnings")
        total_learnings = cursor.fetchone()[0]
        
        # Interacciones por LLM
        cursor.execute("""
            SELECT llm, COUNT(*), AVG(processing_time) 
            FROM interactions 
            GROUP BY llm
        """)
        
        print("\n📊 TRINITY MEMORY STATISTICS")
        print("=" * 40)
        print(f"Total Interactions: {total_interactions}")
        print(f"Total Learnings: {total_learnings}")
        print(f"Session ID: {self.memory.context['session_id']}")
        print("\nPer LLM Statistics:")
        
        for row in cursor.fetchall():
            print(f"  {row[0]}: {row[1]} interactions, {row[2]:.2f}s avg")
        
        print("=" * 40)


async def interactive_mode():
    """Modo interactivo de Trinity Cortex"""
    cortex = TrinityCortex()
    
    print("""
    ╔══════════════════════════════════════════╗
    ║       🔱 TRINITY CORTEX v3.0 🔱         ║
    ║   Parallel Micro-Conversations System    ║
    ║      Distributed Learning Enabled        ║
    ╚══════════════════════════════════════════╝
    
    Commands:
      'query'                - Parallel orchestration (default)
      'seq: query'          - Sequential orchestration
      'consensus: query'    - Consensus mode
      'spec: query'         - Specialized mode
      'memory'              - Show memory statistics
      'clear'               - Clear screen
      'exit'                - Exit TCC
    """)
    
    while True:
        try:
            user_input = input("\n🔱 tcc> ").strip()
            
            if not user_input:
                continue
            
            if user_input == 'exit':
                print("Trinity Cortex shutting down...")
                break
            
            if user_input == 'memory':
                cortex.show_memory_stats()
                continue
            
            if user_input == 'clear':
                os.system('clear' if os.name != 'nt' else 'cls')
                continue
            
            # Determinar modo
            mode = 'parallel'
            query = user_input
            
            if user_input.startswith('seq:'):
                mode = 'sequential'
                query = user_input[4:].strip()
            elif user_input.startswith('consensus:'):
                mode = 'consensus'
                query = user_input[10:].strip()
            elif user_input.startswith('spec:'):
                mode = 'specialized'
                query = user_input[5:].strip()
            
            # Ejecutar orquestación
            result = await cortex.orchestrate(query, mode)
            
            # Mostrar resultados
            print("\n" + "=" * 50)
            if result.get('unified_response'):
                print(result['unified_response'])
            
            print("\n📊 Summary:")
            summary = result.get('summary', {})
            print(f"  ✓ Successful: {summary.get('successful', 0)}")
            print(f"  ✗ Failed: {summary.get('failed', 0)}")
            print(f"  ⏱️ Total Time: {summary.get('total_processing_time', 0):.2f}s")
            print(f"  🧠 Learnings: {summary.get('learnings_extracted', 0)}")
            
        except KeyboardInterrupt:
            print("\n\nInterrupted by user")
            break
        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    # Ejecutar modo interactivo
    asyncio.run(interactive_mode())
