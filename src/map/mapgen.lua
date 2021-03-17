FF = require 'floodfill.ff'
local wallPercent = 0.45
local floorpercent = 0.05

Map = {w = 0, h = 0}

local bit = require("bit")
local band, bxor = bit.band, bit.bxor

function setSeed(seed)
    love.math.setRandomSeed(seed)
    return seed
end

function mapAutomata(map)
    for i = 1, map.w, 1 do
        for j = 1, map.h, 1 do
            walls = getWallCount(i, j, map)

            if (walls > 4) then
                map[i][j] = 1
            elseif walls < 4 then
                map[i][j] = 0
            end
        end
    end
    return map
end

function getWallCount(cX, cY, map)
    local count = 0
    for i = cX - 1, cX + 1, 1 do
        for j = cY - 1, cY + 1, 1 do
            if (i >= 1 and i <= map.w and j >= 1 and j <= map.h) then
                if (i ~= cX or j ~= cY) then
                    count = count + map[i][j]
                end
            else
                count = count + 1
            end
        end
    end
    return count
end


function Map:generateRandomMap(w, h)
    for i = 1, w, 1 do
        self.w, self.h = w, h
        self[i] = {}
        for j = 1, h, 1 do
            if (i == 1 or i == w or j == 1 or j == h) then
                self[i][j] = 1
            elseif (j >= h/2 - 1 and j <= h/2 + 1) then
                self[i][j] = 0
            else
                self[i][j] = (wallPercent < sigmoid(love.math.randomNormal(20, 0)) and 0 or 1)
                -- map[i][j] = (wallPercent < love.math.random() and 0 or 1)
            end
        end
    end
    return self
end



function sigmoid(x)
    return tonumber(1/(1 + math.exp(-x)))
end

function Map:generateCave(w, h, interations)
    m = self:generateRandomMap(w, h)
    for i = 1, interations, 1 do
        m = mapAutomata(m)
    end
    self = FloodFill(m)

    -- local px, py = 35, 8
    -- print(binaryNear(px, py, m))
    -- printMap(m, px-1, px+1, py-1, py+1)
    return self
end

function FloodFill(map)
    FF(math.floor(map.w/2), math.floor(map.h/2), map, 2)
    RestoreMapFill(map)

    SolveWallEdgeTiles(map)
    return map
end
        
function RestoreMapFill(map)
    for i = 1, map.w, 1 do
        for j = 1, map.h, 1 do
            local v = map[i][j]
            if v ~= 2 then
                map[i][j] = 1
            else
                map[i][j] = 0
            end
        end
    end
    return map
end

local bmask_pair = {{221, 28}, {119, 7}, {85, 69}, {85,81}, {245, 4}, {125, 1}, {1, 2}, {119, 112}, {221, 193}, {85, 21}, {85, 84}, {95, 64}, {215, 16}, {1, 2}}

function SolveWallEdgeTiles(map)
    for i = 1, map.w, 1 do
        for j = 1, map.h, 1 do
            if isEdgeTile(i, j, map) then
                local b = binaryNear(i, j, map)
                for index, value in ipairs(bmask_pair) do
                    if index ~= 7 and index ~= 14 then
                        if checkEdgeTileMask(b, value[1], value[2]) == 0 then
                            map[i][j] = 10+index
                            break
                        end
                    end
                end
            end
        end
    end
    return map
end

function checkEdgeTileMask(b, msk_and, msk_xor)
    local k = band(b, msk_and)
    return bxor(k, msk_xor)
end

function isEdgeTile(cX, cY, map)
    for i = cX - 1, cX + 1, 1 do
        for j = cY - 1, cY + 1, 1 do
            if (i >= 1 and i <= map.w and j >= 1 and j <= map.h) then
                if (i ~= cX or j ~= cY) then
                    if map[i][j] == 0 and map[cX][cY] == 1 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

ilist = {{-1,-1}, {0,-1}, {1,-1}, {1,0}, {1,1}, {0,1}, {-1,1}, {-1,0}}

function binaryNear(cX, cY, map)
    local t = {}
    for index, value in ipairs(ilist) do
        local i = cX+value[1]
        local j = cY+value[2]
        if (i>= 1 and i <= map.w and j >= 1 and j <= map.h) then
            -- print(i .. " " .. j)
            if map[i][j] >= 1 then 
                table.insert(t, tostring(1))
            else
                table.insert(t, tostring(0))
            end
        else
            table.insert(t, tostring(1))
        end
        -- print(table.concat(t))
    end
    local s = table.concat(t)
    return tonumber(s, 2)
end


function printMap(map, x1, x2, y1, y2)
    for j = y1, y2, 1 do
        print("")
        for i = x1, x2, 1 do
            local s = map[i][j]
            io.write(tostring(s .. " "))
        end
    end
end

function walkNeighboursMap(x, y, map)
    for index, value in pairs(ilist) do
        print(map[x+value[1]][y+value[2]])
    end
end

return Map