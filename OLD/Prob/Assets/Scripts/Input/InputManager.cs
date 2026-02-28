using UnityEngine;
using RacingGame.Utilities;
using RacingGame.Managers;

namespace RacingGame.InputSystem
{
    /// <summary>
    /// Система ввода. Обрабатывает ввод с клавиатуры и мыши.
    /// </summary>
    public class InputManager : MonoBehaviour
    {
        public static InputManager Instance { get; private set; }

        [Header("Настройки чувствительности")]
        [SerializeField] private float _mouseSensitivity = 2f;
        [SerializeField] private float _keyboardSpeed = 5f;

        [Header("Горячие клавиши")]
        [SerializeField] private KeyCode _pauseKey = KeyCode.Escape;
        [SerializeField] private KeyCode _saveKey = KeyCode.S;
        [SerializeField] private KeyCode _loadKey = KeyCode.L;
        [SerializeField] private KeyCode _menuKey = KeyCode.M;

        // Состояние ввода
        public Vector2 MovementInput { get; private set; }
        public Vector2 MouseDelta { get; private set; }
        public bool FirePressed { get; private set; }
        public bool FireHeld { get; private set; }
        public bool AltFirePressed { get; private set; }
        public bool JumpPressed { get; private set; }
        public bool SubmitPressed { get; private set; }
        public bool CancelPressed { get; private set; }

        // События ввода
        public event System.Action<Vector2> OnMovementInputChanged;
        public event System.Action OnPausePressed;
        public event System.Action OnSavePressed;
        public event System.Action OnLoadPressed;
        public event System.Action OnMenuPressed;

        private bool _pauseKeyReleased = true;

        public float MouseSensitivity
        {
            get => _mouseSensitivity;
            set => _mouseSensitivity = Mathf.Max(0.1f, value);
        }

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
                return;
            }

            GameLogger.LogInfo("InputManager инициализирован");
        }

        private void Update()
        {
            HandleKeyboardInput();
            HandleMouseInput();
            HandleHotkeys();
        }

        private void HandleKeyboardInput()
        {
            // WASD / Стрелки
            float horizontal = 0f;
            float vertical = 0f;

            if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.UpArrow))
                vertical = 1f;
            else if (Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.DownArrow))
                vertical = -1f;

            if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.LeftArrow))
                horizontal = -1f;
            else if (Input.GetKey(KeyCode.D) || Input.GetKey(KeyCode.RightArrow))
                horizontal = 1f;

            MovementInput = new Vector2(horizontal, vertical) * _keyboardSpeed;

            // Пробел - прыжок
            JumpPressed = Input.GetKeyDown(KeyCode.Space);

            // Левый Ctrl - огонь
            FirePressed = Input.GetKeyDown(KeyCode.LeftControl);
            FireHeld = Input.GetKey(KeyCode.LeftControl);

            // Левый Alt - альтернативный огонь
            AltFirePressed = Input.GetKeyDown(KeyCode.LeftAlt);

            // Enter - подтверждение
            SubmitPressed = Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.KeypadEnter);
        }

        private void HandleMouseInput()
        {
            // Движение мыши
            float mouseX = Input.GetAxis("Mouse X");
            float mouseY = Input.GetAxis("Mouse Y");
            MouseDelta = new Vector2(mouseX, mouseY) * _mouseSensitivity;

            // Левая кнопка мыши - огонь
            if (Input.GetMouseButtonDown(0))
            {
                FirePressed = true;
                GameLogger.LogDebug("ЛКМ нажата");
            }
            FireHeld = Input.GetMouseButton(0);

            // Правая кнопка мыши - альтернативный огонь
            if (Input.GetMouseButtonDown(1))
            {
                AltFirePressed = true;
                GameLogger.LogDebug("ПКМ нажата");
            }

            // Средняя кнопка мыши
            if (Input.GetMouseButtonDown(2))
            {
                GameLogger.LogDebug("СКМ нажата");
            }

            // Колесо мыши
            float scrollWheel = Input.GetAxis("Mouse ScrollWheel");
            if (scrollWheel != 0)
            {
                GameLogger.LogDebug($"Колесо мыши: {scrollWheel:F2}");
            }
        }

        private void HandleHotkeys()
        {
            // Pause - Escape
            if (Input.GetKeyDown(_pauseKey))
            {
                if (_pauseKeyReleased)
                {
                    OnPausePressed?.Invoke();
                    
                    var gameState = GameManager.Instance?.CurrentState;
                    if (gameState == Managers.GameManager.GameState.Playing)
                    {
                        GameManager.Instance?.PauseGame();
                        MenuManager.Instance?.ShowPauseMenu();
                    }
                    else if (gameState == Managers.GameManager.GameState.Paused)
                    {
                        GameManager.Instance?.ResumeGame();
                        MenuManager.Instance?.HideCurrentMenu();
                    }
                    
                    GameLogger.LogInfo("Нажата клавиша паузы");
                    _pauseKeyReleased = false;
                }
            }
            else if (Input.GetKeyUp(_pauseKey))
            {
                _pauseKeyReleased = true;
            }

            // Save - S (когда не нажаты модификаторы)
            if (Input.GetKeyDown(_saveKey) && !Input.GetKey(KeyCode.LeftControl) && !Input.GetKey(KeyCode.RightControl))
            {
                OnSavePressed?.Invoke();
                GameManager.Instance?.SaveGame();
                GameLogger.LogInfo("Нажата клавиша сохранения (S)");
            }

            // Load - L
            if (Input.GetKeyDown(_loadKey))
            {
                OnLoadPressed?.Invoke();
                GameManager.Instance?.LoadGame();
                GameLogger.LogInfo("Нажата клавиша загрузки (L)");
            }

            // Menu - M
            if (Input.GetKeyDown(_menuKey))
            {
                OnMenuPressed?.Invoke();
                GameLogger.LogInfo("Нажата клавиша меню (M)");
            }
        }

        public void ResetInput()
        {
            MovementInput = Vector2.zero;
            MouseDelta = Vector2.zero;
            FirePressed = false;
            FireHeld = false;
            AltFirePressed = false;
            JumpPressed = false;
            SubmitPressed = false;
            CancelPressed = false;
        }

        public bool IsAnyKeyPressed()
        {
            return MovementInput != Vector2.zero || 
                   MouseDelta != Vector2.zero || 
                   FirePressed || 
                   JumpPressed || 
                   SubmitPressed || 
                   CancelPressed;
        }

        public Vector3 GetMovementVector3()
        {
            return new Vector3(MovementInput.x, 0, MovementInput.y);
        }

        public Ray GetMouseRay(Camera camera)
        {
            if (camera == null) camera = Camera.main;
            return camera.ScreenPointToRay(Input.mousePosition);
        }

        public Vector3 GetMouseWorldPosition(Camera camera, Plane plane)
        {
            if (camera == null) camera = Camera.main;
            Ray ray = camera.ScreenPointToRay(Input.mousePosition);
            
            if (plane.Raycast(ray, out float distance))
            {
                return ray.GetPoint(distance);
            }
            
            return Vector3.zero;
        }
    }
}
