--functions
iniRenderFunc = nil
detectClickFunc = nil
inputLetterFunc = nil
detectKeyFunc = nil

--vars
local objAreaMinX = {}
local objAreaMaxX = {}
local objAreaY = {}
local objActFunc = {}
local objType = {}
local objMaxWidth = {}
local isEnable = {}
local strList = {}
local isSelected = {}
clickFlag = 0
quitFlag = false;

local haveSpeaker = false
local PaletteUITest = ""


local speaker = peripheral.find("speaker")
if speaker ~= nil then
    haveSpeaker = true
end

---Create a normal text with color
---@param x number
---@param y number
---@param str string
---@param color any
function showNormalText(x, y, str, color)
    if color == nil then color = colors.black end
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(color)
    term.setCursorPos(x, y)
    term.write(str)

end

---Create a button runs the function when pressed
---@param x number
---@param y number
---@param str string
---@param actFunc function
function showButton(x, y, str, actFunc)
    term.setBackgroundColor(colors.lime)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write(str)

    objAreaMinX[#objAreaMinX + 1] = x
    objAreaMaxX[#objAreaMaxX + 1] = x + string.len(str)
    objAreaY[#objAreaY + 1] = y
    objActFunc[#objActFunc + 1] = actFunc
    objType[#objType + 1] = "B"
    objMaxWidth[#objMaxWidth + 1] = #str
    isEnable[#isEnable + 1] = true
    strList[#strList + 1] = str
    
    term.setBackgroundColor(colors.lightGray)
end

local function showPressedButton(x, y, str)
    if x == nil or y == nil then return end
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write(str)
    

    sleep(0.15)
    term.setBackgroundColor(colors.lime)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write(str)
    term.setBackgroundColor(colors.lightGray)
end

---Create A Selectable Text
---@param x number
---@param y number
---@param str string
function showSelectableText(x, y, str)
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.setCursorPos(x, y)
    term.write(str)

    objAreaMinX[#objAreaMinX + 1] = x
    objAreaMaxX[#objAreaMaxX + 1] = x + string.len(str)
    objAreaY[#objAreaY + 1] = y
    objActFunc[#objActFunc + 1] = nil
    objType[#objType + 1] = "S"
    objMaxWidth[#objMaxWidth + 1] = #str
    isEnable[#isEnable + 1] = true
    strList[#strList + 1] = str
end

local function showSelectedText(x, y, str)
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write(str)
    
    term.setBackgroundColor(colors.lightGray)
end

local function showDisabledButton(x, y, str)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write(str)
    
    term.setBackgroundColor(colors.lightGray)
end

local function showEnableButton(x, y, str)
    term.setBackgroundColor(colors.lime)
    term.setTextColor(colors.white)
    term.setCursorPos(x, y)
    term.write(str)
    
    term.setBackgroundColor(colors.lightGray)
end 

local function showDisabledField(x, y, i)
    local t = ""
    for i=0, objMaxWidth[i] do
        t = t .. " "
    end
    term.setBackgroundColor(colors.lightGray)
    
    term.setTextColor(colors.gray)
    term.setCursorPos(x, y)
    term.write(t)
    term.setCursorPos(x, y)
    term.write(objActFunc[i](true))
    
    term.setBackgroundColor(colors.lightGray)
end

local function showEnableField(x, y, i)
    local t = ""
    for i=0, objMaxWidth[i] do
        t = t .. " "
    end
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(x, y)
    term.write(t)
    term.setCursorPos(x, y)
    term.write(objActFunc[i](true))

    term.setBackgroundColor(colors.lightGray)
end

---Disable an object
---@param x number
---@param y number
function disableObj(x, y)
    local objId
    for i, val in ipairs(objAreaY) do
        if val == y then
            if objAreaMinX[i] == x then
                objId = i
                break
            end
        end
    end

    if objId ~= nil then
        if objType[objId] == "B" then
            showDisabledButton(x, y, strList[objId])
        elseif objType[objId] == "F" then
            showDisabledField(x, y, objId)
        end
        
        isEnable[objId] = false
    end
end

---Get an object's status
---@param byStr boolean
---@param x number
---@param y number
---@return boolean
function getObjStatus(byStr, x, y)
    local objId
    if byStr == nil or byStr == false then
        for i, val in ipairs(objAreaY) do
            if val == y then
                if objAreaMinX[i] == x then
                    objId = i
                    break
                end
            end
        end
    
        
    else
        for i, val in ipairs(strList) do
            if val == x then
                objId = i
                break
            end
        end
    end
    
    if objId ~= nil then
        if objType[objId] == "S" or objType[objId] == "G" then
            return isSelected[objId]
        else
            return isEnable[objId]
        end
        
    end
end

---Enable an object
---@param x number
---@param y number
function enableObj(x, y)
    local objId
    for i, val in ipairs(objAreaY) do
        if val == y then
            if objAreaMinX[i] == x then
                objId = i
                break
            end
        end
    end

    if objId ~= nil then
        if objType[objId] == "B" then
            showEnableButton(x, y, strList[objId])
        elseif objType[objId] == "F" then
            showEnableField(x, y, objId)
        end
        
        isEnable[objId] = true
    end
end

---Create a single-selectable text
---@param x number
---@param y number
---@param str string
function showSingleSelectableText(x, y, str)
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.setCursorPos(x, y)
    term.write(str)

    objAreaMinX[#objAreaMinX + 1] = x
    objAreaMaxX[#objAreaMaxX + 1] = x + string.len(str)
    objAreaY[#objAreaY + 1] = y
    objActFunc[#objActFunc + 1] = nil
    objType[#objType + 1] = "G"
    objMaxWidth[#objMaxWidth + 1] = #str
    isEnable[#isEnable + 1] = true
    strList[#strList + 1] = str

    term.setBackgroundColor(colors.lightGray)
end

local function createTextField(x, y, str, ini, w, actFunc, i)
    if ini == nil then
        ini = false
    end
    
    local maxLetter

    if str == nil then str = "" end

    if i == nil then maxLetter = 20
    else maxLetter = objMaxWidth[i] end

    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(x, y)
    if ini == true then
        local t = ""
        for i1=1, w do
            t = t .. " "
        end

        objAreaMinX[#objAreaMinX + 1] = x
        objAreaMaxX[#objAreaMaxX + 1] = x + w
        objAreaY[#objAreaY + 1] = y
        objActFunc[#objActFunc + 1] = actFunc
        objType[#objType + 1] = "F"
        objMaxWidth[#objMaxWidth + 1] = w - 1
        isEnable[#isEnable + 1] = true
        strList[#strList + 1] = str
        

        term.write(t)
        return
    end

    if maxLetter ~= nil and string.len(str) <= maxLetter and ini == false then
        term.write(str)
    end

    term.setBackgroundColor(colors.lightGray)

end

---Create a textfield
---@param x number
---@param y number
---@param w number
---@param actFunc function
function showTextField(x, y, w, actFunc)
    createTextField(x, y, "", true, w, actFunc, nil)
end

---Get Selected Text (Single-Selectable Text)
---@return string
function getSelectedText()
    for i, v in ipairs(strList) do
        if objType[i] == "G" and getObjStatus(true, strList[i]) then
            return strList[i]
        end
    end
end

---Reset current selecting single-selectable text
function resetSelectedText()
    for i, v in ipairs(objAreaMinX) do
        if objType[i] == "G" and getObjStatus(true, strList[i]) then
            isSelected[i] = false
            showSelectableText(objAreaMinX[i], objAreaY[i], strList[i])
        end
    end
end

---Delete an object, if "byStr" is true, the x is the obj string
---@param byStr boolean
---@param x any
---@param y number
function deleteObj(byStr, x, y)
    local objId
    if byStr == nil or byStr == false then
        for i, val in ipairs(objAreaY) do
            if val == y then
                if objAreaMinX[i] == x then
                    objId = i
                    break
                end
            end
        end
    
        
    else
        for i, val in ipairs(strList) do
            if val == x then
                objId = i
                break
            end
        end
    end
    
    if objId ~= nil then
        local t = ""
        for i = 0, objMaxWidth[objId] do
            t = t .. " "
        end
        showNormalText(objAreaMinX[objId], objAreaY[objId], t)
        objAreaMaxX[objId], objAreaMinX[objId], objAreaY[objId], objActFunc[objId], objType[objId], objMaxWidth[objId], isEnable[objId], isSelected[objId], strList[objId] = 
        nil, nil, nil, nil, nil, nil, nil, nil, nil
        
    end
end

---Delete all object
function deleteAllObj()
    objAreaMaxX, objAreaMinX, objAreaY, objActFunc, objType, objMaxWidth, isEnable, isSelected, strList = 
    {}, {}, {}, {}, {}, {}, {}, {}, {}
end

local previousX
local previousY
local previousStrLen

---Show alert
---@param x number
---@param y number
---@param str string
function showAlert(x, y, str)
    
    local t = ""
    if previousX == nil or previousY == nil or previousStrLen == nil then
        for i = 1, #str do
            t = t .. " "
        end
        showNormalText(x, y, t)
    elseif not (previousX == nil and previousY == nil and previousStrLen == nil) then
        for i = 1, previousStrLen do
            t = t .. " "
        end
        showNormalText(previousX, previousY, t)
    end
    
    previousX = x
    previousY = y
    previousStrLen = #str
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.red)
    term.setCursorPos(x, y)
    term.write(str)
    if haveSpeaker then
        speaker.playSound("block.note_block.didgeridoo")
    end
end

---Show remind
---@param x number
---@param y number
---@param str string
function showReminder(x, y, str)
    local t = ""
    if previousX == nil or previousY == nil or previousStrLen == nil then
        for i = 1, #str do
            t = t .. " "
        end
        showNormalText(x, y, t)
    elseif not (previousX == nil and previousY == nil and previousStrLen == nil) then
        for i = 1, previousStrLen do
            t = t .. " "
        end
        showNormalText(previousX, previousY, t)
    end
    
    previousX = x
    previousY = y
    previousStrLen = #str
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.green)
    term.setCursorPos(x, y)
    term.write(str)
    if haveSpeaker then
        speaker.playSound("block.note_block.cow_bell")
    end
end

---Clear the screen
function clearsc()
    term.setBackgroundColor(colors.lightGray)
    term.clear()
end



local function actTest(readFlag, val)
    if readFlag then return PaletteUITest
    else PaletteUITest = val end
end

local function testBtn()
    showReminder(22, 7, "Clicked!")
    if getObjStatus(false, 19, 6) then
        disableObj(19, 6)
    else
        enableObj(19, 6)
    end
end

local function showFieldCont()
    if PaletteUITest == "" then
        showReminder(13, 7, "You doesn't wrote anything!")
    else
        showReminder(10, 7, "You wrote: " .. PaletteUITest)
    end
    
end

local function testDisableOrNotBtn()
    showReminder(22, 7, "Enabled!")
end

local function switchDisableBtn()
    if getObjStatus(true, "[Just A Button]") then
        disableObj(28, 10)
    else
        enableObj(28, 10)
    end
    
end

local function amISelectedBtn()
    if getObjStatus(true, "Select Me!") then
        showReminder(21, 7, "Selected!")
    else
        showReminder(19, 7, "Not Selected!")
    end
end

local function renderMain()
    showNormalText(20, 1, "Hello World!")
    showNormalText(13, 2, "--------------------------")
    showNormalText(11, 3, "This is a test Palette UI app!")
    showNormalText(9, 4, "Thank you for choosing Palette UI!")
    showNormalText(13, 6, "field:")
    showTextField(19, 6, "", true, 20, actTest, nil)
    showButton(12, 8, "[Switch Field]", testBtn)
    showButton(28, 8, "[WHAT I WROTE]", showFieldCont)

    showButton(14, 10, "[Switch Btn]", switchDisableBtn)
    showButton(28, 10, "[Just A Button]", testDisableOrNotBtn)
    showButton(11, 12, "[Am I Selected]", amISelectedBtn)
    showSelectableText(21, 14, "Select Me!")
end



local function detectClick()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            for i = 1, #objAreaMaxX do

                if isEnable[i] == nil then return end

                if clickFlag == i then
                    if objType[i] == "F" then
                        if objActFunc[i](true) == nil and isEnable[i] then
                            createTextField(objAreaMinX[i], objAreaY[i], " ", false, 0, nil, i)
                        else
                            createTextField(objAreaMinX[i] + string.len(objActFunc[i](true)), objAreaY[i], " ", false, 0, nil, i)
                        end
                        
                    end
                    
                    
                end
                
                if x >= objAreaMinX[i] and x <= objAreaMaxX[i] and y == objAreaY[i] and isEnable[i] then
                    if objType[i] == "F" then
                        if objActFunc[i](true) ~= nil then
                            createTextField(objAreaMinX[i] + string.len(objActFunc[i](true)), objAreaY[i], "_", false, 0, nil, i)
                        else
                            createTextField(objAreaMinX[i], objAreaY[i], "_", false, 0, nil, i)
                        end
                        
                    elseif objType[i] == "B" then
                        showPressedButton(objAreaMinX[i], objAreaY[i], strList[i])
                        objActFunc[i]()
                        if haveSpeaker then
                            speaker.playSound("ui.button.click")
                        end
                    elseif objType[i] == "S" or objType[i] == "G" then

                        if isSelected[i] == nil or isSelected[i] == false then
                            if objType[i] == "G" then
                                for index, value in ipairs(objAreaMinX) do
                                    if objType[index] == "G" then
                                        showNormalText(objAreaMinX[index], objAreaY[index], strList[index])
                                        isSelected[index] = false
                                        isSelected[i] = true
                                    end
                                    
                                end
                            end
                            showSelectedText(objAreaMinX[i], objAreaY[i], strList[i])
                            isSelected[i] = true
                        else
                            showNormalText(objAreaMinX[i], objAreaY[i], strList[i])
                            isSelected[i] = false
                        end

                        if haveSpeaker then
                            speaker.playSound("block.note_block.hat")
                        end
                    end
                    clickFlag = i
                end

                
            end
        end
    end
end

local function inputLetter(str, key)

    if str == nil then
        str = ""
    end
    
    local keyName = keys.getName(key)
    
    if keyName == "backspace" and string.len(str) > 0 then
        return string.sub(str, 1, string.len(str) - 1)
    end
    
    


    local event, ch = os.pullEvent("char")

    if ch ~= nil then
        return str .. ch
    end
    
    
end






local function detectKey()
    while true do
        local event, key, _ = os.pullEvent("key")

        for i = 1, #objActFunc do
            
            if clickFlag == i and isEnable[i] then
                if objType[i] == "F" then
                    local charT = inputLetter(objActFunc[i](true), key)
                    if charT ~= nil and string.len(charT) <= objMaxWidth[i] then
                        objActFunc[i](false, charT)
                    end
                    
                    if objActFunc[i](true) == nil then
                        
                        createTextField(objAreaMinX[i], objAreaY[i], string.format("%s_ ", ""), false, 0, nil, i)
                    else
                        
                        createTextField(objAreaMinX[i], objAreaY[i], string.format("%s_ ", objActFunc[i](true)), false, 0, nil, i)
                    end
                end
                
            end
        end
    end
end

iniRenderFunc = renderMain
detectClickFunc = detectClick
inputLetterFunc = inputLetter
detectKeyFunc = detectKey



--main
function main()
    clearsc()
    term.setPaletteColor(colors.lightGray, 0xe0e0e0)
    term.setPaletteColor(colors.gray, 0x808080)
    iniRenderFunc()
    while true do
        if quitFlag == true then break end
        parallel.waitForAny(detectClickFunc, detectKeyFunc)
    end

    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.setPaletteColor(colors.lightGray, 0x999999)
    term.setPaletteColor(colors.gray, 0x4c4c4c)
end

