Camera = Class{}

function Camera:init(x, y, zoom, rotation, speed)
    self.x = x or 0 
    self.y = y or 0 
    self.scale = zoom or 0 
    self.rotation = rotation or 0
    self.spd = speed or 100
    self.stiffness = 5

    self.w = love.graphics.getWidth()
    self.h = love.graphics.getHeight()
end

--[[
    All things that are part of the camera must be drawn inside attach/detach
]]
function Camera:attach()
    love.graphics.push()
    love.graphics.translate(math.floor(self.w/2), math.floor(self.h/2))
    love.graphics.scale(math.floor(self.scale))
    love.graphics.rotate(math.floor(self.rotation))
    love.graphics.translate(math.floor(-self.x), math.floor(-self.y))
end

function Camera:detach()
    love.graphics.pop()
end

-- places the camera at a certain position in the world. CAN BE OUT OF BOUNDS!!
function Camera:lookAt(x, y)
    self.x = x
    self.y = y
end

function Camera:ease(dx, dy, stiffness) 
    local dts = love.timer.getDelta()
    return dx * dts * stiffness, dy * dts * stiffness
end 

function Camera:linear(dx, dy, speed)
    local d = math.sqrt(dx*dx+dy*dy)
    local dts = math.min(speed * love.timer.getDelta(), d)
    if d > 0 then
        dx,dy = dx/d, dy/d
    end

    return dx*dts, dy*dts
end


-- moves camera x by a fixed dx amout
function Camera:moveX(dx, method, speed, stiffness)
    local dx = dx
    
    if method == 'linear' then
        local speed = speed or self.spd
        dx = self:linear(dx, 0, speed)
    elseif method == 'ease' then
        local stiffness = stiffness or self.stiffness
        dx = self:ease(dx, 0, stiffness)
    end

    self.x = self.x + dx
end

-- moves camera y by a fixed dy amount
function Camera:moveY(dy, method, speed, stiffness)
    local dy = dy
    
    if method == 'linear' then
        local speed = speed or self.spd
        _, dy = self:linear(0, dy, speed)
    elseif method == 'ease' then
        local stiffness = stiffness or self.stiffness
        _, dy = self:ease(0, dy, stiffness)
    end

    self.y = self.y + dy
end

-- moves camera x and y by a fixed dx and dy amount
function Camera:move(dx, dy, method, speed, stiffness)
    local dx = dx
    local dy = dy
    
    if method == 'linear' then
        local speed = speed or self.spd
        dx, dy = self:linear(dx, dy, speed)
    elseif method == 'ease' then
        local stiffness = stiffness or self.stiffness
        dx, dy = self:ease(dx, dy, stiffness)
    end

    self.x = self.x + dx
    self.y = self.y + dy
end

--[[
    Locks the camera to an object/set of coordinates. It's also important to note that
    this function takes the width and the height of the world, so that it can properly stop
    the camera from getting out of bounds of the world map.

    Method and stiffness in case you want easing, if there is easing, be sure not to start
    the camera out of bounds of the world, else it will be eased into bounds and it will look weird.
]]
function Camera:lock(object, worldW, worldH, method, speed, stiffness)
    local dts = love.timer.getDelta()
    if object.x < self.w/(2 * self.scale) then
        self:moveX(self.w/(2 * self.scale) - self.x, method, speed, stiffness)
    elseif object.x > worldW - self.w/(2 * self.scale) then
        self:moveX((worldW - self.w/(2 * self.scale)) - self.x, method, speed, stiffness)
    else
        self:moveX(object.x - self.x, method, speed, stiffness)
    end

    if object.y < self.h/(2 * self.scale) then
        self:moveY(self.h/(2 * self.scale) - self.y, method, speed, stiffness)
    elseif object.y > worldH - self.h/(2 * self.scale) then
        self:moveY((worldH - self.h/(2 * self.scale)) - self.y, method, speed, stiffness)
    else
        self:moveY(object.y - self.y, method, speed, stiffness)
    end
end

-- transforms screen coordinates to world coordinates
function Camera:worldCoords(x, y)
    local worldX = self.x + (x - self.w/2) / self.scale
    local worldY = self.y  + (y - self.h/2) / self.scale

    return worldX, worldY
end

-- transforms world coordinates to screen coordinates
function Camera:screenCoords(x, y)
    local screenX = (x - self.x) * self.scale + w/2
    local screenY = (y - self.y) * self.scale + h/2

    return screenX, screenY
end

-- multiplies current zoom setting
function Camera:zoom(zoom)
    self.scale = self.scale * zoom
end

-- changes camera zoom to the specified value
function Camera:zoomTo(zoom)
    self.scale = zoom
end

-- sets camera rotation to a specific angle
function Camera:rotateTo(angle)
    self.rotation = angle
end

-- adds angle to camera rotation
function Camera:rotate(angle)
    self.rotation = self.rotation + angle
end


-- animates the camera to a certain position using tweening
function Camera:animate(tx, ty, method, func)
    local func  = func or function() end
    local method = method or 'linear'
    local h = math.sqrt(tx^2 + ty^2)
    local t = h/self.spd

    local timer = time:tween(t, self, {x = tx, y = ty}, method, func)

    return timer
end

-- returns the position of the camera in world coords
function Camera:position()
    return self.x, self.y
end

-- returns the position of the mouse in world coords
function Camera:mousePosition()
    return self:worldCoords(love.mouse.getX(), love.mouse.getY())
end

-- changes the camera speed
function Camera:speed(speed)
    self.spd = speed
end
