-- Установщик казино "Spartak" для Pastebin
-- Использование: pastebin run <КОД>
-- Автор: DynyaCS

local component = require("component")
local computer = require("computer")
local os = require("os")

local gpu = component.gpu

-- Проверка системных требований
do
    local problems = {}
    
    -- Internet Card
    if not component.isAvailable("internet") then
        table.insert(problems, "Internet Card")
    end
    
    -- HDD (минимум 1MB свободного места)
    do
        local found = false
        for address in component.list("filesystem") do
            if component.invoke(address, "spaceTotal") >= 1 * 1024 * 1024 then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(problems, "At least tier 1 hard disk drive (1MB+)")
        end
    end
    
    -- Если есть проблемы - выходим
    if #problems > 0 then
        print("Ваш компьютер не соответствует минимальным требованиям:")
        print("")
        for i = 1, #problems do
            print("  ✗ " .. problems[i])
        end
        print("")
        return
    end
end

-- Проверка доступности GitHub
do
    local success, result = pcall(component.internet.request, "https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua")
    
    if not success then
        print("✗ Ошибка подключения к GitHub:")
        print(tostring(result))
        print("")
        print("Возможные причины:")
        print("  • Репозиторий приватный")
        print("  • GitHub заблокирован")
        print("  • Проблемы с SSL сертификатом")
        print("")
        return
    end
    
    local deadline = computer.uptime() + 5
    local message
    
    while computer.uptime() < deadline do
        success, message = result.finishConnect()
        
        if success then
            break
        else
            if message then
                break
            else
                os.sleep(0.1)
            end
        end
    end
    
    result.close()
    
    if not success then
        print("✗ GitHub недоступен")
        print("")
        if message and message:match("PKIX") then
            print("Проблема с SSL сертификатом.")
            print("Обновите Java до последней версии.")
        else
            print("Проверьте:")
            print("  • Подключение к интернету")
            print("  • Настройки OpenComputers")
            print("  • Доступность github.com")
        end
        print("")
        return
    end
end

-- Загружаем и запускаем главный установщик
print("╔═══════════════════════════════════════════════════╗")
print("║                                                   ║")
print("║         КАЗИНО \"SPARTAK\" - УСТАНОВЩИК            ║")
print("║                                                   ║")
print("╚═══════════════════════════════════════════════════╝")
print("")
print("Загрузка установщика с GitHub...")
print("")

local connection = component.internet.request("https://raw.githubusercontent.com/DynyaCS/spartak-casino/master/quick_install.lua")
local data = ""
local chunk

while true do
    chunk = connection.read(math.huge)
    
    if chunk then
        data = data .. chunk
        io.write(".")
        io.flush()
    else
        break
    end
end

connection.close()

print("")
print("")

if #data == 0 then
    print("✗ Не удалось загрузить установщик")
    print("")
    return
end

print("✓ Установщик загружен (" .. #data .. " байт)")
print("")
print("Запуск установщика...")
print("")
os.sleep(1)

-- Запускаем установщик
local func, err = load(data)

if not func then
    print("✗ Ошибка загрузки установщика:")
    print(tostring(err))
    print("")
    return
end

-- Выполняем
local success, err = pcall(func)

if not success then
    print("")
    print("✗ Ошибка установки:")
    print(tostring(err))
    print("")
end

