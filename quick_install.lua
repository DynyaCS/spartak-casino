-- Быстрый установщик казино "Spartak"
-- Загружает все файлы одной командой с GitHub
-- Использование: wget -f https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua && lua quick_install.lua

local component = require("component")
local internet = require("internet")
local filesystem = require("filesystem")
local serialization = require("serialization")

-- Конфигурация
local GITHUB_USER = "DynyaCS"
local GITHUB_REPO = "spartak-casino"
local GITHUB_BRANCH = "master"
local BASE_URL = "https://raw.githubusercontent.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/" .. GITHUB_BRANCH .. "/"
local INSTALL_DIR = "/home/casino"

-- Проверка Internet Card
if not component.isAvailable("internet") then
    print("✗ Ошибка: Internet Card не найдена!")
    print("Установите Internet Card и попробуйте снова.")
    return false
end

-- Список файлов для загрузки
local FILES = {
    -- Серверные файлы
    {url = "server/main.lua", path = "server/main.lua", required = true},
    
    -- Терминальные файлы
    {url = "terminal/main.lua", path = "terminal/main.lua", required = true},
    {url = "terminal/deposit.lua", path = "terminal/deposit.lua", required = true},
    {url = "terminal/ui.lua", path = "terminal/ui.lua", required = true},
    
    -- Библиотеки
    {url = "lib/database.lua", path = "lib/database.lua", required = true},
    {url = "lib/games.lua", path = "lib/games.lua", required = true},
    {url = "lib/network.lua", path = "lib/network.lua", required = true},
    {url = "lib/pim.lua", path = "lib/pim.lua", required = true},
    
    -- Утилиты
    {url = "install.lua", path = "install.lua", required = false},
    
    -- Документация
    {url = "README.md", path = "README.md", required = false},
    {url = "README_PIM.md", path = "README_PIM.md", required = false},
    {url = "QUICKSTART.md", path = "QUICKSTART.md", required = false},
}

-- Функция загрузки файла
local function downloadFile(url, path)
    local fullPath = INSTALL_DIR .. "/" .. path
    
    -- Создаем директорию
    local dir = filesystem.path(fullPath)
    if not filesystem.exists(dir) then
        filesystem.makeDirectory(dir)
    end
    
    -- Загружаем файл
    local success, response = pcall(internet.request, url)
    if not success then
        return false, "Ошибка соединения: " .. tostring(response)
    end
    
    local data = ""
    local chunks = 0
    for chunk in response do
        data = data .. chunk
        chunks = chunks + 1
        if chunks % 5 == 0 then
            io.write(".")
            io.flush()
        end
    end
    
    if chunks > 0 then
        io.write(" ")
    end
    
    -- Проверка размера
    if #data == 0 then
        return false, "Файл пустой"
    end
    
    -- Сохраняем файл
    local file, err = io.open(fullPath, "w")
    if not file then
        return false, "Не удалось создать файл: " .. tostring(err)
    end
    
    file:write(data)
    file:close()
    
    return true, #data
end

-- Функция создания директорий
local function createDirectories()
    local dirs = {
        INSTALL_DIR,
        INSTALL_DIR .. "/server",
        INSTALL_DIR .. "/terminal",
        INSTALL_DIR .. "/lib",
        INSTALL_DIR .. "/data",
        INSTALL_DIR .. "/logs",
    }
    
    for _, dir in ipairs(dirs) do
        if not filesystem.exists(dir) then
            filesystem.makeDirectory(dir)
        end
    end
end

-- Функция создания конфига
local function createConfig()
    local configPath = INSTALL_DIR .. "/config.lua"
    local config = [[-- Конфигурация казино "Spartak"
return {
    -- Сетевые настройки
    network = {
        port = 5555,
        timeout = 5,
    },
    
    -- Настройки игр
    games = {
        minBet = 1,
        maxBet = 100,
    },
    
    -- Настройки депозита/вывода
    deposit = {
        minAmount = 1,
        maxAmount = 10000,
    },
    
    -- Настройки безопасности
    security = {
        logTransactions = true,
        backupInterval = 1800,
    },
}
]]
    
    local file = io.open(configPath, "w")
    if file then
        file:write(config)
        file:close()
        return true
    end
    return false
