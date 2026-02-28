using UnityEngine;
using UnityEngine.Audio;
using RacingGame.Utilities;

namespace RacingGame.Managers
{
    /// <summary>
    /// Менеджер аудио. Управляет музыкой, звуковыми эффектами и настройками громкости.
    /// </summary>
    public class AudioManager : MonoBehaviour
    {
        public static AudioManager Instance { get; private set; }

        [Header("Audio Mixer")]
        [SerializeField] private AudioMixer _audioMixer;

        [Header("Audio Sources")]
        [SerializeField] private int _audioSourcePoolSize = 10;

        [Header("Громкость по умолчанию")]
        [Range(0, 1)]
        [SerializeField] private float _masterVolume = 0.8f;
        [Range(0, 1)]
        [SerializeField] private float _musicVolume = 0.6f;
        [Range(0, 1)]
        [SerializeField] private float _sfxVolume = 0.7f;

        public enum AudioChannel
        {
            Master,
            Music,
            SFX,
            Voice
        }

        private AudioSource[] _audioSourcePool;
        private int _currentAudioSourceIndex;

        public float MasterVolume
        {
            get => _masterVolume;
            set
            {
                _masterVolume = Mathf.Clamp01(value);
                SetVolume(AudioChannel.Master, _masterVolume);
            }
        }

        public float MusicVolume
        {
            get => _musicVolume;
            set
            {
                _musicVolume = Mathf.Clamp01(value);
                SetVolume(AudioChannel.Music, _musicVolume);
            }
        }

        public float SfxVolume
        {
            get => _sfxVolume;
            set
            {
                _sfxVolume = Mathf.Clamp01(value);
                SetVolume(AudioChannel.SFX, _sfxVolume);
            }
        }

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
                return;
            }

            InitializeAudioPool();
            LoadAudioSettings();
            GameLogger.LogInfo("AudioManager инициализирован");
        }

        private void InitializeAudioPool()
        {
            _audioSourcePool = new AudioSource[_audioSourcePoolSize];
            for (int i = 0; i < _audioSourcePoolSize; i++)
            {
                GameObject audioObject = new GameObject($"AudioSource_{i}");
                audioObject.transform.SetParent(transform);
                _audioSourcePool[i] = audioObject.AddComponent<AudioSource>();
                _audioSourcePool[i].playOnAwake = false;
            }
            _currentAudioSourceIndex = 0;
        }

        public void SetVolume(AudioChannel channel, float volume)
        {
            volume = Mathf.Clamp01(volume);

            switch (channel)
            {
                case AudioChannel.Master:
                    _masterVolume = volume;
                    _audioMixer?.SetFloat("MasterVolume", Mathf.Log10(Mathf.Max(0.0001f, volume)) * 20);
                    break;
                case AudioChannel.Music:
                    _musicVolume = volume;
                    _audioMixer?.SetFloat("MusicVolume", Mathf.Log10(Mathf.Max(0.0001f, volume)) * 20);
                    break;
                case AudioChannel.SFX:
                    _sfxVolume = volume;
                    _audioMixer?.SetFloat("SFXVolume", Mathf.Log10(Mathf.Max(0.0001f, volume)) * 20);
                    break;
            }

            GameLogger.LogDebug($"Громкость {channel}: {volume:F2}");
        }

        public void PlaySound(AudioClip clip, float volumeScale = 1f)
        {
            if (clip == null)
            {
                GameLogger.LogWarning("Попытка воспроизвести null AudioClip");
                return;
            }

            AudioSource source = GetAvailableAudioSource();
            if (source != null)
            {
                source.clip = clip;
                source.volume = _sfxVolume * volumeScale;
                source.pitch = 1f;
                source.Play();
                GameLogger.LogDebug($"Воспроизведение звука: {clip.name}");
            }
        }

        public void PlayMusic(AudioClip clip, bool loop = true)
        {
            if (clip == null)
            {
                GameLogger.LogWarning("Попытка воспроизвести null Music Clip");
                return;
            }

            // Находим специальный AudioSource для музыки (первый в пуле)
            AudioSource musicSource = _audioSourcePool[0];
            musicSource.Stop();
            musicSource.clip = clip;
            musicSource.volume = _musicVolume;
            musicSource.loop = loop;
            musicSource.Play();
            GameLogger.LogInfo($"Воспроизведение музыки: {clip.name}");
        }

        public void StopMusic()
        {
            _audioSourcePool[0]?.Stop();
        }

        public void StopAllSounds()
        {
            for (int i = 1; i < _audioSourcePool.Length; i++)
            {
                _audioSourcePool[i]?.Stop();
            }
        }

        public void PauseAllSounds(bool pause)
        {
            foreach (var source in _audioSourcePool)
            {
                if (source != null && source.isPlaying)
                {
                    source.Pause();
                }
            }
        }

        private AudioSource GetAvailableAudioSource()
        {
            // Ищем свободный AudioSource (начиная со второго, первый для музыки)
            for (int i = 0; i < _audioSourcePoolSize; i++)
            {
                int index = (_currentAudioSourceIndex + i + 1) % _audioSourcePoolSize;
                if (!_audioSourcePool[index].isPlaying)
                {
                    _currentAudioSourceIndex = index;
                    return _audioSourcePool[index];
                }
            }

            // Если все заняты, возвращаем следующий по кругу (прервет текущий)
            _currentAudioSourceIndex = (_currentAudioSourceIndex + 1) % _audioSourcePoolSize;
            return _audioSourcePool[_currentAudioSourceIndex];
        }

        public void LoadAudioSettings()
        {
            // Загружаем настройки из PlayerPrefs если есть
            _masterVolume = PlayerPrefs.GetFloat("MasterVolume", 0.8f);
            _musicVolume = PlayerPrefs.GetFloat("MusicVolume", 0.6f);
            _sfxVolume = PlayerPrefs.GetFloat("SFXVolume", 0.7f);

            SetVolume(AudioChannel.Master, _masterVolume);
            SetVolume(AudioChannel.Music, _musicVolume);
            SetVolume(AudioChannel.SFX, _sfxVolume);

            GameLogger.LogInfo("Настройки аудио загружены");
        }

        public void SaveAudioSettings()
        {
            PlayerPrefs.SetFloat("MasterVolume", _masterVolume);
            PlayerPrefs.SetFloat("MusicVolume", _musicVolume);
            PlayerPrefs.SetFloat("SFXVolume", _sfxVolume);
            PlayerPrefs.Save();

            GameLogger.LogInfo("Настройки аудио сохранены");
        }

        public void MuteAll(bool mute)
        {
            float volume = mute ? 0f : _masterVolume;
            SetVolume(AudioChannel.Master, volume);
            GameLogger.LogInfo(mute ? "Звук отключен" : "Звук включен");
        }
    }
}
