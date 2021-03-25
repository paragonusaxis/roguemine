require 'src/dependencies'

function love.load()
    -- Crisp 2d >:3
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- set the application title bar
    love.window.setTitle('Roguemine')

    -- graphical assets
    graphics = {
        map = love.graphics.newImage('graphics/map.png'),
        topero = love.graphics.newImage('graphics/topero.png')
    }

    -- creates a time manager
    time = Time()
    
    -- creates a state machine, with our states 
    stateMachine = StateMachine({
        ['playState'] = function() return PlayState() end,
        ['timerState'] = function() return TimerState() end
    })

    -- changes state to playState
    stateMachine:change('playState')

    --[[ 
        A table we'll use to keep track of which keys have been pressed  and released this
        frame, to get around the fact that LÖVE's default callback won't let us
        test for input from within other functions
    ]]
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.update(dt)
    -- updates our time manager
    time:update(dt)
    
    -- updates the state machine
    stateMachine:update(dt)

    -- reset keys pressed and keys released
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
    -- add to our table of keys released this frame
    love.keyboard.keysReleased[key] = true
end

--[[
    Custom functions that will let us test for individual keystrokes outside
    of the default `love.keypressed` and `love.keyreleased` callbacks, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.keyboard.wasReleased(key)
    if love.keyboard.keysReleased[key] then
        return true
    else
        return false
    end
end

function love.draw()
    -- renders the state machine
    stateMachine:render()
end