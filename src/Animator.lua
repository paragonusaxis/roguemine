Animator = Class {}

--[[
    The purpose of this object is to handle all of the animations of the object that owns it.
    Animations should be stored in the owner object and passed to the animator as needed. 
]]

-- The constructor takes as argument the starter animation of the object, for example an idle animation,
-- and sets it as the objects current animation. The constructor ALREADY starts the animation!
function Animator:init(animation)
    self.currentAnimation = animation
    self.currentAnimation:start()
end

-- starts the current animation
function Animator:start()
    self.currentAnimation:start()
end

-- stops the current animation, timer to next frame gets reset
function Animator:stop()
    self.currentAnimation:stop()
end

-- pauses the current animation, timer to next frame remains unchanged
function Animator:pause()
    self.currentAnimation:pause()
end

-- stops the current animation, timer to next frame gets reseted, and animtion frame goes back to the first frame
function Animator:reset()
    self.currentAnimation:reset()
end

--[[
    This should be the main function used when animating. It takes an animation as argument.
    It first pauses the current animation, then it changes the current animation to the animation 
    passed as argument, and, finally, it starts the new animation.
]]
function Animator:change(animation)
    self:pause()
    self.currentAnimation = animation
    self:start()
end

-- helper function for easy access to current animation's frame
function Animator:getQuad()
    return self.currentAnimation.frames[self.currentAnimation.currentFrame]
end

-- helper function for easy access to current animation's texture
function Animator:getTexture()
    return self.currentAnimation.texture
end
    