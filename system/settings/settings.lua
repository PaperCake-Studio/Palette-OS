require("/system/paletteUI_api")
require("/system/apis/base64")

local page = 1
local speaker = peripheral.find("speaker")

local function changePage(tpage)
    deleteAllObj()
    page = tpage
    renderSettingsPage()
end

function mainPage()
    changePage(1)
end


local fullName
local username
local passwd

local usernameChange = ""
local passwdChange = ""
local fullnameChange = ""
local oldPasswdWrote = ""

local themeStr
local bgColor

function profilePage()
    changePage(2)
end

function themePage()
    changePage(4)
end

function changeProfileBtn()
    if page == 2 then
        changePage(3)
    elseif page == 3 then
        changePage(2)
    end
    
end

local salt

function calcPassword(password)
    salt = generateSalt(6)
    local temp = password .. salt
    return encodeBase64(temp)
end

function verifyPassword(password, s)
    local temp = password .. s
    return encodeBase64(temp)
end

function applyChangesBtn()
    if oldPasswdWrote == "" then
        showAlert(23, 16, "Field is empty!")
        if speaker ~= nil then
            speaker.playSound("block.note_block.didgeridoo")
        end
        return
    end

    local f = io.open("/system/settings/user.data", "r")
    local n = f:read()
    local fu = f:read()
    local oldPass = f:read()
    local oldSalt = f:read()
    f:close()

    if verifyPassword(oldPasswdWrote, salt) == passwd then
        if string.gsub(usernameChange, " ", "") == "" then
            usernameChange = username
        end
        if string.gsub(fullnameChange, " ", "") == "" then
            fullnameChange = fullName
        end
        if string.gsub(passwdChange, " ", "") == "" then
            passwdChange = passwd
        end

        local file = io.open("system/settings/user.data", "w")
        file:write(usernameChange .. "\n" .. fullnameChange .. "\n" .. calcPassword(passwdChange) .. "\n" .. salt)
        file:close()
        showReminder(27, 16, "Changed!")
        if speaker ~= nil then
            speaker.playSound("block.note_block.cow_bell")
        end
    else
        showAlert(23, 16, "Wrong Password!")
        if speaker ~= nil then
            speaker.playSound("block.note_block.didgeridoo")
        end
    end
end



function newUsernameAct(flag, val)
    if flag then return usernameChange
    else usernameChange = val end
end

function newPasswdAct(flag, val)
    if flag then return passwdChange
    else passwdChange = val end
end

function oldPasswdAct(flag, val)
    if flag then return oldPasswdWrote
    else oldPasswdWrote = val end
end

function newFullnameAct(flag, val)
    if flag then return fullnameChange
    else fullnameChange = val end
end


function lightGrayTheme() 
    writeThemeConfig("lightGray")
end

function lightBlueTheme()
    writeThemeConfig("lightBlue")
end

function pinkTheme()
    writeThemeConfig("pink")
end

function writeThemeConfig(str)
    local file = io.open("system/settings/theme.data", "w")
    file:write(str)
    file:close()
    local file2 = io.open("system/settings/.setupdone", "w")
    file2:write("Nothing here")
    file2:close()
    showReminder(24, 3, "Chosen! Reboot to apply all!")
    sleep(0.75)
    clearsc()
    deleteAllObj()
    fetchTheme()
    initialize(renderSettingsPage, bgColor)
end

local function getCurrentTheme() 
    if bgColor == colors.lightGray then return "Classic" end
    if bgColor == colors.lightBlue then return "Aqua" end
    if bgColor == colors.pink then return "Pinky" end
end

function renderSettingsPage()
    deleteAllObj()
    clearsc()
    local userData = io.open("system/settings/user.data", "r")
    username = userData:read()
    fullName = userData:read()
    passwd = userData:read()
    salt = userData:read()

    showNormalText(1, 1, "PaletteOS|")
    showNormalText(12, 1, "Settings - PaletteOS 23.02/01")
    showNormalText(1, 2, "---------+------------------------------------------")
    for i = 3, 20 do
        if i % 2 == 0 then
            showNormalText(10, i, "*")
            showNormalText(1, i, "---------")
        else
            showNormalText(10, i, "|")
        end
        
    end
    showButton(1, 3, "[Overall]", mainPage)
    showButton(1, 5, "[Profile]", profilePage)
    showButton(1, 7, "[ Theme ]", themePage)
    
    if page == 1 then
        --overall page
        
        disableObj(1, 3)
        showNormalText(14, 4, "PaletteOS Version:")
        showNormalText(14, 5, "PaletteOS 23.02/01 Nickel")

        showNormalText(14, 8, "PaletteOS is given to:")
        showNormalText(14, 9, username .. " @")
        showNormalText(14, 10, fullName)
        showNormalText(14, 13, "Developer:")
        showNormalText(14, 14, "BlueStarrySky")
        showNormalText(14, 15, "- PaletteOS & PaletteUI")

        showNormalText(14, 18, "PaletteOS 23.02/01 Made with Love")
    elseif page == 2 then
        disableObj(1, 5)
        showNormalText(14, 4, "Profile Details:")
        showNormalText(14, 6, username .. " @ ")
        showNormalText(14, 7, fullName)
        showButton(41, 14, "[Change]", changeProfileBtn)
        showButton(42, 15, "[Apply]", applyChangesBtn)
        disableObj(42, 15)

    elseif page == 3 then
        disableObj(1, 5)
        showNormalText(14, 4, "Profile Details:")
        showNormalText(18, 6, "Fullname:")
        showTextField(27, 6, 22, newFullnameAct)
        showNormalText(18, 8, "Username:")
        showTextField(27, 8, 22, newUsernameAct)
        showNormalText(14, 10, "Old Password:")
        showTextField(27, 10, 22, oldPasswdAct)
        showNormalText(14, 12, "New Password:")
        showTextField(27, 12, 22, newPasswdAct)
        showButton(41, 14, "[Cancel]", changeProfileBtn)
        showButton(42, 15, "[Apply]", applyChangesBtn)
    elseif page == 4 then
        disableObj(1, 7)
        showNormalText(14, 4, "Current Theme:")
        showNormalText(14, 5, getCurrentTheme(), colors.blue)
        showNormalText(14, 7, "---------", nil, colors.lightGray)
        showNormalText(14, 8, " Classic ", nil, colors.lightGray)
        showNormalText(14, 9, "---------", nil, colors.lightGray)
        showNormalText(14, 11, "---------", nil, colors.lightBlue)
        showNormalText(14, 12, "  Aqua   ", nil, colors.lightBlue)
        showNormalText(14, 13, "---------", nil, colors.lightBlue)
        showNormalText(14, 15, "---------", nil, colors.pink)
        showNormalText(14, 16, "  Pinky  ", nil, colors.pink)
        showNormalText(14, 17, "---------", nil, colors.pink)

        showButton(25, 9, "[Choose]", lightGrayTheme)
        showButton(25, 13, "[Choose]", lightBlueTheme)
        showButton(25, 17, "[Choose]", pinkTheme)

        if themeStr == "lightGray" then
            showButton(25, 9, "[Chosen]", lightGrayTheme)
            disableObj(25, 9)
        end
        if themeStr == "lightBlue" then
            showButton(25, 13, "[Chosen]", lightGrayTheme)
            disableObj(25, 13)
        end
        if themeStr == "pink" then
            showButton(25, 17, "[Chosen]", lightGrayTheme)
            disableObj(25, 17)
        end
    end
end




function fetchTheme()
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

local currTheme

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
end

fetchTheme()
initialize(renderSettingsPage, bgColor)