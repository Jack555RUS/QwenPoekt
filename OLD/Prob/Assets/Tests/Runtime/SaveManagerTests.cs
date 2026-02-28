using NUnit.Framework;
using RacingGame.Managers;
using RacingGame.Utilities;
using UnityEngine;

namespace RacingGame.Tests
{
    /// <summary>
    /// Тесты для SaveManager
    /// </summary>
    public class SaveManagerTests
    {
        [SetUp]
        public void Setup()
        {
            GameLogger.Initialize();
            SaveManager.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            SaveManager.DeleteSave();
            SaveManager.CurrentData = null;
        }

        [Test]
        public void Initialize_SetsCurrentData_ToNull()
        {
            Assert.IsNull(SaveManager.CurrentData);
        }

        [Test]
        public void HasSave_ReturnsFalse_WhenNoSaveExists()
        {
            Assert.IsFalse(SaveManager.HasSave());
        }

        [Test]
        public void CreateNewGame_CreatesValidGameData()
        {
            SaveManager.CreateNewGame("TestPlayer");

            Assert.IsNotNull(SaveManager.CurrentData);
            Assert.AreEqual("TestPlayer", SaveManager.CurrentData.playerName);
            Assert.AreEqual(1000, SaveManager.CurrentData.currentMoney);
            Assert.AreEqual(0, SaveManager.CurrentData.currentExperience);
        }

        [Test]
        public void SaveGame_CreatesSaveFile()
        {
            SaveManager.CreateNewGame("SaveTest");
            SaveManager.SaveGame();

            Assert.IsTrue(SaveManager.HasSave());
        }

        [Test]
        public void LoadGame_RestoresSavedData()
        {
            // Создаем и сохраняем
            SaveManager.CreateNewGame("LoadTest");
            SaveManager.AddMoney(500);
            SaveManager.SaveGame();

            // Очищаем и загружаем
            SaveManager.CurrentData = null;
            SaveManager.LoadGame();

            Assert.IsNotNull(SaveManager.CurrentData);
            Assert.AreEqual("LoadTest", SaveManager.CurrentData.playerName);
            Assert.AreEqual(1500, SaveManager.CurrentData.currentMoney);
        }

        [Test]
        public void AddMoney_IncreasesCurrentMoney()
        {
            SaveManager.CreateNewGame("MoneyTest");
            int initialMoney = SaveManager.CurrentData.currentMoney;

            SaveManager.AddMoney(100);

            Assert.AreEqual(initialMoney + 100, SaveManager.CurrentData.currentMoney);
        }

        [Test]
        public void SpendMoney_DecreasesCurrentMoney()
        {
            SaveManager.CreateNewGame("SpendTest");
            int initialMoney = SaveManager.CurrentData.currentMoney;

            SaveManager.SpendMoney(100);

            Assert.AreEqual(initialMoney - 100, SaveManager.CurrentData.currentMoney);
        }

        [Test]
        public void SpendMoney_DoesNotGoNegative()
        {
            SaveManager.CreateNewGame("NegativeTest");
            SaveManager.CurrentData.currentMoney = 50;

            SaveManager.SpendMoney(100);

            // Не должно уйти в минус
            Assert.AreEqual(50, SaveManager.CurrentData.currentMoney);
        }

        [Test]
        public void AddExperience_IncreasesExperience()
        {
            SaveManager.CreateNewGame("ExpTest");
            int initialExp = SaveManager.CurrentData.currentExperience;

            SaveManager.AddExperience(200);

            Assert.AreEqual(initialExp + 200, SaveManager.CurrentData.currentExperience);
        }

        [Test]
        public void UpdateCarData_UpdatesCarCorrectly()
        {
            SaveManager.CreateNewGame("CarTest");
            
            var newCar = new CarData("TestCar");
            newCar.speed = 80;
            newCar.handling = 70;
            newCar.color = Color.blue;

            SaveManager.UpdateCarData(0, newCar);
            var loadedCar = SaveManager.GetCarData(0);

            Assert.AreEqual("TestCar", loadedCar.carName);
            Assert.AreEqual(80, loadedCar.speed);
            Assert.AreEqual(70, loadedCar.handling);
            Assert.AreEqual(Color.blue, loadedCar.color);
        }

        [Test]
        public void GetCarData_ReturnsDefault_WhenIndexOutOfBounds()
        {
            SaveManager.CreateNewGame("BoundsTest");
            
            var car = SaveManager.GetCarData(100);

            Assert.IsNotNull(car);
            Assert.AreEqual("Car", car.carName);
        }

        [Test]
        public void DeleteSave_RemovesSaveFile()
        {
            SaveManager.CreateNewGame("DeleteTest");
            SaveManager.SaveGame();
            
            Assert.IsTrue(SaveManager.HasSave());

            SaveManager.DeleteSave();

            Assert.IsFalse(SaveManager.HasSave());
        }

        [Test]
        public void EncryptDecrypt_RoundTrip_Successful()
        {
            string original = "Test data for encryption";
            
            // Используем рефлексию для доступа к приватным методам
            var method = typeof(SaveManager).GetMethod("Encrypt", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Static);
            
            if (method != null)
            {
                string encrypted = (string)method.Invoke(null, new object[] { original });
                string decrypted = (string)method.Invoke(null, new object[] { encrypted });

                Assert.AreEqual(original, decrypted);
            }
        }
    }
}
