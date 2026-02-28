using UnityEngine;
using System.Collections;

namespace DragRace.Audio
{
    /// <summary>
    /// Менеджер аудио системы
    /// Управляет звуками двигателя, эффектами, музыкой
    /// </summary>
    public class AudioManager : MonoBehaviour
    {
        #region Singleton
        
        private static AudioManager _instance;
        
        public static AudioManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindFirstObjectByType<AudioManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("AudioManager");
                        _instance = go.AddComponent<AudioManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
        }
        
        #endregion
        
        #region Parameters
        
        [Header("Источники звука")]
        [Tooltip("Источник музыки")]
        public AudioSource musicSource;
        
        [Tooltip("Источник эффектов")]
        public AudioSource sfxSource;
        
        [Tooltip("Источник звука двигателя")]
        public AudioSource engineSource;
        
        [Header("Клипы")]
        [Tooltip("Музыка меню")]
        public AudioClip menuMusic;
        
        [Tooltip("Музыка гонки")]
        public AudioClip raceMusic;
        
        [Tooltip("Звук двигателя (холостой)")]
        public AudioClip engineIdle;
        
        [Tooltip("Звук двигателя (ускорение)")]
        public AudioClip engineAccelerate;
        
        [Tooltip("Звук переключения передач")]
        public AudioClip gearShiftSound;
        
        [Tooltip("Звук пробуксовки")]
        public AudioClip tireSquealSound;
        
        [Tooltip("Звук нитро")]
        public AudioClip nitroSound;
        
        [Tooltip("Звук финиша")]
        public AudioClip finishSound;
        
        [Header("Настройки")]
        [Tooltip("Общая громкость (0-1)")]
        [Range(0f, 1f)]
        public float masterVolume = 0.8f;
        
        [Tooltip("Громкость музыки (0-1)")]
        [Range(0f, 1f)]
        public float musicVolume = 0.7f;
        
        [Tooltip("Громкость эффектов (0-1)")]
        [Range(0f, 1f)]
        public float sfxVolume = 1.0f;
        
        [Tooltip("Громкость двигателя (0-1)")]
        [Range(0f, 1f)]
        public float engineVolume = 1.0f;
        
        [Header("Параметры двигателя")]
        [Tooltip("Минимальная высота тона (холостой)")]
        public float minEnginePitch = 0.8f;
        
        [Tooltip("Максимальная высота тона (красная зона)")]
        public float maxEnginePitch = 2.5f;
        
        [Tooltip("Минимальные обороты (холостой)")]
        public float minRpm = 800f;
        
        [Tooltip("Максимальные обороты (отсечка)")]
        public float maxRpm = 8000f;
        
        #endregion
        
        #region State
        
        private bool isInitialized = false;
        private float currentEngineRpm = 800f;
        private float targetEnginePitch = 1.0f;
        private bool isEngineRunning = false;
        
        #endregion
        
        #region Events
        
        public delegate void AudioStateChangedHandler();
        public event AudioStateChangedHandler OnAudioChanged;
        
        #endregion
        
        #region Properties
        
        public float MasterVolume 
        { 
            get => masterVolume; 
            set { masterVolume = Mathf.Clamp01(value); UpdateVolumes(); }
        }
        
        public float MusicVolume 
        { 
            get => musicVolume; 
            set { musicVolume = Mathf.Clamp01(value); UpdateVolumes(); }
        }
        
        public float EngineVolume 
        { 
            get => engineVolume; 
            set { engineVolume = Mathf.Clamp01(value); UpdateVolumes(); }
        }
        
        public float SfxVolume 
        { 
            get => sfxVolume; 
            set { sfxVolume = Mathf.Clamp01(value); UpdateVolumes(); }
        }
        
        #endregion
        
        #region Unity Methods
        
        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            _instance = this;
            DontDestroyOnLoad(gameObject);
            
