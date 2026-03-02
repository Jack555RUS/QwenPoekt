using UnityEngine;
using UnityEngine.Events;
using System.Collections.Generic;
using ProbMenu.Core;

namespace ProbMenu.Core
{
    /// <summary>
    /// Система событий для слабой связанности между системами
    /// </summary>
    public class EventBus : MonoBehaviour
    {
        private static EventBus _instance;
        public static EventBus Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<EventBus>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("EventBus");
                        _instance = go.AddComponent<EventBus>();
                        DontDestroyOnLoad(go);
                        Logger.I("EventBus created");
                    }
                }
                return _instance;
            }
        }

        private Dictionary<string, UnityEvent> events = new Dictionary<string, UnityEvent>();
        private int _totalEventsTriggered = 0;

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

        /// <summary>
        /// Подписаться на событие
        /// </summary>
        public static void Subscribe(string eventName, UnityAction action)
        {
            Logger.Assert(!string.IsNullOrEmpty(eventName), "Event name is empty!");
            Logger.AssertNotNull(action, "Action is null!");

            if (string.IsNullOrEmpty(eventName))
            {
                Logger.E("Cannot subscribe to empty event name!");
                return;
            }

            if (action == null)
            {
                Logger.E("Cannot subscribe null action!");
                return;
            }

            if (!Instance.events.ContainsKey(eventName))
            {
                Instance.events[eventName] = new UnityEvent();
                Logger.D($"Created new event: {eventName}");
            }

            Instance.events[eventName].AddListener(action);
            Logger.D($"Subscribed to '{eventName}'");
        }

        /// <summary>
        /// Отписаться от события
        /// </summary>
        public static void Unsubscribe(string eventName, UnityAction action)
        {
            Logger.Assert(!string.IsNullOrEmpty(eventName), "Event name is empty!");

            if (string.IsNullOrEmpty(eventName))
            {
                Logger.E("Cannot unsubscribe from empty event name!");
                return;
            }

            if (Instance.events.ContainsKey(eventName))
            {
                Instance.events[eventName].RemoveListener(action);
                Logger.D($"Unsubscribed from '{eventName}'");

                // Очистка пустых событий
                if (Instance.events[eventName].GetPersistentEventCount() == 0)
                {
                    Instance.events.Remove(eventName);
                    Logger.D($"Removed empty event: {eventName}");
                }
            }
        }

        /// <summary>
        /// Вызвать событие
        /// </summary>
        public static void Trigger(string eventName)
        {
            Logger.Assert(!string.IsNullOrEmpty(eventName), "Event name is empty!");

            if (string.IsNullOrEmpty(eventName))
            {
                Logger.E("Cannot trigger empty event!");
                return;
            }

            if (Instance.events.ContainsKey(eventName))
            {
                Logger.D($"📢 Triggering event: {eventName}");
                Instance.events[eventName].Invoke();
                Instance._totalEventsTriggered++;
            }
            else
            {
                Logger.W($"Event not found: {eventName}");
            }
        }

        /// <summary>
        /// Вызвать событие с параметром
        /// </summary>
        public static void Trigger<T>(string eventName, T parameter)
        {
            Logger.Assert(!string.IsNullOrEmpty(eventName), "Event name is empty!");

            if (string.IsNullOrEmpty(eventName))
            {
                Logger.E("Cannot trigger empty event!");
                return;
            }

            // Для событий с параметром используем другой подход
            Logger.D($"📢 Triggering event with param: {eventName} = {parameter}");
            // TODO: Реализовать через UnityEvent<T>
        }

        /// <summary>
        /// Получить количество подписчиков на событие
        /// </summary>
        public static int GetSubscriberCount(string eventName)
        {
            if (Instance.events.ContainsKey(eventName))
            {
                return Instance.events[eventName].GetPersistentEventCount();
            }
            return 0;
        }

        /// <summary>
        /// Получить статистику событий
        /// </summary>
        public static string GetStatistics()
        {
            return $"Events: {Instance.events.Count} | Triggered: {Instance._totalEventsTriggered}";
        }

        /// <summary>
        /// Очистить все события
        /// </summary>
        public static void ClearAll()
        {
            Instance.events.Clear();
            Instance._totalEventsTriggered = 0;
            Logger.I("All events cleared");
        }
    }

    /// <summary>
    /// Предопределённые имена событий
    /// </summary>
    public static class EventNames
    {
        // Игра
        public const string OnGameStarted = "OnGameStarted";
        public const string OnGamePaused = "OnGamePaused";
        public const string OnGameResumed = "OnGameResumed";
        public const string OnGameEnded = "OnGameEnded";

        // Игрок
        public const string OnPlayerCreated = "OnPlayerCreated";
        public const string OnPlayerLevelUp = "OnPlayerLevelUp";
        public const string OnMoneyChanged = "OnMoneyChanged";
        public const string OnExperienceChanged = "OnExperienceChanged";

        // Сохранения
        public const string OnGameSaved = "OnGameSaved";
        public const string OnGameLoaded = "OnGameLoaded";

        // Настройки
        public const string OnSettingsChanged = "OnSettingsChanged";
        public const string OnResolutionChanged = "OnResolutionChanged";
        public const string OnVolumeChanged = "OnVolumeChanged";

        // Гонка
        public const string OnRaceStarted = "OnRaceStarted";
        public const string OnRaceFinished = "OnRaceFinished";
        public const string OnCountdownStarted = "OnCountdownStarted";

        // Автомобиль
        public const string OnCarChanged = "OnCarChanged";
        public const string OnCarUpgraded = "OnCarUpgraded";

        // UI
        public const string OnUIOpened = "OnUIOpened";
        public const string OnUIClosed = "OnUIClosed";
    }
}
