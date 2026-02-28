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
        
        public GameState CurrentState { get; private set; }
        public GameData GameData { get; private set; }
        public SettingsData Settings { get; private set; }
        
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
        
        public void StartNewGame(string playerName)
        {
            if (SaveManager.Instance == null)
            {
                Debug.LogError("SaveManager не найден!");
                return;
            }
            
            SaveManager.Instance.InitializeNewGame(playerName);
            GameData = SaveManager.Instance.GetCurrentGameData();
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
        
        public void ApplySettings()
        {
            if (Settings == null) return;
            
            Screen.SetResolution(Settings.screenWidth, Settings.screenHeight, Settings.fullscreen);
            AudioListener.volume = Settings.masterVolume / 100f;
        }
        
        public void UpdateSettings(SettingsData newSettings)
        {
            Settings = newSettings;
            SaveManager.Instance?.SetSettings(newSettings);
            ApplySettings();
        }
        
        public void SaveGame(int slotIndex) => SaveManager.Instance?.SaveGame(slotIndex);
        public bool LoadGame(int slotIndex) => SaveManager.Instance?.LoadGame(slotIndex) ?? false;
        public SaveInfo[] GetSaveSlots() => SaveManager.Instance?.GetSaveSlotsInfo() ?? new SaveInfo[0];
        public SaveInfo[] GetAutoSaves() => SaveManager.Instance?.GetAutoSavesInfo() ?? new SaveInfo[0];
        
        public void AddMoney(float amount)
        {
            if (GameData == null) return;
            GameData.playerData.money += amount;
        }
        
        public void SpendMoney(float amount)
        {
            if (GameData == null) return;
            if (GameData.playerData.money >= amount)
                GameData.playerData.money -= amount;
            else
                Debug.LogWarning("Недостаточно денег!");
        }
        
        public bool HasMoney(float amount)
        {
            if (GameData == null || GameData.playerData == null)
                return false;
            return GameData.playerData.money >= amount;
        }
        
        public void AddExperience(float amount)
        {
            if (GameData == null) return;
            GameData.playerData.AddExperience(amount);
        }
        
        public VehicleData GetCurrentVehicle()
        {
            if (GameData == null || GameData.playerVehicles.Count == 0) return null;
            return GameData.playerVehicles[GameData.currentVehicleIndex];
        }
        
        public void SetCurrentVehicle(int index)
        {
            if (GameData == null || index < 0 || index >= GameData.playerVehicles.Count) return;
            GameData.currentVehicleIndex = index;
        }
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
