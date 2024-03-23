
local basalt = require("basalt")

local exit = false

local main = basalt.createFrame():setBackground(colors.black)

local progressBar = main:addProgressbar()
:setDirection(0)
:setPosition(5, 15)
:setSize(42, 2)
:setProgressBar(colors.blue, " ", colors.blue)

local program = main:addProgram():execute(function ()
    local image = paintutils.loadImage("system/assets/startingLogo.nfp")
    paintutils.drawImage(image, term.getCursorPos())
end)
:setPosition(19, 3)
:setSize(52, 10)

local t = main:addThread()

local function progress()
    while progressBar:getProgress() ~= 100 do
        progressBar:setProgress(progressBar:getProgress() + 5)
        os.sleep(0.15)
    end
    basalt.stopUpdate()
    t:stop()
end

t:start(progress)
basalt.autoUpdate()

shell.run("system/loginScreen.lua")

