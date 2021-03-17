PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.objManager:addObj({Circle()})
end

