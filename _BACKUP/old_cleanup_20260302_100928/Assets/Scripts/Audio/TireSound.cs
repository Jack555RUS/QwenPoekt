using UnityEngine;
using ProbMenu.Core;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Audio
{
    /// <summary>
    /// Звуки шин и пробуксовки
    /// </summary>
    public class TireSound : MonoBehaviour
    {
        [Header("Аудио источники")]
        [SerializeField] private AudioSource tireSource;

        [Header("Клипы")]
        [SerializeField] private AudioClip tireRoll;
        [SerializeField] private AudioClip tireSkid;
        [SerializeField] private AudioClip tireScreech;

        [Header("Настройки")]
        [SerializeField] private float skidThreshold = 0.5f;
        [SerializeField] private float screechThreshold = 0.8f;

        [Header("Ссылки")]
        [SerializeField] private Physics.CarPhysics carPhysics;

        private float slipAmount;
        private float speed;

        private void Start()
        {
            Logger.I("TireSound initialized");

            if (carPhysics == null)
            {
                carPhysics = GetComponent<Physics.CarPhysics>();
            }

            SetupAudioSource();
        }

        private void Update()
        {
            if (carPhysics == null) return;

            speed = carPhysics.GetSpeed();
            CalculateSlip();
            UpdateTireSound();
        }

        #region Setup

        private void SetupAudioSource()
        {
            if (tireSource == null)
            {
                tireSource = gameObject.AddComponent<AudioSource>();
                tireSource.loop = true;
                tireSource.playOnAwake = false;
            }
        }

        #endregion

        #region Physics

        private void CalculateSlip()
        {
            // Упрощённый расчёт пробуксовки
            bool isGasPressed = UnityEngine.Input.GetKey(KeyCode.W) || UnityEngine.Input.GetKey(KeyCode.UpArrow);
            bool isBraking = UnityEngine.Input.GetKey(KeyCode.Space) || UnityEngine.Input.GetKey(KeyCode.S);

            if (isGasPressed && speed < 10f)
            {
                slipAmount = 1f; // Максимальная пробуксовка при старте
            }
            else if (isBraking && speed > 5f)
            {
                slipAmount = 0.8f; // Блокировка при торможении
            }
            else
            {
                slipAmount = Mathf.Lerp(slipAmount, 0f, 5f * Time.deltaTime);
            }
        }

        #endregion

        #region Sound Updates

        private void UpdateTireSound()
        {
            if (tireSource == null) return;

            // Громкость от скорости
            float targetVolume = Mathf.Min(speed / 30f, 1f);

            if (slipAmount > skidThreshold)
            {
                // Пробуксовка/юз
                targetVolume *= slipAmount;
                tireSource.pitch = Random.Range(0.8f, 1.2f);

                if (!tireSource.isPlaying)
                {
                    tireSource.PlayOneShot(tireSkid ?? tireScreech, slipAmount);
                }
            }
            else
            {
                // Обычный качение
                tireSource.volume = Mathf.Lerp(tireSource.volume, targetVolume * 0.3f, 3f * Time.deltaTime);
                tireSource.pitch = 0.5f + (speed / 100f);

                if (targetVolume > 0.1f && !tireSource.isPlaying)
                {
                    tireSource.PlayOneShot(tireRoll, targetVolume * 0.3f);
                }
            }
        }

        #endregion

        #region Public Methods

        public void PlayScreech()
        {
            if (tireSource != null && tireScreech != null)
            {
                tireSource.PlayOneShot(tireScreech, 1f);
                Logger.D("Tire screech!");
            }
        }

        public void Stop()
        {
            if (tireSource != null)
            {
                tireSource.Stop();
            }
        }

        #endregion
    }
}
