# rag-search-simple.py — RAG Поиск (без Chroma)
# Версия: 1.0
# Дата: 4 марта 2026 г.

import sys
import pickle
from pathlib import Path

try:
    from sentence_transformers import SentenceTransformer
except ImportError as e:
    print(f"❌ Ошибка: {e}")
    print("Установите: pip install sentence-transformers")
    sys.exit(1)

# Пути
BASE_PATH = Path(__file__).parent.parent
VECTORS_PATH = BASE_PATH / "03-Resources" / "AI" / "vectors_cache.pkl"

# Загрузка кэша
print("Загрузка векторов...")
with open(VECTORS_PATH, 'rb') as f:
    cache = pickle.load(f)

documents = cache["documents"]
embeddings = cache["embeddings"]
metadatas = cache["metadatas"]

print(f"✅ Загружено: {len(documents)} чанков")

# Загрузка модели
model = SentenceTransformer('all-MiniLM-L6-v2')

# Поиск
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
            "text": documents[idx],
            "path": metadatas[idx]["path"],
            "chunk": metadatas[idx]["chunk"],
            "score": round(score, 4)
        })
    
    return results

# Главный цикл
if __name__ == "__main__":
    if len(sys.argv) > 1:
        query = " ".join(sys.argv[1:])
    else:
        query = input("\nВаш запрос: ")
    
    print(f"\n🔍 Поиск: '{query}'\n")
    
    results = search(query, top_k=5)
    
    print(f"✅ Найдено: {len(results)} результатов\n")
    
    for i, r in enumerate(results, 1):
        print(f"{i}. {r['path']} (chunk {r['chunk']}, score: {r['score']})")
        print(f"   {r['text'][:150]}...\n")
