--[[
    This is an example on how to create an object in the game.
    This object can walk to 8 directions and has 4 walk animations and 4 idle animations.

    It's important to say that current implementation is a bit simplistic in certain aspects,
    and should be reviewed later. There is a pressing need for the implementation of a better input interface,
    and object states and orientations should be tables instead of single variables, for better manipulation 
    and functionality.

    All in all, this works fine...
]]

Skeleton = Class{__includes = Obj}

function Skeleton:init()
    -- position variables
    self.x = 0
    self.y = 0

    -- walking speed
    self.speed = 80
    
    -- dimensions of object, this will be later utilized for collision detection
    self.width = 16
    self.height = 26

    -- this important flag tells the object manager, which this object was added to,
    -- that this object should be visible on this state. Check the ObjManager class for more info
    -- on object manipulation 
    self.flag = 'visible'

    -- some variables to flag when stuff happens. This will help with the manipulation of animations later
    self.orientation = 'down'
    self.state = 'idle'

    -- the texture of the object, this texture is actually stored in a global table in main.lua
    self.texture = graphics.skeleton

    -- time between frames of all animations of this character, you don't actually need to make them all
    -- the same, but I did cause I'm lazy!
    self.animationTime = 0.2

    -- table with all the character animations, 8 in total, I used the naming convention
    -- "state-orientation" because later on I did a little trick to reduce lines of code, but
    -- this could technically be anything you want.
    self.animations = {
        ['walk-right'] = Animation(self.animationTime, 2, self.width, self.height, self.texture),
        ['walk-left'] = Animation(self.animationTime, 2, self.width, self.height, self.texture),
        ['walk-up'] = Animation(self.animationTime, 2, self.width, self.height, self.texture, self.width *2),
        ['walk-down'] = Animation(self.animationTime, 2, self.width, self.height, self.texture, self.width * 4),
        ['idle-right'] = Animation(self.animationTime, 1, self.width, self.height, self.texture),
        ['idle-left'] = Animation(self.animationTime, 1, self.width, self.height, self.texture),
        ['idle-up'] = Animation(self.animationTime, 1, self.width, self.height, self.texture, self.width *2),
        ['idle-down'] = Animation(self.animationTime, 1, self.width, self.height, self.texture, self.width * 4)
    }

    -- creates the animator and passes the starting animation, "idle-down", which are the current state
    -- and current orientation
    self.animator = Animator(self.animations['idle-down'])

end

function Skeleton:update(dt)
    -- defaults to idle, if no input happens, this will remain true
    self.state = 'idle'
    
    -- handles input, updates player's position, updates state and orientation
    if love.keyboard.isDown('left') then
        self.x = math.max(self.x - self.speed * dt, 0)

        self.state = 'walk'
        self.orientation = 'left'
    elseif love.keyboard.isDown('right') then
        self.x = math.min(self.x + self.speed * dt, worldW)
        
        self.state = 'walk'
        self.orientation = 'right'
    end

    if love.keyboard.isDown('up') then
        self.y = math.max(self.y - self.speed * dt, 0)

        self.state = 'walk' 
        self.orientation = 'up'
    elseif love.keyboard.isDown('down') then
        self.y = math.min(self.y + self.speed * dt, worldH)

        self.state = 'walk' 
        self.orientation = 'down'
    end

    -- if up to this point we are still in idle state, then no input was received
    -- so now we just concatenate a string to now current state and positionement
    -- and then change the animation by indexing our animations table with the string
    -- as index
    local animation = self.state ..'-'.. self.orientation
    self.animator:change(self.animations[animation])
end

-- render function is very simple, it just take into account if orientation is left,
-- because, in reality, if you check the object's spritesheet, you'll see that that are no
-- animations for the left side. The left side animations are just the right side animations flipped
-- the x-axis and with an offset to compensate.
-- since I did that little trick with the string concat on update, I actually had to create animation objects 
-- for the left side animations, even though they are exact copies of the right side animations.
function Skeleton:render()
    if self.orientation == 'left' then
        love.graphics.draw(self.animator:getTexture(), self.animator:getQuad(), self.x + 16, self.y, 0, -1, 1)
    else
        love.graphics.draw(self.animator:getTexture(), self.animator:getQuad(), self.x, self.y)
    end
end