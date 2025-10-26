# 🎰 Казино "Spartak" для Minecraft 1.7.10

[![Minecraft](https://img.shields.io/badge/Minecraft-1.7.10-green)](https://minecraft.net)
[![OpenComputers](https://img.shields.io/badge/OpenComputers-1.7.5-blue)](https://oc.cil.li/)
[![License](https://img.shields.io/badge/license-MIT-gold)](LICENSE)

Полнофункциональное казино для сервера **McSkill** с интеграцией **OpenComputers**, **CustomNPCs** и **PIM (Personal Inventory Manager)**.

## 🎮 Особенности

- **3 азартные игры:** Слоты 🎰, Рулетка 🎡, Блэкджек 🃏
- **Автоматический депозит/вывод** через PIM (инвентарь игрока)
- **Клиент-серверная архитектура** с сетевым взаимодействием
- **Красочный интерфейс** с ASCII-арт и анимациями
- **Система управления балансами** с логированием
- **Защита от дюпов** и читерства

## 📦 Быстрый старт

### Требования
- OpenComputers 1.7.5+
- OpenPeripheralAddons (для PIM)
- CustomNPCs (для валюты)
- Tier 3 компьютеры

### Установка

```bash
# 1. Клонировать репозиторий
git clone https://github.com/DynyaCS/spartak-casino.git

# 2. Скопировать на сервер OpenComputers
cp -r spartak-casino /home/casino/

# 3. Запустить сервер
cd /home/casino/server
./main.lua

# 4. Запустить терминал депозита
cd /home/casino/terminal
./deposit.lua
```

## 📚 Документация

- [README.md](README.md) - Полная документация проекта
- [README_PIM.md](README_PIM.md) - Руководство по PIM интеграции
- [QUICKSTART.md](QUICKSTART.md) - Быстрый старт
- [docs/ARCHITECTURE_PIM.md](docs/ARCHITECTURE_PIM.md) - Архитектура системы

## 🎯 Структура проекта

```
spartak_casino/
├── server/          # Серверное приложение
├── terminal/        # Клиентские терминалы
├── lib/             # Библиотеки
├── assets/          # Графические ассеты
├── data/            # База данных
├── logs/            # Логи транзакций
└── docs/            # Документация
```

## 🔐 Безопасность

- Все расчеты на сервере
- Логирование всех транзакций
- Защита от дюпов
- Автоматическое резервное копирование

## 📝 Лицензия

MIT License - см. [LICENSE](LICENSE)

## 🙏 Благодарности

- OpenComputers
- OpenPeripheralAddons
- CustomNPCs
- McSkill Server

---

**Версия:** 1.1  
**Дата:** 26 октября 2025
