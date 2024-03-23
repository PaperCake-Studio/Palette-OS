local basalt = require("system/basalt")

local main = basalt.createFrame()
local mainAnim = main:addAnimation()

local frames = {
    main:addFrame():setPosition(1,2):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray),
    main:addFrame():setPosition("parent.w+1",2):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray),
    main:addFrame():setPosition("parent.w*2+1",2):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray),
    main:addFrame():setPosition("parent.w*3+1",2):setSize("parent.w", "parent.h-1"):setBackground(colors.lightGray),
}

frames[1]:addLabel():setText("This is frame 1")
frames[2]:addLabel():setText("This is frame 2")
frames[3]:addLabel():setText("This is frame 3")
frames[4]:addLabel():setText("This is frame 4")

local menubar = main:addMenubar():ignoreOffset()
        :addItem("Page 1",nil,nil,1)
        :addItem("Page 2",nil,nil,2)
        :addItem("Page 3",nil,nil,3)
        :addItem("Page 4",nil,nil,4)
        :setSpace(3)
        :setSize("parent.w",1)
        :onChange(function(self, value)
            mainAnim:clear()
                    :cancel()
                    :setObject(main)
                    :offset(value.args[1] * main:getWidth() - main:getWidth(), 0, 2)
                    :play()
        end)


basalt.autoUpdate()
