// mcp-session-saver.js — MCP сервер для сохранения сессий
// Версия: 3.0 (для SDK 1.x с McpServer)
// Дата: 2026-03-03
// Назначение: Прямое сохранение диалога ИИ в файлы сессий

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { writeFile, mkdir, readFile, readdir } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';

// ============================================
// КОНФИГУРАЦИЯ
// ============================================

const __dirname = dirname(fileURLToPath(import.meta.url));
const BASE_PATH = join(__dirname, '..');
const SESSIONS_PATH = join(BASE_PATH, 'sessions');

// ============================================
// СХЕМЫ ZOD ДЛЯ ВАЛИДАЦИИ
// ============================================

const SaveSessionSchema = z.object({
  chat: z.string().describe('Переписка (Markdown формат)'),
  sessionId: z.string().describe('ID сессии (YYYY-MM-DD_HH-mm)'),
  metadata: z.object({}).optional().describe('Метаданные сессии (JSON)'),
  task: z.string().optional().describe('Текущая задача')
});

const LoadSessionSchema = z.object({
  sessionId: z.string().describe('ID сессии для загрузки')
});

const ListSessionsSchema = z.object({
  limit: z.number().optional().default(10).describe('Максимальное количество сессий')
});

const UpdateResumeMarkerSchema = z.object({
  sessionId: z.string().describe('ID текущей сессии'),
  currentTask: z.string().optional().describe('Текущая задача'),
  nextStep: z.string().optional().describe('Следующий шаг')
});

// ============================================
// ИНИЦИАЛИЗАЦИЯ СЕРВЕРА
// ============================================

const server = new McpServer({
  name: 'session-saver',
  version: '3.0.0'
}, {
  capabilities: {
    tools: {}
  }
});

// ============================================
// РЕГИСТРАЦИЯ ИНСТРУМЕНТОВ
// ============================================

// Инструмент: list_sessions
server.registerTool('list_sessions', {
  description: 'Получить список всех сессий',
  inputSchema: {
    limit: z.number().optional().default(10).describe('Максимальное количество сессий')
  }
}, async (args) => {
  const { limit = 10 } = ListSessionsSchema.parse(args || {});

  try {
    const entries = await readdir(SESSIONS_PATH, { withFileTypes: true });
    const sessions = [];

    for (const entry of entries) {
      if (entry.isDirectory() && !entry.name.startsWith('_')) {
        const sessionPath = join(SESSIONS_PATH, entry.name);
        const metadataPath = join(sessionPath, 'metadata.json');

        try {
          const metadata = JSON.parse(await readFile(metadataPath, 'utf8'));
          sessions.push({
            id: entry.name,
            timestamp: metadata.timestamp || 0,
            task: metadata.task || '',
            savedAt: metadata.saved_at || ''
          });
        } catch {
          sessions.push({
            id: entry.name,
            timestamp: 0,
            task: '',
            savedAt: ''
          });
        }
      }
    }

    // Сортировка по убыванию времени
    sessions.sort((a, b) => b.timestamp - a.timestamp);

    // Ограничение количества
    const limited = sessions.slice(0, limit);

    return {
      content: [{
        type: 'text',
        text: `📊 Найдено сессий: ${sessions.length}\n\n` +
              limited.map(s => `• **${s.id}** — ${s.task || 'Без задачи'}\n  🕐 ${s.savedAt || 'Время не указано'}`).join('\n')
      }]
    };
  } catch (error) {
    return {
      isError: true,
      content: [{ type: 'text', text: `❌ Ошибка: ${error.message}` }]
    };
  }
});

