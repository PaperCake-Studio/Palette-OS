local basalt = require("basalt")
local utils = require("apis.utils")

--read theme.json
local themeTable = utils.readThemeTable()


--define objects
local main = basalt.createFrame()
:setBackground(tonumber(themeTable.desktopBgColor))

local mainFrame = main:addFrame()
:setZIndex(100)
:setPosition(1, 2)
:setSize(52, 19)
:setBackground(colors.transparent)

local menubar = main:addFrame() --upper menu bar frame
:setSize(52, 1) 
:setBackground(colors.transparent)
:setForeground(tonumber(themeTable.menubarFgColor))

local menuPanel = menubar:addPane() --bar
:setSize(52, 1)
:setBackground(tonumber(themeTable.menubarBgColor))

local bsod = main:addFrame()
:setSize(52, 20)
:setBackground(colors.blue)


local bsodTitle = bsod:addLabel()
:setText(":(")
:setFontSize(2)
:setPosition(2, 2)
:setForeground(colors.white)
:setBackground(colors.blue)

bsod:hide()




--thread to reroll back to the 1st option of paletteOptions
local function rerollDropdown(obj)
    os.sleep(0.1)
    obj:selectItem(1)
end



utils.initializeProgramList(main)



--shutdown callback
local function confirmingShutdown(state)
    if state then
        os.shutdown()
    end
end

--reboot callback
local function confirmingReboot(state)
    if state then
        os.reboot()
    end
end





--thread to update time
local function updateTimeThread(obj)
    local previousTime
    while true do
        local time = textutils.formatTime(os.time("ingame"))
        if (time ~= previousTime) then
            obj:setText(time)
            previousTime = time
        end
        os.sleep(1)
    end
end



--define paletteOptions
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
            utils.createMsgBox(mainFrame, {"Palette OS -", "Basalt Alpha", "Dev Version 1.1.0", "", "Made by BlueStarrySky233"}, "Info", 2, nil)
        end

        if item.text ~= "Palette OS" then
            main:addThread()
            :start(function ()
                rerollDropdown(paletteOptions)
            end)
        end
    end
)




local function terminateThread()
    while true do
        local event = os.pullEventRaw()
        if event == "terminate" then
            bsod:show()
        end
    end
end

--time label
local timeLabel = menubar:addLabel()
:setPosition(44, 1)
:setFontSize(1)
:setForeground(colors.white)

--time thread
local timeThread = main:addThread()
:start(function ()
    updateTimeThread(timeLabel)
end)

--terminate thread
local terminateThread = main:addThread()
:start(terminateThread)

--autoUpdate
basalt.autoUpdate()