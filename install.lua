-- install.lua
-- Скрипт автоматической установки казино "Spartak"

local component = require("component")
local filesystem = require("filesystem")
local shell = require("shell")
local internet = require("internet")

-- Конфигурация
local REPO_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/spartak-casino/main/"
local INSTALL_PATH = "/home/casino/"

-- Цвета
local function setColor(color)
    if component.isAvailable("gpu") then
        component.gpu.setForeground(color)
    end
end

local COLORS = {
    WHITE = 0xFFFFFF,
    YELLOW = 0xFFFF00,
    GREEN = 0x00FF00,
    RED = 0xFF0000,
    GOLD = 0xFFD700
}

-- Вывод сообщений
local function log(message, color)
    setColor(color or COLORS.WHITE)
    print(message)
    setColor(COLORS.WHITE)
end

local function logSuccess(message)
    log("✓ " .. message, COLORS.GREEN)
end

local function logError(message)
    log("✗ " .. message, COLORS.RED)
end

local function logInfo(message)
    log("ℹ " .. message, COLORS.YELLOW)
end

-- Проверка интернет-карты
local function checkInternet()
    if not component.isAvailable("internet") then
        logError("Интернет-карта не найдена!")
        logInfo("Установите Internet Card для автоматической установки")
        logInfo("Или скопируйте файлы вручную")
        return false
    end
    return true
end

-- Загрузка файла
local function downloadFile(url, path)
    local success, response = pcall(internet.request, url)
    if not success then
        return false, "Ошибка подключения"
    end
    
    local data = ""
    for chunk in response do
        data = data .. chunk
    end
    
    -- Создаем директорию если не существует
    local dir = filesystem.path(path)
    if not filesystem.exists(dir) then
        filesystem.makeDirectory(dir)
    end
    
    -- Записываем файл
    local file = io.open(path, "w")
    if not file then
        return false, "Не удалось создать файл"
    end
    
    file:write(data)
    file:close()
    
    return true
end

-- Список файлов для загрузки
local FILES = {
    -- Серверные файлы
    {url = "server/main.lua", path = "server/main.lua"},
    
    -- Терминальные файлы
    {url = "terminal/main.lua", path = "terminal/main.lua"},
    {url = "terminal/ui.lua", path = "terminal/ui.lua"},
    
    -- Библиотеки
    {url = "lib/database.lua", path = "lib/database.lua"},
    {url = "lib/games.lua", path = "lib/games.lua"},
    {url = "lib/network.lua", path = "lib/network.lua"},
    
    -- Документация
    {url = "README.md", path = "README.md"},
    {url = "LICENSE", path = "LICENSE"}
}

-- Главная функция установки
local function install()
    log("═══════════════════════════════════════", COLORS.GOLD)
    log("  УСТАНОВКА КАЗИНО SPARTAK", COLORS.GOLD)
    log("═══════════════════════════════════════", COLORS.GOLD)
    print("")
    
    -- Проверка интернета
    if not checkInternet() then
        return false
    end
    
    -- Создание директорий
    logInfo("Создание структуры директорий...")
    local dirs = {
        INSTALL_PATH,
        INSTALL_PATH .. "server/",
        INSTALL_PATH .. "terminal/",
        INSTALL_PATH .. "lib/",
        INSTALL_PATH .. "data/",
        INSTALL_PATH .. "logs/",
        INSTALL_PATH .. "assets/graphics/"
    }
    
    for _, dir in ipairs(dirs) do
        if not filesystem.exists(dir) then
            filesystem.makeDirectory(dir)
        end
    end
    logSuccess("Директории созданы")
    
    -- Загрузка файлов
    logInfo("Загрузка файлов...")
    local downloaded = 0
    local failed = 0
    
    for i, file in ipairs(FILES) do
        local url = REPO_URL .. file.url
        local path = INSTALL_PATH .. file.path
        
        print(string.format("[%d/%d] %s", i, #FILES, file.url))
        
        local success, err = downloadFile(url, path)
        if success then
            downloaded = downloaded + 1
        else
            logError("Не удалось загрузить " .. file.url .. ": " .. (err or "неизвестная ошибка"))
            failed = failed + 1
        end
    end
    
    print("")
    if failed == 0 then
        logSuccess("Все файлы загружены успешно!")
    else
        logError(string.format("Загружено: %d, Ошибок: %d", downloaded, failed))
    end
    
    -- Создание пустых файлов БД и логов
    logInfo("Инициализация базы данных...")
    local dbFile = io.open(INSTALL_PATH .. "data/players.db", "w")
    if dbFile then
        dbFile:write("{}")
        dbFile:close()
        logSuccess("База данных инициализирована")
    end
    
    local logFile = io.open(INSTALL_PATH .. "logs/transactions.log", "w")
    if logFile then
        logFile:write("")
        logFile:close()
        logSuccess("Лог-файл создан")
    end
    
    -- Завершение
    print("")
    log("═══════════════════════════════════════", COLORS.GOLD)
    log("  УСТАНОВКА ЗАВЕРШЕНА!", COLORS.GREEN)
    log("═══════════════════════════════════════", COLORS.GOLD)
    print("")
    
    logInfo("Для запуска сервера:")
    print("  cd " .. INSTALL_PATH .. "server")
    print("  ./main.lua")
    print("")
    
    logInfo("Для запуска терминала:")
    print("  cd " .. INSTALL_PATH .. "terminal")
    print("  ./main.lua")
    print("")
    
    logInfo("Документация: " .. INSTALL_PATH .. "README.md")
    
    return true
end

-- Запуск установки
local success, err = pcall(install)
if not success then
    logError("Критическая ошибка установки:")
    print(err)
end

