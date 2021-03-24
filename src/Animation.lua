Animation = Class {}

--[[
    t: time in between frames of the animation
    frames: number of frames
    w: width of the frame
    h: height of the frame
    texture: texture image
    x: starting x
    y: starting y
]]

--[[
    A few things to be aware: the frames have to be all in the same row in the texture, 
    and there should be no spacing in between the frames, or else quads won't be captured correctly
]]
function Animation:init(t, frames, w, h, texture, x, y)
    local x = x or 0
    local y = y or 0

    self.w = w
    self.h = h
    self.texture = texture
    self.totalFrames = frames
    
    self.frames = {}

    for i = 1, self.totalFrames do
        self.frames[i] = love.graphics.newQuad(x + w * (i - 1), y, w, h, 
            self.texture:getWidth(), self.texture:getHeight()
        )
    end

    self.time = t
    self.startFrame = 1
    self.currentFrame = 1
    self.handler = time:every(self.time, function() return self:next() end)

    time:stop(self.handler)
end

-- There is no need to use these functions, use the Animator instead!

function Animation:next()
    if self.currentFrame == self.totalFrames then
        self.currentFrame = self.startFrame
    else
        self.currentFrame = self.currentFrame + 1
    end
end

function Animation:start()
    time:start(self.handler)
end

function Animation:pause()
    time:pause(self.handler)
end

function Animation:stop()
    time:stop(self.handler)
end

function Animation:reset()
    time.stop(self.handler)
    self.currentFrame = self.startFrame
end

