using System.Collections;
using UnityEngine;
using UnityEngine.Events;

namespace DragRace.Racing
{
    /// <summary>
    /// Светофор для старта заезда
    /// </summary>
    public class TrafficLight : MonoBehaviour
    {
        [Header("Спрайты индикаторов")]
        public Sprite redLightSprite;
        public Sprite yellowLightSprite;
        public Sprite greenLightSprite;
        public Sprite offLightSprite;
        
        [Header("Временные интервалы")]
        public float redDelay = 1f;
        public float yellowDelay = 0.5f;
        public float greenDelay = 0.1f; // Задержка перед зелёным (реакция)
        
        [Header("События")]
        public UnityEvent OnRedLight;
        public UnityEvent OnYellowLight;
        public UnityEvent OnGreenLight;
        public UnityEvent OnFalseStart;
        
        // Состояние
        public bool IsGreen { get; private set; }
        public bool IsRed { get; private set; }
        public bool SequenceStarted { get; private set; }
        
        private Coroutine _currentSequence;
        
        public void StartSequence()
        {
            if (_currentSequence != null)
                StopCoroutine(_currentSequence);
            
            IsGreen = false;
            IsRed = false;
            SequenceStarted = true;
            
            _currentSequence = StartCoroutine(LightSequence());
        }
        
        private IEnumerator LightSequence()
        {
            // Красный
            yield return new WaitForSeconds(redDelay);
            SetLight(LightState.Red);
            IsRed = true;
            OnRedLight?.Invoke();
            
            // Жёлтый
            yield return new WaitForSeconds(yellowDelay);
            SetLight(LightState.Yellow);
            OnYellowLight?.Invoke();
            
            // Зелёный
            yield return new WaitForSeconds(yellowDelay);
            SetLight(LightState.Green);
            IsGreen = true;
            IsRed = false;
            OnGreenLight?.Invoke();
        }
        
        private void SetLight(LightState state)
        {
            // Здесь должна быть логика обновления спрайтов
            Debug.Log($"Светофор: {state}");
        }
        
        public void CheckFalseStart(float playerReactionTime)
        {
            if (!IsGreen && SequenceStarted)
            {
                OnFalseStart?.Invoke();
                Debug.Log("Фальстарт!");
            }
        }
        
        public void Reset()
        {
            IsGreen = false;
            IsRed = false;
            SequenceStarted = false;
            SetLight(LightState.Off);
        }
        
        private enum LightState
        {
            Off,
            Red,
            Yellow,
            Green
        }
    }
}
