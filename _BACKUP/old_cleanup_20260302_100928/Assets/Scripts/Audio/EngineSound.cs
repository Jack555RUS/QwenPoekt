using UnityEngine;
using ProbMenu.Core;
using ProbMenu.Physics;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Audio
{
    /// <summary>
    /// Звук двигателя автомобиля
    /// Динамический звук от оборотов и нагрузки
    /// </summary>
    public class EngineSound : MonoBehaviour
    {
        [Header("Аудио источники")]
        [SerializeField] private AudioSource engineSource;
        [SerializeField] private AudioSource exhaustSource;
        [SerializeField] private AudioSource turboSource;

        [Header("Клипы")]
        [SerializeField] private AudioClip engineIdle;
        [SerializeField] private AudioClip engineLoad;
        [SerializeField] private AudioClip exhaustLoop;
        [SerializeField] private AudioClip turboWhoosh;

        [Header("Настройки")]
        [SerializeField] private float minPitch = 0.5f;
        [SerializeField] private float maxPitch = 2.0f;
        [SerializeField] private float minVolume = 0.3f;
        [SerializeField] private float maxVolume = 1.0f;

        [Header("Ссылки")]
        [SerializeField] private CarPhysics carPhysics;

        private float currentRpm;
        private float throttle;

        private void Start()
        {
            Logger.I("EngineSound initialized");

            if (carPhysics == null)
            {
                carPhysics = GetComponent<CarPhysics>();
            }

            SetupAudioSources();
        }

        private void Update()
        {
            if (carPhysics == null) return;

            currentRpm = carPhysics.GetRpm();
            UpdateEngineSound();
            UpdateExhaustSound();
            UpdateTurboSound();
        }

        #region Setup

        private void SetupAudioSources()
        {
            // Создаём источники если не назначены
            if (engineSource == null)
            {
                engineSource = gameObject.AddComponent<AudioSource>();
                engineSource.loop = true;
                engineSource.playOnAwake = false;
            }

            if (exhaustSource == null)
            {
                exhaustSource = gameObject.AddComponent<AudioSource>();
                exhaustSource.loop = true;
                exhaustSource.playOnAwake = false;
            }

            if (turboSource == null)
            {
                turboSource = gameObject.AddComponent<AudioSource>();
                turboSource.loop = false;
                turboSource.playOnAwake = false;
            }
        }

        #endregion

        #region Sound Updates

        private void UpdateEngineSound()
        {
            if (engineSource == null) return;

            // Расчёт тона от RPM
            float rpmNormalized = currentRpm / 8000f;
            float targetPitch = Mathf.Lerp(minPitch, maxPitch, rpmNormalized);
            engineSource.pitch = Mathf.Lerp(engineSource.pitch, targetPitch, 5f * Time.deltaTime);

            // Громкость от газа
            throttle = UnityEngine.Input.GetKey(KeyCode.W) || UnityEngine.Input.GetKey(KeyCode.UpArrow) ? 1f : 0.2f;
            float targetVolume = Mathf.Lerp(minVolume, maxVolume, throttle);
            engineSource.volume = Mathf.Lerp(engineSource.volume, targetVolume, 3f * Time.deltaTime);

            // Микширование idle/load
            if (!engineSource.isPlaying)
            {
                engineSource.PlayOneShot(engineIdle ?? engineLoad);
            }
        }

        private void UpdateExhaustSound()
        {
            if (exhaustSource == null) return;

            float rpmNormalized = currentRpm / 8000f;
            exhaustSource.pitch = 0.5f + rpmNormalized * 1.5f;
            exhaustSource.volume = rpmNormalized * throttle;

            if (!exhaustSource.isPlaying && throttle > 0.1f)
            {
                exhaustSource.Play();
            }
            else if (exhaustSource.isPlaying && throttle < 0.1f)
            {
                exhaustSource.Stop();
            }
        }

        private void UpdateTurboSound()
        {
            if (turboSource == null || turboWhoosh == null) return;

            // Звук турбо при переключении
            if (UnityEngine.Input.GetKeyDown(KeyCode.D) || UnityEngine.Input.GetKeyDown(KeyCode.RightArrow))
            {
                if (!turboSource.isPlaying)
                {
                    turboSource.PlayOneShot(turboWhoosh, 0.5f);
                }
            }
        }

        #endregion

        #region Public Methods

        public void StartEngine()
        {
            if (engineSource != null && !engineSource.isPlaying)
            {
                engineSource.Play();
            }

            Logger.I("Engine sound started");
        }

        public void StopEngine()
        {
            if (engineSource != null) engineSource.Stop();
            if (exhaustSource != null) exhaustSource.Stop();
            if (turboSource != null) turboSource.Stop();

            Logger.I("Engine sound stopped");
        }

        public void SetThrottle(float value)
        {
            throttle = Mathf.Clamp01(value);
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 750, 300, 100));
            GUILayout.Label("=== ENGINE SOUND ===");
            GUILayout.Label($"RPM: {currentRpm:F0}");
            GUILayout.Label($"Throttle: {throttle * 100:F0}%");
            GUILayout.Label($"Pitch: {engineSource?.pitch:F2}");
            GUILayout.EndArea();
        }

        #endregion
    }
}