end

-- Главная функция
local function main()
    -- Заголовок
    print("╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    print("║    БЫСТРЫЙ УСТАНОВЩИК КАЗИНО \"SPARTAK\"           ║")
    print("║                                                   ║")
    print("║  Версия: 1.1                                      ║")
    print("║  GitHub: github.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "  ║")
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    
    -- Информация
    print("Директория установки: " .. INSTALL_DIR)
    print("Файлов для загрузки: " .. #FILES)
    print("")
    
    -- Проверка существующей установки
    if filesystem.exists(INSTALL_DIR .. "/.version") then
        print("⚠ Обнаружена существующая установка!")
        io.write("Продолжить? (y/n): ")
        local answer = io.read()
        if answer ~= "y" and answer ~= "Y" then
            print("Установка отменена.")
            return
        end
        print("")
    end
    
    print("Начинаем установку...")
    print("")
    
    -- [1/3] Создание директорий
    print("[1/3] Создание директорий...")
    createDirectories()
    print("  ✓ Директории созданы")
    print("")
    
    -- [2/3] Загрузка файлов
    print("[2/3] Загрузка файлов с GitHub...")
    print("")
    
    local success_count = 0
    local fail_count = 0
    local failed_files = {}
    
    for i, file in ipairs(FILES) do
        local url = BASE_URL .. file.url
        io.write("  [" .. i .. "/" .. #FILES .. "] " .. file.path .. " ")
        
        local success, result = downloadFile(url, file.path)
        
        if success then
            print("✓ (" .. result .. " байт)")
            success_count = success_count + 1
        else
            print("✗")
            print("      Ошибка: " .. result)
            fail_count = fail_count + 1
            table.insert(failed_files, {path = file.path, required = file.required})
        end
        
        -- Небольшая пауза
        os.sleep(0.3)
    end
    
    print("")
    print("  Загружено: " .. success_count .. "/" .. #FILES)
    if fail_count > 0 then
        print("  Ошибок: " .. fail_count)
    end
    print("")
    
    -- Проверка критических файлов
    local critical_failed = false
    for _, file in ipairs(failed_files) do
        if file.required then
            critical_failed = true
            break
        end
    end
    
    if critical_failed then
        print("✗ Не удалось загрузить критические файлы:")
        for _, file in ipairs(failed_files) do
            if file.required then
                print("  - " .. file.path)
            end
        end
        print("")
        print("Установка не может быть завершена.")
        print("Проверьте подключение к интернету и попробуйте снова.")
        return
    end
    
    -- [3/3] Финализация
    print("[3/3] Финализация...")
    
    -- Создаем конфиг
    if createConfig() then
        print("  ✓ Создан config.lua")
    end
    
    -- Создаем файл версии
    local versionFile = io.open(INSTALL_DIR .. "/.version", "w")
    if versionFile then
        versionFile:write("1.1\n")
        versionFile:close()
        print("  ✓ Версия: 1.1")
    end
    
    print("")
    
    -- Итоговое сообщение
    print("╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    print("║         ✓ УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!           ║")
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    
    -- Инструкции
    print("📚 Документация:")
    print("  edit " .. INSTALL_DIR .. "/README.md")
    print("")
    print("🚀 Запуск сервера:")
    print("  cd " .. INSTALL_DIR .. "/server")
    print("  lua main.lua")
    print("")
    print("🎮 Запуск терминала игр:")
    print("  cd " .. INSTALL_DIR .. "/terminal")
    print("  lua main.lua")
    print("")
    print("💰 Запуск терминала депозита:")
    print("  cd " .. INSTALL_DIR .. "/terminal")
    print("  lua deposit.lua")
    print("")
    print("🎰 Удачи в казино \"Spartak\"! ✨")
    print("")
end

-- Запуск
local status, err = pcall(main)
if not status then
    print("")
    print("✗ Критическая ошибка:")
    print(tostring(err))
    print("")
    print("Попробуйте:")
    print("1. Проверить подключение к интернету")
    print("2. Убедиться, что Internet Card установлена")
    print("3. Использовать ручную установку")
end

