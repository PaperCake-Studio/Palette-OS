
local themeTable = {}

utils = {}

local defaultThemeTable = {
    ["desktopBgColor"] = "0x8",
    ["desktopFgColor"] = "0x8000",
    ["menubarBgColor"] = "0x200",
    ["menubarFgColor"] = "0x1",
    ["optionsBgColor"] = "0x200",
    ["optionsFgColor"] = "0x8000",
    ["msgBoxBgColor"] = "0x80",
    ["msgBoxFgColor"] = "0x1",
    ["topBarBgColor"] = "0x8000",
    ["topBarFgColor"] = "0x1",
    ["desktopIconBgColor"] = "0x200",
    ["desktopIconFgColor"] = "0x1",
    ["desktopIconBgColorSelected"] = "0x800",
    ["desktopIconFgColorSelected"] = "0x1"
}

function utils.readThemeTable()
    --read theme.json
    theme = io.open("system/settings/theme.json", "r")
    if theme == nil then 
        theme = io.open("system/settings/theme.json", "w")
        theme:write(textutils.serializeJSON(defaultThemeTable))
        theme:close()
        theme = io.open("system/settings/theme.json", "r")
    end
    local themeData = theme:read("a")
    local themeTable = textutils.unserializeJSON(themeData)
    theme:close()
    return themeTable
end

--create Msgbox function
function utils.createMsgBox(text, title, optionNum, callback, width, height)

    themeTable = utils.readThemeTable()

    local enableCallback = callback ~= nil

    local messageBox = mainFrame:addFrame()
    :setMovable(true)
    :setSize(width or 30, height or 12)
    :setPosition(12, 5)
    :setBorder(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.msgBoxFgColor))
    :setBackground(tonumber(themeTable.msgBoxBgColor))
    :setZIndex(999)
    :setBar(title or "Info", tonumber(themeTable.topBarBgColor), tonumber(themeTable.topBarFgColor))
    :showBar()
    :hide()

    --[[local msgBoxTopBar = messageBox:addFrame()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setSize("parent.w", 1)

    local msgBoxTitle = msgBoxTopBar:addLabel()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.topBarFgColor))
    :setText(title or "Palette MsgBox")]]--

    local msgBoxCloseBtn = messageBox:addButton()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(colors.red)
    :setPosition("parent.w", 1)
    :setText("X")
    :setSize(1, 1)
    :onClick(function ()
        messageBox:remove()
    end)
    

    if type(text) == "table" then
        for index, value in ipairs(text) do
            messageBox:addLabel()
            :setFontSize(1)
            :setPosition(5, 2 + index)
            :setText(value or "Nothing")
            :setForeground(tonumber(themeTable.msgBoxFgColor))
        end
        
    else
        messageBox:addLabel()
        :setFontSize(1)
        :setPosition(5, 3)
        :setText(text or "Nothing")
        :setForeground(tonumber(themeTable.msgBoxFgColor))
    end
    

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
        :setPosition("parent.w - 19", "parent.h - 1")
        :setBackground(colors.green)
        :setForeground(colors.white)

        msgBoxConfirmBtn:setText(confirm)
        :onClick(function()
            if enableCallback then
                callback(true)
            end
            messageBox:remove()
        end)
    end
    
    if cancelA then
        local msgBoxCancelBtn = messageBox:addButton()
        :setText("Cancel")
        :setSize(9, 1)
        :setPosition("parent.w - 9", "parent.h - 1")
        :setBackground(colors.cyan)
        :setForeground(colors.white)

        msgBoxCancelBtn:setText(cancel)
        :onClick(function()
            if enableCallback then
                callback(false)
            end
            
            messageBox:remove()
        end)        
    end
    
    
    

    

    messageBox:show():setFocus()
end

--make a frame resizable
function utils.makeResizeable(frame, program, minW, minH, maxW, maxH)
    minW = minW or 30
    minH = minH or 12
    maxW = maxW or 52
    maxH = maxH or 18
    local btn = frame:addButton()
        :setPosition("parent.w", "parent.h")
        :setSize(1, 1)
        :setText("/")
        :setForeground(colors.blue)
        :setBackground(colors.transparent)
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

function utils.rerollDropdown(obj)
    os.sleep(0.1)
    obj:selectItem(1)
end


