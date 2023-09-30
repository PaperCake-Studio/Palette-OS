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
local dirNum = 0
local fileNum = 0

speaker = peripheral.find("speaker")


local function refresh(dir)
    
    if dir == nil then dir = "" end
    showAll()
    local t = 0
    local tY = 5
    totalPage = 0
    if dirFlag then
        for i, v in ipairs(dirName) do

            if tY <= 16 and dirFlag then
                if i == #dirY then
                    dirFlag = false
                end
    
                if dirName[i] ~= nil then
                    --showNormalText(12, tY, "                                        ")
                    showSingleSelectableText(12, tY, dirName[i])
                    
                    tY = tY + 1
                end
                
            end
        end
    
    end
    

    for i, v in ipairs(fileName) do
        if not dirFlag then
            if fileName[i] ~= nil and tY <= 16 then
                --showNormalText(12, tY, "                                        ")
                showSingleSelectableText(12, tY, fileName[i])
                tY = tY + 1
            end
        end


    end

    if t <= 12 then
        totalPage = math.ceil((fileNum + dirNum) / 12)
    else
        totalPage = 1
    end
    
    showNormalText(12, 17, "Page " .. currPage .. "/" .. totalPage)
end

function renderExplorer(dir)
    if not (id == nil or id <= totalPage) then return end
    dirName = {}
    fileName = {}
    dirY = {}
    fileY = {}
    totalPage = 1
    dirFlag = true
    fileNum = 0
    dirNum = 0
    resetSelectedText()
    deleteAllObj()
    clearsc()
    showNormalText(1, 1, "PaletteOS| PaletteOS File Explorer Alpha (U)")
    showNormalText(1, 2, "---------+------------------------------------------")
    showNormalText(12, 3, dir)
    showNormalText(11, 4, "------------------------------------------")
    showNormalText(12, 18, "#You know, it's alpha, bugs are normal#", colors.red)
    showButton(1, 3, "[Page Up]", pageupBtn)
    showButton(1, 5, "[Page Dn]", pagednBtn)
    showButton(1, 7, "[  <--  ]", previousDirBtn)
    showButton(1, 9, "[ Enter ]", enterDirBtn)
    showButton(1, 11, "[  Edit ]", editBtn)
    showButton(1, 13, "[ Delete]", deleteBtn)
    showButton(1, 15, "[Refresh]", refreshBtn)
    --disableObj(1, 3)
    --disableObj(1, 5)
    if dirHistoryId == 1 then
        disableObj(1, 7)
    end
    

    for i = 3, 20 do
        if i % 2 == 0 then
            showNormalText(10, i, "*")
            showNormalText(1, i, "---------")
        else
            showNormalText(10, i, "|")
        end
        
    end
    

    
    
    
    
    
end


function refreshBtn()
    renderExplorer(currDir)
    refresh(currDir)
end

function deleteBtn()
    local v = getSelectedText()
    if v ~= nil then
        pcall(fs.delete, currDir .. v)
        renderExplorer(currDir)
        refresh(currDir)
    end
end

function pageupBtn()
    if not ((currPage - 1) < 1) then
        currPage = currPage - 1
        renderExplorer(currDir)
        refresh(currDir)
    end
    
end

function pagednBtn()
    
    if ((currPage + 1) <= totalPage) then
        currPage = currPage + 1
        renderExplorer(currDir)
        refresh(currDir)
    end

end

function enterDirBtn()
    local v = getSelectedText()
    if v == nil then return end
    --print(v)
    if string.sub(v, string.len(v)) == "/" then
        currDir = currDir .. v
        renderExplorer(currDir)
        refresh(currDir)
        dirHistoryId = dirHistoryId + 1
        dirHistory[dirHistoryId] = currDir
        if currDir ~= "/" then
            enableObj(1, 7)
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
    dirHistory[dirHistoryId + 1] = nil
    renderExplorer(currDir)
    refresh(currDir)
    if currDir == "/" then
        disableObj(1, 7)
    end
end


function showAll()
    local tList = fs.list(currDir .. "*")
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
    renderExplorer(currDir)
    refresh(currDir)
end



iniRenderFunc = enterExplorer

main()



