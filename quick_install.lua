-- Быстрый установщик казино "Spartak" для OpenComputers
-- Загружает все файлы одной командой с GitHub
-- Использование: wget -f https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua && lua quick_install.lua

local component = require("component")
local internet = require("internet")
local filesystem = require("filesystem")
local shell = require("shell")

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
    local fullPath = filesystem.concat(INSTALL_DIR, path)
    
    -- Создаем директорию рекурсивно
    local dir = filesystem.path(fullPath)
    if dir and dir ~= "" and not filesystem.exists(dir) then
        local success, err = filesystem.makeDirectory(dir)
        if not success then
            return false, "Не удалось создать директорию " .. dir .. ": " .. tostring(err)
        end
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
    
    -- Сохраняем файл через filesystem API
    local file, err = filesystem.open(fullPath, "w")
    if not file then
        return false, "Не удалось создать файл " .. fullPath .. ": " .. tostring(err)
    end
    
    file:write(data)
    file:close()
    
    return true, #data
end

-- Функция отрисовки заголовка
local function printHeader()
    print("╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    print("║    БЫСТРЫЙ УСТАНОВЩИК КАЗИНО \"SPARTAK\"           ║")
    print("║                                                   ║")
    print("║  Версия: 1.1                                      ║")
    print("║  GitHub: github.com/DynyaCS/spartak-casino        ║")
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
end

-- Функция отрисовки прогресса
local function printProgress(current, total, status)
    io.write(string.format("\r[%d/%d] %s", current, total, status))
    io.flush()
end

-- Главная функция установки
local function install()
    printHeader()
    
    print("Директория установки: " .. INSTALL_DIR)
    print("Файлов для загрузки: " .. #FILES)
    print("")
    
    -- Создаем базовую директорию
    if not filesystem.exists(INSTALL_DIR) then
        print("[1/3] Создание базовой директории...")
        local success, err = filesystem.makeDirectory(INSTALL_DIR)
        if not success then
            print("✗ Ошибка: Не удалось создать директорию " .. INSTALL_DIR)
            print("  " .. tostring(err))
            return false
        end
        print("  ✓ Директория создана")
    else
        print("[1/3] Базовая директория существует")
    end
    print("")
    
    -- Создаем поддиректории
    print("[2/3] Создание поддиректорий...")
    local dirs = {"server", "terminal", "lib", "data", "logs"}
    for _, dir in ipairs(dirs) do
        local fullDir = filesystem.concat(INSTALL_DIR, dir)
        if not filesystem.exists(fullDir) then
            filesystem.makeDirectory(fullDir)
        end
    end
    print("  ✓ Поддиректории созданы")
    print("")
    
    -- Загружаем файлы
    print("[3/3] Загрузка файлов с GitHub...")
    print("")
    
    local success_count = 0
    local failed_files = {}
    
    for i, file in ipairs(FILES) do
        local status = string.format("[%d/%d] %s", i, #FILES, file.path)
        io.write(status .. " ")
        io.flush()
        
        local url = BASE_URL .. file.url
        local success, result = downloadFile(url, file.path)
        
        if success then
            print("✓ (" .. result .. " байт)")
            success_count = success_count + 1
        else
            print("✗")
            print("  Ошибка: " .. result)
            if file.required then
                table.insert(failed_files, file.path)
            end
        end
    end
    
    print("")
    
    -- Проверяем результат
    if #failed_files > 0 then
        print("╔═══════════════════════════════════════════════════╗")
        print("║                                                   ║")
        print("║         ✗ УСТАНОВКА ЗАВЕРШЕНА С ОШИБКАМИ         ║")
        print("║                                                   ║")
        print("╚═══════════════════════════════════════════════════╝")
        print("")
        print("Не удалось загрузить обязательные файлы:")
        for _, file in ipairs(failed_files) do
            print("  • " .. file)
        end
        print("")
        print("Проверьте подключение к интернету и попробуйте снова.")
        return false
    end
    
    -- Создаем конфигурационный файл
    local configPath = filesystem.concat(INSTALL_DIR, "config.lua")
    if not filesystem.exists(configPath) then
        local config = [[-- Конфигурация казино "Spartak"
return {
    version = "1.1",
    network = {
        port = 5555,
        timeout = 5,
    },
    games = {
        minBet = 1,
        maxBet = 100,
    },
    deposit = {
        minAmount = 1,
        maxAmount = 10000,
    },
}
]]
        local file = filesystem.open(configPath, "w")
        if file then
            file:write(config)
            file:close()
        end
    end
    
    -- Успешное завершение
    print("╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    print("║         ✓ УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!           ║")
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    print("Статистика:")
    print("  • Загружено файлов: " .. success_count .. "/" .. #FILES)
    print("  • Директория: " .. INSTALL_DIR)
    print("  • Версия: 1.1")
    print("")
    print("╔═══════════════════════════════════════════════════╗")
    print("║                 ЗАПУСК СЕРВЕРА                    ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    print("  cd " .. INSTALL_DIR .. "/server")
    print("  lua main.lua")
    print("")
    print("╔═══════════════════════════════════════════════════╗")
    print("║              ЗАПУСК ТЕРМИНАЛА ИГР                 ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    print("  cd " .. INSTALL_DIR .. "/terminal")
    print("  lua main.lua")
    print("")
    print("╔═══════════════════════════════════════════════════╗")
    print("║            ЗАПУСК ТЕРМИНАЛА ДЕПОЗИТА              ║")
    print("╚═══════════════════════════════════════════════════╝")
    print("")
    print("  cd " .. INSTALL_DIR .. "/terminal")
    print("  lua deposit.lua")
    print("")
    print("Документация: " .. INSTALL_DIR .. "/README.md")
    print("")
    print("Удачи в казино \"Spartak\"! 🎰")
    print("")
    
    return true
end

-- Запуск установки
local success, err = pcall(install)

if not success then
    print("")
    print("✗ Критическая ошибка установки:")
    print(tostring(err))
    print("")
    return false
end

return success

