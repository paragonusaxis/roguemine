-- Object primitive

Obj = Class{}

--[[
    SUPER IMPORTANT!!!!!!!!!

    ----!!!----
    IF YOUR CHILD CLASS HAS IT'S OWN INIT FUNCTION, YOU HAVE TO INITIALIZE
    SELF.FLAG AGAIN, AS NEEDED
    ----!!!----

    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
]]
function Obj:init()
    --[[
        Flags are as follows: 
            visible: is rendered && updated
            hidden: is updated only
            disabled: nothing happens
            removed: gets deleted in the next iteration of the game loop
    ]]
    self.flag = 'visible' 
end

function Obj:update(dt) end

function Obj:render() end
