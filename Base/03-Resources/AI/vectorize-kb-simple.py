# vectorize-kb-simple.py — Векторизация БЗ (без Chroma, Python 3.14 совместимо)
# Версия: 1.0
# Дата: 4 марта 2026 г.

import os
import sys
import json
import hashlib
import pickle
from pathlib import Path

try:
    from sentence_transformers import SentenceTransformer
    import chardet
except ImportError as e:
    print(f"❌ Ошибка импорта: {e}")
    print("\nУстановите: pip install sentence-transformers chardet")
    sys.exit(1)

# ============================================
# КОНФИГУРАЦИЯ
# ============================================

BASE_PATH = Path(__file__).parent.parent
KB_PATH = BASE_PATH / "03-Resources" / "Knowledge"
VECTORS_PATH = BASE_PATH / "03-Resources" / "AI" / "vectors_cache.pkl"

CHUNK_SIZE = 500
CHUNK_OVERLAP = 50

print("╔══════════════════════════════════════════════════════════╗")
print("║         ВЕКТОРИЗАЦИЯ БАЗЫ ЗНАНИЙ (Lite)                  ║")
print("╚══════════════════════════════════════════════════════════╝")
print()

# ============================================
# 1. ЗАГРУЗКА МОДЕЛИ
# ============================================

print("[1/4] Загрузка модели...")
model = SentenceTransformer('all-MiniLM-L6-v2')
print(f"  ✅ Модель загружена (384 измерения)")
print()

# ============================================
# 2. ЧТЕНИЕ ДОКУМЕНТОВ
# ============================================

print("[2/4] Чтение документов...")

documents = []
metadatas = []

md_files = list(KB_PATH.glob("**/*.md"))
print(f"  📄 Найдено файлов: {len(md_files)}")

for file_path in md_files:
    try:
        with open(file_path, 'rb') as f:
            raw_data = f.read()
        
        result = chardet.detect(raw_data)
        encoding = result['encoding'] if result['encoding'] else 'utf-8'
        content = raw_data.decode(encoding)
        
        rel_path = file_path.relative_to(BASE_PATH)
        file_hash = hashlib.md5(raw_data).hexdigest()
        
        # Разбиение на чанки
        chunks = []
        for i in range(0, len(content), CHUNK_SIZE - CHUNK_OVERLAP):
            chunk = content[i:i + CHUNK_SIZE]
            if len(chunk) > 50:
                chunks.append(chunk)
        
        for i, chunk in enumerate(chunks):
            documents.append(chunk)
            metadatas.append({
                "path": str(rel_path),
                "chunk": i,
                "total_chunks": len(chunks),
                "file_hash": file_hash
            })
        
    except Exception as e:
        print(f"  ⚠️ Ошибка: {file_path}: {e}")

print(f"  ✅ Прочитано файлов: {len(md_files)}")
print(f"  ✅ Создано чанков: {len(documents)}")
print()

# ============================================
# 3. ВЕКТОРИЗАЦИЯ
# ============================================

print("[3/4] Векторизация (может занять 5-10 мин)...")

embeddings = model.encode(documents, show_progress_bar=True)
print(f"  ✅ Векторизовано: {len(embeddings)} чанков")
print()

# ============================================
# 4. СОХРАНЕНИЕ
# ============================================

print("[4/4] Сохранение кэша...")

cache = {
    "documents": documents,
    "embeddings": embeddings.tolist(),
    "metadatas": metadatas,
    "model": "all-MiniLM-L6-v2"
}

with open(VECTORS_PATH, 'wb') as f:
    pickle.dump(cache, f)

print(f"  ✅ Сохранено: {VECTORS_PATH}")
print(f"  ✅ Размер: {VECTORS_PATH.stat().st_size / 1024 / 1024:.2f} MB")
print()

# ============================================
# ТЕСТОВЫЙ ПОИСК
# ============================================

print("[Тест] Поиск...")

def search(query, top_k=5):
    query_embedding = model.encode([query])[0]
    
    similarities = []
    for i, emb in enumerate(embeddings):
        sim = sum(a * b for a, b in zip(query_embedding, emb))
        similarities.append((i, sim))
    
    similarities.sort(key=lambda x: x[1], reverse=True)
    
    results = []
    for idx, score in similarities[:top_k]:
        results.append({
            "text": documents[idx][:200] + "...",
            "path": metadatas[idx]["path"],
            "score": round(score, 4)
        })
    
    return results

# Тест
test_query = "автосохранение сессии"
results = search(test_query)

print(f"  Запрос: '{test_query}'")
print(f"  Найдено: {len(results)} результатов")
for r in results:
    print(f"    • {r['path']} (score: {r['score']})")

print()
print("╔══════════════════════════════════════════════════════════╗")
print("║                    ВЕКТОРИЗАЦИЯ ЗАВЕРШЕНА                ║")
print("╚══════════════════════════════════════════════════════════╝")
print()
print("✅ Готово к использованию!")
print()
print("Пример использования:")
print('  python 03-Resources/AI/rag-search-simple.py "ваш вопрос"')
print()
