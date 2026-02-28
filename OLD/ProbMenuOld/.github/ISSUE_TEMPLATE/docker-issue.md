# =============================================================================
# Шаблон issue для сообщений об ошибках Docker
# =============================================================================

name: Docker Issue
description: Сообщить о проблеме с Docker-конфигурацией
title: "[Docker] "
labels: ["docker", "bug"]
body:
  - type: markdown
    attributes:
      value: |
        Спасибо за сообщение! Пожалуйста, заполните форму подробно.
  - type: textarea
    id: description
    attributes:
      label: Описание проблемы
      description: Что произошло? Что вы ожидали?
      placeholder: Подробное описание проблемы
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Шаги воспроизведения
      description: Как воспроизвести проблему?
      placeholder: |
        1. Запустить `docker compose --profile app up`
        2. ...
    validations:
      required: true
  - type: input
    id: docker-version
    attributes:
      label: Версия Docker
      description: Вывод команды `docker --version`
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Логи
      description: Вывод команды `docker compose logs`
      render: shell
    validations:
      required: true
  - type: dropdown
    id: os
    attributes:
      label: Операционная система
      options:
        - Windows 10/11
        - Linux (Ubuntu)
        - Linux (Other)
        - macOS
        - WSL2
    validations:
      required: true
