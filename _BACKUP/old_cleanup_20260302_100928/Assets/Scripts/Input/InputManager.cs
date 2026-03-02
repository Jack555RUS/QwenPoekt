using UnityEngine;
using System;
using System.Collections.Generic;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Input
{
    /// <summary>
    /// Менеджер ввода
    /// Управление: Клавиатура + Мышь
    /// </summary>
    public class InputManager : MonoBehaviour
    {
        private static InputManager _instance;
        public static InputManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<InputManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("InputManager");
                        _instance = go.AddComponent<InputManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
        }

        // Текущее состояние ввода
        private InputState currentState;

        // События ввода
        public event Action OnGasPressed;
        public event Action OnGasReleased;
        public event Action OnShiftUpPressed;
        public event Action OnShiftDownPressed;
        public event Action OnNitroPressed;
        public event Action OnNitroReleased;
        public event Action OnPausePressed;

        [Serializable]
        public class InputState
        {
            public bool isGasPressed;
            public bool isShiftUpPressed;
            public bool isShiftDownPressed;
            public bool isNitroPressed;
            public bool isPausePressed;
            
            public InputState()
            {
                isGasPressed = false;
                isShiftUpPressed = false;
                isShiftDownPressed = false;
                isNitroPressed = false;
                isPausePressed = false;
            }
        }

        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }

            _instance = this;
            DontDestroyOnLoad(gameObject);
        }

        private void Start()
        {
            currentState = new InputState();
            Logger.I("=== INPUT MANAGER INITIALIZED ===");
        }

        private void Update()
        {
            // Получаем клавиши из SettingsManager
            KeyCode keyGas = Settings.SettingsManager.Instance.GetKeyGas();
            KeyCode keyShiftUp = Settings.SettingsManager.Instance.GetKeyShiftUp();
            KeyCode keyShiftDown = Settings.SettingsManager.Instance.GetKeyShiftDown();
            KeyCode keyNitro = Settings.SettingsManager.Instance.GetKeyNitro();
            KeyCode keyPause = Settings.SettingsManager.Instance.GetKeyPause();

            // Газ / Старт
            bool gasPressed = UnityEngine.Input.GetKey(keyGas) || UnityEngine.Input.GetKey(KeyCode.UpArrow);
            if (gasPressed && !currentState.isGasPressed)
                OnGasPressed?.Invoke();
            if (!gasPressed && currentState.isGasPressed)
                OnGasReleased?.Invoke();
            currentState.isGasPressed = gasPressed;

            // Переключение вверх
            bool shiftUpPressed = UnityEngine.Input.GetKeyDown(keyShiftUp) || UnityEngine.Input.GetKeyDown(KeyCode.RightArrow);
            if (shiftUpPressed)
                OnShiftUpPressed?.Invoke();
            currentState.isShiftUpPressed = shiftUpPressed;

            // Переключение вниз
            bool shiftDownPressed = UnityEngine.Input.GetKeyDown(keyShiftDown) || UnityEngine.Input.GetKeyDown(KeyCode.LeftArrow);
            if (shiftDownPressed)
                OnShiftDownPressed?.Invoke();
            currentState.isShiftDownPressed = shiftDownPressed;

            // Нитро
            bool nitroPressed = UnityEngine.Input.GetKey(keyNitro) || UnityEngine.Input.GetKey(KeyCode.N);
            if (nitroPressed && !currentState.isNitroPressed)
                OnNitroPressed?.Invoke();
            if (!nitroPressed && currentState.isNitroPressed)
                OnNitroReleased?.Invoke();
            currentState.isNitroPressed = nitroPressed;

            // Пауза
            bool pausePressed = UnityEngine.Input.GetKeyDown(keyPause);
            if (pausePressed)
                OnPausePressed?.Invoke();
            currentState.isPausePressed = pausePressed;
        }

        #region Getters

        public bool IsGasPressed() => currentState.isGasPressed;
        public bool IsShiftUpPressed() => currentState.isShiftUpPressed;
        public bool IsShiftDownPressed() => currentState.isShiftDownPressed;
        public bool IsNitroPressed() => currentState.isNitroPressed;
        public bool IsPausePressed() => currentState.isPausePressed;

        public InputState GetCurrentState()
        {
            return new InputState
            {
                isGasPressed = currentState.isGasPressed,
                isShiftUpPressed = currentState.isShiftUpPressed,
                isShiftDownPressed = currentState.isShiftDownPressed,
                isNitroPressed = currentState.isNitroPressed,
                isPausePressed = currentState.isPausePressed
            };
        }

        #endregion

        #region Test Input

        /// <summary>
        /// Тестовый ввод для отладки
        /// </summary>
        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 10, 200, 200));
            GUILayout.Label("=== INPUT DEBUG ===");
            GUILayout.Label($"Gas: {currentState.isGasPressed}");
            GUILayout.Label($"Shift Up: {currentState.isShiftUpPressed}");
            GUILayout.Label($"Shift Down: {currentState.isShiftDownPressed}");
            GUILayout.Label($"Nitro: {currentState.isNitroPressed}");
            GUILayout.Label($"Pause: {currentState.isPausePressed}");
            GUILayout.EndArea();
        }

        #endregion
    }
}
