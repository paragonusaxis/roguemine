Time = Class {}

-- empty table with all the timers of our game
function Time:init()
    self.timers = {}
end

--[[
    FLAGS
    -----
    1 = ACTIVE
    2 = INACTIVE
    3 = REMOVED

    -----

    I decided to go for numerical flags in this case, which, in hindsight, seems stupid,
    since all other flags on the game are actually easy to read string... sorry.

    I can't be bothered to change this at the moment, but it shouldn't take that long tbh.
]]

-- after TIME seconds, call FUNC. this will happen just once
-- func should ALWAYS be passed as an anonymous function, even if it already exists!
-- so if you want to pass a function foo(x) that was already defined you must write it as:
-- time:after(time, function() return foo(x) end)
-- else foo(x) will be called before it's time
function Time:after(time, func)
    -- creates an anonymous table with some important entries
    table.insert(self.timers, {
        ['time'] = time, 
        ['flag'] = 1, 
        ['func'] = func,
        ['current'] = 0,
        -- counter is 1 because this will happen just ocne
        ['counter'] = 1
    })

    -- returns a reference to this table, which means that you can save this in a variable
    -- this is important in case you want to have control over this specific timer (ongoing timers for example)
    -- this is really neat
    return self.timers[#self.timers]
end

-- calls FUNC every TIME seconds for COUNTER times
-- you don't actually have to pass a counter. If you don't, this will go on forever
function Time:every(time, func, counter)
    table.insert(self.timers, {
        ['time'] = time, 
        ['flag'] = 1, 
        ['func'] = func,
        ['current'] = 0,
        ['counter'] = counter
    })

    -- same thing as before, returns a reference to itself, so that you can manipulate it later
    -- this a pointer bb
    return self.timers[#self.timers]
end

-- marks a timer for removal (will happen in the next frame)
function Time:remove(timer)
    timer.flag = 3
end

-- pause timer, it will stop counting, but current counter will remain the same
-- for example, you have timer calling a function every 10s, you stop it when it's current time
-- is equal to 5s. When you resume it, it will take 5s for the function to be called again.
function Time:pause(timer)
    timer.flag = 2
end

-- different than time:pause(), time:stop() will not only desactivate the time, but also reset
-- it's current time, so it'l be back to 0 when it starts again
function Time:stop(timer)
    timer.flag = 2
    timer.current = 0
end

-- restarts the timer
function Time:start(timer)
    timer.flag = 1
end

-- ads number to timer's current time
function Time:add(time, timer)
    timer.current = timer.current + time
end

-- resets timer to 0
function Time:reset(timer)
    timer.current = 0
end

-- adds to counter, I haven't tested this and don't know how it will work irl
-- be aware that a timer will get removed from the update logic after it's counter gets to 0, 
-- so if you try to access it after that happens, nothig will happen...
function Time:addCounter(timer, add)
    timer.counter = time.counter + add
end

-- CLEAR ALL TIMERS AND ALL TIMED FUNCTIONS, SO TWEENS WILL STOP WORKING AS WELL!
-- might break your game idk be careful
function Time:clear()
    self.timers = {}
end

-- update function for times, this is called in love.update(dt)
function Time:update(dt)
    for k, timer in pairs(self.timers) do
        -- updates timer if it is active
        if timer.flag == 1 then
            -- Tween here maybe?
            -- Yep, tween here
            -- checks to see if this timer is a tween
            if timer.tween then
                -- checks method and tweens stuff, some crazy math ahead, tread carefully
                if timer.tween.method == 'linear' then
                    for k, v in pairs(timer.tween.change) do
                        timer.tween.object[k] = timer.tween.object[k] + (v/timer.time) * dt
                    end
                elseif timer.tween.method == 'easein' then
                    for k, v in pairs(timer.tween.change) do
                        local a = (2 * v)/(timer.time)^2
                        local vel = a * (timer.current)
                        timer.tween.object[k] = timer.tween.object[k] + vel * dt + (a * dt^2)/2
                    end
                elseif timer.tween.method == 'easeout' then
                    for k, v in pairs(timer.tween.change) do
                        local a = (2 * v)/(timer.time)^2
                        local fVel = a * timer.time 
                        local vel = fVel - a * (timer.current)
                        print(vel)
                        timer.tween.object[k] = timer.tween.object[k] + vel * dt + (a * dt^2)/2
                    end
                -- This somehow works and I don't know why...
                elseif timer.tween.method == 'easeinout' then
                    for k, v in pairs(timer.tween.change) do
                        local half = timer.time/2
                        local a = (2 * v/2)/(half)^2
                        -- If you're smarter than me, plz explain why final vel is a * t and not
                        -- a * t/2
                        -- i suck at physics >:c
                        local fVel = a * timer.time
                        local vel = nil
                          
                        if timer.current <= half then
                            vel = a * (timer.current)
                        else
                            vel = fVel - a * (timer.current)
                        end

                        timer.tween.object[k] = timer.tween.object[k] + vel * dt + (a * dt^2)/2
                    end
                end                            
            end
            -- updates current time
            timer.current = timer.current + dt

            -- if current time is bigger than the time stipulated for stuff to happen...
            if timer.current > timer.time then
                -- stuff happens (ie, the timer's function is called)
                timer.func()

                -- timer current goes back to 0 in case this is an ongoing timer
                timer.current = 0 + (timer.current - timer.time)
                
                -- if counter exists (ie, this won't go forever)
                if timer.counter then
                    -- subtract 1 from counter
                    timer.counter = timer.counter - 1
                    
                    -- if counter is now 0 or less (for some reason, idk, better safe than sorry)
                    if timer.counter <= 0 then
                        -- flag this timer for removal
                        timer.flag = 3
                    end
                end                
            end
        -- remmoves timer from the update logic, if you have no other references to this timer, 
        -- lua's garbage collector will take care of it for you, else it will sit uselessly on yours pc's
        -- memory, so think this through
        elseif timer.flag == 3 then
            self.timers[k] = nil
        end
    end
end

--[[
    Double brackets because this one is serious!

    THE TWEENING FUNCTION ™
    ----------------------

    Duration: how long the tween will take
    Object: the TABLE with the FIELDS that will be tweened
    Target: the TABLE with the TARGETS of the tween
    Method: 'linear', 'easein', 'easeout', 'easeinout'
    After: function to be called after the tween is completed

    -----------------------

    Ok, so here's the deal with Object and Target: They both have to be tables,
    and they have to have MATCHING INDEXES so that my dumb program know what to change!
    
    EXAMPLE TIME:
    =============
    player = {x = 100, y = 100}
    time:tween(2, player, {x = 700})
    =============

    In this example, player is a simple object with two fields representing positions.
    The field being tweened is player.x, so the target has to have a matching index (x).
    You don't really need to pass a method or a function, as they default to linear and an 
    empty function, respectively.

    =============
    player = {
        pos = {
            x = 100, 
            y = 100
        },
        speed = 100
    }
    time:tween(2, player.pos, {x = 700, y = 1000}, 'easeinout')
    =============

    In this example, player is a little bit more complex, and has a position
    table inside itself to store it's x and it's y (more closely to an object in a real game). 
    Sadly my tweening engine is shit, so it can't deal with tables inside of tables, so the object 
    in this case HAS TO BE player.pos, since the target fields (x and y) are inside it. But notice 
    how you can actually tween many values at once, as long as they are inside the same table.
    
    What this means is that if you wanted to also tween the player.speed, you would actually have
    to call a different tween function, since speed is an entry in a diferent table (player), when compared
    to x and y (inside player.pos)
    
    =============
    color = {1, 1, 1, 1}
    time:tween(2, color, {0, 0, 0})
    =============

    This actualy works, because the numerical indexes in target can be mapped to the 
    numerical indexes in color, since lua assigns numerical indexes when you don't specify
    keys yourself. The first three entries in color would be tweened in this case.

    =============
    color = {r = 1, g = 1, b = 1, a = 1}
    time:tween(2, color, {0, 0, 0, 0})
    =============

    This, on the other hand, WON'T WORK, since the entries in the object are specific,
    and the function won't know how to access them unless they are specified in the target.

    
]]
function Time:tween(duration, object, target, method, after)
    -- some default stuff
    local method = method or 'linear'
    local change = {}
    local after = after or function () end

    -- go through target
    for k, entry in pairs(target) do
        -- make sure that what resides in target is the same type of the thing in the object
        assert(type(entry) == type(object[k]), 'Type mismatch in field "'..k..'".')

        -- makes sure the fields support arithmetic operations
        local ok = pcall(function() return (entry-object[k])*1 end)
        assert(ok, 'Field "'..k..'" does not support arithmetic operations')

        -- adds the DIFFERENCE between TARGET and ORIGINAL FIELD to change[key]
        change[k] = (entry - object[k])
    end

    -- creates a timer that will handle this tweening function, this timer
    -- has a special entry called tween that stores extra stuff so that we can use later
    table.insert(self.timers, {
        ['time'] = duration, 
        ['flag'] = 1, 
        ['func'] = after,
        ['current'] = 0,
        ['counter'] = 1,
        ['tween'] = {
            ['method'] = method,
            ['object'] = object,
            ['change'] = change
        }
    })

    return self.timers[#self.timers]
end



