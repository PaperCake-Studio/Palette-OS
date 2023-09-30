require("/system/paletteUI_api")
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

function profilePage()
    changePage(2)
end

function changeProfileBtn()
    if page == 2 then
        changePage(3)
    elseif page == 3 then
        changePage(2)
    end
    
end

function applyChangesBtn()
    if oldPasswdWrote == "" then
        showAlert(23, 16, "Field is empty!")
        if speaker ~= nil then
            speaker.playSound("block.note_block.didgeridoo")
        end
        return
    end

    if oldPasswdWrote == passwd then
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
        file:write(usernameChange .. "\n" .. passwdChange .. "\n" .. fullnameChange)
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

function renderSettingsPage()
    deleteAllObj()
    clearsc()
    local userData = io.open("system/settings/user.data", "r")
    username = userData:read()
    passwd = userData:read()
    fullName = userData:read()

    showNormalText(1, 1, "PaletteOS|")
    showNormalText(12, 1, "Settings - PaletteOS 23.01/01")
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
    
    if page == 1 then
        --overall page
        
        disableObj(1, 3)
        showNormalText(14, 4, "PaletteOS Version:")
        showNormalText(14, 5, "PaletteOS 23.01/01 Silicon")

        showNormalText(14, 8, "PaletteOS is given to:")
        showNormalText(14, 9, username .. " @")
        showNormalText(14, 10, fullName)
        showNormalText(14, 13, "Developer:")
        showNormalText(14, 14, "BlueStarrySky")
        showNormalText(14, 15, "- PaletteOS & PaletteUI")

        showNormalText(14, 18, "PaletteOS 23.01/01 Made with Love")
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
    end
end

iniRenderFunc = renderSettingsPage

main()