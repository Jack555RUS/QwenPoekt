using NUnit.Framework;
using UnityEngine;

/// <summary>
/// Тесты для системы сохранений.
/// </summary>
[TestFixture]
public class SaveSystemTests
{
    private const int TestSlot = 0;
    private PlayerData _testData;

    [SetUp]
    public void SetUp()
    {
        // Создаём тестовые данные
        _testData = new PlayerData
        {
            PlayerName = "TestRacer",
            Level = 5,
            Experience = 2500,
            Money = 5000,
            CurrentCarId = 3
        };

        // Очищаем тестовый слот перед каждым тестом
        SaveSystem.Delete(TestSlot);
    }

    [TearDown]
    public void TearDown()
    {
        // Очищаем тестовый слот после каждого теста
        SaveSystem.Delete(TestSlot);
    }

    #region Save Tests

    [Test]
    public void Save_WithValidData_ReturnsTrue()
    {
        // Act
        bool result = SaveSystem.Save(TestSlot, _testData);

        // Assert
        Assert.That(result, Is.True);
    }

    [Test]
    public void Save_WithValidData_CreatesFile()
    {
        // Act
        SaveSystem.Save(TestSlot, _testData);

        // Assert
        Assert.That(SaveSystem.HasSave(TestSlot), Is.True);
    }

    [Test]
    public void Save_WithInvalidSlot_ReturnsFalse()
    {
        // Act
        bool result = SaveSystem.Save(10, _testData);

        // Assert
        Assert.That(result, Is.False);
    }

    #endregion

    #region Load Tests

    [Test]
    public void Load_WithExistingSave_ReturnsData()
    {
        // Arrange
        SaveSystem.Save(TestSlot, _testData);

        // Act
        PlayerData loadedData = SaveSystem.Load(TestSlot);

        // Assert
        Assert.That(loadedData, Is.Not.Null);
        Assert.That(loadedData.PlayerName, Is.EqualTo(_testData.PlayerName));
        Assert.That(loadedData.Level, Is.EqualTo(_testData.Level));
        Assert.That(loadedData.Money, Is.EqualTo(_testData.Money));
    }

    [Test]
    public void Load_WithEmptySlot_ReturnsNull()
    {
        // Act
        PlayerData result = SaveSystem.Load(TestSlot);

        // Assert
        Assert.That(result, Is.Null);
    }

    [Test]
    public void Load_WithInvalidSlot_ReturnsNull()
    {
        // Act
        PlayerData result = SaveSystem.Load(10);

        // Assert
        Assert.That(result, Is.Null);
    }

    #endregion

    #region Delete Tests

    [Test]
    public void Delete_WithExistingSave_ReturnsTrue()
    {
        // Arrange
        SaveSystem.Save(TestSlot, _testData);

        // Act
        bool result = SaveSystem.Delete(TestSlot);

        // Assert
        Assert.That(result, Is.True);
        Assert.That(SaveSystem.HasSave(TestSlot), Is.False);
    }

    [Test]
    public void Delete_WithEmptySlot_ReturnsFalse()
    {
        // Act
        bool result = SaveSystem.Delete(TestSlot);

        // Assert
        Assert.That(result, Is.False);
    }

    #endregion

    #region HasSave Tests

    [Test]
    public void HasSave_AfterSaving_ReturnsTrue()
    {
        // Arrange
        SaveSystem.Save(TestSlot, _testData);

        // Act
        bool result = SaveSystem.HasSave(TestSlot);

        // Assert
        Assert.That(result, Is.True);
    }

    [Test]
    public void HasSave_BeforeSaving_ReturnsFalse()
    {
        // Act
        bool result = SaveSystem.HasSave(TestSlot);

        // Assert
        Assert.That(result, Is.False);
    }

    #endregion

    #region PlayerData Tests

    [Test]
    public void PlayerData_NewInstance_HasDefaultValues()
    {
        // Arrange & Act
        PlayerData data = new PlayerData();

        // Assert
        Assert.That(data.PlayerName, Is.EqualTo("Racer"));
        Assert.That(data.Level, Is.EqualTo(1));
        Assert.That(data.Money, Is.EqualTo(1000));
        Assert.That(data.UnlockedCars, Is.Not.Null);
    }

