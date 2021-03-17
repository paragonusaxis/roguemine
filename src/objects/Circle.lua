Circle = Class{__includes = Obj}

function Circle:render()
    love.graphics.circle('line', self.x, self.y, 50)
end



