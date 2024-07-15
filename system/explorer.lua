local basalt = require("basalt")

local main = basalt.createFrame():setBackground(colors.lightGray)

local fileList = main:addList():setPosition(1, 3):setSize("parent.w", "parent.h"):setScrollable(true)

local contextMenu = main:addFrame()
:setSize(10, 3)
:setBackground(colors.lightGray)
:setForeground(colors.white)
:setZIndex(999)
:hide()
contextMenu:onLoseFocus(function ()
    contextMenu:hide()
end)

fileList:onClick(function (self, event, btn, x, y)
    if btn == 2 then
        contextMenu:setPosition(x, y):show()
    end
    if btn == 1 then
        contextMenu:hide()
        fileList:setFocus()
    end
end)

local function refreshList(path) 
    fileList:clear()
    local files = fs.list(path)
    local dirs = {}
    local normalFiles = {}
    for index, value in ipairs(files) do
        if fs.isDir("/" .. fs.combine(path, value)) then
            table.insert(dirs, value .. "/")
        else
            table.insert(normalFiles, value)
        end
    end

    for index, value in ipairs(dirs) do
        fileList:addItem(value, colors.blue, colors.white)
    end

    for index, value in ipairs(normalFiles) do
        fileList:addItem(value, colors.gray, colors.white)
    end
end 


local currentSelectedIndex = 0
local currentPath = "/"
local prevPath = nil
local forwardPath = nil

local dirPathField

local dirPathLabel = main:addLabel():setPosition(1, 1):setSize("parent.w", 1):setForeground(colors.lightGray):setBackground(colors.transparent):setZIndex(999):setText("/")

local prevDirBtn = main:addButton():setPosition(1, 2):setSize(1, 1):setBackground(colors.cyan):setForeground(colors.white):setText("<")

local forwardDirBtn = main:addButton():setPosition(3, 2):setSize(1, 1):setBackground(colors.cyan):setForeground(colors.white):setText(">")

local refreshBtn = main:addButton():setPosition(5, 2):setSize(7, 1):setBackground(colors.cyan):setForeground(colors.white):setText("Refresh")