    [Test]
    public void PlayerData_AddExperience_IncreasesExperience()
    {
        // Arrange
        int expToAdd = 500;

        // Act
        _testData.AddExperience(expToAdd);

        // Assert
        Assert.That(_testData.Experience, Is.EqualTo(2500 + expToAdd));
    }

    [Test]
    public void PlayerData_AddExperience_LevelsUp()
    {
        // Arrange
        _testData.Experience = 4900;
        _testData.Level = 5;

        // Act
        _testData.AddExperience(1000);

        // Assert
        Assert.That(_testData.Level, Is.GreaterThan(5));
    }

    [Test]
    public void PlayerData_SpendMoney_WithSufficientFunds_ReturnsTrue()
    {
        // Act
        bool result = _testData.SpendMoney(1000);

        // Assert
        Assert.That(result, Is.True);
        Assert.That(_testData.Money, Is.EqualTo(4000));
    }

    [Test]
    public void PlayerData_SpendMoney_WithInsufficientFunds_ReturnsFalse()
    {
        // Act
        bool result = _testData.SpendMoney(10000);

        // Assert
        Assert.That(result, Is.False);
        Assert.That(_testData.Money, Is.EqualTo(5000));
    }

    [Test]
    public void PlayerData_UnlockCar_NewCar_AddsToUnlocked()
    {
        // Act
        _testData.UnlockCar(99);

        // Assert
        Assert.That(_testData.IsCarUnlocked(99), Is.True);
    }

    [Test]
    public void PlayerData_UnlockCar_DuplicateCar_DoesNotAdd()
    {
        // Arrange
        int initialCount = _testData.UnlockedCars.Length;

        // Act
        _testData.UnlockCar(0); // Already unlocked

        // Assert
        Assert.That(_testData.UnlockedCars.Length, Is.EqualTo(initialCount));
    }

    [Test]
    public void PlayerData_RecordWin_IncreasesWinCount()
    {
        // Arrange
        int initialWins = _testData.RacesWon;

        // Act
        _testData.RecordWin();

        // Assert
        Assert.That(_testData.RacesWon, Is.EqualTo(initialWins + 1));
    }

    [Test]
    public void PlayerData_RecordLoss_IncreasesLossCount()
    {
        // Arrange
        int initialLosses = _testData.RacesLost;

        // Act
        _testData.RecordLoss();

        // Assert
        Assert.That(_testData.RacesLost, Is.EqualTo(initialLosses + 1));
    }

    #endregion

    #region Integration Tests

    [Test]
    public void SaveAndLoad_RoundTrip_PreservesData()
    {
        // Arrange
        var originalData = new PlayerData
        {
            PlayerName = "RoundTripTest",
            Level = 10,
            Money = 9999,
            CurrentCarId = 7
        };
        originalData.AddExperience(5000);
        originalData.UnlockCar(42);
        originalData.RecordWin();

        // Act
        SaveSystem.Save(TestSlot, originalData);
        var loadedData = SaveSystem.Load(TestSlot);

        // Assert
        Assert.That(loadedData.PlayerName, Is.EqualTo(originalData.PlayerName));
        Assert.That(loadedData.Level, Is.EqualTo(originalData.Level));
        Assert.That(loadedData.Money, Is.EqualTo(originalData.Money));
        Assert.That(loadedData.CurrentCarId, Is.EqualTo(originalData.CurrentCarId));
        Assert.That(loadedData.RacesWon, Is.EqualTo(originalData.RacesWon));
    }

    [Test]
    public void GetSaveInfo_WithSave_ReturnsCorrectInfo()
    {
        // Arrange
        SaveSystem.Save(TestSlot, _testData);

        // Act
        string info = SaveSystem.GetSaveInfo(TestSlot);

        // Assert
        Assert.That(info, Does.Contain("TestRacer"));
        Assert.That(info, Does.Contain("Ур. 5"));
    }

    [Test]
    public void GetSaveInfo_WithoutSave_ReturnsEmptyMessage()
    {
        // Act
        string info = SaveSystem.GetSaveInfo(TestSlot);

        // Assert
        Assert.That(info, Does.Contain("Пусто"));
    }

    #endregion
}
