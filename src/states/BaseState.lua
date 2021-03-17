BaseState = Class{}

-- Generic object manager 
function BaseState:init()
    self.objManager = ObjManager()
end

function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) self.objManager:update(dt) end
function BaseState:render() self.objManager:render() end