TimerState = Class{__includes = BaseState}

function TimerState:enter()
    -- create a bunch fo random objects (spoiler, they are balls)
    -- couldn't bother with creating classes for them, so they are here
    -- they have a position, that's it
    obj = {x = 100, y = 100}
    obj1 = {x = 100, y = 250}
    obj2 = {x = 100, y = 400}
    obj3 = {x = 100, y = 550}

    -- here I call some functions, check them at the end of this file
    toRight(obj, 'linear')
    toRight(obj1, 'easein')
    toRight(obj2, 'easeout')
    toRight(obj3, 'easeinout')

end

-- timers and tweens are updated by themselves on main.lua, so all the stuff here
-- happens behind the scenes :)
function TimerState:update(dt)
    -- empty much
end

function TimerState:render()
    -- render objects, the methods utilized in each tween and a line for -*- a e s t h e t i c -*- purposes
    love.graphics.printf("linear", 0, 50, love.graphics.getWidth(), 'center')
    love.graphics.line(100, obj.y, 700, obj.y)
    love.graphics.circle('fill', obj.x, obj.y, 10)

    love.graphics.printf("ease-in", 0, 200, love.graphics.getWidth(), 'center')
    love.graphics.line(100, obj1.y, 700, obj1.y)
    love.graphics.circle('fill', obj1.x, obj1.y, 10)
    
    love.graphics.printf("ease-out", 0, 350, love.graphics.getWidth(), 'center')
    love.graphics.line(100, obj2.y, 700, obj2.y)
    love.graphics.circle('fill', obj2.x, obj2.y, 10)
    
    love.graphics.printf("ease-in-out", 0, 500, love.graphics.getWidth(), 'center')
    love.graphics.line(100, obj3.y, 700, obj3.y)
    love.graphics.circle('fill', obj3.x, obj3.y, 10)
end

-- some very simple function duo showing the power of the timer and tweening """libs""" 
function toRight (object, method)
    -- tween object to position x = 700, using a certain tweening method, this will take 2s
    time:tween(2, object, {x = 700}, method,
        -- after this tween is completed, it will create a timer using time:after()
        function() return 
            -- after this timer is complete, it will call toLeft()
            time:after(1, function() return toLeft(object, method) end) 
        end
    )
end

-- toLeft() will then tween the object back to it's original position (x = 100), and will then
-- call toRight(), so on and so forth!
function toLeft (object, method)
    time:tween(2, object, {x = 100}, method, 
        function() return 
            time:after(1, function() return toRight(object, method) end) 
        end
    )
end