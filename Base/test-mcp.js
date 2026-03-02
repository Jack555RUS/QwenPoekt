// Тест MCP Filesystem сервера
// Запуск: node test-mcp.js

import { readFile, readdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';

async function testFileSystem() {
    const testPath = 'D:\\QwenPoekt';
    
    console.log('🧪 ТЕСТ ДОСТУПА К ФАЙЛОВОЙ СИСТЕМЕ\n');
    
    // Тест 1: Проверка существования папки
    console.log('Тест 1: Проверка существования папки');
    console.log(`Путь: ${testPath}`);
    console.log(`Существует: ${existsSync(testPath) ? '✅ ДА' : '❌ НЕТ'}\n`);
    
    // Тест 2: Чтение папки
    console.log('Тест 2: Чтение содержимого папки');
    try {
        const files = await readdir(testPath, { withFileTypes: true });
        console.log(`Найдено объектов: ${files.length}`);
        console.log('Список:');
        files.slice(0, 10).forEach(file => {
            const type = file.isDirectory() ? '📁' : '📄';
            console.log(`  ${type} ${file.name}`);
        });
        if (files.length > 10) {
            console.log(`  ... и ещё ${files.length - 10} объектов`);
        }
        console.log('');
    } catch (err) {
        console.log(`❌ Ошибка: ${err.message}\n`);
    }
    
    // Тест 3: Чтение файла
    console.log('Тест 3: Чтение файла');
    const testFile = 'D:\\QwenPoekt\\Base\\README.md';
    try {
        if (existsSync(testFile)) {
            const content = await readFile(testFile, 'utf8');
            console.log(`Файл: ${testFile}`);
            console.log(`Размер: ${content.length} символов`);
            console.log('Первые 200 символов:');
            console.log(content.substring(0, 200));
            console.log('✅ УСПЕХ\n');
        } else {
            console.log(`❌ Файл не найден: ${testFile}\n`);
        }
    } catch (err) {
        console.log(`❌ Ошибка: ${err.message}\n`);
    }
    
    // Тест 4: Проверка Junction ссылок
    console.log('Тест 4: Проверка Junction ссылок');
    const junctions = [
        'D:\\QwenPoekt\\Base\\_PROJECTS',
        'D:\\QwenPoekt\\Base\\_BACKUP_LINK',
        'D:\\QwenPoekt\\Base\\_TEST_ENV_LINK'
    ];
    
    for (const junction of junctions) {
        const exists = existsSync(junction);
        console.log(`${exists ? '✅' : '❌'} ${junction}`);
    }
    console.log('');
    
    console.log('✅ ТЕСТ ЗАВЕРШЁН');
}

testFileSystem().catch(console.error);
