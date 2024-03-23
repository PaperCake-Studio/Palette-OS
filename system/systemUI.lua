local basalt = require("basalt")

--read theme.json
local theme = io.open("system/settings/theme.json", "r")
local themeData = theme:read("a")
local themeTable = textutils.unserializeJSON(themeData)


--define objects
local main = basalt.createFrame()
:setBackground(tonumber(themeTable.desktopBgColor))

local menubar = main:addFrame() --upper menu bar frame
:setSize(52, 4) 
:setBackground(colors.transparent)
:setForeground(tonumber(themeTable.menubarFgColor))

local menuPanel = menubar:addPane() --bar
:setSize(52, 1)
:setBackground(tonumber(themeTable.menubarBgColor))



--create Msgbox function
function createMsgBox(text, title, optionNum, callback, width, height)
    

    local messageBox = main:addMovableFrame()
    :setSize(width or 30, height or 12)
    :setPosition(12, 5)
    :setBorder(tonumber(themeTable.topBarBgColor))
    :setBackground(tonumber(themeTable.msgBoxBgColor))
    :hide()

    local msgBoxTopBar = messageBox:addFrame()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setSize("{parent.w}", 1)

    local msgBoxTitle = msgBoxTopBar:addLabel()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.topBarFgColor))
    :setText(title or "Palette MsgBox")

    local msgBoxCloseBtn = msgBoxTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.red)
    :setPosition("{parent.w - 2}", 1)
    :setText("X")
    :setSize(1, 1)
    :onClick(function ()
        messageBox:remove()
    end)
    
    local msgBoxText = messageBox:addLabel()
    :setText("Example")
    :setFontSize(1)
    :setPosition(5, 3)
    
    local msgBoxConfirmBtn = messageBox:addButton()
    :setText("Confirm")
    :setSize(9, 1)
    :setPosition(11, 11)
    :setBackground(colors.green)
    :setForeground(colors.white)
    
    local msgBoxCancelBtn = messageBox:addButton()
    :setText("Cancel")
    :setSize(9, 1)
    :setPosition(21, 11)
    :setBackground(colors.cyan)
    :setForeground(colors.white)

    local confirm
    local cancel
    if optionNum == 0 then
        confirm = "Confirm"
        cancel = "Cancel"
    end
    if optionNum == 1 then
        confirm = "Yes"
        cancel = "No"
    end
    
    msgBoxText:setText(text or "Nothing")
    :setForeground(tonumber(themeTable.msgBoxFgColor))

    msgBoxConfirmBtn:setText(confirm)
    :onClick(function()
        callback(true)
        messageBox:remove()
    end)
    msgBoxCancelBtn:setText(cancel)
    :onClick(function()
        callback(false)
        messageBox:remove()
    end)

    messageBox:show()
end

--make a frame resizable
local function makeResizeable(frame, program, minW, minH, maxW, maxH)
    minW = minW or 4
    minH = minH or 4
    maxW = maxW or 99
    maxH = maxH or 99
    local btn = frame:addButton()
        :setPosition("{parent.w-1}", "{parent.h-1}")
        :setSize(1, 1)
        :setText("/")
        :setForeground(colors.blue)
        :setBackground(colors.black)
        :onDrag(function(self, event, btn, xOffset, yOffset)
            local w, h = frame:getSize()
            local wOff, hOff = w, h
            if(w+xOffset-1>=minW)and(w+xOffset-1<=maxW)then
                wOff = w+xOffset-1
            end
            if(h+yOffset-1>=minH)and(h+yOffset-1<=maxH)then
                hOff = h+yOffset-1
            end
            frame:setSize(wOff, hOff)
        end)
    program:setPosition(1, 2):setSize("{parent.w}", "{parent.h - 1}")
    return btn
end


local id = 1
local processes = {}
local maximumState = {}
local processX = {}
local processY = {}
local processW = {}
local processH = {}
local resizeBtn = {}


--start a program
function startProgram(title, programPath, w, h)
    local pId = id
    id = id + 1

    local programWindow = main:addMovableFrame()
    :setSize(w or 30, h or 12)
    :setPosition(12, 5)
    :setBorder(tonumber(themeTable.topBarBgColor))


    local mainProgram = programWindow:addProgram():execute(function ()
        shell.run(programPath)
    end)
    :onError(function(self, event, err)
        print("An error occurred: " .. err)
    end)
    :onDone(function ()
        programWindow:remove()
    end)
    :setPosition(1, 2)
    :setSize(52, 20)

    local programTopBar = programWindow:addFrame()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setSize("{parent.w}", 1)

    local msgBoxTitle = programTopBar:addLabel()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.topBarFgColor))
    :setText(title or "Program")

    local msgBoxCloseBtn = programTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.red)
    :setPosition("{parent.w - 2}", 1)
    :setText("X")
    :setSize(1, 1)
    :onClick(function ()
        programWindow:remove()
    end)

    local btn = makeResizeable(programWindow, mainProgram, 8, 4)
    resizeBtn[pId] = btn

    local msgBoxMaximumBtn = programTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.yellow)
    :setPosition("{parent.w - 4}", 1)
    :setText("+")
    :setSize(1, 1)
    msgBoxMaximumBtn:onClick(function ()
        if maximumState[pId] then
            maximumState[pId] = false
            processes[pId]:setSize(processW[pId], processH[pId]):setPosition(processX[pId], processY[pId])
            msgBoxMaximumBtn:setText("+")
            resizeBtn[pId]:show()
        else
            maximumState[pId] = true
            processX[pId] = processes[pId]:getX()
            processY[pId] = processes[pId]:getY()
            processW[pId] = processes[pId]:getWidth()
            processH[pId] = processes[pId]:getHeight()
            processes[pId]:setSize(51, 19):setPosition(1, 1)
            msgBoxMaximumBtn:setText("-")
            resizeBtn[pId]:hide()
        end
        
    end)

    processes[pId] = programWindow
    maximumState[pId] = false
    return programWindow
end


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

--thread to reroll back to the 1st option of paletteOptions
local function paletteOptionsRerollThread(obj)
    os.sleep(0.1)
    obj:selectItem(1)
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
local paletteOptions = menubar:addDropdown()
:setForeground(tonumber(themeTable.optionsFgColor))
:setBackground(tonumber(themeTable.optionsBgColor))
:addItem("Palette OS", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:addItem("Shutdown", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
:addItem("Reboot", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
paletteOptions:onChange(
    function(self, event, item)
        if item.text == "Shutdown" then
            createMsgBox("[!] Confirm Shutdown?", "Confirm", 0, confirmingShutdown)
        end
        if item.text == "Reboot" then
            createMsgBox("[!] Confirm Reboot?", "Confirm", 0, confirmingReboot)
        end

        if item.text ~= "Palette OS" then
            main:addThread()
            :start(function ()
                paletteOptionsRerollThread(paletteOptions)
            end)
        end
    end
)

local function terminateThread()
    while true do
        local event = os.pullEventRaw()
        if event == "terminate" then
            basalt.stopUpdate()
            error()
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


startProgram("Worm", "rom/programs/fun/worm.lua")
--autoUpdate
basalt.autoUpdate()