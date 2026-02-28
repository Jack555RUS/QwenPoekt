using UnityEngine;
using DragRace.Data;
using DragRace.SaveSystem;

namespace DragRace.Core
{
    /// <summary>
    /// Главный менеджер игры (Singleton)
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        public static GameManager Instance { get; private set; }
        
        [Header("Ссылки на ScriptableObjects")]
        public GameConfig gameConfig;
        public CarDatabase carDatabase;
        public PartsDatabase partsDatabase;
        
        // Состояния игры
        public GameState CurrentState { get; private set; }
        
        // Данные
        public GameData GameData { get; private set; }
        public SettingsData Settings { get; private set; }
        
        // События
        public delegate void GameStateHandler(GameState state);
        public event GameStateHandler OnStateChanged;
        
        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }

            Instance = this;
            DontDestroyOnLoad(gameObject);
            
            // Инициализация конфигурации
            if (gameConfig == null)
            {
                gameConfig = Resources.Load<GameConfig>("GameConfig");
            }
            
            CurrentState = GameState.MainMenu;
            Settings = SaveManager.Instance?.GetSettings() ?? new SettingsData();
            
            ApplySettings();
        }
        
        private void Start()
        {
            // Подписка на события сохранения
            if (SaveManager.Instance != null)
            {
                SaveManager.Instance.OnGameLoaded += OnGameLoaded;
            }
        }
        
        private void OnDestroy()
        {
            if (SaveManager.Instance != null)
            {
                SaveManager.Instance.OnGameLoaded -= OnGameLoaded;
            }
        }
        
        #region Управление состоянием
        
        public void ChangeState(GameState newState)
        {
            GameState oldState = CurrentState;
            CurrentState = newState;
            
            Debug.Log($"Смена состояния: {oldState} -> {newState}");
            OnStateChanged?.Invoke(newState);
        }
        
        private void OnGameLoaded()
        {
            GameData = SaveManager.Instance.GetCurrentGameData();
            ChangeState(GameState.MainMenu);
        }
        
        #endregion
        
        #region Новая игра
        
        public void StartNewGame(string playerName)
        {
            if (SaveManager.Instance == null)
            {
                Debug.LogError("SaveManager не найден!");
                return;
            }
            
            SaveManager.Instance.InitializeNewGame(playerName);
            GameData = SaveManager.Instance.GetCurrentGameData();
            
            // Добавляем стартовый автомобиль
            AddStarterCar();
            
            ChangeState(GameState.GameMenu);
        }
        
        private void AddStarterCar()
        {
            if (carDatabase == null || carDatabase.carModels == null || carDatabase.carModels.Count == 0)
            {
                Debug.LogWarning("База автомобилей пуста");
                return;
            }
            
            // Берём первый доступный автомобиль (самый дешёвый)
            var starterCar = carDatabase.carModels[0];
            
            var vehicleData = new VehicleData
            {
                vehicleId = System.Guid.NewGuid().ToString(),
                vehicleName = starterCar.displayName,
                modelName = starterCar.modelName,
                manufacturer = starterCar.manufacturer,
                baseStats = starterCar.baseStats,
                currentStats = starterCar.baseStats,
                isOwned = true,
                purchasePrice = starterCar.basePrice,
                currentValue = starterCar.basePrice
            };
            
            GameData.playerVehicles.Add(vehicleData);
        }
        
        #endregion
        
        #region Настройки
        
        public void ApplySettings()
        {
            if (Settings == null) return;
            
            // Разрешение
            Screen.SetResolution(Settings.screenWidth, Settings.screenHeight, Settings.fullscreen);
            
            // Громкость
            AudioListener.volume = Settings.masterVolume / 100f;
        }
        
        public void UpdateSettings(SettingsData newSettings)
        {
            Settings = newSettings;
            SaveManager.Instance?.SetSettings(newSettings);
            ApplySettings();
        }
        
        #endregion
        
        #region Сохранение/Загрузка
        
        public void SaveGame(int slotIndex)
        {
            SaveManager.Instance?.SaveGame(slotIndex);
        }
        
        public bool LoadGame(int slotIndex)
        {
            return SaveManager.Instance?.LoadGame(slotIndex) ?? false;
        }
        
        public SaveInfo[] GetSaveSlots()
        {
            return SaveManager.Instance?.GetSaveSlotsInfo() ?? new SaveInfo[0];
        }
        
        public SaveInfo[] GetAutoSaves()
        {
            return SaveManager.Instance?.GetAutoSavesInfo() ?? new SaveInfo[0];
        }
        
        #endregion
        
        #region Экономика
        
        public void AddMoney(float amount)
        {
            if (GameData == null) return;
            
            GameData.playerData.money += amount;
        }
        
        public void SpendMoney(float amount)
        {
            if (GameData == null) return;
            
            if (GameData.playerData.money >= amount)
            {
                GameData.playerData.money -= amount;
            }
            else
            {
                Debug.LogWarning("Недостаточно денег!");
            }
        }
        
        public bool HasMoney(float amount)
        {
            return GameData?.playerData?.money >= amount ?? false;
        }
        
        public void AddExperience(float amount)
        {
            if (GameData == null) return;
            
            GameData.playerData.AddExperience(amount);
        }
        
        #endregion
        
        #region Транспорт
        
        public VehicleData GetCurrentVehicle()
        {
            if (GameData == null || GameData.playerVehicles.Count == 0)
                return null;
            
            return GameData.playerVehicles[GameData.currentVehicleIndex];
        }
        
        public void SetCurrentVehicle(int index)
        {
            if (GameData == null || index < 0 || index >= GameData.playerVehicles.Count)
                return;
            
            GameData.currentVehicleIndex = index;
        }
        
        #endregion
    }
    
    public enum GameState
    {
        MainMenu,
        GameMenu,
        Racing,
        Garage,
        Tuning,
        Shop,
        Settings,
        Paused
    }
}
