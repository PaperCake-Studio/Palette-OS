local basalt = require("basalt")
local utils = require("apis.utils")


local errMsgAndPossibleReasonTable = {
    ["CRITICAL_PROCESS_DIED"] = "Accidentaly terminated/ended the system process"
}

--read theme.json and settings.json
local themeTable = utils.readThemeTable()
local settingsTable = utils.readSettings()

--#region write errlog
local function writeErrlog(errorMsg)
    local possibleReason = errMsgAndPossibleReasonTable[errorMsg]
    local filename = os.date("%Y%m%d_%H%M%S")
    local errlog = io.open("system/errlogs/" .. filename .. ".log", "w")
    errlog:write(os.date("%Y %B %d %A %T") .. "\nError Info: \nStopcode: " .. errorMsg ..
    "\nPossible Reason: " .. possibleReason ..
    "\n\nif you think it's a bug, report it on github." .. 
    "\nhttps://github.com/PaperCake-Studio/Palette-OS/issues\nMake sure to bring the \"beta/alpha bug\" label if you're sure it's a bug when publishing issue")
    errlog:close()
end
--#endregion


--#region define objects
local main = basalt.createFrame()
:setBackground(tonumber(themeTable.desktopBgColor))


local mainFrame = main:addFrame()
:setZIndex(100)
:setPosition(1, 2)
:setSize(52, 19)
:setBackground(colors.transparent)

local contextMenu = mainFrame:addFrame()
:setSize(10, 5)
:setBackground(colors.gray)
:setForeground(colors.write)
:setZIndex(1)
:hide()
contextMenu:onLoseFocus(function ()
    contextMenu:hide()
end)

mainFrame:onClick(function (self, event, btn, x, y)
    --right click
    if btn == 2 and y >= 2 then
        if 19 - y < contextMenu:getHeight() then
            contextMenu:setPosition(x, y - contextMenu:getHeight()):show():setZIndex(900):setFocus()
        else
            contextMenu:setPosition(x, y):show():setZIndex(900):setFocus()
        end
        
    end
end)

local menubar = main:addFrame() --upper menu bar frame
:setSize(52, 1) 
:setBackground(colors.transparent)
:setForeground(tonumber(themeTable.menubarFgColor))

local menuPanel = menubar:addPane() --bar
:setSize(52, 1)
:setBackground(tonumber(themeTable.menubarBgColor))

local timeLabel = menubar:addLabel()
:setPosition(44, 1)
:setFontSize(1)
:setForeground(colors.white)


--#endregion


--#region BSoD Screen definition
local bsod = main:addFrame()
:setSize(52, 20)
:setBackground(colors.blue)

bsod:addLabel()
:setText(":(")
:setFontSize(2)
:setPosition(2, 2)
:setForeground(colors.white)
:setBackground(colors.blue)

bsod:addLabel()
:setText("Your system has ended unexpectedly,")
:setPosition(2, 8)
:setForeground(colors.white)
:setBackground(colors.blue)

bsod:addLabel()
:setText("it seems like the user did something wrong.")
:setPosition(2, 9)
:setForeground(colors.white)
:setBackground(colors.blue)

bsod:addLabel()
:setText("If you think it's not your bad,")
:setPosition(2, 10)
:setForeground(colors.white)
:setBackground(colors.blue)

bsod:addLabel()
:setText("Please report it onto github.")
:setPosition(2, 11)
:setForeground(colors.white)
:setBackground(colors.blue)

bsod:addLabel()
:setText("Here's the stopcode if you think it will help.")
:setPosition(2, 12)
:setForeground(colors.white)
:setBackground(colors.blue)

local stopcodeLabel = bsod:addLabel()
:setText("STOPCODE: ")
:setPosition(2, 14)
:setForeground(colors.white)
:setBackground(colors.blue)

local bsodProcessInfo = bsod:addLabel()
:setText("We'll store some information on your computer.")
:setPosition(2, 17)
:setForeground(colors.white)
:setBackground(colors.blue)

local bsodProcessLabel = bsod:addLabel()
:setText("Process: 0%")
:setPosition(2, 16)
:setForeground(colors.white)
:setBackground(colors.blue)

