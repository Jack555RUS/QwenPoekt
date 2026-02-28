using System;
using UnityEngine;

/// <summary>
/// Модель данных игрока.
/// Хранит всю информацию о прогрессе.
/// </summary>
[Serializable]
public class PlayerData
{
    /// <summary>
    /// Уникальный идентификатор игрока.
    /// </summary>
    public string PlayerId;

    /// <summary>
    /// Имя игрока.
    /// </summary>
    public string PlayerName;

    /// <summary>
    /// Текущий уровень игрока.
    /// </summary>
    public int Level;

    /// <summary>
    /// Опыт игрока.
    /// </summary>
    public int Experience;

    /// <summary>
    /// Деньги игрока.
    /// </summary>
    public int Money;

    /// <summary>
    /// ID текущего автомобиля.
    /// </summary>
    public int CurrentCarId;

    /// <summary>
    /// Массив IDs открытых автомобилей.
    /// </summary>
    public int[] UnlockedCars;

    /// <summary>
    /// Дата последнего сохранения.
    /// </summary>
    public string LastSaveDate;

    /// <summary>
    /// Общее время игры в секундах.
    /// </summary>
    public float TotalPlayTime;

    /// <summary>
    /// Количество выигранных гонок.
    /// </summary>
    public int RacesWon;

    /// <summary>
    /// Количество проигранных гонок.
    /// </summary>
    public int RacesLost;

    /// <summary>
    /// Лучшее время на трассе (ключ: трасса, значение: время).
    /// </summary>
    public string BestTrackTimes;

    /// <summary>
    /// Создать новые данные игрока.
    /// </summary>
    public PlayerData()
    {
        PlayerId = Guid.NewGuid().ToString();
        PlayerName = "Racer";
        Level = 1;
        Experience = 0;
        Money = 1000;
        CurrentCarId = 0;
        UnlockedCars = new int[] { 0 };
        LastSaveDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        TotalPlayTime = 0f;
        RacesWon = 0;
        RacesLost = 0;
        BestTrackTimes = "";
    }

    /// <summary>
    /// Добавить опыт.
    /// </summary>
    public void AddExperience(int amount)
    {
        Experience += amount;
        
        // Простая формула уровня: каждый уровень требует 1000 * level опыта
        int requiredExp = Level * 1000;
        while (Experience >= requiredExp)
        {
            Experience -= requiredExp;
            Level++;
            Logger.Info($"Уровень повышен! Теперь уровень {Level}", null);
        }
    }

    /// <summary>
    /// Добавить деньги.
    /// </summary>
    public void AddMoney(int amount)
    {
        Money += amount;
        Logger.Info($"Деньги добавлены: +{amount}, всего: {Money}", null);
    }

    /// <summary>
    /// Потратить деньги.
    /// </summary>
    public bool SpendMoney(int amount)
    {
        if (Money >= amount)
        {
            Money -= amount;
            Logger.Info($"Деньги потрачены: -{amount}, осталось: {Money}", null);
            return true;
        }
        
        Logger.Warning($"Недостаточно денег! Требуется: {amount}, есть: {Money}", null);
        return false;
    }

    /// <summary>
    /// Разблокировать автомобиль.
    /// </summary>
    public void UnlockCar(int carId)
    {
        if (!IsCarUnlocked(carId))
        {
            Array.Resize(ref UnlockedCars, UnlockedCars.Length + 1);
            UnlockedCars[UnlockedCars.Length - 1] = carId;
            Logger.Info($"Автомобиль {carId} разблокирован!", null);
        }
    }

    /// <summary>
    /// Проверить, разблокирован ли автомобиль.
    /// </summary>
    public bool IsCarUnlocked(int carId)
    {
        foreach (int id in UnlockedCars)
        {
            if (id == carId)
                return true;
        }
        return false;
    }

    /// <summary>
    /// Записать время игры.
    /// </summary>
    public void UpdatePlayTime(float deltaTime)
    {
        TotalPlayTime += deltaTime;
    }

    /// <summary>
    /// Записать победу.
    /// </summary>
    public void RecordWin()
    {
        RacesWon++;
        Logger.Info($"Победа! Всего побед: {RacesWon}", null);
    }

    /// <summary>
    /// Записать поражение.
    /// </summary>
    public void RecordLoss()
    {
        RacesLost++;
        Logger.Info($"Поражение. Всего поражений: {RacesLost}", null);
    }

    /// <summary>
    /// Обновить дату сохранения.
    /// </summary>
    public void UpdateSaveDate()
    {
        LastSaveDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
    }
}
