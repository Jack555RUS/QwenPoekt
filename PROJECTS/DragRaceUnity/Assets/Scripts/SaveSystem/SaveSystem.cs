using System;
using System.IO;
using UnityEngine;

/// <summary>
/// Система сохранений для DragRaceUnity.
/// Поддерживает 5 слотов сохранений.
/// </summary>
public static class SaveSystem
{
    /// <summary>
    /// Количество слотов сохранений.
    /// </summary>
    public const int SaveSlotsCount = 5;

    /// <summary>
    /// Путь к папке сохранений.
    /// </summary>
    private static readonly string SavePath = Path.Combine(Application.persistentDataPath, "SaveGames");

    /// <summary>
    /// Расширение файлов сохранений.
    /// </summary>
    private const string SaveExtension = ".save";

    /// <summary>
    /// Инициализировать систему сохранений.
    /// </summary>
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void Initialize()
    {
        // Создаём папку для сохранений, если не существует
        if (!Directory.Exists(SavePath))
        {
            Directory.CreateDirectory(SavePath);
            Logger.Info($"Папка сохранений создана: {SavePath}", null);
        }
        
        Logger.Info($"Система сохранений инициализирована. Слотов: {SaveSlotsCount}", null);
    }

    #region Public Methods

    /// <summary>
    /// Сохранить данные игрока в указанный слот.
    /// </summary>
    /// <param name="slot">Номер слота (0-4).</param>
    /// <param name="data">Данные для сохранения.</param>
    /// <returns>True если сохранение успешно.</returns>
    public static bool Save(int slot, PlayerData data)
    {
        if (!IsValidSlot(slot))
        {
            Logger.Error($"Неверный номер слота: {slot}. Допустимые: 0-{SaveSlotsCount - 1}", null);
            return false;
        }

        try
        {
            // Обновляем дату сохранения
            data.UpdateSaveDate();

            // Сериализуем в JSON
            string json = JsonUtility.ToJson(data, true);

            // Получаем путь к файлу
            string filePath = GetSaveFilePath(slot);

            // Записываем файл
            File.WriteAllText(filePath, json);

            Logger.Info($"Сохранение в слот {slot} успешно. Файл: {filePath}", null);
            return true;
        }
        catch (Exception e)
        {
            Logger.Error($"Ошибка сохранения в слот {slot}: {e.Message}", null);
            return false;
        }
    }

    /// <summary>
    /// Загрузить данные игрока из указанного слота.
    /// </summary>
    /// <param name="slot">Номер слота (0-4).</param>
    /// <returns>Данные игрока или null если загрузка не удалась.</returns>
    public static PlayerData Load(int slot)
    {
        if (!IsValidSlot(slot))
        {
            Logger.Error($"Неверный номер слота: {slot}. Допустимые: 0-{SaveSlotsCount - 1}", null);
            return null;
        }

        try
        {
            string filePath = GetSaveFilePath(slot);

            // Проверяем существование файла
            if (!File.Exists(filePath))
            {
                Logger.Warning($"Слот {slot} пуст. Файл не найден: {filePath}", null);
                return null;
            }

            // Читаем файл
            string json = File.ReadAllText(filePath);

            // Десериализуем
            PlayerData data = JsonUtility.FromJson<PlayerData>(json);

            Logger.Info($"Загрузка из слота {slot} успешна. Игрок: {data.PlayerName}, Уровень: {data.Level}", null);
            return data;
        }
        catch (Exception e)
        {
            Logger.Error($"Ошибка загрузки из слота {slot}: {e.Message}", null);
            return null;
        }
    }

    /// <summary>
    /// Проверить, существует ли сохранение в указанном слоте.
    /// </summary>
    /// <param name="slot">Номер слота (0-4).</param>
    /// <returns>True если сохранение существует.</returns>
    public static bool HasSave(int slot)
    {
        if (!IsValidSlot(slot))
        {
            return false;
        }

        string filePath = GetSaveFilePath(slot);
        return File.Exists(filePath);
    }

    /// <summary>
    /// Удалить сохранение из указанного слота.
    /// </summary>
    /// <param name="slot">Номер слота (0-4).</param>
    /// <returns>True если удаление успешно.</returns>
    public static bool Delete(int slot)
    {
        if (!IsValidSlot(slot))
        {
            Logger.Error($"Неверный номер слота: {slot}", null);
            return false;
        }

        try
        {
            string filePath = GetSaveFilePath(slot);

            if (File.Exists(filePath))
            {
                File.Delete(filePath);
                Logger.Info($"Сохранение в слоте {slot} удалено", null);
                return true;
            }
            else
            {
                Logger.Warning($"Слот {slot} уже пуст", null);
                return false;
            }
        }
        catch (Exception e)
        {
            Logger.Error($"Ошибка удаления слота {slot}: {e.Message}", null);
            return false;
        }
    }

    /// <summary>
    /// Получить информацию о сохранении в слоте.
    /// </summary>
    /// <param name="slot">Номер слота.</param>
    /// <returns>Краткая информация или null если нет сохранения.</returns>
    public static string GetSaveInfo(int slot)
    {
        if (!HasSave(slot))
        {
            return $"Слот {slot}: Пусто";
        }

        PlayerData data = Load(slot);
        if (data == null)
        {
            return $"Слот {slot}: Ошибка чтения";
        }

        return $"Слот {slot}: {data.PlayerName} (Ур. {data.Level}) - {data.LastSaveDate}";
    }

    /// <summary>
    /// Получить все данные о сохранениях.
    /// </summary>
    /// <returns>Массив информации о всех слотах.</returns>
    public static string[] GetAllSaveInfo()
    {
        string[] info = new string[SaveSlotsCount];
        
        for (int i = 0; i < SaveSlotsCount; i++)
        {
            info[i] = GetSaveInfo(i);
        }
        
        return info;
    }

    /// <summary>
    /// Очистить все сохранения.
    /// </summary>
    public static void DeleteAll()
    {
        for (int i = 0; i < SaveSlotsCount; i++)
        {
            Delete(i);
        }
        
        Logger.Info("Все сохранения удалены", null);
    }

    #endregion

    #region Private Methods

    /// <summary>
    /// Проверить валидность слота.
    /// </summary>
    private static bool IsValidSlot(int slot)
    {
        return slot >= 0 && slot < SaveSlotsCount;
    }

    /// <summary>
    /// Получить путь к файлу сохранения.
    /// </summary>
    private static string GetSaveFilePath(int slot)
    {
        return Path.Combine(SavePath, $"SaveSlot_{slot}{SaveExtension}");
    }

    #endregion
}
