using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using RacingGame.Managers;
using RacingGame.Utilities;
using System.Collections;

namespace RacingGame.Tests
{
    /// <summary>
    /// Тесты для MenuManager
    /// </summary>
    public class MenuManagerTests
    {
        private GameObject _gameObject;
        private MenuManager _menuManager;

        [SetUp]
        public void Setup()
        {
            _gameObject = new GameObject("MenuManagerTest");
            _menuManager = _gameObject.AddComponent<MenuManager>();
            
            GameLogger.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            if (_gameObject != null)
            {
                Object.DestroyImmediate(_gameObject);
            }
            MenuManager.Instance = null;
        }

        [Test]
        public void Instance_NotNull_AfterAwake()
        {
            Assert.IsNotNull(MenuManager.Instance);
        }

        [Test]
        public void ShowMainMenu_DoesNotThrow_Exception()
        {
            Assert.DoesNotThrow(() => _menuManager.ShowMainMenu());
        }

        [Test]
        public void HideCurrentMenu_DoesNotThrow_Exception()
        {
            Assert.DoesNotThrow(() => _menuManager.HideCurrentMenu());
        }

        [UnityTest]
        public IEnumerator ShowMainMenu_SetsCurrentMenuName()
        {
            _menuManager.ShowMainMenu();
            yield return null;
            
            // Проверяем что имя меню установлено
            Assert.AreEqual("MainMenu", _menuManager.CurrentMenuName);
        }

        [UnityTest]
        public IEnumerator ShowSettingsMenu_SetsCurrentMenuName()
        {
            _menuManager.ShowSettingsMenu();
            yield return null;
            
            Assert.AreEqual("SettingsMenu", _menuManager.CurrentMenuName);
        }

        [UnityTest]
        public IEnumerator ShowPauseMenu_SetsCurrentMenuName()
        {
            _menuManager.ShowPauseMenu();
            yield return null;
            
            Assert.AreEqual("PauseMenu", _menuManager.CurrentMenuName);
        }

        [UnityTest]
        public IEnumerator HideCurrentMenu_ClearsCurrentMenuName()
        {
            _menuManager.ShowMainMenu();
            yield return null;
            
            _menuManager.HideCurrentMenu();
            yield return null;
            
            Assert.AreEqual("", _menuManager.CurrentMenuName);
        }

        [Test]
        public void GetElement_ReturnsNull_WhenMenuNotLoaded()
        {
            var element = _menuManager.GetElement<UnityEngine.UIElements.Button>("TestButton");
            Assert.IsNull(element);
        }
    }
}
