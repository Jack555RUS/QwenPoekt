using UnityEngine;
using UnityEngine.UI;

namespace DragRace.Racing
{
    /// <summary>
    /// Менеджер заезда
    /// Управляет гонкой: светофор, старт, финиш, результаты
    /// </summary>
    public class RaceManager : MonoBehaviour
    {
        #region Singleton
        
        private static RaceManager _instance;
        
        public static RaceManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindFirstObjectByType<RaceManager>();
                }
                return _instance;
            }
        }
        
        #endregion
        
        #region Parameters
        
        [Header("Светофор")]
        [Tooltip("Объект светофора")]
        public GameObject trafficLightObject;
        
        [Tooltip("Красный свет")]
        public Sprite redLightSprite;
        
        [Tooltip("Жёлтый свет")]
        public Sprite yellowLightSprite;
        
        [Tooltip("Зелёный свет")]
        public Sprite greenLightSprite;
        
        [Header("UI")]
        [Tooltip("Текст скорости")]
        public Text speedText;
        
        [Tooltip("Текст времени")]
        public Text timeText;
        
        [Tooltip("Текст передачи")]
        public Text gearText;
        
        [Tooltip("Текст результатов")]
        public Text resultsText;
        
        [Header("Игрок")]
        [Tooltip("Автомобиль игрока")]
        public Vehicles.CarPhysics playerCar;
        
        [Header("Соперники")]
        [Tooltip("Массив ИИ соперников")]
        public OpponentAI[] opponents;
        
        [Header("Дистанция заезда")]
        [Tooltip("Дистанция по умолчанию (м)")]
        public float defaultRaceDistance = 402f; // 1/4 мили
        
        #endregion
        
        #region State
        
        public enum RaceState
        {
            Waiting,
            Countdown,
            Racing,
            Finished
        }
        
        private RaceState currentState = RaceState.Waiting;
        private float countdownTimer = 0f;
        private int lightIndex = 0;
        private bool raceStarted = false;
        private bool raceFinished = false;
        
        // Результаты
        private float playerFinishTime = 0f;
        private float playerFinishSpeed = 0f;
        
        #endregion
        
        #region Events
        
        public delegate void RaceStateHandler(RaceState newState);
        public event RaceStateHandler OnRaceStateChanged;
        
        public delegate void RaceFinishedHandler();
        public event RaceFinishedHandler OnRaceFinished;
        
        #endregion
        
        #region Properties
        
        public RaceState CurrentState => currentState;
        public bool IsRaceStarted => raceStarted;
        public bool IsRaceFinished => raceFinished;
        public float PlayerFinishTime => playerFinishTime;
        public float PlayerFinishSpeed => playerFinishSpeed;
        
        #endregion
        
        #region Unity Methods
        
        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            _instance = this;
        }
        
        private void Start()
        {
            InitializeRace();
        }
        
        private void Update()
        {
            UpdateUI();
            
            if (currentState == RaceState.Countdown)
            {
                UpdateCountdown();
            }
            else if (currentState == RaceState.Racing)
            {
                UpdateRace();
            }
        }
        
        #endregion
        
        #region Initialization
        
        /// <summary>
        /// Инициализация заезда
        /// </summary>
        public void InitializeRace()
        {
            Debug.Log("🏁 RaceManager инициализирован");
            
            // Подписка на события
            if (playerCar != null)
            {
                playerCar.OnRaceFinished += OnPlayerFinished;
            }
            
            foreach (var opponent in opponents)
            {
                if (opponent != null)
                {
                    opponent.OnAIFinished += OnOpponentFinished;
                }
            }
            
            SetRaceState(RaceState.Waiting);
        }
        
        /// <summary>
        /// Сброс заезда
        /// </summary>
        public void ResetRace()
        {
            raceStarted = false;
            raceFinished = false;
            playerFinishTime = 0f;
            playerFinishSpeed = 0f;
            countdownTimer = 0f;
            lightIndex = 0;
            
            if (playerCar != null)
            {
                playerCar.ResetState();
            }
            
            foreach (var opponent in opponents)
            {
                if (opponent != null)
                {
                    opponent.ResetState();
                }
            }
            
            SetRaceState(RaceState.Waiting);
            
            Debug.Log("🔄 Заезд сброшен");
        }
        
        #endregion
        
        #region Race Control
        
        /// <summary>
        /// Начать заезд
        /// </summary>
        public void StartRace()
        {
            StartRace(defaultRaceDistance);
        }
        
        /// <summary>
        /// Начать заезд на указанную дистанцию
        /// </summary>
        public void StartRace(float distance)
        {
            if (currentState == RaceState.Racing)
            {
                Debug.LogWarning("⚠️ Гонка уже идёт!");
                return;
            }
            
            ResetRace();
            
            Debug.Log($"🏁 Заезд начался: {distance}м ({distance/402f:F2}x 1/4 мили)");
            
            // Запуск светофора
            SetRaceState(RaceState.Countdown);
            countdownTimer = 0f;
            lightIndex = 0;
            
            // Подготовка автомобилей
            if (playerCar != null)
            {
                playerCar.StartRace(distance);
            }
            
            foreach (var opponent in opponents)
            {
                if (opponent != null)
                {
                    opponent.StartRace(distance);
                }
            }
        }
        
        /// <summary>
        /// Обновление отсчёта светофора
        /// </summary>
        private void UpdateCountdown()
        {
            countdownTimer += Time.deltaTime;
            
            // Красный (1 сек) → Красный+Жёлтый (1 сек) → Зелёный (старт)
            if (countdownTimer >= 1f && lightIndex == 0)
            {
                lightIndex = 1;
                UpdateTrafficLight(1); // Красный+Жёлтый
            }
            else if (countdownTimer >= 2f && lightIndex == 1)
            {
                lightIndex = 2;
                UpdateTrafficLight(2); // Зелёный
                
                // Старт!
                SetRaceState(RaceState.Racing);
                raceStarted = true;
                
                if (playerCar != null)
                {
                    playerCar.isThrottlePressed = true;
                }
                
                Debug.Log("🟢 СТАРТ!");
            }
        }
        
        /// <summary>
        /// Обновление светофора
        /// </summary>
        private void UpdateTrafficLight(int state)
        {
            // TODO: Реализовать визуальное обновление
            switch (state)
            {
                case 0:
                    Debug.Log("🔴 Красный");
                    break;
                case 1:
                    Debug.Log("🟠 Красный + Жёлтый");
                    break;
                case 2:
                    Debug.Log("🟢 Зелёный");
                    break;
            }
        }
        
        /// <summary>
        /// Обновление гонки
        /// </summary>
        private void UpdateRace()
        {
            // Обновление позиций для rubber-banding
            if (playerCar != null)
            {
                foreach (var opponent in opponents)
                {
                    if (opponent != null)
                    {
                        opponent.UpdatePlayerPosition(playerCar.distanceTraveled);
                    }
                }
            }
            
            // Проверка финиша всех
            CheckAllFinished();
        }
        
        /// <summary>
        /// Проверка завершения всеми
        /// </summary>
        private void CheckAllFinished()
        {
            if (raceFinished) return;
            
            bool allFinished = true;
            
            if (playerCar != null && !playerCar.HasFinished)
            {
                allFinished = false;
            }
            
            foreach (var opponent in opponents)
            {
                if (opponent != null && !opponent.HasFinished)
                {
                    allFinished = false;
                    break;
                }
            }
            
            if (allFinished)
            {
                FinishRace();
            }
        }
        
        /// <summary>
        /// Финиш заезда
        /// </summary>
        private void FinishRace()
        {
            raceFinished = true;
            SetRaceState(RaceState.Finished);
            
            Debug.Log("🏁 Завершён!");
            ShowResults();
            
            OnRaceFinished?.Invoke();
        }
        
        #endregion
        
        #region Events Handlers
        
        /// <summary>
        /// Игрок финишировал
        /// </summary>
        private void OnPlayerFinished(Vehicles.CarPhysics car, float time, float speed)
        {
            playerFinishTime = time;
            playerFinishSpeed = speed;
            
            Debug.Log($"✅ Игрок финишировал: {time:F3}с, {speed*3.6f:F1} км/ч");
        }
        
        /// <summary>
        /// Соперник финишировал
        /// </summary>
        private void OnOpponentFinished(OpponentAI ai)
        {
            Debug.Log($"🤖 Соперник финишировал: {ai.GetComponent<Vehicles.CarPhysics>().raceTime:F3}с");
        }
        
        #endregion
        
        #region State Management
        
        /// <summary>
        /// Установка состояния гонки
        /// </summary>
        private void SetRaceState(RaceState newState)
        {
            RaceState oldState = currentState;
            currentState = newState;
            
            Debug.Log($"🔄 Состояние: {oldState} → {newState}");
            
            OnRaceStateChanged?.Invoke(newState);
        }
        
        #endregion
        
        #region UI
        
        /// <summary>
        /// Обновление UI
        /// </summary>
        private void UpdateUI()
        {
            if (playerCar != null && speedText != null)
            {
                speedText.text = $"Speed: {playerCar.CurrentSpeedKmh:F1} km/h";
            }
            
            if (playerCar != null && timeText != null)
            {
                timeText.text = $"Time: {playerCar.raceTime:F3}s";
            }
            
            if (playerCar != null && gearText != null)
            {
                string gearStr = playerCar.currentGear == 0 ? "N" : playerCar.currentGear.ToString();
                gearText.text = $"Gear: {gearStr}";
            }
        }
        
        /// <summary>
        /// Показать результаты
        /// </summary>
        private void ShowResults()
        {
            if (resultsText == null) return;
            
            string results = "=== РЕЗУЛЬТАТЫ ===\n\n";
            
            results += $"Игрок: {playerFinishTime:F3}с\n";
            results += $"Скорость: {playerFinishSpeed * 3.6f:F1} км/ч\n\n";
            
            // Сортировка соперников по времени
            System.Array.Sort(opponents, (a, b) => 
            {
                float timeA = a?.GetComponent<Vehicles.CarPhysics>().raceTime ?? 999f;
                float timeB = b?.GetComponent<Vehicles.CarPhysics>().raceTime ?? 999f;
                return timeA.CompareTo(timeB);
            });
            
            for (int i = 0; i < opponents.Length; i++)
            {
                if (opponents[i] != null)
                {
                    float time = opponents[i].GetComponent<Vehicles.CarPhysics>().raceTime;
                    results += $"{i + 1}. ИИ: {time:F3}с\n";
                }
            }
            
            resultsText.text = results;
            resultsText.gameObject.SetActive(true);
        }
        
        #endregion
        
        #region Input Handlers
        
        /// <summary>
        /// Обработка ввода (газ)
        /// </summary>
        public void OnAccelerate(bool pressed)
        {
            if (playerCar != null && raceStarted && !raceFinished)
            {
                playerCar.isThrottlePressed = pressed;
            }
        }
        
        /// <summary>
        /// Обработка ввода (переключение вверх)
        /// </summary>
        public void OnShiftUp()
        {
            if (playerCar != null && raceStarted && !raceFinished)
            {
                playerCar.ShiftUp();
            }
        }
        
        /// <summary>
        /// Обработка ввода (переключение вниз)
        /// </summary>
        public void OnShiftDown()
        {
            if (playerCar != null && raceStarted && !raceFinished)
            {
                playerCar.ShiftDown();
            }
        }
        
        /// <summary>
        /// Обработка ввода (нитро)
        /// </summary>
        public void OnNitro(bool pressed)
        {
            if (playerCar != null && raceStarted && !raceFinished)
            {
                if (pressed)
                    playerCar.ActivateNitro();
                else
                    playerCar.DeactivateNitro();
            }
        }
        
        #endregion
    }
}
