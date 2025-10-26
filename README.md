# 🎰 Казино "Spartak" для OpenComputers

Полнофункциональное казино для Minecraft 1.7.10 с интеграцией валюты CustomNPCs (Npcmoney) на сервере McSkill.

![Версия](https://img.shields.io/badge/версия-1.0-gold)
![Minecraft](https://img.shields.io/badge/Minecraft-1.7.10-green)
![OpenComputers](https://img.shields.io/badge/OpenComputers-1.7.5-blue)

## 📋 Содержание

- [Особенности](#особенности)
- [Требования](#требования)
- [Установка](#установка)
- [Интеграция с CustomNPCs](#интеграция-с-customnpcs)
- [Игры](#игры)
- [Структура проекта](#структура-проекта)
- [Использование](#использование)
- [Конфигурация](#конфигурация)
- [Устранение неполадок](#устранение-неполадок)
- [Лицензия](#лицензия)

## ✨ Особенности

- **Три азартные игры:**
  - 🎰 **Слоты** - классический игровой автомат с 7 символами
  - 🎡 **Рулетка** - европейская рулетка с числами 0-36
  - 🃏 **Блэкджек** - карточная игра против дилера

- **Интеграция с CustomNPCs:**
  - Депозит/вывод валюты Npcmoney через NPC-банкира
  - Синхронизация баланса между игрой и казино
  - Безопасное хранение средств

- **Красочный интерфейс:**
  - ASCII-арт логотип
  - Цветные элементы UI
  - Анимации игровых процессов
  - Адаптивный дизайн для разных разрешений

- **Клиент-серверная архитектура:**
  - Центральный сервер для обработки игр
  - Множество терминалов для игроков
  - Сетевое взаимодействие через Wireless Network Card

- **Система управления:**
  - База данных игроков
  - Статистика казино
  - Таблица лидеров
  - Логирование транзакций

## 📦 Требования

### Моды
- **OpenComputers** 1.7.5+ ([скачать](https://www.curseforge.com/minecraft/mc-mods/opencomputers))
- **CustomNPCs** 1.7.10 ([скачать](https://www.curseforge.com/minecraft/mc-mods/custom-npcs))

### Компоненты OpenComputers

#### Для сервера (1 компьютер):
- **Case:** Tier 3
- **CPU:** Tier 3
- **RAM:** 2x Tier 3.5 (2MB каждая)
- **HDD:** Tier 3 (4MB)
- **GPU:** Tier 3
- **Screen:** Tier 3 (160x50)
- **Keyboard:** 1x
- **Wireless Network Card:** Tier 2
- **Power Supply:** Достаточная мощность (рекомендуется генератор)

#### Для терминала (на каждого игрока):
- **Case:** Tier 2 или 3
- **CPU:** Tier 2
- **RAM:** 2x Tier 2 (1MB каждая)
- **HDD:** Tier 2 (2MB)
- **GPU:** Tier 3
- **Screen:** Tier 3 (160x50) - для лучшего отображения
- **Keyboard:** 1x
- **Wireless Network Card:** Tier 2

#### Для NPC-банкира:
- **Adapter:** 1x (для связи с CustomNPCs)
- Расположить рядом с NPC

## 🔧 Установка

### Шаг 1: Загрузка проекта

```bash
# В OpenComputers выполните:
cd /home
wget https://raw.githubusercontent.com/YOUR_USERNAME/spartak-casino/main/install.lua
install.lua
```

Или вручную скопируйте файлы в следующую структуру:

```
/home/casino/
├── server/
│   └── main.lua
├── terminal/
│   ├── main.lua
│   └── ui.lua
├── lib/
│   ├── database.lua
│   ├── games.lua
│   └── network.lua
├── data/
│   └── (создается автоматически)
├── logs/
│   └── (создается автоматически)
└── assets/
    └── graphics/
        └── (графические ассеты)
```

### Шаг 2: Настройка сервера

1. Соберите серверный компьютер согласно требованиям
2. Установите OpenOS (вставьте диск OpenOS и выполните `install`)
3. Скопируйте файлы проекта
4. Запустите сервер:

```bash
cd /home/casino/server
./main.lua
```

Сервер должен отобразить интерфейс с надписью "РАБОТАЕТ".

### Шаг 3: Настройка терминалов

1. Соберите терминальные компьютеры
2. Установите OpenOS
3. Скопируйте файлы проекта
4. Запустите терминал:

```bash
cd /home/casino/terminal
./main.lua
```

Терминал автоматически найдет сервер в сети.

### Шаг 4: Настройка NPC-банкира

1. Создайте NPC с помощью CustomNPCs
2. Установите Adapter рядом с NPC
3. Создайте скрипт для NPC (см. раздел [Интеграция с CustomNPCs](#интеграция-с-customnpcs))

## 🔗 Интеграция с CustomNPCs

### Скрипт для NPC-банкира

Откройте GUI NPC → Advanced → Scripts → Add Script

```javascript
// Скрипт депозита (при клике правой кнопкой)
function interact(event) {
    var player = event.player;
    var playerName = player.getName();
    var money = player.getMoney();
    
    // Показываем диалог
    var dialog = API.createDialog();
    dialog.setTitle("Банкир казино Spartak");
    dialog.setText("У вас: " + money + " денег\\n\\nВыберите действие:");
    
    // Кнопка депозита
    dialog.addButton(1, "Пополнить баланс");
    // Кнопка вывода
    dialog.addButton(2, "Вывести средства");
    // Кнопка отмены
    dialog.addButton(3, "Отмена");
    
    player.showDialog(dialog);
}

// Обработка выбора в диалоге
function dialogClosed(event) {
    var player = event.player;
    var playerName = player.getName();
    var buttonId = event.buttonId;
    
    if (buttonId == 1) {
        // Депозит
        showDepositDialog(player);
    } else if (buttonId == 2) {
        // Вывод
        showWithdrawDialog(player);
    }
}

function showDepositDialog(player) {
    var money = player.getMoney();
    var dialog = API.createDialog();
    dialog.setTitle("Пополнение баланса");
    dialog.setText("Введите сумму для пополнения (1-100):");
    dialog.setTextField(1, "");
    dialog.addButton(1, "Подтвердить");
    dialog.addButton(2, "Отмена");
    player.showDialog(dialog);
}

function showWithdrawDialog(player) {
    var dialog = API.createDialog();
    dialog.setTitle("Вывод средств");
    dialog.setText("Введите сумму для вывода:");
    dialog.setTextField(1, "");
    dialog.addButton(1, "Подтвердить");
    dialog.addButton(2, "Отмена");
    player.showDialog(dialog);
}

// Обработка ввода суммы
function dialogTextInput(event) {
    var player = event.player;
    var playerName = player.getName();
    var buttonId = event.buttonId;
    var amount = parseInt(event.getText(1));
    
    if (buttonId == 2) {
        return; // Отмена
    }
    
    if (isNaN(amount) || amount <= 0) {
        player.message("§cОшибка: Неверная сумма!");
        return;
    }
    
    // Определяем тип операции по заголовку
    var title = event.getTitle();
    
    if (title.indexOf("Пополнение") != -1) {
        // Депозит
        var money = player.getMoney();
        if (money < amount) {
            player.message("§cУ вас недостаточно денег!");
            return;
        }
        
        // Снимаем деньги
        player.setMoney(money - amount);
        
        // Отправляем запрос на сервер казино через Adapter
        // ВАЖНО: Этот код должен быть адаптирован под вашу конфигурацию
        sendToServer("deposit", playerName, amount);
        
        player.message("§aВы пополнили баланс на " + amount + " денег!");
        
    } else if (title.indexOf("Вывод") != -1) {
        // Вывод
        // Проверяем баланс в казино через Adapter
        var casinoBalance = getBalanceFromServer(playerName);
        
        if (casinoBalance < amount) {
            player.message("§cНедостаточно средств в казино!");
            return;
        }
        
        // Отправляем запрос на вывод
        sendToServer("withdraw", playerName, amount);
        
        // Выдаем деньги
        var money = player.getMoney();
        player.setMoney(money + amount);
        
        player.message("§aВы вывели " + amount + " денег!");
    }
}

// Функции для связи с сервером казино
function sendToServer(action, playerName, amount) {
    // Эта функция должна отправлять данные на сервер OpenComputers
    // через Adapter, расположенный рядом с NPC
    
    // Пример (требует настройки):
    // var adapter = world.getBlock(x, y, z); // Координаты адаптера
    // adapter.callMethod("send", action, playerName, amount);
}

function getBalanceFromServer(playerName) {
    // Эта функция должна запрашивать баланс с сервера
    // Пример:
    // var adapter = world.getBlock(x, y, z);
    // return adapter.callMethod("getBalance", playerName);
    
    return 0; // Заглушка
}
```

### Альтернативный метод: Прямая интеграция через Adapter

Если скриптинг CustomNPCs недоступен, используйте Adapter:

1. Разместите Adapter рядом с NPC
2. Создайте скрипт на Lua для обработки взаимодействия:

```lua
-- npc_banker.lua
local component = require("component")
local event = require("event")

local adapter = component.adapter

-- Обработчик взаимодействия с NPC
function handleNPCInteraction(playerName, action, amount)
    if action == "deposit" then
        -- Логика депозита
        -- Отправить запрос на сервер казино
    elseif action == "withdraw" then
        -- Логика вывода
    end
end

-- Основной цикл
while true do
    local e = {event.pull("npc_interact")}
    handleNPCInteraction(e[2], e[3], e[4])
end
```

## 🎮 Игры

### 🎰 Слоты

**Правила:**
- Ставка: 1-100 денег
- Три барабана с символами
- Выигрыш при совпадении символов

**Таблица выплат:**
| Комбинация | Множитель |
|-----------|-----------|
| ⭐⭐⭐ | x100 |
| 7️⃣7️⃣7️⃣ | x50 |
| 💎💎💎 | x25 |
| 🍇🍇🍇 | x10 |
| 🍊🍊🍊 | x5 |
| 🍋🍋🍋 | x3 |
| 🍒🍒🍒 | x2 |
| Любые 2 одинаковых | x1 |

### 🎡 Рулетка

**Правила:**
- Ставка: 1-100 денег
- Числа от 0 до 36
- Различные типы ставок

**Типы ставок:**
| Тип | Множитель |
|-----|-----------|
| Конкретное число | x35 |
| Красное/Черное | x2 |
| Четное/Нечетное | x2 |
| 1-18 / 19-36 | x2 |
| Дюжина (1-12, 13-24, 25-36) | x3 |

### 🃏 Блэкджек

**Правила:**
- Ставка: 1-100 денег
- Цель: набрать 21 или ближе к 21, чем у дилера
- Дилер останавливается на 17
- Блэкджек платит 3:2

**Действия:**
- **Hit** - взять карту
- **Stand** - остановиться
- **Double** - удвоить ставку (только с 2 картами)

## 📁 Структура проекта

```
spartak_casino/
├── README.md                 # Этот файл
├── LICENSE                   # Лицензия MIT
├── install.lua               # Скрипт автоустановки
├── server/
│   └── main.lua             # Главный серверный скрипт
├── terminal/
│   ├── main.lua             # Главный терминальный скрипт
│   └── ui.lua               # Библиотека UI
├── lib/
│   ├── database.lua         # Управление БД
│   ├── games.lua            # Игровая логика
│   └── network.lua          # Сетевое взаимодействие
├── data/
│   ├── players.db           # База данных игроков
│   └── players.db.backup    # Резервная копия
├── logs/
│   └── transactions.log     # Лог транзакций
├── assets/
│   └── graphics/            # Графические ассеты
│       ├── logo_spartak.png
│       ├── icon_slots.png
│       ├── icon_roulette.png
│       ├── icon_blackjack.png
│       ├── slot_symbols.png
│       ├── background_main.png
│       ├── button_gold.png
│       ├── chip_stack.png
│       ├── frame_terminal.png
│       └── icon_money.png
└── docs/
    ├── UI_DESIGN.md         # Документация дизайна
    ├── ARCHITECTURE.md      # Архитектура системы
    └── API.md               # API документация
```

## 💻 Использование

### Запуск сервера

```bash
cd /home/casino/server
./main.lua
```

**Управление сервером:**
- `Q` - остановить сервер
- Автосохранение каждые 30 минут

### Запуск терминала

```bash
cd /home/casino/terminal
./main.lua
```

**Управление терминалом:**
- `←/→` - навигация по меню
- `Enter` - подтвердить выбор
- `Backspace` - вернуться назад
- `Q` - выход

### Для игроков

1. Подойдите к терминалу казино
2. Введите свой ник
3. Пополните баланс у NPC-банкира
4. Выберите игру
5. Сделайте ставку
6. Играйте и выигрывайте!
7. Выведите средства у NPC-банкира

## ⚙️ Конфигурация

### Настройки сервера

Откройте `server/main.lua` и измените:

```lua
local CONFIG = {
    MIN_BET = 1,              -- Минимальная ставка
    MAX_BET = 100,            -- Максимальная ставка
    BACKUP_INTERVAL = 1800,   -- Интервал автосохранения (сек)
    LOG_FILE = "/home/casino/logs/transactions.log"
}
```

### Настройки игр

Откройте `lib/games.lua` для изменения:

**Слоты:**
```lua
-- Веса символов (вероятность выпадения)
Games.Slots.WEIGHTS = {
    ["🍒"] = 30,  -- 30%
    ["🍋"] = 25,  -- 25%
    -- ...
}

-- Таблица выплат
Games.Slots.PAYOUTS = {
    ["⭐⭐⭐"] = 100,
    -- ...
}
```

**Рулетка:**
```lua
-- Красные и черные числа
Games.Roulette.RED_NUMBERS = {1, 3, 5, ...}
Games.Roulette.BLACK_NUMBERS = {2, 4, 6, ...}
```

**Блэкджек:**
```lua
-- Правила дилера, выплаты и т.д.
```

### Настройки сети

Откройте `lib/network.lua`:

```lua
Network.PORT = 5555  -- Порт для связи
```

## 🔍 Устранение неполадок

### Сервер не запускается

**Проблема:** Ошибка "Сетевая карта не найдена"
**Решение:** Установите Wireless Network Card Tier 2 в сервер

**Проблема:** Недостаточно памяти
**Решение:** Установите 2x RAM Tier 3.5

### Терминал не находит сервер

**Проблема:** "Сервер не найден"
**Решение:** 
1. Проверьте, что сервер запущен
2. Убедитесь, что Wireless Network Card установлены в обоих компьютерах
3. Проверьте дальность связи (макс. 400 блоков для Tier 2)

### Ошибки интеграции с CustomNPCs

**Проблема:** NPC не взаимодействует с казино
**Решение:**
1. Проверьте, что Adapter установлен рядом с NPC
2. Убедитесь, что скрипт NPC настроен правильно
3. Проверьте логи сервера

### Проблемы с отображением

**Проблема:** Интерфейс отображается неправильно
**Решение:**
1. Используйте экран Tier 3 (160x50)
2. Установите GPU Tier 3
3. Проверьте разрешение: `gpu.getResolution()`

### База данных повреждена

**Проблема:** Ошибка загрузки БД
**Решение:**
1. Остановите сервер
2. Восстановите из резервной копии:
```bash
cd /home/casino/data
cp players.db.backup players.db
```
3. Перезапустите сервер

## 📊 Мониторинг и статистика

### Просмотр логов

```bash
cd /home/casino/logs
edit transactions.log
```

### Резервное копирование

Автоматическое резервное копирование выполняется каждые 30 минут.

Ручное резервное копирование:
```bash
cd /home/casino/data
cp players.db players.db.manual_backup_$(date +%Y%m%d_%H%M%S)
```

### Статистика казино

Статистика отображается на экране сервера:
- Всего игроков
- Общий баланс
- Прибыль казино
- Количество игр
- Топ-5 игроков

## 🛡️ Безопасность

### Рекомендации

1. **Регулярное резервное копирование** - настройте автоматическое копирование БД
2. **Ограничение доступа** - защитите серверный компьютер от посторонних
3. **Мониторинг логов** - регулярно проверяйте логи на подозрительную активность
4. **Обновления** - следите за обновлениями проекта

### Защита от читерства

- Все расчеты выполняются на сервере
- Терминалы не имеют прямого доступа к БД
- Валидация всех входных данных
- Логирование всех транзакций

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие проекта!

1. Fork репозитория
2. Создайте ветку для новой функции (`git checkout -b feature/AmazingFeature`)
3. Commit изменений (`git commit -m 'Add some AmazingFeature'`)
4. Push в ветку (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📝 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

## 📧 Контакты

**Автор:** Manus AI Agent
**Проект:** Казино "Spartak" для OpenComputers
**Сервер:** McSkill (Minecraft 1.7.10)

## 🙏 Благодарности

- **OpenComputers** - за отличный мод программирования
- **CustomNPCs** - за возможность создания интерактивных NPC
- **McSkill** - за отличный сервер

## 📚 Дополнительные ресурсы

- [Документация OpenComputers](https://ocdoc.cil.li/)
- [Wiki CustomNPCs](https://www.curseforge.com/minecraft/mc-mods/custom-npcs/wiki)
- [Форум McSkill](https://mcskill.net/)

---

**Удачи в казино! 🎰✨**