            InitializeAudio();
        }
        
        private void Update()
        {
            if (isEngineRunning && engineSource != null)
            {
                UpdateEngineSound();
            }
        }
        
        #endregion
        
        #region Initialization
        
        /// <summary>
        /// Инициализация аудио системы
        /// </summary>
        public void InitializeAudio()
        {
            if (isInitialized) return;
            
            Debug.Log("🔊 AudioManager инициализирован");
            
            // Создание источников если не назначены
            CreateAudioSources();
            
            // Применение громкости
            UpdateVolumes();
            
            isInitialized = true;
        }
        
        /// <summary>
        /// Создание источников звука
        /// </summary>
        private void CreateAudioSources()
        {
            if (musicSource == null)
            {
                musicSource = gameObject.AddComponent<AudioSource>();
                musicSource.loop = true;
                musicSource.playOnAwake = false;
                musicSource.spatialBlend = 0f; // 2D звук
            }
            
            if (sfxSource == null)
            {
                sfxSource = gameObject.AddComponent<AudioSource>();
                sfxSource.loop = false;
                sfxSource.playOnAwake = false;
                sfxSource.spatialBlend = 0f; // 2D звук
            }
            
            if (engineSource == null)
            {
                engineSource = gameObject.AddComponent<AudioSource>();
                engineSource.loop = true;
                engineSource.playOnAwake = false;
                engineSource.spatialBlend = 0f; // 2D звук
            }
        }
        
        #endregion
        
        #region Volume Control
        
        /// <summary>
        /// Обновление громкости всех каналов
        /// </summary>
        public void UpdateVolumes()
        {
            if (musicSource != null)
            {
                musicSource.volume = masterVolume * musicVolume;
            }
            
            if (sfxSource != null)
            {
                sfxSource.volume = masterVolume * sfxVolume;
            }
            
            if (engineSource != null)
            {
                engineSource.volume = masterVolume * engineVolume;
            }
            
            Debug.Log($"🔊 Громкость обновлена: Master={masterVolume:F2}, Music={musicVolume:F2}, SFX={sfxVolume:F2}, Engine={engineVolume:F2}");
            
            OnAudioChanged?.Invoke();
        }
        
        /// <summary>
        /// Установить общую громкость
        /// </summary>
        public void SetMasterVolume(float volume)
        {
            masterVolume = Mathf.Clamp01(volume);
            UpdateVolumes();
        }
        
        /// <summary>
        /// Установить громкость музыки
        /// </summary>
        public void SetMusicVolume(float volume)
        {
            musicVolume = Mathf.Clamp01(volume);
            UpdateVolumes();
        }
        
        /// <summary>
        /// Установить громкость эффектов
        /// </summary>
        public void SetSfxVolume(float volume)
        {
            sfxVolume = Mathf.Clamp01(volume);
            UpdateVolumes();
        }
        
        /// <summary>
        /// Установить громкость двигателя
        /// </summary>
        public void SetEngineVolume(float volume)
        {
            engineVolume = Mathf.Clamp01(volume);
            UpdateVolumes();
        }
        
        #endregion
        
        #region Music
        
        /// <summary>
        /// Воспроизвести музыку меню
        /// </summary>
        public void PlayMenuMusic()
        {
            if (musicSource == null) return;
            
            StopMusic();
            
            if (menuMusic != null)
            {
                musicSource.clip = menuMusic;
                musicSource.Play();
                Debug.Log("🎵 Музыка меню воспроизводится");
            }
        }
        
        /// <summary>
        /// Воспроизвести музыку гонки
        /// </summary>
        public void PlayRaceMusic()
        {
            if (musicSource == null) return;
            
            StopMusic();
            
            if (raceMusic != null)
            {
                musicSource.clip = raceMusic;
                musicSource.Play();
                Debug.Log("🎵 Музыка гонки воспроизводится");
            }
        }
        
        /// <summary>
        /// Остановить музыку
        /// </summary>
        public void StopMusic()
        {
            if (musicSource != null && musicSource.isPlaying)
            {
                musicSource.Stop();
            }
        }
        
        /// <summary>
        /// Поставвить музыку на паузу
        /// </summary>
        public void PauseMusic(bool pause)
        {
            if (musicSource != null)
            {
                musicSource.Pause();
            }
        }
        
        #endregion
        
        #region Engine Sound
        
        /// <summary>
        /// Запустить звук двигателя
        /// </summary>
        public void StartEngine()
        {
            if (engineSource == null) return;
            
            if (engineIdle != null)
            {
                engineSource.clip = engineIdle;
                engineSource.loop = true;
                engineSource.Play();
                isEngineRunning = true;
                currentEngineRpm = minRpm;
                Debug.Log("🚗 Двигатель запущен");
            }
        }
        
        /// <summary>
        /// Остановить звук двигателя
        /// </summary>
        public void StopEngine()
        {
            if (engineSource != null && isEngineRunning)
            {
                engineSource.Stop();
                isEngineRunning = false;
                Debug.Log("🔌 Двигатель остановлен");
            }
        }
        
        /// <summary>
        /// Обновить звук двигателя (вызывать каждый кадр)
        /// </summary>
        public void UpdateEngineSound()
        {
            if (!isEngineRunning || engineSource == null) return;
            
            // Расчёт высоты тона от оборотов
            float rpmRatio = (currentEngineRpm - minRpm) / (maxRpm - minRpm);
            rpmRatio = Mathf.Clamp01(rpmRatio);
            
            targetEnginePitch = Mathf.Lerp(minEnginePitch, maxEnginePitch, rpmRatio);
            
            // Плавное изменение высоты тона
            engineSource.pitch = Mathf.Lerp(engineSource.pitch, targetEnginePitch, Time.deltaTime * 5f);
        }
        
        /// <summary>
        /// Установить текущие обороты двигателя
        /// </summary>
        public void SetEngineRpm(float rpm)
        {
            currentEngineRpm = Mathf.Clamp(rpm, minRpm, maxRpm);
        }
        
        /// <summary>
        /// Воспроизвести звук ускорения
        /// </summary>
        public void PlayAccelerateSound()
        {
            if (engineAccelerate != null && sfxSource != null)
            {
                sfxSource.PlayOneShot(engineAccelerate, sfxVolume);
            }
        }
        
        #endregion
        
        #region Sound Effects
        
        /// <summary>
        /// Воспроизвести звук переключения передач
        /// </summary>
        public void PlayGearShiftSound()
        {
            if (gearShiftSound != null && sfxSource != null)
            {
                sfxSource.PlayOneShot(gearShiftSound, sfxVolume * 0.8f);
                Debug.Log("🔊 Переключение передач");
            }
        }
        
        /// <summary>
        /// Воспроизвести звук пробуксовки
        /// </summary>
        public void PlayTireSquealSound(float intensity = 1f)
        {
            if (tireSquealSound != null && sfxSource != null)
            {
                sfxSource.PlayOneShot(tireSquealSound, sfxVolume * intensity);
                Debug.Log($"🔊 Пробуксовка (интенсивность: {intensity:F2})");
            }
        }
        
        /// <summary>
        /// Воспроизвести звук нитро
        /// </summary>
        public void PlayNitroSound()
        {
            if (nitroSound != null && sfxSource != null)
            {
                sfxSource.PlayOneShot(nitroSound, sfxVolume);
                Debug.Log("🔊 Нитро активировано");
            }
        }
        
        /// <summary>
        /// Воспроизвести звук финиша
        /// </summary>
        public void PlayFinishSound()
        {
            if (finishSound != null && sfxSource != null)
            {
                sfxSource.PlayOneShot(finishSound, sfxVolume);
                Debug.Log("🔊 Финиш!");
            }
        }
        
        /// <summary>
        /// Воспроизвести любой звук
        /// </summary>
        public void PlaySound(AudioClip clip, float volumeScale = 1f)
        {
            if (clip != null && sfxSource != null)
            {
                sfxSource.PlayOneShot(clip, sfxVolume * volumeScale);
            }
        }
        
        #endregion
        
        #region Helper Methods
        
        /// <summary>
        /// Остановить все звуки
        /// </summary>
        public void StopAllSounds()
        {
            StopMusic();
            StopEngine();
            
            if (sfxSource != null)
            {
                sfxSource.Stop();
            }
            
            Debug.Log("🔇 Все звуки остановлены");
        }
        
        /// <summary>
        /// Поставвить все звуки на паузу
        /// </summary>
        public void PauseAll(bool pause)
        {
            if (musicSource != null)
            {
                if (pause) musicSource.Pause(); else musicSource.UnPause();
            }
            
            if (engineSource != null && isEngineRunning)
            {
                if (pause) engineSource.Pause(); else engineSource.UnPause();
            }
        }
        
        #endregion
        
        #region Debug
        
        /// <summary>
        /// Отладочная информация
        /// </summary>
        public string GetDebugInfo()
        {
            return $@"AudioManager:
Master: {masterVolume:F2}
Music: {musicVolume:F2}
SFX: {sfxVolume:F2}
Engine: {engineVolume:F2}
RPM: {currentEngineRpm:F0}
Pitch: {engineSource?.pitch:F2}";
        }
        
        #endregion
    }
}
