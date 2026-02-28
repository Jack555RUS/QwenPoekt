using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using RacingGame.Managers;
using RacingGame.Utilities;
using System.Collections;

namespace RacingGame.Tests
{
    /// <summary>
    /// Тесты для GameManager
    /// </summary>
    public class GameManagerTests
    {
        private GameObject _gameObject;
        private GameManager _gameManager;

        [SetUp]
        public void Setup()
        {
            _gameObject = new GameObject("GameManagerTest");
            _gameManager = _gameObject.AddComponent<GameManager>();
            
            // Инициализируем логгер
            GameLogger.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            if (_gameObject != null)
            {
                Object.DestroyImmediate(_gameObject);
            }
            GameManager.Instance = null;
        }

        [Test]
        public void Instance_NotNull_AfterAwake()
        {
            Assert.IsNotNull(GameManager.Instance);
        }

        [Test]
        public void InitialState_IsMainMenu()
        {
            // После Start должно быть MainMenu
            _gameManager.GetType().GetMethod("Start", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance)
                ?.Invoke(_gameManager, null);
            
            Assert.AreEqual(GameManager.GameState.MainMenu, _gameManager.CurrentState);
        }

        [Test]
        public void SetState_ChangesState_Correctly()
        {
            bool stateChanged = false;
            GameManager.GameState newState = GameManager.GameState.None;

            _gameManager.OnStateChanged += (s) =>
            {
                stateChanged = true;
                newState = s;
            };

            _gameManager.SetState(GameManager.GameState.Playing);

            Assert.IsTrue(stateChanged);
            Assert.AreEqual(GameManager.GameState.Playing, newState);
            Assert.AreEqual(GameManager.GameState.Playing, _gameManager.CurrentState);
        }

        [Test]
        public void QuitGame_DoesNotThrow_Exception()
        {
            Assert.DoesNotThrow(() => _gameManager.QuitGame());
        }

        [Test]
        public void SaveGame_DoesNotThrow_Exception()
        {
            Assert.DoesNotThrow(() => _gameManager.SaveGame());
        }

        [UnityTest]
        public IEnumerator PauseGame_SetsTimeScale_ToZero()
        {
            Time.timeScale = 1f;
            _gameManager.SetState(GameManager.GameState.Playing);
            _gameManager.PauseGame();
            
            yield return null;
            
            Assert.AreEqual(0f, Time.timeScale);
            Time.timeScale = 1f;
        }

        [UnityTest]
        public IEnumerator ResumeGame_ResetsTimeScale_ToOne()
        {
            Time.timeScale = 0f;
            _gameManager.SetState(GameManager.GameState.Paused);
            _gameManager.ResumeGame();
            
            yield return null;
            
            Assert.AreEqual(1f, Time.timeScale);
        }
    }
}
