using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using RacingGame.InputSystem;
using RacingGame.Utilities;
using System.Collections;

namespace RacingGame.Tests
{
    /// <summary>
    /// Тесты для InputManager
    /// </summary>
    public class InputManagerTests
    {
        private GameObject _gameObject;
        private InputManager _inputManager;

        [SetUp]
        public void Setup()
        {
            _gameObject = new GameObject("InputManagerTest");
            _inputManager = _gameObject.AddComponent<InputManager>();
            
            GameLogger.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            if (_gameObject != null)
            {
                Object.DestroyImmediate(_gameObject);
            }
            InputManager.Instance = null;
        }

        [Test]
        public void Instance_NotNull_AfterAwake()
        {
            Assert.IsNotNull(InputManager.Instance);
        }

        [Test]
        public void InitialMovementInput_IsZero()
        {
            Assert.AreEqual(Vector2.zero, _inputManager.MovementInput);
        }

        [Test]
        public void InitialMouseDelta_IsZero()
        {
            Assert.AreEqual(Vector2.zero, _inputManager.MouseDelta);
        }

        [Test]
        public void MouseSensitivity_CanBeSet()
        {
            _inputManager.MouseSensitivity = 3.5f;
            Assert.AreEqual(3.5f, _inputManager.MouseSensitivity);
        }

        [Test]
        public void MouseSensitivity_MinValue_Clamped()
        {
            _inputManager.MouseSensitivity = 0f;
            Assert.GreaterOrEqual(_inputManager.MouseSensitivity, 0.1f);
        }

        [Test]
        public void ResetInput_ResetsAllInputs()
        {
            // Симуляция нажатий через рефлексию
            var movementField = typeof(InputManager).GetField("MovementInput", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance);
            movementField?.SetValue(_inputManager, new Vector2(1, 1));

            _inputManager.ResetInput();

            Assert.AreEqual(Vector2.zero, _inputManager.MovementInput);
            Assert.AreEqual(Vector2.zero, _inputManager.MouseDelta);
            Assert.IsFalse(_inputManager.FirePressed);
            Assert.IsFalse(_inputManager.FireHeld);
        }

        [Test]
        public void GetMovementVector3_ReturnsCorrectVector()
        {
            // Устанавливаем input через рефлексию
            var movementField = typeof(InputManager).GetField("MovementInput", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance);
            movementField?.SetValue(_inputManager, new Vector2(1, 1));

            Vector3 result = _inputManager.GetMovementVector3();

            Assert.AreEqual(1, result.x);
            Assert.AreEqual(0, result.y);
            Assert.AreEqual(1, result.z);
        }

        [UnityTest]
        public IEnumerator IsAnyKeyPressed_ReturnsFalse_WhenNoInput()
        {
            _inputManager.ResetInput();
            yield return null;

            Assert.IsFalse(_inputManager.IsAnyKeyPressed());
        }

        [Test]
        public void GetMouseRay_ReturnsValidRay()
        {
            // Создаем тестовую камеру
            var camera = new GameObject("TestCamera").AddComponent<Camera>();
            
            Ray ray = _inputManager.GetMouseRay(camera);
            
            Assert.IsNotNull(ray);
            Assert.AreEqual(camera.transform.position, ray.origin);
            
            Object.DestroyImmediate(camera.gameObject);
        }

        [Test]
        public void Events_AreNotNull_AfterSubscribe()
        {
            bool pausePressed = false;
            bool savePressed = false;
            bool loadPressed = false;
            bool menuPressed = false;

            _inputManager.OnPausePressed += () => pausePressed = true;
            _inputManager.OnSavePressed += () => savePressed = true;
            _inputManager.OnLoadPressed += () => loadPressed = true;
            _inputManager.OnMenuPressed += () => menuPressed = true;

            Assert.IsNotNull(_inputManager.OnPausePressed);
            Assert.IsNotNull(_inputManager.OnSavePressed);
            Assert.IsNotNull(_inputManager.OnLoadPressed);
            Assert.IsNotNull(_inputManager.OnMenuPressed);
        }
    }
}
