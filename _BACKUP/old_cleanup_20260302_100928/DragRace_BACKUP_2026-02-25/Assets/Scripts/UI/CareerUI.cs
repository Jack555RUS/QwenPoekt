using UnityEngine;
using UnityEngine.UI;
using DragRace.Data;
using DragRace.Core;
using DragRace.Managers;

namespace DragRace.UI
{
    /// <summary>
    /// UI карьеры - карта прогресса
    /// </summary>
    public class CareerUI : MonoBehaviour
    {
        [Header("Панели")]
        public GameObject careerMapPanel;
        public GameObject tierSelectPanel;
        public GameObject raceDetailPanel;
        
        [Header("Информация о тире")]
        public Text tierNameText;
        public Text tierDescriptionText;
        public Text tierProgressText;
        public Slider tierProgressSlider;
        
        [Header("Список гонок")]
        public Transform racesListContainer;
        public GameObject raceListItemPrefab;
        
        [Header("Детали гонки")]
        public Text raceNameText;
        public Text opponentNameText;
        public Text opponentCarText;
        public Text distanceText;
        public Text entryFeeText;
        public Text prizePoolText;
        public Text bestTimeText;
        public Text starsEarnedText;
        
        [Header("Звёзды")]
        public Image star1;
        public Image star2;
        public Image star3;
        
        [Header("Кнопки")]
        public Button startRaceButton;
        public Button backButton;
        public Button nextTierButton;
        
        [Header("Навигация по тиерам")]
        public Button previousTierButton;
        public Button nextTierButtonNav;
        
        private CareerData careerData;
        private int currentTierIndex;
        private CareerRace selectedRace;
        
        private void Start()
        {
            careerData = CareerManager.Instance?.careerData;
            
            if (careerData == null)
            {
                Debug.LogError("CareerManager не найден!");
                return;
            }
            
            currentTierIndex = careerData.currentTier;
            
            SubscribeToEvents();
            UpdateCareerMap();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (CareerManager.Instance != null)
            {
                CareerManager.Instance.OnCareerUpdated += OnCareerUpdated;
            }
            
            if (startRaceButton != null)
                startRaceButton.onClick.AddListener(OnStartRaceClicked);
            
            if (backButton != null)
                backButton.onClick.AddListener(OnBackClicked);
            
            if (nextTierButton != null)
                nextTierButton.onClick.AddListener(OnNextTierClicked);
            
            if (previousTierButton != null)
                previousTierButton.onClick.AddListener(OnPreviousTierClicked);
            
            if (nextTierButtonNav != null)
                nextTierButtonNav.onClick.AddListener(OnNextTierClicked);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (CareerManager.Instance != null)
            {
                CareerManager.Instance.OnCareerUpdated -= OnCareerUpdated;
            }
        }
        
        #region Отображение
        
        private void UpdateCareerMap()
        {
            var currentTier = careerData.tiers[currentTierIndex];
            
            if (tierNameText != null)
                tierNameText.text = currentTier.name;
            
            if (tierDescriptionText != null)
                tierDescriptionText.text = currentTier.description;
            
            UpdateTierProgress();
            UpdateRacesList();
        }
        
        private void UpdateTierProgress()
        {
            var currentTier = careerData.tiers[currentTierIndex];
            
            // Подсчёт звёзд
            int totalStars = 0;
            int maxStars = currentTier.races.Count * 3;
            
            foreach (var race in currentTier.races)
            {
                totalStars += careerData.GetStars(race.id);
            }
            
            if (tierProgressText != null)
                tierProgressText.text = $"Звёзды: {totalStars}/{maxStars}";
            
            if (tierProgressSlider != null)
                tierProgressSlider.value = (float)totalStars / maxStars;
        }
        
        private void UpdateRacesList()
        {
            if (racesListContainer == null || raceListItemPrefab == null)
                return;
            
            // Очистка
            foreach (Transform child in racesListContainer)
                Destroy(child.gameObject);
            
            var currentTier = careerData.tiers[currentTierIndex];
            
            // Создание элементов
            foreach (var race in currentTier.races)
            {
                GameObject item = Instantiate(raceListItemPrefab, racesListContainer);
                
                var listItem = item.GetComponent<CareerRaceListItem>();
                if (listItem != null)
                {
                    bool isUnlocked = careerData.IsRaceUnlocked(race.id);
                    int stars = careerData.GetStars(race.id);
                    
                    listItem.Initialize(race.name, race.distanceMeters, isUnlocked, stars);
                    listItem.OnClicked += () => OnRaceSelected(race);
                }
            }
            
            // Добавить босса
            if (currentTier.boss != null)
            {
                GameObject bossItem = Instantiate(raceListItemPrefab, racesListContainer);
                var bossListItem = bossItem.GetComponent<CareerRaceListItem>();
                if (bossListItem != null)
                {
                    bossListItem.InitializeAsBoss(currentTier.boss.name, currentTier.boss.requiredStarsToChallenge);
                    bossListItem.OnClicked += () => OnBossSelected(currentTier.boss);
                }
            }
        }
        
        private void OnRaceSelected(CareerRace race)
        {
            selectedRace = race;
            ShowRaceDetails(race);
        }
        
