BaseState = Class{}

-- Generic object manager 
function BaseState:init() end
function BaseState:enter() objManager = ObjManager() end
function BaseState:exit() end
function BaseState:update(dt) objManager:update(dt) end
function BaseState:render() objManager:render() end