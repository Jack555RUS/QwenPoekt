using UnityEngine;
using ProbMenu.Core;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Racing
{
    /// <summary>
    /// Светофор на старте
    /// 3 красных + 1 зелёный
    /// </summary>
    public class TrafficLight : MonoBehaviour
    {
        [Header("Лампы")]
        [SerializeField] private GameObject[] redLights;  // 3 красных
        [SerializeField] private GameObject greenLight;   // 1 зелёный
        
        [Header("Настройки")]
        [SerializeField] private float redDelay = 1f;     // Задержка между красными
        [SerializeField] private float greenDelay = 0.5f; // Задержка перед зелёным
        
        [Header("События")]
        public System.Action OnGreenLight;
        public System.Action OnRedLight;
        
        private bool isRunning;
        
        private void Start()
        {
            Logger.Assert(redLights != null && redLights.Length == 3, "Need 3 red lights!");
            Logger.AssertNotNull(greenLight, "Green light");
            
            ResetLights();
        }
        
        public void StartSequence()
        {
            if (isRunning) return;
            
            Logger.I("🚦 Traffic light sequence started");
            isRunning = true;
            StartCoroutine(RunSequence());
        }
        
        private System.Collections.IEnumerator RunSequence()
        {
            // 3 красных по очереди
            for (int i = 0; i < redLights.Length; i++)
            {
                redLights[i].SetActive(true);
                OnRedLight?.Invoke();
                yield return new WaitForSeconds(redDelay);
            }
            
            // Пауза перед зелёным
            yield return new WaitForSeconds(greenDelay);
            
            // Зелёный!
            greenLight.SetActive(true);
            OnGreenLight?.Invoke();
            Logger.I("🟢 GREEN LIGHT!");
            
            isRunning = false;
        }
        
        public void ResetLights()
        {
            if (redLights != null)
            {
                foreach (var light in redLights)
                {
                    if (light != null) light.SetActive(false);
                }
            }
            
            if (greenLight != null)
            {
                greenLight.SetActive(false);
            }
            
            isRunning = false;
        }
        
        public bool IsGreen()
        {
            return greenLight != null && greenLight.activeSelf;
        }
        
        public bool IsRunning()
        {
            return isRunning;
        }
    }
}
