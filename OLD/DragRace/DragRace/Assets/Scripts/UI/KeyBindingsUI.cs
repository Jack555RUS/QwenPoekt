using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;
using DragRace.InputSystem;

namespace DragRace.UI
{
    /// <summary>
    /// Настройка привязки клавиш
    /// </summary>
    public class KeyBindingsUI : MonoBehaviour
    {
        [Header("Элементы UI")]
        public Button accelerateButton;
        public Button shiftUpButton;
        public Button shiftDownButton;
        public Button nitroButton;
        public Button pauseButton;
        
        public Text accelerateText;
        public Text shiftUpText;
        public Text shiftDownText;
        public Text nitroText;
        public Text pauseText;
        
        public Button resetButton;
        public Button closeButton;
        
        [Header("Сообщения")]
        public Text messageText;
        public GameObject messageContainer;
        
        // Состояние
        private InputAction? waitingForInput;
        
        private void Start()
        {
            UpdateBindingsDisplay();
            SubscribeToEvents();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (accelerateButton != null)
                accelerateButton.onClick.AddListener(() => StartRebind(InputAction.Accelerate));
            
            if (shiftUpButton != null)
                shiftUpButton.onClick.AddListener(() => StartRebind(InputAction.ShiftUp));
            
            if (shiftDownButton != null)
                shiftDownButton.onClick.AddListener(() => StartRebind(InputAction.ShiftDown));
            
            if (nitroButton != null)
                nitroButton.onClick.AddListener(() => StartRebind(InputAction.Nitro));
            
            if (pauseButton != null)
                pauseButton.onClick.AddListener(() => StartRebind(InputAction.Pause));
            
            if (resetButton != null)
                resetButton.onClick.AddListener(OnResetClicked);
            
            if (closeButton != null)
                closeButton.onClick.AddListener(OnCloseClicked);
            
            // Подписка на глобальный ввод
            if (InputManager.Instance != null)
                InputManager.Instance.OnKeyPressed += OnKeyPressed;
        }
        
        private void UnsubscribeFromEvents()
        {
            if (accelerateButton != null)
                accelerateButton.onClick.RemoveListener(() => StartRebind(InputAction.Accelerate));
            
            if (shiftUpButton != null)
                shiftUpButton.onClick.RemoveListener(() => StartRebind(InputAction.ShiftUp));
            
            if (shiftDownButton != null)
                shiftDownButton.onClick.RemoveListener(() => StartRebind(InputAction.ShiftDown));
            
            if (nitroButton != null)
                nitroButton.onClick.RemoveListener(() => StartRebind(InputAction.Nitro));
            
            if (pauseButton != null)
                pauseButton.onClick.RemoveListener(() => StartRebind(InputAction.Pause));
            
            if (resetButton != null)
                resetButton.onClick.RemoveListener(OnResetClicked);
            
            if (closeButton != null)
                closeButton.onClick.RemoveListener(OnCloseClicked);
            
            if (InputManager.Instance != null)
                InputManager.Instance.OnKeyPressed -= OnKeyPressed;
        }
        
        #region Отображение
        
        private void UpdateBindingsDisplay()
        {
            if (InputManager.Instance == null) return;
            
            var bindings = InputManager.Instance.currentBindings;
            
            if (accelerateText != null)
                accelerateText.text = bindings.accelerate.ToString();
            
            if (shiftUpText != null)
                shiftUpText.text = bindings.shiftUp.ToString();
            
            if (shiftDownText != null)
                shiftDownText.text = bindings.shiftDown.ToString();
            
            if (nitroText != null)
                nitroText.text = bindings.nitro.ToString();
            
            if (pauseText != null)
                pauseText.text = bindings.pause.ToString();
        }
        
        #endregion
        
        #region Перепривязка
        
        private void StartRebind(InputAction action)
        {
            waitingForInput = action;
            ShowMessage("Нажмите новую клавишу...");
            
            // Визуальная подсветка кнопки
            HighlightButton(action, true);
        }
        
        private void OnKeyPressed(KeyCode key)
        {
            if (waitingForInput == null) return;
            
            InputAction action = waitingForInput.Value;
            
            // Проверка на дублирование
            if (InputManager.Instance.IsKeyBoundToAnotherAction(action, key))
            {
                ShowMessage($"Клавиша {key} уже используется!");
                waitingForInput = null;
                HighlightButton(action, false);
                return;
            }
            
            // Применение новой привязки
            InputManager.Instance.SetKeyBinding(action, key);
            UpdateBindingsDisplay();
            
            ShowMessage("Привязка изменена!");
            waitingForInput = null;
            HighlightButton(action, false);
        }
        
        private void HighlightButton(InputAction action, bool highlight)
        {
            Button button = action switch
            {
                InputAction.Accelerate => accelerateButton,
                InputAction.ShiftUp => shiftUpButton,
                InputAction.ShiftDown => shiftDownButton,
                InputAction.Nitro => nitroButton,
                InputAction.Pause => pauseButton,
                _ => null
            };
            
            if (button != null)
            {
                ColorBlock colors = button.colors;
                colors.normalColor = highlight ? Color.yellow : Color.white;
                button.colors = colors;
            }
        }
        
        #endregion
        
        #region Сброс
        
        private void OnResetClicked()
        {
            InputManager.Instance?.ResetToDefaults();
            UpdateBindingsDisplay();
            ShowMessage("Привязки сброшены к стандартным");
        }
        
        #endregion
        
        #region Закрытие
        
        private void OnCloseClicked()
        {
            gameObject.SetActive(false);
        }
        
        #endregion
        
        #region Сообщения
        
        private void ShowMessage(string message)
        {
            if (messageText != null)
            {
                messageText.text = message;
            }
            
            if (messageContainer != null)
            {
                messageContainer.SetActive(true);
                CancelInvoke(nameof(HideMessage));
                Invoke(nameof(HideMessage), 2f);
            }
        }
        
        private void HideMessage()
        {
            if (messageContainer != null)
                messageContainer.SetActive(false);
        }
        
        #endregion
    }
}
