using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using RacingGame.Managers;
using RacingGame.Utilities;
using System.Collections;

namespace RacingGame.Tests
{
    /// <summary>
    /// Тесты для AudioManager
    /// </summary>
    public class AudioManagerTests
    {
        private GameObject _gameObject;
        private AudioManager _audioManager;

        [SetUp]
        public void Setup()
        {
            _gameObject = new GameObject("AudioManagerTest");
            _audioManager = _gameObject.AddComponent<AudioManager>();
            
            GameLogger.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            if (_gameObject != null)
            {
                Object.DestroyImmediate(_gameObject);
            }
            AudioManager.Instance = null;
        }

        [Test]
        public void Instance_NotNull_AfterAwake()
        {
            Assert.IsNotNull(AudioManager.Instance);
        }

        [Test]
        public void MasterVolume_CanBeSet()
        {
            _audioManager.MasterVolume = 0.5f;
            Assert.AreEqual(0.5f, _audioManager.MasterVolume);
        }

        [Test]
        public void MusicVolume_CanBeSet()
        {
            _audioManager.MusicVolume = 0.3f;
            Assert.AreEqual(0.3f, _audioManager.MusicVolume);
        }

        [Test]
        public void SfxVolume_CanBeSet()
        {
            _audioManager.SfxVolume = 0.8f;
            Assert.AreEqual(0.8f, _audioManager.SfxVolume);
        }

        [Test]
        public void Volume_Clamped_ToZeroToOne()
        {
            _audioManager.MasterVolume = 1.5f;
            Assert.LessOrEqual(_audioManager.MasterVolume, 1f);

            _audioManager.MasterVolume = -0.5f;
            Assert.GreaterOrEqual(_audioManager.MasterVolume, 0f);
        }

        [Test]
        public void SetVolume_DoesNotThrow_WithValidChannel()
        {
            Assert.DoesNotThrow(() => 
                _audioManager.SetVolume(AudioManager.AudioChannel.Master, 0.5f));
            Assert.DoesNotThrow(() => 
                _audioManager.SetVolume(AudioManager.AudioChannel.Music, 0.5f));
            Assert.DoesNotThrow(() => 
                _audioManager.SetVolume(AudioManager.AudioChannel.SFX, 0.5f));
        }

        [Test]
        public void PlaySound_WithNullClip_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.PlaySound(null));
        }

        [Test]
        public void PlayMusic_WithNullClip_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.PlayMusic(null));
        }

        [Test]
        public void StopMusic_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.StopMusic());
        }

        [Test]
        public void StopAllSounds_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.StopAllSounds());
        }

        [Test]
        public void PauseAllSounds_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.PauseAllSounds(true));
            Assert.DoesNotThrow(() => _audioManager.PauseAllSounds(false));
        }

        [Test]
        public void MuteAll_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.MuteAll(true));
            Assert.DoesNotThrow(() => _audioManager.MuteAll(false));
        }

        [UnityTest]
        public IEnumerator SaveAudioSettings_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.SaveAudioSettings());
            yield return null;
        }

        [UnityTest]
        public IEnumerator LoadAudioSettings_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => _audioManager.LoadAudioSettings());
            yield return null;
        }

        [Test]
        public void AudioPool_IsInitialized()
        {
            // Проверяем что пул аудио источников создан
            // через проверку наличия дочерних объектов
            Assert.Greater(_gameObject.transform.childCount, 0);
        }
    }
}
