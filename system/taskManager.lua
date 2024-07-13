local basalt = require("basalt")

local processes = utils.getAllPids()

local main = basalt:createFrame()
main:addLabel():setText("<title>$<pId>"):setPosition(1, 1)
local processLists = main:addList():setScrollable(true):setBackground(colors.gray):setForeground(colors.white):setPosition(1, 2):setSize("parent.w", "parent.h - 2")


local function refreshList()
    processLists:clear()
    for index, value in ipairs(processes) do
        if utils.getTitleByPid(value) ~= nil then
            processLists:addItem(utils.getTitleByPid(value))
        end
        
    end
end

local endProcessBtn = main:addButton():setText("End"):setSize(5, 1):setPosition(1, "parent.h"):setBackground(colors.cyan):setForeground(colors.white)
endProcessBtn:onClick(function ()
    endProcessBtn:setBackground(colors.blue)
end)
endProcessBtn:onRelease(function ()
    local title = processLists:getItem(processLists:getItemIndex()).text
    local pid = utils.getPidByTitle(title)
    utils.closeProgram(pid)
    refreshList()
    endProcessBtn:setBackground(colors.cyan)
end)

local refreshBtn = main:addButton():setText("Refresh"):setSize(9, 1):setPosition(7, "parent.h"):setBackground(colors.cyan):setForeground(colors.white)
:onClick(refreshList)

main:addThread():start(function ()
    while true do
        refreshList()
        os.sleep(2)
    end
end)

basalt.autoUpdate()