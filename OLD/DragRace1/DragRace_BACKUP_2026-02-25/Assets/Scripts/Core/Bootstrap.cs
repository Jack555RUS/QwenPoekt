using UnityEngine;
using DragRace.Core;
using DragRace.SaveSystem;
using DragRace.InputSystem;
using DragRace.Racing;

namespace DragRace
{
    /// <summary>
    /// Автоматическая инициализация менеджеров
    /// </summary>
    public class Bootstrap : MonoBehaviour
    {
        [Header("Менеджеры")]
        public GameManager gameManagerPrefab;
        public SaveManager saveManagerPrefab;
        public InputManager inputManagerPrefab;
        public RaceManager raceManagerPrefab;
        
        private void Awake()
        {
            // Создание менеджеров
            CreateManager<GameManager>(gameManagerPrefab);
            CreateManager<SaveManager>(saveManagerPrefab);
            CreateManager<InputManager>(inputManagerPrefab);
            CreateManager<RaceManager>(raceManagerPrefab);
        }
        
        private void CreateManager<T>(T prefab) where T : MonoBehaviour
        {
            if (FindFirstObjectByType<T>() == null)
            {
                if (prefab != null)
                {
                    Instantiate(prefab);
                }
                else
                {
                    var go = new GameObject(typeof(T).Name);
                    go.AddComponent<T>();
                }
            }
        }
    }
}