        private void OnBossSelected(CareerBoss boss)
        {
            // Показать детали босса
            ShowBossDetails(boss);
        }
        
        private void ShowRaceDetails(CareerRace race)
        {
            if (raceNameText != null)
                raceNameText.text = race.name;
            
            if (opponentNameText != null)
                opponentNameText.text = $"Соперник: {race.opponentName}";
            
            if (opponentCarText != null)
                opponentCarText.text = $"Авто: {race.opponentCarId}";
            
            if (distanceText != null)
                distanceText.text = $"Дистанция: {race.distanceMeters:F0} м";
            
            if (entryFeeText != null)
                entryFeeText.text = $"Взнос: {race.entryFee:F0} $";
            
            if (prizePoolText != null)
                prizePoolText.text = $"Приз: {race.prizePool * CareerManager.Instance.basePrizeMultiplier:F0} $";
            
            // Лучшее время
            float bestTime = careerData.GetBestTime(race.id);
            if (bestTimeText != null)
            {
                if (bestTime == float.MaxValue)
                    bestTimeText.text = "Лучшее время: --";
                else
                    bestTimeText.text = $"Лучшее: {bestTime:F3} с";
            }
            
            // Звёзды
            UpdateStarsDisplay(careerData.GetStars(race.id));
            
            // Проверка доступности
            bool canStart = careerData.IsRaceUnlocked(race.id);
            if (startRaceButton != null)
                startRaceButton.interactable = canStart;
        }
        
        private void ShowBossDetails(CareerBoss boss)
        {
            if (raceNameText != null)
                raceNameText.text = $"БОСС: {boss.name}";
            
            if (opponentCarText != null)
                opponentCarText.text = $"Авто босса: {boss.bossCarId}";
            
            if (distanceText != null)
                distanceText.text = $"Дистанция: {boss.distanceMeters:F0} м";
            
            if (prizePoolText != null)
                prizePoolText.text = $"Приз: {boss.prizePool:F0} $";
            
            // Проверка доступности
            int totalStars = GetTotalStarsInCurrentTier();
            bool canChallenge = totalStars >= boss.requiredStarsToChallenge;
            
            if (startRaceButton != null)
                startRaceButton.interactable = canChallenge;
        }
        
        private void UpdateStarsDisplay(int stars)
        {
            if (star1 != null) star1.gameObject.SetActive(stars >= 1);
            if (star2 != null) star2.gameObject.SetActive(stars >= 2);
            if (star3 != null) star3.gameObject.SetActive(stars >= 3);
        }
        
        private int GetTotalStarsInCurrentTier()
        {
            var currentTier = careerData.tiers[currentTierIndex];
            int total = 0;
            
            foreach (var race in currentTier.races)
            {
                total += careerData.GetStars(race.id);
            }
            
            return total;
        }
        
        #endregion
        
        #region Действия
        
        private void OnStartRaceClicked()
        {
            if (selectedRace == null) return;
            
            // Запуск гонки
            CareerManager.Instance.StartRace(selectedRace.id);
        }
        
        private void OnNextTierClicked()
        {
            if (careerData.CanAdvanceToNextTier() && currentTierIndex < careerData.tiers.Count - 1)
            {
                currentTierIndex++;
                UpdateCareerMap();
            }
        }
        
        private void OnPreviousTierClicked()
        {
            if (currentTierIndex > 0)
            {
                currentTierIndex--;
                UpdateCareerMap();
            }
        }
        
        private void OnBackClicked()
        {
            GameManager.Instance.ChangeState(GameState.GameMenu);
        }
        
        #endregion
        
        #region События
        
        private void OnCareerUpdated(CareerData data)
        {
            UpdateCareerMap();
        }
        
        #endregion
    }
    
    /// <summary>
    /// Элемент списка гонок в карьере
    /// </summary>
    public class CareerRaceListItem : MonoBehaviour
    {
        public Text raceNameText;
        public Text distanceText;
        public Image lockedOverlay;
        public Text lockedText;
        public Image[] starImages;
        public Button selectButton;
        
        public System.Action OnClicked;
        
        public void Initialize(string name, float distance, bool isUnlocked, int stars)
        {
            if (raceNameText != null)
                raceNameText.text = name;
            
            if (distanceText != null)
                distanceText.text = $"{distance:F0} м";
            
            if (lockedOverlay != null)
                lockedOverlay.gameObject.SetActive(!isUnlocked);
            
            if (lockedText != null)
                lockedText.gameObject.SetActive(!isUnlocked);
            
            // Звёзды
            for (int i = 0; i < starImages.Length; i++)
            {
                if (starImages[i] != null)
                    starImages[i].gameObject.SetActive(i < stars);
            }
            
            if (selectButton != null)
                selectButton.onClick.AddListener(() => OnClicked?.Invoke());
        }
        
        public void InitializeAsBoss(string name, int requiredStars)
        {
            if (raceNameText != null)
                raceNameText.text = $"👑 {name}";
            
            if (lockedText != null)
                lockedText.text = $"{requiredStars} ⭐";
        }
    }
}