local function bsodProcessThreadFunc(enableRandomTime, processStep, processStepTime)

    --if not enable random time
    if enableRandomTime ~= true then
        processStep = processStep or 20
        processStepTime = processStepTime or 1.5
        restartWaitingTime = restartWaitingTime or 3
    end
   
    local currentProcess = 0
    while currentProcess < 100 do
        if enableRandomTime then
            --if enable random time, sleep a random time
            os.sleep(math.random(1, 3))
        else
            os.sleep(processStepTime)
        end
        
        if enableRandomTime then
            --if enable random time, grow a random val
            processStep = math.random(10, 30)
        end
        

        if currentProcess + processStep > 100 then
            currentProcess = 100
        else
            currentProcess = currentProcess + processStep
        end
        
        bsodProcessLabel:setText("Process: ".. currentProcess .. "%")
    end
    bsodProcessInfo:setText("We'll restart your computer in a short time.  ")

    os.sleep(3)
    os.reboot()
end

bsod:hide()
--#endregion


--#region bsod func
local function generateBSoD(reason, enableRandomTime, processStep, processStepTime)
    if settingsTable.noErrLogsWhenBSoD ~= 1 then
        writeErrlog(reason)
    end
    
    stopcodeLabel:setText("STOPCODE: " .. reason)
    bsod:setZIndex(9999):show()
    main:addThread():start(function ()
        bsodProcessThreadFunc(enableRandomTime, processStep, processStepTime)
    end)
end
--#endregion


--#region thread to reroll back to the 1st option of paletteOptions
local function rerollDropdown(obj)
    os.sleep(0.1)
    obj:selectItem(1)
end
--#endregion


--#region initializeProgramList for utils
utils.initializeProgramList(main)
--#endregion


--#region shutdown msgBox callback
local function confirmingShutdown(state)
    if state then
        os.shutdown()
    end
end
--#endregion


--#region reboot msgBox callback
local function confirmingReboot(state)
    if state then
        os.reboot()
    end
end
--#endregion


--#region thread to update time
local timeThread = main:addThread()
:start(function ()
    local previousTime
    while true do
        local time = textutils.formatTime(os.time("ingame"))
        if (time ~= previousTime) then
            timeLabel:setText(time)
            previousTime = time
        end
        os.sleep(1)
    end
end)
--#endregion


--#region about msg box
local function popAboutMsgBox()
    utils.createMsgBox(mainFrame, {"Palette OS -", "Basalt Alpha", "Dev Version 1.1.1", "", "Made by BlueStarrySky233"}, "Info", 2, nil)
end
--#endregion


