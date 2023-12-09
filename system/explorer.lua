require("paletteUI_api")
local dirName = {}
local fileName = {}
local dirY = {}
local fileY = {}
local dirHistory = {"/"}
local dirHistoryId = 1
local currDir = "/"
local currPage = 1
local totalPage = 1
local speaker
local dirFlag = true
local dirEndPage = 1
local dirShows = 0
local dirNum = 0
local fileNum = 0
local showPage = 1

local creatingFileName
local renamingFileName

speaker = peripheral.find("speaker")


local function refresh(dir, pageNum)
    if dir == nil then dir = "" end
    if pageNum == nil or pageNum == 0 then pageNum = 1 end
    showAll()

    

    if dirName[1] == nil then dirFlag = false end
    local t = 0
    local tY = 5
    totalPage = 0
    if dirFlag == true then 
        for i, v in ipairs(dirName) do
        
            if tY <= 17 then
                if dirName[i] ~= nil then
                    --showNormalText(12, tY, "                                        ")
                    showSingleSelectableText(12, tY, dirName[i])
                    tY = tY + 1
                    dirShows = dirShows + 1

                    
                end
                
                if i == #dirName then
                    dirFlag = false
                    dirEndPage = pageNum
                end
            end
        end
    end
    
    
    for i, v in ipairs(fileName) do
        if dirFlag == true then return end

        local calcId = 0
        if pageNum <= 1 then calcId = i 
        else calcId = i + 13 * (pageNum - 1) - dirShows end

        if fileName[calcId] ~= nil and tY <= 17 then
            --showNormalText(12, tY, "                                        ")
            showSingleSelectableText(12, tY, fileName[calcId])
            tY = tY + 1

            
        end


    end

    totalPage = math.ceil((fileNum + dirNum) / 13)
    showNormalText(12, 18, "Page " .. currPage .. "/" .. totalPage, colors.blue)

    if (currPage - 1) < 1 then disableObj(1, 3) end
    if (currPage + 1) > totalPage then disableObj(4, 3) end

    
end


function creatingFileNameActFunc(f, v)
    if f then return creatingFileName
    else creatingFileName = v end
end

function renamingFileNameActFunc(f, v)
    if f then return renamingFileName
    else renamingFileName = v end
end

function createBtn() 
    deleteAllObj()
    clearsc()
    showCenteredText(4, "Please Enter the name of your file / folder:")
    showTextField(3, 6, 46, creatingFileNameActFunc)
    showSingleSelectableText(19, 8, "File")
    showSingleSelectableText(26, 8, "Folder")
    showButton(41, 10, "[Create]", createBtnInside)
    showButton(32, 10, "[Cancel]", enterExplorer)
end

local currentCopiedFile
local isCopyingFile
local copiedFileName
local isCut = false

