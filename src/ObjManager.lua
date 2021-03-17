ObjManager = Class{}

function ObjManager:init(objects)
    self.objects = objects or {}
end

function ObjManager:update()
    for k, object in pairs(self.objects) do
        if object.flag == 'removed' then
            --[[
                It's important to be aware that this removes the object from the objects table but it doesn't
                update the indexes!!!!

                That means that there will be missing indexes (ie: 1, 2, 4, 5, 8 and so on).

                I'm not sure if this is currently a problem, but I dont think it is??
            ]]
            self.objects[k] = nil
        elseif object.flag ~= 'disabled' then
            object:update()
        end
    end
end

function ObjManager:render()
    for k, object in pairs(self.objects) do
        if object.flag == 'visible' then
            object:render()
        end
    end
end

-- Takes an Object table and adds it to the self.objects table
function ObjManager:addObj(objectTable)
    for k, object in pairs(objectTable) do
        table.insert(self.objects, object)
    end
end

-- Hides all objects
function ObjManager:hideAll()
    for k, object in pairs(self.objects) do
        object.flag = 'hidden'
    end
end

-- remove all objects
function ObjManager:removeAll()
    for k, object in pairs(self.objects) do
        object.flag = 'removed'
    end
end

-- makes all objects visible
function ObjManager:showAll()
    for k, object in pairs(self.objects) do
        object.flag = 'visible'
    end
end




