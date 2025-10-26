#!/usr/bin/env lua
-- Установщик казино "Spartak" для OpenComputers
-- Версия: 1.1
-- Автор: DynyaCS
-- GitHub: https://github.com/DynyaCS/spartak-casino

local component = require("component")
local filesystem = require("filesystem")
local internet = require("internet")

-- Проверка наличия Internet Card
if not component.isAvailable("internet") then
    print("✗ Ошибка: Internet Card не найдена!")
    print("Установите Internet Card в компьютер и попробуйте снова.")
    os.exit(1)
end

-- Конфигурация
local BASE_URL = "https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/"
local INSTALL_DIR = "/home/casino"

-- Список файлов для загрузки
local FILES = {
    -- Серверные файлы
    {url = "server/main.lua", path = "server/main.lua"},
    
    -- Терминальные файлы
    {url = "terminal/main.lua", path = "terminal/main.lua"},
    {url = "terminal/deposit.lua", path = "terminal/deposit.lua"},
    {url = "terminal/ui.lua", path = "terminal/ui.lua"},
    
    -- Библиотеки
    {url = "lib/database.lua", path = "lib/database.lua"},
    {url = "lib/games.lua", path = "lib/games.lua"},
    {url = "lib/network.lua", path = "lib/network.lua"},
    {url = "lib/pim.lua", path = "lib/pim.lua"},
    
    -- Утилиты
    {url = "install.lua", path = "install.lua"},
    
    -- Документация
    {url = "README.md", path = "README.md"},
    {url = "README_PIM.md", path = "README_PIM.md"},
    {url = "QUICKSTART.md", path = "QUICKSTART.md"},
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
    print("  Загрузка: " .. path)
    
    local success, response = pcall(internet.request, url)
    if not success then
        print("    ✗ Ошибка соединения: " .. tostring(response))
        return false
    end
    
    local data = ""
    local chunks = 0
    for chunk in response do
        data = data .. chunk
        chunks = chunks + 1
        if chunks % 10 == 0 then
            io.write(".")
            io.flush()
        end
    end
    
    if chunks > 0 then
        print("")
    end
    
    -- Проверка размера
    if #data == 0 then
        print("    ✗ Файл пустой")
        return false
    end
    
    -- Сохраняем файл
    local file, err = io.open(fullPath, "w")
    if not file then
        print("    ✗ Не удалось создать файл: " .. tostring(err))
        return false
    end
    
    file:write(data)
    file:close()
    
    -- Делаем исполняемым, если это .lua файл в server/ или terminal/
    if path:match("^server/") or path:match("^terminal/") then
        if path:match("%.lua$") then
            filesystem.setPermissions(fullPath, "rwxr-xr-x")
        end
    end
    
    print("    ✓ Загружено (" .. #data .. " байт)")
    return true
end

-- Функция создания директорий
local function createDirectories()
    print("\n[1/3] Создание директорий...")
    
    local dirs = {
        INSTALL_DIR,
        INSTALL_DIR .. "/server",
        INSTALL_DIR .. "/terminal",
        INSTALL_DIR .. "/lib",
        INSTALL_DIR .. "/data",
        INSTALL_DIR .. "/logs",
        INSTALL_DIR .. "/assets",
        INSTALL_DIR .. "/docs",
    }
    
    for _, dir in ipairs(dirs) do
        if not filesystem.exists(dir) then
            filesystem.makeDirectory(dir)
            print("  ✓ Создано: " .. dir)
        else
            print("  • Существует: " .. dir)
        end
    end
end

-- Функция загрузки файлов
local function downloadFiles()
    print("\n[2/3] Загрузка файлов...")
    
    local success_count = 0
    local fail_count = 0
    local failed_files = {}
    
    for i, file in ipairs(FILES) do
        local url = BASE_URL .. file.url
        print("\n  [" .. i .. "/" .. #FILES .. "]")
        
        if downloadFile(url, file.path) then
            success_count = success_count + 1
        else
            fail_count = fail_count + 1
            table.insert(failed_files, file.path)
        end
        
        -- Небольшая пауза между запросами
        os.sleep(0.5)
    end
    
    print("\n  Результат:")
    print("    ✓ Загружено: " .. success_count)
    print("    ✗ Ошибок: " .. fail_count)
    
    if fail_count > 0 then
        print("\n  Не удалось загрузить:")
        for _, path in ipairs(failed_files) do
            print("    - " .. path)
        end
    end
    
    return fail_count == 0
end

-- Функция финализации
local function finalize()
    print("\n[3/3] Финализация...")
    
    -- Создаем файл версии
    local versionFile = io.open(INSTALL_DIR .. "/.version", "w")
    if versionFile then
        versionFile:write("1.1\n")
        versionFile:close()
        print("  ✓ Версия: 1.1")
    end
    
    -- Создаем файл конфигурации по умолчанию
    local configFile = io.open(INSTALL_DIR .. "/config.lua", "w")
    if configFile then
        configFile:write([[
-- Конфигурация казино "Spartak"
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
        backupInterval = 1800, -- 30 минут
    },
}
]])
        configFile:close()
        print("  ✓ Создан config.lua")
    end
    
    print("  ✓ Установка завершена")
end

-- Главная функция
local function main()
    print("╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    print("║         УСТАНОВЩИК КАЗИНО \"SPARTAK\"              ║")
    print("║                                                   ║")
    print("║  Версия: 1.1                                      ║")
    print("║  GitHub: github.com/DynyaCS/spartak-casino        ║")
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    
    print("\nДиректория установки: " .. INSTALL_DIR)
    print("Файлов для загрузки: " .. #FILES)
    
    -- Проверка существующей установки
    if filesystem.exists(INSTALL_DIR .. "/.version") then
        print("\n⚠ Обнаружена существующая установка!")
        print("Продолжить установку? (y/n): ")
        local answer = io.read()
        if answer ~= "y" and answer ~= "Y" then
            print("Установка отменена.")
            os.exit(0)
        end
    end
    
    print("\nНачинаем установку...")
    
    -- Создание директорий
    createDirectories()
    
    -- Загрузка файлов
    local success = downloadFiles()
    
    -- Финализация
    finalize()
    
    -- Итоговое сообщение
    print("\n╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    if success then
        print("║         ✓ УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!           ║")
    else
        print("║         ⚠ УСТАНОВКА ЗАВЕРШЕНА С ОШИБКАМИ         ║")
    end
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    
    if success then
        print("\n📚 Документация:")
        print("  cat " .. INSTALL_DIR .. "/README.md")
        print("  cat " .. INSTALL_DIR .. "/QUICKSTART.md")
        
        print("\n🚀 Запуск сервера:")
        print("  cd " .. INSTALL_DIR .. "/server")
        print("  ./main.lua")
        
        print("\n🎮 Запуск терминала:")
        print("  cd " .. INSTALL_DIR .. "/terminal")
        print("  ./main.lua")
        
        print("\n💰 Запуск терминала депозита:")
        print("  cd " .. INSTALL_DIR .. "/terminal")
        print("  ./deposit.lua")
        
        print("\n🎰 Удачи в казино \"Spartak\"! ✨")
    else
        print("\n⚠ Некоторые файлы не были загружены.")
        print("Проверьте подключение к интернету и попробуйте снова.")
        print("\nИли используйте ручную установку:")
        print("  https://github.com/DynyaCS/spartak-casino")
    end
end

-- Запуск
main()

