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

    -- creates a Skeleton
    skeleton = Skeleton()

    -- creates an object manager for the state
    objManager = ObjManager()
    
    -- adds the skeleton to the manager. Don't forget the objects must be inside a table
    objManager:addObj({skeleton})
end

-- update for the state
function PlayState:update(dt)
    -- locks camera to the skeleton, world dimensions must be passed as argument as well
    camera:lock(skeleton, worldW, worldH)

    -- changes state if space is pressed
    if love.keyboard.wasPressed('space') then
        stateMachine:change('timerState')
    end

    -- updates all objects
    objManager:update(dt)
end

function PlayState:render()
    -- attaches camera
    camera:attach()

    -- draws map
    love.graphics.draw(map)

    -- draws objects
    objManager:render()

    -- prints the world coordinates of the object
    love.graphics.print(string.format('%d', skeleton.x) .. ', ' .. string.format('%d', skeleton.y), 
    skeleton.x + skeleton.width, skeleton.y + skeleton.height + 10)

    -- detaches camera
    camera:detach()
end