local function enterDir(path)
    currentPath = path
    if fs.getDir(currentPath) == "" then
        prevPath = "/"
    else
        prevPath = "/" .. fs.getDir(currentPath) .. "/"
    end
    refreshList(currentPath)
    fileList:setFocus()
    dirPathLabel:setText(currentPath)
    if prevPath == nil or currentPath == "/" then
        prevDirBtn:setBackground(colors.gray)
        prevDirBtn:disable()
    else
        prevDirBtn:enable()
        prevDirBtn:setBackground(colors.cyan)
    end
    if dirPathField ~= nil then
        dirPathField:remove()
    end

    if forwardPath == currentPath or forwardPath == nil then
        forwardDirBtn:setBackground(colors.gray)
        forwardDirBtn:disable()
    else
        forwardDirBtn:setBackground(colors.cyan)
        forwardDirBtn:enable()
    end
    
    dirPathField = main:addInput():setPosition(1, 1):setSize("parent.w", 1):setForeground(colors.lightGray):setBackground(colors.gray)
    dirPathField:onGetFocus(function ()
        dirPathLabel:hide()
        dirPathField:setForeground(colors.white)
        :setBackground(colors.lightGray)
    end)
    dirPathField:onLoseFocus(function ()
        dirPathLabel:show()
        dirPathField:setForeground(colors.gray)
        :setBackground(colors.gray)
    end)
    :onKey(function (self, event, key)
        if key ~= keys.enter then return end
        local path = dirPathField:getValue()
        if string.sub(path, 1, 1) ~= "/" then
            path = "/" .. path
        end
        if string.sub(path, #path) ~= "/" then
            path = path .. "/"
        end
        enterDir(path)
    end)
end

local function doAction(filePath, fileName)
    if filePath == "" or fileName == "" then return end
    if string.sub(fileName, #fileName) == "/" then fileName = string.sub(fileName, 1, #fileName - 1) end
    local fileExtension = utils.split(fileName, ".")
    basalt.debug(fileExtension[#fileExtension])
    if fileExtension[#fileExtension] == "lua" then
        utils.startProgram(string.sub(fileName, 1, #fileName - 4), filePath)
        return
    end
    if fileExtension[#fileExtension] == "txt" or fileExtension[#fileExtension+1] == "json" then
        utils.startProgram("Edit", "edit " .. filePath)
        return
    end
    if fileExtension[#fileExtension] == "nfp" then
        utils.startProgram("Paint", "paint " .. filePath)
        return
    end
    utils.createMsgBox("Unknown File Type: " .. fileExtension[#fileExtension], "Info", 2, nil, nil, 7)
end


fileList:onClickUp(function (self, event, button, x, y)
    if button ~= 1 then return end
    if currentSelectedIndex ~= fileList:getItemIndex() then
        currentSelectedIndex = fileList:getItemIndex()
        return
    end
    if currentSelectedIndex == fileList:getItemIndex() then
        if fs.isDir("/" .. fs.combine(currentPath, fileList:getItem(currentSelectedIndex).text)) then
            enterDir("/" .. fs.combine(currentPath, fileList:getItem(currentSelectedIndex).text) .. "/")
        else
            doAction("/" .. fs.combine(currentPath, fileList:getItem(currentSelectedIndex).text) .. "/", fileList:getItem(currentSelectedIndex).text)
        end
        currentSelectedIndex = 0
    end
    
end)


prevDirBtn:onClick(function (self, event, button, x, y)
    if button == 1 then
        prevDirBtn:setBackground(colors.blue)
    end
end)
prevDirBtn:onClickUp(function (self, event, button, x, y)
    if button == 1 then
        prevDirBtn:setBackground(colors.cyan)
    end
    forwardPath = currentPath
    enterDir(prevPath)
end)

forwardDirBtn:onClick(function (self, event, button, x, y)
    if button == 1 then
        forwardDirBtn:setBackground(colors.blue)
    end
end)
forwardDirBtn:onClickUp(function (self, event, button, x, y)
    if button == 1 then
        forwardDirBtn:setBackground(colors.cyan)
    end
    enterDir(forwardPath)
end)

refreshBtn:onClick(function (self, event, button, x, y)
    if button == 1 then
        refreshBtn:setBackground(colors.blue)
    end
end)
refreshBtn:onClickUp(function (self, event, button, x, y)
    if button == 1 then
        refreshBtn:setBackground(colors.cyan)
    end
    refreshList(currentPath)
end)


local contextRefreshBtn = contextMenu:addButton():setPosition(1, 1):setSize("parent.w", 1):setText("Refresh"):setForeground(colors.white):setBackground(colors.lightGray)
:setHorizontalAlign("left")
contextRefreshBtn:onClick(function (self, event, btn, x, y)
    if btn == 1 then
        contextRefreshBtn:setBackground(colors.black)
    end
    
end)
contextRefreshBtn:onRelease(function (self, event, btn, x, y)
    if btn ~= 1 then return end
    contextRefreshBtn:setBackground(colors.lightGray)
    refreshList(currentPath)
    contextMenu:hide()
end)


local contextEditBtn = contextMenu:addButton():setPosition(1, 2):setSize("parent.w", 1):setText("Edit"):setForeground(colors.white):setBackground(colors.lightGray)
:setHorizontalAlign("left")
contextEditBtn:onClick(function (self, event, btn, x, y)
    if btn == 1 then
        contextEditBtn:setBackground(colors.black)
    end
    
end)
contextEditBtn:onRelease(function (self, event, btn, x, y)
    if btn ~= 1 then return end
    contextEditBtn:setBackground(colors.lightGray)
    contextMenu:hide()
    if "/" .. fs.combine(currentPath, fileList:getItem(currentSelectedIndex).text) .. "/" ~= "" then
        utils.startProgram("Edit", "edit " .. "/" .. fs.combine(currentPath, fileList:getItem(currentSelectedIndex).text) .. "/")
    end
end)


local contextAboutBtn = contextMenu:addButton():setPosition(1, "parent.h"):setSize("parent.w", 1):setText("About"):setForeground(colors.white):setBackground(colors.lightGray)
:setHorizontalAlign("left")
contextAboutBtn:onClick(function (self, event, btn, x, y)
    if btn == 1 then
        contextAboutBtn:setBackground(colors.black)
    end
    
end)
contextAboutBtn:onRelease(function (self, event, btn, x, y)
    if btn ~= 1 then return end
    contextAboutBtn:setBackground(colors.lightGray)
    contextMenu:hide()
    utils.createMsgBox({"Palette Explorer", "Version a1.0", "", "Made by BlueStarrySky233", "Made with Love"}, "About", 2, nil)
end)

enterDir(currentPath)
basalt.autoUpdate()