--#region paletteOptions definition
local paletteOptions = main:addDropdown()
:setForeground(tonumber(themeTable.optionsFgColor))
:setBackground(tonumber(themeTable.optionsBgColor))
:addItem("Palette OS", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:addItem("Shutdown", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:addItem("Reboot", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:addItem("Terminal", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:addItem("About", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:selectItem(1)
:setZIndex(900)

paletteOptions:onChange(
    function(self, item)
        if item.text == "Shutdown" then
            utils.createMsgBox(mainFrame, "[!] Confirm Shutdown?", "Confirm", 0, confirmingShutdown)
        end
        if item.text == "Reboot" then
            utils.createMsgBox(mainFrame, "[!] Confirm Reboot?", "Confirm", 0, confirmingReboot)
        end
        if item.text == "Terminal" then
            utils.startProgram(mainFrame, "Terminal", "shell")
        end
        if item.text == "About" then
            popAboutMsgBox()
        end

        if item.text ~= "Palette OS" then
            main:addThread()
            :start(function ()
                rerollDropdown(paletteOptions)
            end)
        end
    end
)
--#endregion


--#region main thread that both included autoUpdate and terminate prevention
local function mainThread()
    while true do
        local event
        parallel.waitForAll(function ()
            event = os.pullEventRaw()
        end, basalt.autoUpdate)
        if event == "terminate" then
            generateBSoD("CRITICAL_PROCESS_DIED", true)
        end
    end
end
--#endregion


--#region Desktop icons creation func definition
local startingY = 2
local yStep = 4

local maxWidth = 15
local height = 3

local maxProgramCountInColumn = 4

local startingX = 2
local xStep = 11

local desktopAppsList = {}

local yFuncVariable = startingY
local currentColumnNumber = 0

local currentSelectedSprite = nil

local function createDesktopSpirte(desktopName, execCommand)
    --function y=4x+2 describes the first 4 icons' y pos with default settings, 4x-14 describes the next 4 with default settings
    if math.floor(#desktopAppsList / maxProgramCountInColumn) > currentColumnNumber then
        currentColumnNumber = currentColumnNumber + 1
        yFuncVariable = yFuncVariable - (maxProgramCountInColumn * yStep)
    end
    --set the real name before clamping it
    local realName = desktopName
    --y pos function y=sx+k
    local currentY = yFuncVariable + (yStep * #desktopAppsList)
    --function y=11*ceil(x-(m-1)/m)+2 describes the x pos with default settings
    local currentX = startingX + (xStep * math.ceil((#desktopAppsList - (maxProgramCountInColumn - 1)) / (maxProgramCountInColumn)))
    local width = #desktopName + 2
    if width > maxWidth then 
        width = maxWidth 
        desktopName = string.sub(desktopName, 1, #desktopName - 3) .. "..."
    end
    --button obj
    local obj = mainFrame:addButton():setPosition(currentX, currentY):setSize(width, height):setText(desktopName)
    :setBackground(tonumber(themeTable.desktopIconBgColor)):setForeground(tonumber(themeTable.desktopIconFgColor))
    obj:onClick(function ()
        --when on click, find our index in desktopAppsList
        for index, value in ipairs(desktopAppsList) do
            if value.realName == realName then
                if currentSelectedSprite ~= index then
                    if currentSelectedSprite ~= nil then
                        --return the previous icon into initial state when it's not nil
                        desktopAppsList[currentSelectedSprite].obj:setBackground(tonumber(themeTable.desktopIconBgColor)):setForeground(tonumber(themeTable.desktopIconFgColor))
                    end
                    --set currentSelectedSprite to this obj
                    currentSelectedSprite = index
                    --set theme
                    obj:setBackground(tonumber(themeTable.desktopIconBgColorSelected)):setForeground(tonumber(themeTable.desktopIconFgColorSelected))
                elseif currentSelectedSprite == index then
                    --when clicking on it twice, opens the app
                    utils.startProgram(mainFrame, value.realName, value.execCommand)
                end
                
                break
            end
        end
    end)
    :onLoseFocus(function ()
        --if nothing is selected, return
        if currentSelectedSprite == nil then return end
        --when not focus on it, return to the initial state, and set currentSelectedSprite to nil
        desktopAppsList[currentSelectedSprite].obj:setBackground(tonumber(themeTable.desktopIconBgColor)):setForeground(tonumber(themeTable.desktopIconFgColor))
        currentSelectedSprite = nil
    end)

    desktopAppsList[#desktopAppsList + 1] = 
    {
        ["desktopName"] = desktopName,
        ["realName"] = realName,
        ["execCommand"] = execCommand,
        ["yPos"] = currentY,
        ["xPos"] = currentX,
        ["width"] = width,
        ["obj"] = obj
    }
end
--#endregion


--#region desktop icons
local function refreshDesktop()
    desktopAppsList = {}
    createDesktopSpirte("Terminal", "shell")
    createDesktopSpirte("Worm Game", "worm")
    createDesktopSpirte("Task Manager", "/system/taskManager.lua")
    if fs.exists("desktop") then
        local apps = fs.find("desktop/*.applink")
        for index, value in ipairs(apps) do
            local f = io.open(value)
            local appName = f:read()
            local appPath = f:read()
            f:close()
            if appName ~= nil and appPath ~= nil then
                createDesktopSpirte(appName, appPath)
            end
            
        end
    else
        fs.makeDir("desktop")
    end
end

--#endregion


--#region contextMenu buttons
local contextRefreshBtn = contextMenu:addButton():setPosition(1, 1):setSize("parent.w", 1):setText("Refresh"):setForeground(colors.white):setBackground(colors.gray)
:setHorizontalAlign("left")
contextRefreshBtn:onClick(function (self, event, btn, x, y)
    if btn == 1 then
        contextRefreshBtn:setBackground(colors.black)
    end
    
end)
contextRefreshBtn:onRelease(function (self, event, btn, x, y)
    if btn ~= 1 then return end
    contextRefreshBtn:setBackground(colors.gray)
    refreshDesktop()
    contextMenu:hide()
end)


local contextTerminalBtn = contextMenu:addButton():setPosition(1, 2):setSize("parent.w", 1):setText("About"):setForeground(colors.white):setBackground(colors.gray)
:setHorizontalAlign("left")
contextTerminalBtn:onClick(function (self, event, btn, x, y)
    if btn == 1 then
        contextTerminalBtn:setBackground(colors.black)
    end
    
end)
contextTerminalBtn:onRelease(function (self, event, btn, x, y)
    if btn ~= 1 then return end
    contextTerminalBtn:setBackground(colors.gray)
    contextMenu:hide()
    popAboutMsgBox()
    
end)
--#endregion


main:addLabel():setPosition(42, 19):setText("ALPHA TEST"):setSize(10, 1)
--run main
refreshDesktop()
mainThread()