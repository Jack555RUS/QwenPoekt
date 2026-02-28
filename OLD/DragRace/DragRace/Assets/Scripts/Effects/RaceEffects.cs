using UnityEngine;

namespace DragRace.Effects
{
    /// <summary>
    /// Система частиц для дыма от шин
    /// </summary>
    public class TireSmokeEffect : MonoBehaviour
    {
        [Header("Настройки частиц")]
        public ParticleSystem smokeParticles;
        public float minEmissionRate = 10f;
        public float maxEmissionRate = 100f;
        
        [Header("Условия")]
        public float slipThreshold = 0.5f;
        public float speedThreshold = 5f;
        
        private ParticleSystem.EmissionModule emissionModule;
        private bool isEmitting;
        
        private void Start()
        {
            if (smokeParticles != null)
            {
                emissionModule = smokeParticles.emission;
                emissionModule.enabled = false;
            }
        }
        
        public void UpdateSmoke(float slipRatio, float speed)
        {
            if (smokeParticles == null) return;
            
            bool shouldEmit = slipRatio > slipThreshold && speed < speedThreshold;
            
            if (shouldEmit && !isEmitting)
            {
                StartEmitting();
            }
            else if (!shouldEmit && isEmitting)
            {
                StopEmitting();
            }
            
            if (isEmitting)
            {
                // Интенсивность зависит от пробуксовки
                float intensity = Mathf.InverseLerp(slipThreshold, 1f, slipRatio);
                emissionModule.rateOverTime = Mathf.Lerp(minEmissionRate, maxEmissionRate, intensity);
            }
        }
        
        private void StartEmitting()
        {
            isEmitting = true;
            emissionModule.enabled = true;
            smokeParticles.Play();
        }
        
        private void StopEmitting()
        {
            isEmitting = false;
            emissionModule.enabled = false;
            smokeParticles.Stop();
        }
    }
    
    /// <summary>
    /// Эффект нитро
    /// </summary>
    public class NitroEffect : MonoBehaviour
    {
        [Header("Настройки")]
        public ParticleSystem nitroFlames;
        public Light nitroLight;
        public float lightIntensity = 2f;
        
        [Header("Аудио")]
        public AudioSource nitroAudioSource;
        
        private bool isActive;
        
        private void Start()
        {
            if (nitroFlames != null)
            {
                var emissionModule = nitroFlames.emission;
                emissionModule.enabled = false;
            }
            
            if (nitroLight != null)
                nitroLight.enabled = false;
        }
        
        public void ActivateNitro()
        {
            isActive = true;
            
            if (nitroFlames != null)
            {
                var emissionModule = nitroFlames.emission;
                emissionModule.enabled = true;
                nitroFlames.Play();
            }
            
            if (nitroLight != null)
            {
                nitroLight.enabled = true;
                nitroLight.intensity = lightIntensity;
            }
            
            if (nitroAudioSource != null)
                nitroAudioSource.Play();
        }
        
        public void DeactivateNitro()
        {
            isActive = false;
            
            if (nitroFlames != null)
            {
                var emissionModule = nitroFlames.emission;
                emissionModule.enabled = false;
                nitroFlames.Stop();
            }
            
            if (nitroLight != null)
                nitroLight.enabled = false;
            
            if (nitroAudioSource != null)
                nitroAudioSource.Stop();
        }
        
        private void Update()
        {
            if (isActive && nitroLight != null)
            {
                // Мерцание света
                nitroLight.intensity = lightIntensity + Random.Range(-0.2f, 0.2f);
            }
        }
    }
    
    /// <summary>
    /// Камера для заезда
    /// </summary>
    public class RaceCamera : MonoBehaviour
    {
        [Header("Цель")]
        public Transform target;
        
        [Header("Позиция")]
        public Vector3 offset = new Vector3(0, 2, -5);
        public float smoothSpeed = 10f;
        
        [Header("Зум")]
        public float minZoom = 5f;
        public float maxZoom = 20f;
        public float currentZoom = 10f;
        
        [Header("Режимы камеры")]
        public CameraMode cameraMode = CameraMode.Follow;
        
        private Camera cam;
        private float startDistance;
        
        private void Start()
        {
            cam = GetComponent<Camera>();
            startDistance = currentZoom;
        }
        
        private void LateUpdate()
        {
            if (target == null) return;
            
            switch (cameraMode)
            {
                case CameraMode.Follow:
                    FollowCamera();
                    break;
                case CameraMode.SideScrolling:
                    SideScrollingCamera();
                    break;
                case CameraMode.Fixed:
                    // Камера не двигается
                    break;
            }
        }
        
        private void FollowCamera()
        {
            Vector3 targetPosition = target.position + offset;
            transform.position = Vector3.Lerp(transform.position, targetPosition, smoothSpeed * Time.deltaTime);
            transform.LookAt(target);
        }
        
        private void SideScrollingCamera()
        {
            // Камера двигается только по X
            Vector3 targetPosition = transform.position;
            targetPosition.x = target.position.x + offset.x;
            transform.position = Vector3.Lerp(transform.position, targetPosition, smoothSpeed * Time.deltaTime);
        }
        
        public void SetZoom(float zoom)
        {
            currentZoom = Mathf.Clamp(zoom, minZoom, maxZoom);
            
            if (cam != null)
            {
                cam.orthographicSize = currentZoom;
            }
        }
        
        public void ZoomIn()
        {
            SetZoom(currentZoom - 1f);
        }
        
        public void ZoomOut()
        {
            SetZoom(currentZoom + 1f);
        }
        
        public enum CameraMode
        {
            Follow,
            SideScrolling,
            Fixed
        }
    }
}