function copyBtn()
    if string.sub(getSelectedText(), #getSelectedText()) == "/" then isCopyingFile = false else isCopyingFile = true end
    copiedFileName = getSelectedText()
    currentCopiedFile = currDir .. getSelectedText()
end

function pasteBtn()
    if currentCopiedFile == nil then return end
    local dest
    dest = currDir .. copiedFileName
    if fs.exists(dest) then 
        if isCut then
            local pos = getObjPosByStr(copiedFileName)
            enableObj(pos[1], pos[2])
            return
        end
        showAlert(34, 5, "Destination exists") 
        sleep(0.5)
        refreshBtn()
        return
    elseif fs.isReadOnly(dest) then
        showAlert(28, 5, "Destination is read-only")
        sleep(0.5)
        refreshBtn()
        return
    elseif fs.getFreeSpace(dest) < fs.getSize(copiedFileName) then
        showAlert(46, 5, "Not enough space")
        sleep(0.5)
        refreshBtn()
        return
    end

    fs.copy(currentCopiedFile, dest)
    if isCut then 
        fs.delete(currentCopiedFile) 
        currentCopiedFile = nil
    end
    refreshBtn()
end

function cutBtn()
    if string.sub(getSelectedText(), #getSelectedText()) == "/" then isCopyingFile = false else isCopyingFile = true end
    copiedFileName = getSelectedText()
    currentCopiedFile = currDir .. getSelectedText()
    isCut = true
    local pos = getObjPosByStr(copiedFileName)
    disableObj(pos[1], pos[2])
end


function createBtnInside()
    if getSelectedText() == nil then
        showAlert(12, 12, "You haven't choose the type!")
    else
        if getSelectedText() == "File" then 
            local f = io.open(currDir .. creatingFileName, "w")
            f:close()
        end
        if getSelectedText() == "Folder" then
             shell.run("mkdir " .. creatingFileName) 
        end
        showReminder(22, 12, "Created!")
        sleep(0.5)
        enterExplorer()
        creatingFileName = ""
    end
end

local chosenRenameFile
local isRenamingFolder

function renameBtnInside()
    shell.run("move " .. currDir .. chosenRenameFile .. " " .. currDir .. renamingFileName)
    showReminder(22, 12, "Renamed!")
    sleep(0.5)
    enterExplorer()
    renamingFileName = ""
end


function renameBtn()
    if getSelectedText() == nil then return end
    chosenRenameFile = getSelectedText()
    if string.sub(chosenRenameFile, #chosenRenameFile) == "/" then isRenamingFolder = true end
    deleteAllObj()
    clearsc()
    showCenteredText(4, "Please Enter the name of your chosen file:")
    showTextField(3, 6, 46, renamingFileNameActFunc)
    showButton(41, 8, "[Rename]", renameBtnInside)
    showButton(32, 8, "[Cancel]", enterExplorer)
end

local writtenDir

function dirActFunc(f, v)
    if f then return writtenDir
    else writtenDir = v end
end

function visitPath()
    if fs.isDir(writtenDir) then
        currDir = writtenDir
        renderExplorer(currDir)
        dirFlag = true
        dirShows = 0
        refresh(currDir, 1)
        dirHistoryId = dirHistoryId + 1
        dirHistory[dirHistoryId] = currDir
        if currDir ~= "/" then
            enableObj(7, 3)
        end
    else
        dirActFunc(false, currDir)
        showAlert(38, 5, "Doesn't exists")
        sleep(0.5)
        refreshBtn()
    end
end

function renderExplorer(dir)
    if not (id == nil or id <= totalPage) then return end
    dirName = {}
    fileName = {}
    dirY = {}
    fileY = {}
    totalPage = 1
    fileNum = 0
    dirNum = 0
    resetSelectedText()
    deleteAllObj()
    clearsc()
    showNormalText(1, 1, "PaletteOS| File Explorer")
    showNormalText(1, 2, "---------+------------------------------------------")
    writtenDir = dir
    showTextField(12, 3, 46, dirActFunc)
    showButton(49, 3, "[>]", visitPath)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(12, 3)
    term.write(dir)
    showNormalText(1, 4, "----------------------------------------------------")
    showButton(1, 3, "[^]", pageupBtn)
    showButton(4, 3, "[V]", pagednBtn)
    showButton(7, 3, "[<]", previousDirBtn)
    showButton(1, 5, "[ Copy  ]", copyBtn)
    showButton(1, 6, "[ Cut   ]", cutBtn)
    showButton(1, 7, "[ Paste ]", pasteBtn)
    showButton(1, 8, "[ Enter ]", enterDirBtn)
    showButton(1, 9, "[ Edit  ]", editBtn)
    showButton(1, 10, "[Create ]", createBtn)
    showButton(1, 11, "[Rename ]", renameBtn)
    showButton(1, 12, "[Delete ]", deleteBtn)
    showButton(1, 18, "[Refresh]", refreshBtn)
    --disableObj(1, 3)
    --disableObj(1, 5)
    if dirHistoryId == 1 then
        disableObj(7, 3)
    end
    

    for i = 3, 20 do
        showNormalText(10, i, "|")
    end

    
    
    

end




function refreshBtn()
    enterExplorer()
end

function deleteBtn()
    local v = getSelectedText()
    if v ~= nil then
        shell.run("delete " .. currDir .. v)
        refreshBtn()
    end
end

function pageupBtn()
    if not ((currPage - 1) < 1) then
        currPage = currPage - 1
        renderExplorer(currDir)
        if dirEndPage == currPage then 
            dirFlag = true 
            dirShows = 0
        end
        refresh(currDir, currPage)
    end
    
end

function pagednBtn()
    
    if ((currPage + 1) <= totalPage) then
        currPage = currPage + 1
        if dirEndPage == currPage then 
            dirFlag = true 
            dirShows = 0
        end
        renderExplorer(currDir)
        refresh(currDir, currPage)
    end

end

function enterDirBtn()
    local v = getSelectedText()
    if v == nil then return end
    --print(v)
    if string.sub(v, string.len(v)) == "/" then
        currDir = currDir .. v
        writtenDir = currDir
        renderExplorer(currDir)
        dirFlag = true
        dirShows = 0
        refresh(currDir, 1)
        dirHistoryId = dirHistoryId + 1
        dirHistory[dirHistoryId] = currDir
        if currDir ~= "/" then
            enableObj(7, 3)
        end
    elseif string.sub(v, string.len(v) - 3) == ".lua" then
        shell.run("fg " .. currDir .. v)
    elseif string.sub(v, string.len(v) - 3) == ".nfp" then
        shell.run("fg paint " .. currDir .. v)
    elseif string.sub(v, string.len(v) - 5) == ".dfpwm" then
        shell.run("fg speaker play " .. currDir .. v)
    else
        shell.run("fg edit " .. currDir .. v)
    end
end

function editBtn()
    local v = getSelectedText()
    if v == nil then return end
    --print(v)
    if string.sub(v, string.len(v)) ~= "/"  then
        shell.run("fg edit " .. currDir .. v)
    end
end

function previousDirBtn()
    dirHistoryId = dirHistoryId - 1
    currDir = dirHistory[dirHistoryId]
    writtenDir = currDir
    dirHistory[dirHistoryId + 1] = nil
    renderExplorer(currDir)
    dirFlag = true
    dirShows = 0
    currPage = 1
    refresh(currDir, currPage)
    if currDir == "/" then
        disableObj(7, 3)
    end
end





function showAll()
    local tList = fs.list(currDir, "*")
    local j = 5
    for i, v in ipairs(tList) do
        if fs.isDir(currDir .. v) then
            dirName[#dirName+1] = v .. "/"
            dirY[#dirY+1] = j
            dirNum = dirNum + 1
        else
            fileName[#fileName+1] = v
            fileY[#fileY+1] = j
            fileNum = fileNum + 1
        end
        --showSingleSelectableText(12, j, v)
        j = j + 1
    end
end


function enterExplorer()
    dirFlag = true
    dirShows = 0
    renderExplorer(currDir)
    refresh(currDir, currPage)

end

local bgColor

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

--addParallelFunctions(detectScroll)
initialize(enterExplorer, bgColor)

