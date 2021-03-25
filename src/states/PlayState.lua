PlayState = Class{__includes = BaseState}

--[[
    I'm almost sure that the way the state machine works, when we leave a state, all references to it are
    lost, an thus lua's garbage collector gets rid of it for us. I think that's why we don't need to 
    initialize variables in states with the "self" keyword, like we have to do for the many objects inside 
    the state.
]]

function PlayState:enter()
    -- creates camera for the state
    camera = Camera(200, 150, 2)

    -- sets the map for the current state, this map is stored in a table in love.load
    map = graphics.map

    -- gets size of word base on map
    worldW = map:getWidth()
    worldH = map:getHeight()

    -- creates a player
    player = Player()

    -- creates an object manager for the state
    objManager = ObjManager()
    
    -- adds the player to the manager. Don't forget the objects must be inside a table
    objManager:addObj({player})
end

-- update for the state
function PlayState:update(dt)
    -- changes state if space is pressed
    if love.keyboard.wasPressed('space') then
        stateMachine:change('timerState')
    end

    -- handles player input, and updates player's state and orientation
    -- this should be handled here and not in the player's update method,
    -- cause we want the player input to be state-based, for mor organized code
    -- defaults player to idle
    player.state = 'idle'
    -- we also need to do this because we now use x and y velocities to determine
    -- where we are walking to...
    -- collision code will have be here anyways so we honestly could have a walk function
    -- that we can use from here, instead of having to check velocities inside the player update!
    player.dx, player.dy = 0, 0

    if love.keyboard.isDown('left') then
        player.state = 'walk'
        player.orientation = 'left'
        player.dx = -player.speed
    elseif love.keyboard.isDown('right') then   
        player.state = 'walk'
        player.orientation = 'right'
        player.dx = player.speed
    end

    if love.keyboard.isDown('up') then
        player.state = 'walk' 
        player.dy = -player.speed
    elseif love.keyboard.isDown('down') then
        player.state = 'walk' 
        player.dy = player.speed
    end

    -- updates all objects
    objManager:update(dt)
    
    -- locks camera to the player, world dimensions must be passed as argument as well
    camera:lock(player, worldW, worldH, 'ease')
end

function PlayState:render()
    -- attaches camera
    camera:attach()

    -- draws map
    love.graphics.draw(map)

    -- draws objects
    objManager:render()

    -- prints the world coordinates of the object
    love.graphics.print(string.format('%d', player.x) .. ', ' .. string.format('%d', player.y), 
    player.x + player.width, player.y + player.height + 10)

    -- detaches camera
    camera:detach()
end

