require("/system/paletteUI_api")
local username = ""

function usernameAct(readFlag, val)
    if readFlag then return username
    else username = val end
end

local passwd = ""
local fullname = ""

function passwdAct(readFlag, val)
    if readFlag then return passwd
    else passwd = val end
end

function createUserBtn()
    if username:gsub("%s+", "") == "" or passwd:gsub("%s+", "") == "" then
        showAlert(17, 17, "Don't leave empty!")
    else
        showReminder(20, 17, "Creating...")
        local file = io.open("system/settings/user.data", "w")
        file:write(username .. "\n" .. passwd .. "\n" .. fullname)
        file:close()
        showReminder(22, 17, "Created!")
        enableObj(35, 16)
    end
end

function finishBtn()
    shell.run("system/systemUI.lua")
end

function nextBtn()
    deleteAllObj()
    clearsc()
    renderThemePage()
end

function fullNameAct(flag, val)
    if flag then return fullname
    else fullname = val end
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
    showReminder(22, 17, "Chosen!")
    enableObj(33, 16)
end

function renderMainSetup()
    showNormalText(10, 1, "PaletteOS 23.01/02 Silicon Setup")
    showNormalText(1, 2, "----------------------------------------------------")
    showNormalText(7, 4, "Welcome to PaletteOS 23.01/02 Silicon, ")
    showNormalText(7, 5, "Follow the steps below to start using.")
    showNormalText(19, 7, "Create a user:")
    showNormalText(10, 9, "Fullname:")
    showTextField(19, 9, 22, fullNameAct)
    showNormalText(10, 11, "Username:")
    showTextField(19, 11, 22, usernameAct)
    showNormalText(10, 13, "Password:")
    showTextField(19, 13, 22, passwdAct)
    showButton(33, 15, "[Create]", createUserBtn)
    showButton(35, 16, "[Next]", nextBtn)
    disableObj(35, 16)
end

function renderThemePage() 
    showNormalText(10, 1, "PaletteOS 23.01/02 Silicon Setup")
    showNormalText(1, 2, "----------------------------------------------------")
    showNormalText(7, 4, "Welcome to PaletteOS 23.01/02 Silicon, ")
    showNormalText(7, 5, "Follow the steps below to start using.")
    showNormalText(18, 7, "Choose a theme:")
    showNormalText(12, 9, "---------", nil, colors.lightGray)
    showNormalText(12, 10, "LightGray", nil, colors.lightGray)
    showNormalText(12, 11, "---------", nil, colors.lightGray)
    showNormalText(22, 9, "---------", nil, colors.lightBlue)
    showNormalText(22, 10, "LightBlue", nil, colors.lightBlue)
    showNormalText(22, 11, "---------", nil, colors.lightBlue)
    showNormalText(32, 9, "---------", nil, colors.pink)
    showNormalText(32, 10, "  Pink   ", nil, colors.pink)
    showNormalText(32, 11, "---------", nil, colors.pink)
    showButton(12, 13, "[Choose!]", lightGrayTheme)
    showButton(22, 13, "[Choose!]", lightBlueTheme)
    showButton(32, 13, "[Choose!]", pinkTheme)
    showButton(33, 16, "[Finish]", finishBtn)
    disableObj(33, 16)
end

initialize(renderMainSetup)