function utils.initializeProgramList( main)
    programList = main:addDropdown()
    :setForeground(tonumber(themeTable.optionsFgColor))
    :setBackground(tonumber(themeTable.optionsBgColor))
    :addItem("Programs", tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
    :setPosition(32, 1)
    :setSize(10, 1)
    :selectItem(1)
    :setZIndex(900)
    programList:onChange(
        function (self, item)
            if item.text ~= "Programs" then
                if utils.getProcessIsHiddenByIndex(utils.getPidByTitle(item.text)) == true then
                    utils.getProcesses()[utils.getPidByTitle(item.text)]:show()
                    :setFocus()
                    utils.setProcessIsHiddenByIndex(utils.getPidByTitle(item.text), false)
                else
                    utils.getProcesses()[utils.getPidByTitle(item.text)]:setFocus()
                end 
    
                main:addThread()
                :start(function ()
                    utils.rerollDropdown(programList)
                end)
            end
            
        end
    )
end

function utils.getProgramListIndexByTitle(title)
    for i = 2, programList:getItemCount(), 1 do
        if programList:getItem(i).text == title then
            return i
        end
    end
    return false
end

local mainFrame

function utils.initializeMainFrame(mainFrameObj)
    mainFrame = mainFrameObj
end

local id = 1
local maximumState = {}
local processX = {}
local processY = {}
local processW = {}
local processH = {}
local resizeBtn = {}


local pids = {}
local isHidden = {}
local programTitles = {}
local processes = {}


--start a program
function utils.startProgram(title, programPath, w, h)
    themeTable = utils.readThemeTable()

    local pId = id
    id = id + 1
    table.insert(pids, #pids + 1, pId)
    table.insert(isHidden, pId, false)
    local trueTitle = title .. "$" .. tostring(pId)

    table.insert(programTitles, pId, trueTitle)
    programList:addItem(trueTitle, tonumber(themeTable.optionsBgColor), tonumber(themeTable.optionsFgColor))
    

    local programWindow = mainFrame:addFrame()
    :setMovable(true)
    :setSize(w or 30, h or 12)
    :setPosition(12, 5)
    :setBorder(tonumber(themeTable.topBarBgColor))
    :setBar(title or "Program", tonumber(themeTable.topBarBgColor), tonumber(themeTable.topBarFgColor))
    :showBar()

    

    
    local mainProgram = programWindow:addProgram():execute(programPath)
    :onError(function (self, err)
        utils.createMsgBox("An error occured: " + err, "Error!", 2, function (flag) 
            programWindow:remove()
            processes[pId] = ""
            programList:removeItem(utils.getProgramListIndexByTitle(trueTitle))
            programTitles[pId] = ""
            isHidden[pId] = ""
            pids[pId] = ""
        end)
    end)
    :onDone(function (self)
        programWindow:remove()
        processes[pId] = ""
        programList:removeItem(utils.getProgramListIndexByTitle(trueTitle))
        programTitles[pId] = ""
        isHidden[pId] = ""
        pids[pId] = ""
    end)
    :setPosition(1, 2)
    :setSize(52, 20)

    --[[
    local programTopBar = programWindow:addFrame()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setSize("parent.w", 1)


    local msgBoxTitle = programTopBar:addLabel()
    :setBackground(tonumber(themeTable.topBarBgColor))
    :setForeground(tonumber(themeTable.topBarFgColor))
    :setText(title or "Program")
    ]]


    local msgBoxCloseBtn = programWindow:addButton()
    :setBackground(colors.red)
    :setForeground(tonumber(themeTable.topBarBgColor))
    :setPosition("parent.w", 1)
    :setText("X")
    :setSize(1, 1)
    :onClick(function ()
        programWindow:remove()
        processes[pId] = ""
        programList:removeItem(utils.getProgramListIndexByTitle(trueTitle))
        programTitles[pId] = ""
        isHidden[pId] = ""
        pids[pId] = ""
    end)

    local msgBoxMinimumBtn = programWindow:addButton()
    :setBackground(colors.yellow)
    :setForeground(tonumber(themeTable.topBarBgColor))
    :setPosition("parent.w - 4", 1)
    :setText("-")
    :setSize(1, 1)
    :onClick(function ()
        programWindow:hide()
        isHidden[utils.getPidByTitle(trueTitle)] = true
    end)

    local btn = utils.makeResizeable(programWindow, mainProgram, w, h)
    resizeBtn[pId] = btn

    local msgBoxMaximumBtn = programWindow:addButton()
    :setBackground(colors.green)
    :setForeground(tonumber(themeTable.topBarBgColor))
    :setPosition("parent.w - 2", 1)
    :setText("+")
    :setSize(1, 1)
    msgBoxMaximumBtn:onClick(function ()
        if maximumState[pId] then
            maximumState[pId] = false
            processes[pId]:setSize(processW[pId], processH[pId]):setPosition(processX[pId], processY[pId])
            :setMovable(true)
            resizeBtn[pId]:show()
            msgBoxMaximumBtn:setText("+")
        else
            maximumState[pId] = true
            processX[pId] = processes[pId]:getX()
            processY[pId] = processes[pId]:getY()
            processW[pId] = processes[pId]:getWidth()
            processH[pId] = processes[pId]:getHeight()
            processes[pId]:setSize(51, 18):setPosition(1, 1)
            :setMovable(false)
            resizeBtn[pId]:hide()
            msgBoxMaximumBtn:setText("#")
        end
        
    end)

    table.insert(processes, pId, programWindow)
    table.insert(maximumState, pId, false)

    programWindow:setZIndex(999):setFocus()
    return programWindow
end



function utils.getProcesses()
    return processes
end

function utils.getAllPids()
    return pids
end

function utils.getProcessIsHiddenByIndex(index)
    return isHidden[index]
end

function utils.setProcessIsHiddenByIndex(index, val)
    isHidden[index] = val
end

function utils.getPidByTitle(title)
    for index, value in ipairs(programTitles) do
        if (value == title) then return index end
    end
    return false
end

function utils.getAllTitles() 
    return programTitles
end

function utils.getTitleByPid(pid)
    return programTitles[pid]
end

local defaultSettingsTable = {
    ["openWithoutStartScreens"] = 0,
    ["noErrLogsWhenBSoD"] = 0
}

function utils.readSettings()
    settings = io.open("system/settings/settings.json", "r")
    if settings == nil then 
        settings = io.open("system/settings/settings.json", "w")
        settings:write(textutils.serializeJSON(defaultSettingsTable))
        settings:close()
        settings = io.open("system/settings/settings.json", "r")
    end
    local settingsData = settings:read("a")
    local settingsTable = textutils.unserializeJSON(settingsData)
    settings:close()
    return settingsTable
end

function utils.closeProgram(pid)
    processes[pid]:remove()
    processes[pid] = ""
    programList:removeItem(utils.getProgramListIndexByTitle(utils.getTitleByPid(pid)))
    programTitles[pid] = ""
    isHidden[pid] = ""
    pids[pid] = ""
end

function utils.split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end
  

return utils