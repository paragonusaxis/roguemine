--[[
    This is an example on how to create an object in the game.
    This object can walk to 8 directions and has 4 walk animations and 4 idle animations.

    It's important to say that current implementation is a bit simplistic in certain aspects,
    and should be reviewed later. There is a pressing need for the implementation of a better input interface,
    and object states and orientations should be tables instead of single variables, for better manipulation 
    and functionality.

    All in all, this works fine...

    UPDATE: AFTER REMOVAL OF SOME ORIENTATIOS, THIS REALLY NEEDS TO BE REDONE ASAP
    THIS + PLAYER CODE IN PLAYSTATE IS A POS!!!!!!!!!!!
]]

Player = Class{__includes = Obj}

function Player:init()
    -- position variables
    self.x = 0
    self.y = 0

    -- walking speed and velocities
    self.speed = 80
    self.dx = self.speed
    self.dy = self.speed
    
    -- dimensions of object, this will be later utilized for collision detection
    self.width = 19
    self.height = 24

    -- this important flag tells the object manager, which this object was added to,
    -- that this object should be visible on this state. Check the ObjManager class for more info
    -- on object manipulation 
    self.flag = 'visible'

    -- some variables to flag when stuff happens. This will help with the manipulation of animations later
    self.orientation = 'right'
    self.state = 'idle'

    -- the texture of the object, this texture is actually stored in a global table in main.lua
    self.texture = graphics.topero

    -- time between frames of all animations of this character, you don't actually need to make them all
    -- the same, but I did cause I'm lazy!
    self.animationTime = 0.07

    -- table with all the character animations, 8 in total, I used the naming convention
    -- "state-orientation" because later on I did a little trick to reduce lines of code, but
    -- this could technically be anything you want.
    self.animations = {
        ['walk-right'] = Animation(self.animationTime, 13, self.width, self.height, self.texture, 8 * self.width),
        ['walk-left'] = Animation(self.animationTime, 13, self.width, self.height, self.texture, 8 * self.width),
        ['idle-right'] = Animation(self.animationTime, 8, self.width, self.height, self.texture),
        ['idle-left'] = Animation(self.animationTime, 8, self.width, self.height, self.texture)
    }

    -- creates the animator and passes the starting animation, "idle-down", which are the current state
    -- and current orientation
    self.animator = Animator(self.animations['idle-right'])

end

function Player:update(dt)    
    -- in playstate we default the player state to idle at every update
    -- ideally this should be done in another way, with better input module based
    -- on presed/released callbacks, but this is fine for now

    -- checks if walking and updates position
    if self.state == 'walk' then
        if self.dx < 0 then
            self.x = math.max(self.x + self.dx * dt, 0)
        else
            self.x = math.min(self.x + self.dx * dt, worldW)
        end
        
        if self.dy < 0 then
            self.y = math.max(self.y + self.dy * dt, 0)
        else
            self.y = math.min(self.y + self.dy * dt, worldH)
        end
    end

    -- if up to this point we are still in idle state, then no input was received on the playstate
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
function Player:render()
    if self.orientation == 'left' then
        love.graphics.draw(self.animator:getTexture(), self.animator:getQuad(), self.x + 16, self.y, 0, -1, 1)
    else
        love.graphics.draw(self.animator:getTexture(), self.animator:getQuad(), self.x, self.y)
    end
end