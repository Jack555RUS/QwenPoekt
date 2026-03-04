# vectorize-kb.py — Векторизация Базы Знаний для Chroma DB
# Версия: 1.0
# Дата: 4 марта 2026 г.

import os
import sys
import hashlib
from pathlib import Path

try:
    import chromadb
    from chromadb.config import Settings
    from sentence_transformers import SentenceTransformer
    import markdown
    import chardet
except ImportError as e:
    print(f"❌ Ошибка импорта: {e}")
    print("\nУстановите зависимости:")
    print("  pip install -r 03-Resources/AI/requirements-vector-db.txt")
    sys.exit(1)

# ============================================
# КОНФИГУРАЦИЯ
# ============================================

BASE_PATH = Path(__file__).parent.parent
CHROMA_PATH = BASE_PATH / "chroma" / "knowledge_base"
KB_PATH = BASE_PATH / "03-Resources" / "Knowledge"

CHUNK_SIZE = 500  # символов
CHUNK_OVERLAP = 50  # символов

print("╔══════════════════════════════════════════════════════════╗")
print("║         ВЕКТОРИЗАЦИЯ БАЗЫ ЗНАНИЙ                         ║")
print("╚══════════════════════════════════════════════════════════╝")
print()

# ============================================
# 1. ИНИЦИАЛИЗАЦИЯ
# ============================================

print("[1/5] Инициализация Chroma DB...")

# Создание клиента Chroma
client = chromadb.PersistentClient(path=str(CHROMA_PATH))

# Создание или получение коллекции
try:
    collection = client.get_collection("knowledge_base")
    print(f"  ✅ Коллекция найдена")
    count = collection.count()
    print(f"  📊 Документов в БД: {count}")
except Exception:
    collection = client.create_collection("knowledge_base")
    print(f"  ✅ Коллекция создана")

# Загрузка модели для эмбеддингов
print("  📥 Загрузка модели (может занять 1-2 мин)...")
model = SentenceTransformer('all-MiniLM-L6-v2')
print(f"  ✅ Модель загружена (384 измерения)")
print()

# ============================================
# 2. ЧТЕНИЕ ДОКУМЕНТОВ
# ============================================

print("[2/5] Чтение документов...")

documents = []
metadatas = []
ids = []

md_files = list(KB_PATH.glob("**/*.md"))
print(f"  📄 Найдено файлов: {len(md_files)}")

for file_path in md_files:
    try:
        # Чтение файла
        with open(file_path, 'rb') as f:
            raw_data = f.read()
        
        # Определение кодировки
        result = chardet.detect(raw_data)
        encoding = result['encoding'] if result['encoding'] else 'utf-8'
        
        # Декодирование
        content = raw_data.decode(encoding)
        
        # Метаданные
        rel_path = file_path.relative_to(BASE_PATH)
        file_hash = hashlib.md5(raw_data).hexdigest()
        
        # Разбиение на чанки
        chunks = []
        for i in range(0, len(content), CHUNK_SIZE - CHUNK_OVERLAP):
            chunk = content[i:i + CHUNK_SIZE]
            if len(chunk) > 50:  # Минимальный размер чанка
                chunks.append(chunk)
        
        # Добавление чанков
        for i, chunk in enumerate(chunks):
            documents.append(chunk)
            metadatas.append({
                "path": str(rel_path),
                "chunk": i,
                "total_chunks": len(chunks),
                "file_hash": file_hash
            })
            ids.append(f"{rel_path}:{i}")
        
    except Exception as e:
        print(f"  ⚠️ Ошибка чтения {file_path}: {e}")

print(f"  ✅ Прочитано файлов: {len(md_files)}")
print(f"  ✅ Создано чанков: {len(documents)}")
print()

# ============================================
# 3. ВЕКТОРИЗАЦИЯ И СОХРАНЕНИЕ
# ============================================

print("[3/5] Векторизация и сохранение...")

# Пакетная обработка (по 100 чанков)
batch_size = 100
total_batches = (len(documents) + batch_size - 1) // batch_size

for i in range(0, len(documents), batch_size):
    batch_docs = documents[i:i + batch_size]
    batch_meta = metadatas[i:i + batch_size]
    batch_ids = ids[i:i + batch_size]
    
    # Векторизация
    embeddings = model.encode(batch_docs).tolist()
    
    # Сохранение в Chroma
    collection.add(
        documents=batch_docs,
        embeddings=embeddings,
        metadatas=batch_meta,
        ids=batch_ids
    )
    
    batch_num = (i // batch_size) + 1
    print(f"  📊 Пакет {batch_num}/{total_batches} — обработано {min(i + batch_size, len(documents))}/{len(documents)} чанков")

print(f"  ✅ Векторизация завершена")
print()

# ============================================
# 4. ПРОВЕРКА
# ============================================

print("[4/5] Проверка...")

count = collection.count()
print(f"  📊 Всего документов в БД: {count}")

# Тестовый поиск
test_query = "автосохранение сессии"
print(f"  🔍 Тестовый запрос: '{test_query}'")

# Векторизация запроса
query_embedding = model.encode([test_query]).tolist()

# Поиск
results = collection.query(
    query_embeddings=query_embedding,
    n_results=3,
    include=["documents", "metadatas", "distances"]
)

if results['documents'] and len(results['documents'][0]) > 0:
    print(f"  ✅ Найдено результатов: {len(results['documents'][0])}")
    for i, doc in enumerate(results['documents'][0]):
        path = results['metadatas'][0][i]['path']
        distance = results['distances'][0][i]
        print(f"    {i+1}. {path} (distance: {distance:.4f})")
else:
    print(f"  ⚠️ Результаты не найдены")

print()

# ============================================
# 5. ИТОГИ
# ============================================

print("[5/5] Итоги...")
print()
print("╔══════════════════════════════════════════════════════════╗")
print("║                    ВЕКТОРИЗАЦИЯ ЗАВЕРШЕНА                ║")
print("╚══════════════════════════════════════════════════════════╝")
print()
print(f"📊 Обработано файлов: {len(md_files)}")
print(f"📊 Создано чанков: {len(documents)}")
print(f"📊 Документов в БД: {count}")
print(f"💾 Chroma DB: {CHROMA_PATH}")
print()
print("✅ Готово к использованию!")
print()
print("Пример использования:")
print('  python 03-Resources/AI/rag-search.py "как настроить автосохранение?"')
print()
