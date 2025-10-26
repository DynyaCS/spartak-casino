# 🚀 Установка казино "Spartak" ОДНОЙ КОМАНДОЙ

## ⚡ Самый быстрый способ

### На OpenComputers выполните:

```lua
wget -f https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua /tmp/install.lua && lua /tmp/install.lua
```

**Готово!** Установщик автоматически:
- ✅ Создаст все директории
- ✅ Скачает все файлы с GitHub
- ✅ Настроит конфигурацию
- ✅ Проверит установку

---

## 📋 Требования

- **Internet Card** (любого уровня)
- **Подключение к интернету**
- **OpenOS** установлена

---

## 🎮 После установки

### Запуск сервера:
```bash
cd /home/casino/server
lua main.lua
```

### Запуск терминала игр:
```bash
cd /home/casino/terminal
lua main.lua
```

### Запуск терминала депозита:
```bash
cd /home/casino/terminal
lua deposit.lua
```

---

## 🔧 Если что-то не работает

### Проблема: wget не найден

**Решение:**
```bash
# Установите wget
install wget
```

### Проблема: Репозиторий приватный

**Решение 1:** Сделайте репозиторий публичным временно

**Решение 2:** Используйте альтернативную команду:
```lua
wget -f https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/installer.lua /tmp/install.lua && lua /tmp/install.lua
```

### Проблема: GitHub недоступен

**Решение:** Используйте установку через Pastebin (см. PASTEBIN_INSTALLATION.md)

---

## 📊 Что устанавливается

| Компонент | Файлы | Размер |
|-----------|-------|--------|
| Сервер | server/main.lua | ~50KB |
| Терминалы | terminal/*.lua | ~80KB |
| Библиотеки | lib/*.lua | ~60KB |
| Документация | *.md | ~50KB |
| **Всего** | **12 файлов** | **~240KB** |

---

## 💡 Альтернативные команды

### Короткая версия (если wget настроен):
```bash
wget -qO- https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua | lua
```

### С сохранением установщика:
```bash
wget https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua
lua quick_install.lua
```

### Через curl (если доступен):
```bash
curl -fsSL https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua | lua
```

---

## 🎯 Полная команда (копируй-вставь)

```lua
wget -f https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua /tmp/install.lua && lua /tmp/install.lua
```

**Скопируйте эту команду и вставьте в OpenComputers!**

---

## ✅ Проверка установки

После установки проверьте:

```bash
# Проверить структуру
tree /home/casino

# Или вручную
ls -la /home/casino/server/
ls -la /home/casino/terminal/
ls -la /home/casino/lib/

# Проверить версию
cat /home/casino/.version
```

Должно быть:
```
/home/casino/
├── server/
│   └── main.lua
├── terminal/
│   ├── main.lua
│   ├── deposit.lua
│   └── ui.lua
├── lib/
│   ├── database.lua
│   ├── games.lua
│   ├── network.lua
│   └── pim.lua
├── data/
├── logs/
├── config.lua
└── .version
```

---

## 🎰 Готово!

Теперь запустите сервер и терминалы, и казино "Spartak" готово к работе!

**Удачи!** ✨

---

**Версия:** 1.1  
**GitHub:** https://github.com/DynyaCS/spartak-casino  
**Дата:** 26 октября 2025