// Инструмент: save_session
server.registerTool('save_session', {
  description: 'Сохранить текущую сессию (диалог + метаданные)',
  inputSchema: {
    chat: z.string().describe('Переписка (Markdown формат)'),
    sessionId: z.string().describe('ID сессии (YYYY-MM-DD_HH-mm)'),
    metadata: z.object({}).optional().describe('Метаданные сессии (JSON)'),
    task: z.string().optional().describe('Текущая задача')
  }
}, async (args) => {
  const { chat, metadata, sessionId, task } = SaveSessionSchema.parse(args);

  // Создание папки сессии
  const sessionPath = join(SESSIONS_PATH, sessionId);
  await mkdir(sessionPath, { recursive: true });

  // Формирование полного содержимого chat.md
  const header = `# 📋 СЕССИЯ: ${sessionId}

**Дата:** ${new Date().toLocaleString('ru-RU')}
**Задача:** ${task || 'Не указана'}
**Сохранено:** ${new Date().toLocaleString('ru-RU')}

---

## 📖 ДИАЛОГ

`;

  const fullChat = header + chat;

  // Сохранение chat.md
  const chatFilePath = join(sessionPath, 'chat.md');
  await writeFile(chatFilePath, fullChat, 'utf8');

  // Сохранение metadata.json
  const metadataPath = join(sessionPath, 'metadata.json');
  const fullMetadata = {
    session_id: sessionId,
    timestamp: Date.now(),
    task: task || '',
    saved_at: new Date().toISOString(),
    ...metadata
  };
  await writeFile(metadataPath, JSON.stringify(fullMetadata, null, 2), 'utf8');

  // Расчёт размера
  const chatSize = (fullChat.length / 1024).toFixed(2);
  const metaSize = (JSON.stringify(fullMetadata).length / 1024).toFixed(2);

  return {
    content: [{
      type: 'text',
      text: `✅ Сессия сохранена: ${sessionId}\n📁 Путь: ${sessionPath}\n💾 Размер: chat.md (${chatSize} KB), metadata.json (${metaSize} KB)`
    }]
  };
});

// Инструмент: load_session
server.registerTool('load_session', {
  description: 'Загрузить сохранённую сессию',
  inputSchema: {
    sessionId: z.string().describe('ID сессии для загрузки')
  }
}, async (args) => {
  const { sessionId } = LoadSessionSchema.parse(args);

  const sessionPath = join(SESSIONS_PATH, sessionId);
  const chatPath = join(sessionPath, 'chat.md');
  const metadataPath = join(sessionPath, 'metadata.json');

  // Проверка существования
  try {
    await readFile(chatPath, 'utf8');
  } catch {
    return {
      isError: true,
      content: [{ type: 'text', text: `❌ Сессия не найдена: ${sessionId}` }]
    };
  }

  // Чтение файлов
  const chat = await readFile(chatPath, 'utf8');
  const metadata = JSON.parse(await readFile(metadataPath, 'utf8'));

  return {
    content: [{
      type: 'text',
      text: `✅ Сессия загружена: ${sessionId}\n📄 Сообщений: ${metadata.message_count || 'N/A'}\n🕐 Время: ${new Date(metadata.timestamp).toLocaleString('ru-RU')}`
    }],
    data: { chat, metadata }
  };
});

// Инструмент: update_resume_marker
server.registerTool('update_resume_marker', {
  description: 'Обновить маркер восстановления сессии',
  inputSchema: {
    sessionId: z.string().describe('ID текущей сессии'),
    currentTask: z.string().optional().describe('Текущая задача'),
    nextStep: z.string().optional().describe('Следующий шаг')
  }
}, async (args) => {
  const { currentTask, nextStep, sessionId } = UpdateResumeMarkerSchema.parse(args);

  const markerPath = join(BASE_PATH, '.resume_marker.json');

  const markerData = {
    GitCommit: await getGitCommit(),
    AutoSave: true,
    CurrentTask: currentTask || '',
    NextStep: nextStep || '',
    Date: new Date().toLocaleString('ru-RU'),
    Reason: 'MCP Session Saver',
    SessionFile: `sessions/${sessionId}/chat.md`
  };

  await writeFile(markerPath, JSON.stringify(markerData, null, 2), 'utf8');

  return {
    content: [{
      type: 'text',
      text: `✅ Маркер восстановления обновлён\n📋 Задача: ${currentTask || 'Не указана'}\n📍 Шаг: ${nextStep || 'Не указан'}`
    }]
  };
});

// ============================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// ============================================

async function getGitCommit() {
  try {
    const { exec } = await import('node:child_process');
    return new Promise((resolve) => {
      exec('git rev-parse HEAD', (error, stdout) => {
        resolve(error ? null : stdout.trim());
      });
    });
  } catch {
    return null;
  }
}

// ============================================
// ЗАПУСК СЕРВЕРА
// ============================================

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('✅ MCP Session Saver запущен (SDK 1.x, McpServer)');
}

main().catch((error) => {
  console.error('❌ Критическая ошибка:', error);
  process.exit(1);
});
