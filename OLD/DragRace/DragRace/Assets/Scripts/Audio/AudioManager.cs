using UnityEngine;
using DragRace.Core;

namespace DragRace.Audio
{
    /// <summary>
    /// Менеджер аудио
    /// </summary>
    public class AudioManager : MonoBehaviour
    {
        public static AudioManager Instance { get; private set; }
        
        [Header("Источники звука")]
        public AudioSource musicSource;
        public AudioSource sfxSource;
        
        [Header("Клипы")]
        public AudioClip[] musicTracks;
        public AudioClip[] engineSounds;
        public AudioClip[] shiftSounds;
        public AudioClip[] nitroSounds;
        public AudioClip[] uiSounds;
        
        [Header("Настройки")]
        [Range(0, 1)]
        public float musicVolume = 0.6f;
        [Range(0, 1)]
        public float sfxVolume = 0.7f;
        
        private int currentMusicIndex;
        
        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            
            Instance = this;
            DontDestroyOnLoad(gameObject);
            
            InitializeAudio();
        }
        
        private void Update()
        {
            UpdateVolumeFromSettings();
        }
        
        private void InitializeAudio()
        {
            // Создание источников звука если не назначены
            if (musicSource == null)
            {
                musicSource = gameObject.AddComponent<AudioSource>();
                musicSource.loop = true;
                musicSource.playOnAwake = false;
            }
            
            if (sfxSource == null)
            {
                sfxSource = gameObject.AddComponent<AudioSource>();
                sfxSource.loop = false;
                sfxSource.playOnAwake = false;
            }
        }
        
        private void UpdateVolumeFromSettings()
        {
            if (GameManager.Instance?.Settings != null)
            {
                var settings = GameManager.Instance.Settings;
                musicVolume = settings.musicVolume / 100f;
                sfxVolume = settings.sfxVolume / 100f;
                
                if (musicSource != null)
                    musicSource.volume = musicVolume;
                
                if (sfxSource != null)
                    sfxSource.volume = sfxVolume;
            }
        }
        
        #region Музыка
        
        public void PlayMusic(int trackIndex = 0)
        {
            if (musicTracks == null || musicTracks.Length == 0)
                return;
            
            currentMusicIndex = Mathf.Clamp(trackIndex, 0, musicTracks.Length - 1);
            
            if (musicSource != null)
            {
                musicSource.clip = musicTracks[currentMusicIndex];
                musicSource.Play();
            }
        }
        
        public void StopMusic()
        {
            if (musicSource != null)
                musicSource.Stop();
        }
        
        public void PauseMusic(bool pause)
        {
            if (musicSource != null)
                musicSource.Pause();
        }
        
        #endregion
        
        #region Звуковые эффекты
        
        public void PlayEngineSound(AudioClip clip, float pitch = 1f)
        {
            if (sfxSource != null && clip != null)
            {
                sfxSource.pitch = pitch;
                sfxSource.PlayOneShot(clip);
            }
        }
        
        public void PlayShiftSound()
        {
            if (shiftSounds == null || shiftSounds.Length == 0)
                return;
            
            int index = Random.Range(0, shiftSounds.Length);
            PlaySfx(shiftSounds[index]);
        }
        
        public void PlayNitroSound()
        {
            if (nitroSounds == null || nitroSounds.Length == 0)
                return;
            
            int index = Random.Range(0, nitroSounds.Length);
            PlaySfx(nitroSounds[index]);
        }
        
        public void PlayUISound()
        {
            if (uiSounds == null || uiSounds.Length == 0)
                return;
            
            int index = Random.Range(0, uiSounds.Length);
            PlaySfx(uiSounds[index]);
        }
        
        public void PlaySfx(AudioClip clip)
        {
            if (sfxSource != null && clip != null)
            {
                sfxSource.PlayOneShot(clip);
            }
        }
        
        #endregion
        
        #region Звук двигателя
        
        /// <summary>
        /// Обновление звука двигателя на основе оборотов
        /// </summary>
        public void UpdateEngineSound(float rpm, float maxRpm)
        {
            if (sfxSource == null || sfxSource.clip == null)
                return;
            
            // Изменение питча в зависимости от оборотов
            float normalizedRpm = rpm / maxRpm;
            sfxSource.pitch = 0.5f + normalizedRpm * 1.5f;
            
            // Громкость зависит от нагрузки
            sfxSource.volume = sfxVolume * (0.3f + normalizedRpm * 0.7f);
        }
        
        #endregion
    }
}
