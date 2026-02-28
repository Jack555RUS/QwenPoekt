-- =============================================================================
-- Инициализация базы данных для ProbMenu
-- =============================================================================

-- Таблица сохранений игры
CREATE TABLE IF NOT EXISTS game_saves (
    id SERIAL PRIMARY KEY,
    save_name VARCHAR(255) NOT NULL,
    player_name VARCHAR(100),
    progress_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Таблица статистики гонок
CREATE TABLE IF NOT EXISTS race_stats (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    car_type VARCHAR(100),
    race_time_ms INTEGER,
    track_name VARCHAR(255),
    position INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица настроек игроков
CREATE TABLE IF NOT EXISTS player_settings (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(100) UNIQUE NOT NULL,
    settings_data JSONB NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица лидеров (leaderboard)
CREATE TABLE IF NOT EXISTS leaderboard (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL,
    best_time_ms INTEGER NOT NULL,
    track_name VARCHAR(255) NOT NULL,
    car_type VARCHAR(100),
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для ускорения поиска
CREATE INDEX IF NOT EXISTS idx_game_saves_active ON game_saves(is_active);
CREATE INDEX IF NOT EXISTS idx_game_saves_player ON game_saves(player_name);
CREATE INDEX IF NOT EXISTS idx_race_stats_player ON race_stats(player_name);
CREATE INDEX IF NOT EXISTS idx_race_stats_time ON race_stats(race_time_ms);
CREATE INDEX IF NOT EXISTS idx_leaderboard_time ON leaderboard(best_time_ms);
CREATE INDEX IF NOT EXISTS idx_leaderboard_track ON leaderboard(track_name);

-- Функция обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггеры для автообновления updated_at
CREATE TRIGGER update_game_saves_updated_at
    BEFORE UPDATE ON game_saves
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_settings_updated_at
    BEFORE UPDATE ON player_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Начальные данные (демонстрация)
INSERT INTO player_settings (player_name, settings_data) 
VALUES 
    ('Default', '{"volume": 0.7, "difficulty": "normal", "controls": "keyboard"}')
ON CONFLICT (player_name) DO NOTHING;
