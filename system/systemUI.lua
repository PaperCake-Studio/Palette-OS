require("paletteUI_api")
require("/system/apis/base64")

local passwdWrote
local shortFileName = {}
local fileName = {}
local bgColor


local function showMessage(isAlert, str)
    if isAlert then
        showAlert(51 - #tostring(str), 3, tostring(str))
     else
        showReminder(51 - #tostring(str), 3, tostring(str))
    end 
    sleep(1)
    showNormalText(1, 3, "                                                    ")
 end

function reboot()
    showMessage(false, "Rebooting...")
    sleep(0.5)
    os.reboot()
end

function shutdown()
    showMessage(false, "Shuting Down...")
    sleep(0.5)
    os.shutdown()
end

function runApp()
    
    if getSelectedText() ~= nil then
        for i, v in ipairs(shortFileName) do
            if v == getSelectedText() then
                if i == 1 then
                    shell.run("fg system/explorer.lua")
                elseif i == 2 then
                    shell.run("fg system/settings/settings.lua")
                elseif i == 3 then
                    shell.run("fg shell")
                else
                    shell.run("fg desktop/" .. fileName[i] .. ".lua")
                end
                multishell.setTitle(multishell.getCurrent(), "PaletteOS")
                break
            end
        end
        
    
        
    else
        showMessage(true, "Not Selected!")
    end
    
end

function logoffBtn()
    passwdWrote = ""
    showMessage(false, "Logging off...")
    sleep(0.2)
    renderLogin()
end



function refresh()
    deleteAllObj()
    renderMain()
end


function userLogin(readFlag, val)
    if readFlag then return passwdWrote
    else passwdWrote = val end
end

local function switchPage()
    deleteAllObj()

end

function renderMain()
    
    switchPage()
    clearsc()
    showNormalText(1, 1, "PaletteOS", colors.blue)
    showNormalText(10, 1, "|")
    showButton(12, 1, "[Power]", shutdown)
    showButton(20, 1, "[Reboot]", reboot)
    showButton(29, 1, "[Run]", runApp)
    showButton(35, 1, "[Flush]", refresh)
    showButton(43, 1, "[Logoff]", logoffBtn)
    showNormalText(1, 2, "---------+------------------------------------------")

    local list = fs.find("desktop/*.lua")
    local num = #list
    local j = 10
    local k = 2
    resetSelectedText()
    shortFileName = {}
    fileName = {}

    showSingleSelectableText(2, 4, "Explorer")
    table.insert(shortFileName, "Explorer")
    table.insert(fileName, "explorer")
    
    showSingleSelectableText(2, 6, "Settings")
    table.insert(shortFileName, "Settings")
    table.insert(fileName, "settings")

    showSingleSelectableText(2, 8, "DOS Shell")
    table.insert(shortFileName, "DOS Shell")
    table.insert(fileName, "multishell")


    for i = 1, 21 do
        
        if j > 16 then
            j = 4
            k = k + 17
        end
        if list[i] == nil then
            break
        end
        w = string.sub(string.sub(list[i], 9), 1, string.len(string.sub(list[i], 9)) - 4)
        showNormalText(k, j, "                ")

        if string.len(w) > 14 then
            showSingleSelectableText(k, j, string.sub(w, 1, 13) .. "..." .. "")
            table.insert(shortFileName, string.sub(w, 1, 13) .. "...")
            table.insert(fileName, w)
        else
            showSingleSelectableText(k, j, w)
            table.insert(shortFileName, w)
            table.insert(fileName, w)
        end 
            
        w = nil
        j = j + 2
    end
        
        
    
end

local passwd 
local salt

function calcPassword(password, s)
    local temp = password .. s
    return encodeBase64(temp)
end

function loginBtn()
    if passwdWrote == nil or passwdWrote == "" then 
        showAlert(18, 13, "Empty Password!") 
        return
    end
    if calcPassword(passwdWrote, salt) == passwd then
        showReminder(22, 13, "Welcome!")
        sleep(0.5)
        renderMain()
    else
        showAlert(18, 13, "Wrong Password!")
    end
end


function renderLogin()
    switchPage()
    clearsc(bgColor)
    showCenteredText(2, "User Login")
    showCenteredText(4, "Palette OS 23.02/01")
    local nameF = io.open("system/settings/user.data", "r")
    if nameF ~= nil then
        local username = nameF:read()
        local fullname = nameF:read()
        passwd = nameF:read()
        salt = nameF:read()
        nameF:close()
        if username == "" or username == nil or passwd == "" or passwd == nil or fullname == "" or fullname == nil then
            shell.run("system/settings/setup.lua")
        end
        showCenteredText(7, username .. " @ " .. fullname)
        showTextField(15, 9, 22, userLogin)
        showButton(30, 11, "[Login]", loginBtn)
    else
        shell.run("system/settings/setup.lua")
    end
end




local setupdone = io.open("system/settings/.setupdone", "r")
local nameF = io.open("system/settings/user.data", "r")
if setupdone == nil or nameF == nil then
    shell.run("system/settings/setup.lua")
end
if setupdone ~= nil then setupdone:close() end
if nameF ~= nil then nameF:close() end


local themeR = io.open("system/settings/theme.data", "r")
if themeR == nil then
    local themeNew = io.open("system/settings/theme.data", "w")
    themeNew:write("lightGray")
    themeNew:close()
end
if themeR ~= nil then themeR:close() end



local themeF = io.open("system/settings/theme.data", "r")
local themeStr = themeF:read()
themeF:close()


if themeStr ~= nil then
    if themeStr == "lightGray" then
        bgColor = colors.lightGray
    end
    if themeStr == "lightBlue" then
        bgColor = colors.lightBlue
    end
    if themeStr == "pink" then
        bgColor = colors.pink
    end
end
initialize(renderLogin, bgColor)
while true do
    multishell.setTitle(multishell.getCurrent(), "PaletteOS")
end