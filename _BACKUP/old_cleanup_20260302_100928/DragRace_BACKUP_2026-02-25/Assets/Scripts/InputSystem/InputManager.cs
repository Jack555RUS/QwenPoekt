using UnityEngine;
using DragRace.Data;
using DragRace.Core;

namespace DragRace.InputSystem
{
    /// <summary>
    /// Менеджер ввода
    /// </summary>
    public class InputManager : MonoBehaviour
    {
        public static InputManager Instance { get; private set; }
        
        public KeyBindings currentBindings;
        public bool IsAccelerating { get; private set; }
        public bool IsShiftUpPressed { get; private set; }
        public bool IsShiftDownPressed { get; private set; }
        public bool IsNitroPressed { get; private set; }
        public bool IsPausePressed { get; private set; }
        public float AccelerateInput { get; private set; }
        
        public delegate void InputHandler(KeyCode key);
        public event InputHandler OnKeyPressed;
        public delegate void OnRaceInput(RaceInputType inputType);
        public event OnRaceInput OnRaceInputChanged;
        
        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }

            Instance = this;
            DontDestroyOnLoad(gameObject);
            LoadKeyBindings();
        }
        
        private void Update()
        {
            HandleKeyboardInput();
        }
        
        private void HandleKeyboardInput()
        {
            IsAccelerating = Input.GetKey(currentBindings.accelerate);
            AccelerateInput = IsAccelerating ? 1f : 0f;
            
            IsShiftUpPressed = Input.GetKeyDown(currentBindings.shiftUp);
            IsShiftDownPressed = Input.GetKeyDown(currentBindings.shiftDown);
            IsNitroPressed = Input.GetKeyDown(currentBindings.nitro);
            IsPausePressed = Input.GetKeyDown(currentBindings.pause);
            
            if (IsShiftUpPressed) OnRaceInputChanged?.Invoke(RaceInputType.ShiftUp);
            if (IsShiftDownPressed) OnRaceInputChanged?.Invoke(RaceInputType.ShiftDown);
            if (IsNitroPressed) OnRaceInputChanged?.Invoke(RaceInputType.Nitro);
            if (IsPausePressed) OnRaceInputChanged?.Invoke(RaceInputType.Pause);
            
            if (Input.anyKeyDown)
            {
                KeyCode pressedKey = GetPressedKey();
                OnKeyPressed?.Invoke(pressedKey);
            }
        }
        
        private KeyCode GetPressedKey()
        {
            foreach (KeyCode key in System.Enum.GetValues(typeof(KeyCode)))
            {
                if (Input.GetKeyDown(key))
                    return key;
            }
            return KeyCode.None;
        }
        
        public void LoadKeyBindings()
        {
            var settings = GameManager.Instance?.Settings;
            currentBindings = settings?.keyBindings ?? new KeyBindings();
        }
        
        public void SetKeyBinding(InputAction action, KeyCode key)
        {
            if (IsKeyBoundToAnotherAction(action, key))
            {
                Debug.LogWarning($"Клавиша {key} уже назначена!");
                return;
            }
            
            switch (action)
            {
                case InputAction.Accelerate: currentBindings.accelerate = key; break;
                case InputAction.ShiftUp: currentBindings.shiftUp = key; break;
                case InputAction.ShiftDown: currentBindings.shiftDown = key; break;
                case InputAction.Nitro: currentBindings.nitro = key; break;
                case InputAction.Pause: currentBindings.pause = key; break;
            }
            
            if (GameManager.Instance != null)
            {
                var settings = GameManager.Instance.Settings;
                settings.keyBindings = currentBindings;
                GameManager.Instance.UpdateSettings(settings);
            }
        }
        
        public bool IsKeyBoundToAnotherAction(InputAction excludeAction, KeyCode key)
        {
            if (excludeAction != InputAction.Accelerate && currentBindings.accelerate == key) return true;
            if (excludeAction != InputAction.ShiftUp && currentBindings.shiftUp == key) return true;
            if (excludeAction != InputAction.ShiftDown && currentBindings.shiftDown == key) return true;
            if (excludeAction != InputAction.Nitro && currentBindings.nitro == key) return true;
            if (excludeAction != InputAction.Pause && currentBindings.pause == key) return true;
            return false;
        }
        
        public KeyCode GetKeyForAction(InputAction action)
        {
            return action switch
            {
                InputAction.Accelerate => currentBindings.accelerate,
                InputAction.ShiftUp => currentBindings.shiftUp,
                InputAction.ShiftDown => currentBindings.shiftDown,
                InputAction.Nitro => currentBindings.nitro,
                InputAction.Pause => currentBindings.pause,
                _ => KeyCode.None
            };
        }
        
        public void ResetToDefaults()
        {
            currentBindings = new KeyBindings();
            if (GameManager.Instance != null)
            {
                var settings = GameManager.Instance.Settings;
                settings.keyBindings = currentBindings;
                GameManager.Instance.UpdateSettings(settings);
            }
        }
    }
    
    public enum InputAction { Accelerate, ShiftUp, ShiftDown, Nitro, Pause }
    public enum RaceInputType { ShiftUp, ShiftDown, Nitro, Pause }
}
