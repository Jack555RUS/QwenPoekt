using UnityEngine;
using UnityEngine.UI;
using ProbMenu.Core;
using ProbMenu.Data;
using ProbMenu.Physics;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Racing
{
    /// <summary>
    /// Состояния гонки
    /// </summary>
    public enum RaceState
    {
        Waiting,        // Ожидание старта
        Countdown,      // Обратный отсчёт
        Racing,         // Гонка
        Finished,       // Финиш
        Crashed         // Авария
    }
    
    /// <summary>
    /// Менеджер гонки
    /// Светофор, таймер, ИИ соперник, финиш
    /// </summary>
    public class RaceManager : MonoBehaviour
    {
        [Header("Состояние гонки")]
        [SerializeField] private RaceState currentState = RaceState.Waiting;
        [SerializeField] private RaceDistance raceDistance = RaceDistance.QuarterMile;
        
        [Header("Игрок")]
        [SerializeField] private CarPhysics playerCar;
        [SerializeField] private PlayerData playerData;
        
        [Header("Соперник (ИИ)")]
        [SerializeField] private CarPhysics aiCar;
        [SerializeField] private float aiReactionTime = 0.5f;
        [SerializeField] private float aiSkillLevel = 0.5f;
        
        [Header("UI")]
        [SerializeField] private Text countdownText;
        [SerializeField] private Text timerText;
        [SerializeField] private Text speedText;
        [SerializeField] private Text gearText;
        [SerializeField] private Text rpmText;
        [SerializeField] private GameObject startLights;
        
        [Header("Настройки")]
        [SerializeField] private float countdownDuration = 3f;
        [SerializeField] private float[] lightTimings;
        
        [Header("Результаты")]
        private float raceStartTime;
        private float raceFinishTime;
        private float playerFinishTime;
        private float aiFinishTime;
        private bool playerFinished;
        private bool aiFinished;
        
        [Header("События")]
        public System.Action<RaceState> OnRaceStateChanged;
        public System.Action<float> OnRaceFinished;
        
        // Дистанции
        private const float DISTANCE_QUARTER_MILE = 402f;
        private const float DISTANCE_HALF_MILE = 804f;
        private const float DISTANCE_ONE_MILE = 1609f;
        private const float DISTANCE_TWO_MILE = 3218f;
        
        private void Start()
        {
            InitializeRace();
        }
        
        private void Update()
        {
            UpdateState();
            UpdateUI();
        }
        
        #region Initialization
        
        private void InitializeRace()
        {
            Logger.I("=== RACE MANAGER INITIALIZED ===");
            
            // Проверка компонентов
            Logger.AssertNotNull(playerCar, "PlayerCar");
            
            if (playerCar == null)
            {
                Logger.E("PlayerCar not found!");
                return;
            }
            
            // Подписка на события
            playerCar.OnRaceFinished += OnPlayerFinished;
            
            // Настройка дистанции
            SetRaceDistance(raceDistance);
            
            // Старт двигателя
            playerCar.StartEngine();
            
            Logger.I($"Race distance: {GetDistanceString()}");
        }
        
        private void SetRaceDistance(RaceDistance distance)
        {
            raceDistance = distance;
            
            float dist = distance switch
            {
                RaceDistance.QuarterMile => DISTANCE_QUARTER_MILE,
                RaceDistance.HalfMile => DISTANCE_HALF_MILE,
                RaceDistance.OneMile => DISTANCE_ONE_MILE,
                RaceDistance.TwoMile => DISTANCE_TWO_MILE,
                _ => DISTANCE_QUARTER_MILE
            };
            
            Logger.I($"Race distance set to: {dist}m ({distance})");
        }
        
        private string GetDistanceString()
        {
            return raceDistance switch
            {
                RaceDistance.QuarterMile => "1/4 мили (402м)",
                RaceDistance.HalfMile => "1/2 мили (804м)",
                RaceDistance.OneMile => "1 миля (1609м)",
                RaceDistance.TwoMile => "2 мили (3218м) ⭐ MAX SPEED",
                RaceDistance.Test => "Тест",
                _ => "Неизвестно"
            };
        }
        
        #endregion
        
        #region State Machine
        
        private void UpdateState()
        {
            switch (currentState)
            {
                case RaceState.Waiting:
                    HandleWaiting();
                    break;
                case RaceState.Countdown:
                    HandleCountdown();
                    break;
                case RaceState.Racing:
                    HandleRacing();
                    break;
                case RaceState.Finished:
                    HandleFinished();
                    break;
            }
        }
        
        private void HandleWaiting()
        {
            // Ожидание начала гонки
            if (UnityEngine.Input.GetKeyDown(KeyCode.Return) || UnityEngine.Input.GetKeyDown(KeyCode.Space))
            {
                StartCountdown();
            }
        }
        
        private void HandleCountdown()
        {
            // Обратный отсчёт
            countdownDuration -= Time.deltaTime;
            
            if (countdownDuration <= 0)
            {
                StartRace();
            }
        }
        
        private void HandleRacing()
        {
            // Гонка в процессе
            float elapsedTime = Time.time - raceStartTime;
            timerText.text = $"{elapsedTime:F3}";
            
            // Проверка ИИ
            if (!aiFinished && aiCar != null)
            {
                UpdateAI();
                
                if (aiCar.GetDistance() >= GetRaceDistanceMeters())
                {
                    OnAIFinished();
                }
            }
        }
        
        private void HandleFinished()
        {
            // Гонка завершена
            if (UnityEngine.Input.GetKeyDown(KeyCode.Return) || UnityEngine.Input.GetKeyDown(KeyCode.Escape))
            {
                ReturnToMenu();
            }
        }
        
        #endregion
        
        #region Race Flow
        
        public void StartCountdown()
        {
            Logger.I("🚦 Starting countdown...");
            currentState = RaceState.Countdown;
            countdownDuration = 3f;
            OnRaceStateChanged?.Invoke(currentState);
        }
        
        public void StartRace()
        {
            Logger.I("🏁 RACE STARTED!");
            currentState = RaceState.Racing;
            raceStartTime = Time.time;
            playerFinished = false;
            aiFinished = false;
            
            OnRaceStateChanged?.Invoke(currentState);
            
            // Запуск ИИ с задержкой (реакция)
            if (aiCar != null)
            {
                Invoke(nameof(StartAI), aiReactionTime);
            }
        }
        
        private void StartAI()
        {
            if (aiCar != null)
            {
                aiCar.StartEngine();
                Logger.I("🤖 AI started");
            }
        }
        
        private void OnPlayerFinished()
        {
            if (playerFinished) return;
            
            playerFinished = true;
            playerFinishTime = Time.time - raceStartTime;
            
            Logger.I($"✅ Player finished: {playerFinishTime:F3}s");
            
            if (aiFinished)
            {
                FinishRace();
            }
        }
        
        private void OnAIFinished()
        {
            if (aiFinished) return;
            
            aiFinished = true;
            aiFinishTime = Time.time - raceStartTime;
            
            Logger.I($"🤖 AI finished: {aiFinishTime:F3}s");
            
            if (playerFinished)
            {
                FinishRace();
            }
        }
        
        private void FinishRace()
        {
            Logger.I("🏁 RACE FINISHED!");
            currentState = RaceState.Finished;
            raceFinishTime = Time.time - raceStartTime;
            
            OnRaceStateChanged?.Invoke(currentState);
            OnRaceFinished?.Invoke(playerFinishTime);
            
            // Определение победителя
            DetermineWinner();
            
            // Награда
            AwardMoneyAndExp();
        }
        
        private void DetermineWinner()
        {
            if (playerFinishTime < aiFinishTime)
            {
                Logger.I($"🏆 YOU WIN! ({playerFinishTime:F3}s vs {aiFinishTime:F3}s)");
            }
            else
            {
                Logger.I($"❌ YOU LOSE! ({playerFinishTime:F3}s vs {aiFinishTime:F3}s)");
            }
        }
        
        private void AwardMoneyAndExp()
        {
            // Награда за гонку
            int baseMoney = 200;
            int baseExp = 50;
            
            if (playerFinishTime < aiFinishTime)
            {
                baseMoney *= 2; // Бонус за победу
                baseExp *= 2;
            }
            
            Logger.I($"💰 Reward: ${baseMoney}");
            Logger.I($"⭐ EXP: {baseExp}");
            
            // TODO: Добавить игроку
            // playerData.money += baseMoney;
            // playerData.experience += baseExp;
        }
        
        #endregion
        
        #region AI Logic
        
        private void UpdateAI()
        {
            if (aiCar == null) return;
            
            // Простой ИИ: газ всегда нажат
            // Более сложный ИИ может переключать передачи и использовать нитро
            
            float aiShiftPoint = 6000f + (aiSkillLevel * 1000f);
            
            if (aiCar.GetRpm() > aiShiftPoint)
            {
                aiCar.ShiftUp();
            }
            else if (aiCar.GetRpm() < 3000f)
            {
                aiCar.ShiftDown();
            }
        }
        
        public void SetAIDifficulty(float skill)
        {
            aiSkillLevel = Mathf.Clamp01(skill);
            
            // Реакция от 0.7с (0 skill) до 0.3с (max skill)
            aiReactionTime = 0.7f - (aiSkillLevel * 0.4f);
            
            Logger.I($"AI difficulty set: {skill:F2} (Reaction: {aiReactionTime:F2}s)");
        }
        
        #endregion
        
        #region UI
        
        private void UpdateUI()
        {
            if (playerCar == null) return;
            
            // Обновление данных
            if (speedText != null)
                speedText.text = $"{playerCar.GetSpeedKmh():F0} км/ч";
            
            if (gearText != null)
                gearText.text = $"{playerCar.GetGear()}";
            
            if (rpmText != null)
                rpmText.text = $"{playerCar.GetRpm():F0}";
            
            // Countdown
            if (countdownText != null && currentState == RaceState.Countdown)
            {
                int count = Mathf.CeilToInt(countdownDuration);
                countdownText.text = count.ToString();
            }
        }
        
        #endregion
        
        #region Helpers
        
        private float GetRaceDistanceMeters()
        {
            return raceDistance switch
            {
                RaceDistance.QuarterMile => DISTANCE_QUARTER_MILE,
                RaceDistance.HalfMile => DISTANCE_HALF_MILE,
                RaceDistance.OneMile => DISTANCE_ONE_MILE,
                RaceDistance.TwoMile => DISTANCE_TWO_MILE,
                _ => DISTANCE_QUARTER_MILE
            };
        }
        
        public void ReturnToMenu()
        {
            Logger.I("Returning to menu...");
            Core.GameManager.Instance.ChangeState(Core.GameManager.GameState.MainMenu);
            Core.GameManager.Instance.LoadScene("MainMenu");
        }
        
        public void RestartRace()
        {
            Logger.I("Restarting race...");
            playerCar.Reset();
            if (aiCar != null) aiCar.Reset();
            currentState = RaceState.Waiting;
            OnRaceStateChanged?.Invoke(currentState);
        }
        
        #endregion
        
        #region Debug
        
        private void OnGUI()
        {
            if (!Application.isEditor) return;
            
            GUILayout.BeginArea(new Rect(10, 10, 300, 200));
            GUILayout.Label("=== RACE MANAGER ===");
            GUILayout.Label($"State: {currentState}");
            GUILayout.Label($"Distance: {GetDistanceString()}");
            
            string timeDisplay = currentState == RaceState.Racing 
                ? $"{(Time.time - raceStartTime):F2}s" 
                : "0.00s";
            GUILayout.Label($"Time: {timeDisplay}");
            
            if (currentState == RaceState.Finished)
            {
                GUILayout.Label($"Player: {playerFinishTime:F3}s");
                GUILayout.Label($"AI: {aiFinishTime:F3}s");
            }
            
            GUILayout.EndArea();
        }
        
        #endregion
    }
}
