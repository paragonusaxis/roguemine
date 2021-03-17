require 'src/dependencies'

function love.load()
    -- Crisp 2d >:3
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- set the application title bar
    love.window.setTitle('Roguemine')
    
    stateMachine = StateMachine({
        ['playState'] = function() return PlayState() end
    })

    stateMachine:change('playState')

    --[[ 
        A table we'll use to keep track of which keys have been pressed this
        frame, to get around the fact that LÖVE's default callback won't let us
        test for input from within other functions
    ]]
    love.keyboard.keysPressed = {}
end

function love.update(dt)
    stateMachine:update()

      -- reset keys pressed
      love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    stateMachine:render()
end

-- hello this is a random commentary laosldaos