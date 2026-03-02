using UnityEngine;
using ProbMenu.Core;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Audio
{
    /// <summary>
    /// Менеджер звука игры
    /// Музыка, SFX, настройки громкости
    /// </summary>
    public class AudioManager : MonoBehaviour
    {
        [Header("Аудио источники")]
        [SerializeField] private AudioSource musicSource;
        [SerializeField] private AudioSource sfxSource;
        [SerializeField] private AudioSource ambientSource;

        [Header("Клипы")]
        [SerializeField] private AudioClip[] musicTracks;
        [SerializeField] private AudioClip[] sfxClips;

        [Header("Настройки громкости")]
        [Range(0, 1)]
        [SerializeField] private float musicVolume = 0.5f;
        [Range(0, 1)]
        [SerializeField] private float sfxVolume = 0.7f;
        [Range(0, 1)]
        [SerializeField] private float ambientVolume = 0.3f;

        [Header("Настройки")]
        [SerializeField] private bool muteAudio = false;

        public static AudioManager Instance { get; private set; }

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

            Logger.I("=== AUDIO MANAGER INITIALIZED ===");
            SetupAudioSources();
        }

        private void Start()
        {
            ApplyVolumeSettings();
            PlayMusic(0);
        }

        #region Setup

        private void SetupAudioSources()
        {
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

            if (ambientSource == null)
            {
                ambientSource = gameObject.AddComponent<AudioSource>();
                ambientSource.loop = true;
                ambientSource.playOnAwake = false;
            }
        }

        #endregion

        #region Music

        public void PlayMusic(int trackIndex = 0)
        {
            if (musicTracks == null || musicTracks.Length == 0)
            {
                Logger.W("No music tracks assigned!");
                return;
            }

            int index = Mathf.Clamp(trackIndex, 0, musicTracks.Length - 1);
            musicSource.clip = musicTracks[index];
            musicSource.Play();

            Logger.I($"Playing music track {index}: {musicTracks[index].name}");
        }

        public void StopMusic()
        {
            musicSource.Stop();
        }

        public void PauseMusic(bool pause)
        {
            if (pause)
                musicSource.Pause();
            else
                musicSource.UnPause();
        }

        #endregion

        #region SFX

        public void PlaySFX(string clipName)
        {
            if (sfxClips == null || sfxClips.Length == 0)
            {
                Logger.W("No SFX clips assigned!");
                return;
            }

            AudioClip clip = System.Array.Find(sfxClips, c => c.name == clipName);

            if (clip != null)
            {
                sfxSource.PlayOneShot(clip);
                Logger.D($"Playing SFX: {clipName}");
            }
            else
            {
                Logger.W($"SFX not found: {clipName}");
            }
        }

        public void PlaySFX(AudioClip clip, float volumeScale = 1f)
        {
            if (clip == null) return;

            sfxSource.PlayOneShot(clip, volumeScale);
        }

        #endregion

        #region Ambient

        public void PlayAmbient(AudioClip clip)
        {
            if (clip == null) return;

            ambientSource.clip = clip;
            ambientSource.Play();
        }

        public void StopAmbient()
        {
            ambientSource.Stop();
        }

        #endregion

        #region Volume Control

        public void SetMusicVolume(float volume)
        {
            musicVolume = Mathf.Clamp01(volume);
            ApplyVolumeSettings();
            Logger.I($"Music volume: {musicVolume * 100:F0}%");
        }

        public void SetSFXVolume(float volume)
        {
            sfxVolume = Mathf.Clamp01(volume);
            ApplyVolumeSettings();
            Logger.I($"SFX volume: {sfxVolume * 100:F0}%");
        }

        public void SetAmbientVolume(float volume)
        {
            ambientVolume = Mathf.Clamp01(volume);
            ApplyVolumeSettings();
            Logger.I($"Ambient volume: {ambientVolume * 100:F0}%");
        }

        public void SetMasterVolume(float volume)
        {
            float v = Mathf.Clamp01(volume);
            musicVolume = v;
            sfxVolume = v;
            ambientVolume = v;
            ApplyVolumeSettings();
            Logger.I($"Master volume: {v * 100:F0}%");
        }

        public void Mute(bool mute)
        {
            muteAudio = mute;
            AudioListener.volume = mute ? 0 : 1;
            Logger.I($"Audio {(mute ? "muted" : "unmuted")}");
        }

        private void ApplyVolumeSettings()
        {
            if (musicSource != null)
                musicSource.volume = muteAudio ? 0 : musicVolume;

            if (sfxSource != null)
                sfxSource.volume = muteAudio ? 0 : sfxVolume;

            if (ambientSource != null)
                ambientSource.volume = muteAudio ? 0 : ambientVolume;
        }

        #endregion

        #region Getters

        public float GetMusicVolume() => musicVolume;
        public float GetSFXVolume() => sfxVolume;
        public float GetAmbientVolume() => ambientVolume;
        public bool IsMuted() => muteAudio;

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(320, 640, 300, 150));
            GUILayout.Label("=== AUDIO MANAGER ===");
            GUILayout.Label($"Music: {musicVolume * 100:F0}%");
            GUILayout.Label($"SFX: {sfxVolume * 100:F0}%");
            GUILayout.Label($"Ambient: {ambientVolume * 100:F0}%");
            GUILayout.Label($"Muted: {muteAudio}");

            if (GUILayout.Button("Mute Toggle"))
            {
                Mute(!muteAudio);
            }

            GUILayout.EndArea();
        }

        #endregion
    }
}
