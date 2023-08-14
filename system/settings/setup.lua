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
        local file2 = io.open("system/settings/.setupdone", "w")
        file2:write("Nothing here")
        file2:close()
        showReminder(22, 17, "Created!")
        enableObj(31, 16)
    end
end

function finishBtn()
    shell.run("system/systemUI.lua")
end



function fullNameAct(flag, val)
    if flag then return fullname
    else fullname = val end
end

function renderMainSetup()
    showNormalText(10, 1, "PaletteOS 23.01/01 Silicon Setup")
    showNormalText(1, 2, "----------------------------------------------------")
    showNormalText(7, 4, "Welcome to PaletteOS 23.01/01 Silicon, ")
    showNormalText(7, 5, "Follow the steps below to start using.")
    showNormalText(19, 7, "Create a user:")
    showNormalText(10, 9, "Fullname:")
    showTextField(19, 9, "", true, 22, fullNameAct, nil)
    showNormalText(10, 11, "Username:")
    showTextField(19, 11, "", true, 22, usernameAct, nil)
    showNormalText(10, 13, "Password:")
    showTextField(19, 13, "", true, 22, passwdAct, nil)
    showButton(33, 15, "[Create]", createUserBtn)
    showButton(31, 16, "[Finished]", finishBtn)
    disableObj(31, 16)
end

iniRenderFunc = renderMainSetup
main()
