local themeTable = {}
function readThemeTable()
    --read theme.json
    local theme = io.open("system/settings/theme.json", "r")
    if theme == nil then error("theme.json doesn't exist!") end
    local themeData = theme:read("a")
    local themeTable = textutils.unserializeJSON(themeData)
    return themeTable
end

--create Msgbox function
function createMsgBox(mainFrame, text, title, optionNum, callback, width, height)
    themeTable = readThemeTable()

    local messageBox = mainFrame:addFrame()
    :setMovable(true)
    :setSize(width or 30, height or 12)
    :setPosition(12, 5)
    :setBorder(tonumber(themeTable.topBarBgColor))
    :setBackground(tonumber(themeTable.msgBoxBgColor))
    :hide()

    local msgBoxTopBar = messageBox:addFrame()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setSize("parent.w", 1)

    local msgBoxTitle = msgBoxTopBar:addLabel()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.topBarFgColor))
    :setText(title or "Palette MsgBox")

    local msgBoxCloseBtn = msgBoxTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.red)
    :setPosition("parent.w", 1)
    :setText("X")
    :setSize(1, 1)
    :onClick(function ()
        messageBox:remove()
    end)
    
    local msgBoxText = messageBox:addLabel()
    :setText("Example")
    :setFontSize(1)
    :setPosition(5, 3)
    
    

    local confirm
    local cancel
    local confirmA = true
    local cancelA = true
    if optionNum == 0 then
        confirm = "Confirm"
        cancel = "Cancel"
    end
    if optionNum == 1 then
        confirm = "Yes"
        cancel = "No"
    end
    if optionNum == 2 then
        confirmA = false
        cancel = "OK"
    end

    if confirmA then
        local msgBoxConfirmBtn = messageBox:addButton()
        :setText("Confirm")
        :setSize(9, 1)
        :setPosition(11, 11)
        :setBackground(colors.green)
        :setForeground(colors.white)

        msgBoxConfirmBtn:setText(confirm)
        :onClick(function()
            callback(true)
            messageBox:remove()
        end)
    end
    
    if cancelA then
        local msgBoxCancelBtn = messageBox:addButton()
        :setText("Cancel")
        :setSize(9, 1)
        :setPosition(21, 11)
        :setBackground(colors.cyan)
        :setForeground(colors.white)

        msgBoxCancelBtn:setText(cancel)
        :onClick(function()
            callback(false)
            messageBox:remove()
        end)        
    end
    
    
    msgBoxText:setText(text or "Nothing")
    :setForeground(tonumber(themeTable.msgBoxFgColor))

    

    messageBox:show()
end

--make a frame resizable
function makeResizeable(frame, program, minW, minH, maxW, maxH)
    minW = minW or 4
    minH = minH or 4
    maxW = maxW or 99
    maxH = maxH or 99
    local btn = frame:addButton()
        :setPosition("parent.w", "parent.h")
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
    program:setPosition(1, 2):setSize("parent.w", "parent.h - 1")
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

local pids = {}
local isHidden = {}
local programTitle = {}



--start a program
function startProgram(mainFrame, title, programPath, w, h)
    themeTable = readThemeTable()

    local pId = id
    id = id + 1
    pids[#pids+1] = pId
    isHidden[pId] = false
    local trueTitle = title .. "$" .. tostring(pId)


    programTitle[pId] = trueTitle

    
    

    local programWindow = mainFrame:addFrame()
    :setMovable(true)
    :setSize(w or 30, h or 12)
    :setPosition(12, 5)
    :setBorder(tonumber(themeTable.topBarBgColor))
    :setZIndex(100)

    

    
    local mainProgram = programWindow:addProgram():execute(programPath)
    :onError(function (self, event, err)
        createMsgBox("An error occured: " + err, "Error!", 2, function () end)
    end)
    :onDone(function (self)
        programWindow:remove()
        processes[getPidByTitle(trueTitle)] = nil
    end)
    :setPosition(1, 2)
    :setSize(52, 20)

    local programTopBar = programWindow:addFrame()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setSize("parent.w", 1)


    local msgBoxTitle = programTopBar:addLabel()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.topBarFgColor))
    :setText(title or "Program")


    local msgBoxCloseBtn = programTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.red)
    :setPosition("parent.w", 1)
    :setText("X")
    :setSize(1, 1)
    :onClick(function ()
        programWindow:remove()
        processes[getPidByTitle(trueTitle)] = nil
    end)

    local msgBoxMinimumBtn = programTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.yellow)
    :setPosition("parent.w - 4", 1)
    :setText("-")
    :setSize(1, 1)
    :onClick(function ()
        programWindow:hide()
        isHidden[getPidByTitle(trueTitle)] = true
    end)

    local btn = makeResizeable(programWindow, mainProgram, 8, 4)
    resizeBtn[pId] = btn

    local msgBoxMaximumBtn = programTopBar:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.green)
    :setPosition("parent.w - 2", 1)
    :setText("+")
    :setSize(1, 1)
    msgBoxMaximumBtn:onClick(function ()
        if maximumState[pId] then
            maximumState[pId] = false
            processes[pId]:setSize(processW[pId], processH[pId]):setPosition(processX[pId], processY[pId])
            resizeBtn[pId]:show()
        else
            maximumState[pId] = true
            processX[pId] = processes[pId]:getX()
            processY[pId] = processes[pId]:getY()
            processW[pId] = processes[pId]:getWidth()
            processH[pId] = processes[pId]:getHeight()
            processes[pId]:setSize(51, 19):setPosition(1, 1)
            resizeBtn[pId]:hide()
        end
        
    end)

    processes[pId] = programWindow
    maximumState[pId] = false
    return programWindow
end

function processesListenerThread(programListObj)
    local processes = {}
    while true do
        local prevProcesses = processes
        processes = getProcesses()
        if #prevProcesses ~= #processes then
            programListObj:clear()
            programListObj:addItem("Programs", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
            for index, value in ipairs(getAllTitles()) do
                programListObj:addItem(value, tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
            end
            
        end
    end
end

function getProcesses()
    return processes
end

function getProcessIsHiddenByIndex(index)
    return isHidden[index]
end

function setProcessIsHiddenByIndex(index, val)
    isHidden[index] = val
end

function getPidByTitle(title)
    for index, value in ipairs(programTitle) do
        if (value == title) then return index end
    end
    return false
end

function getAllTitles() 
    return programTitle
end