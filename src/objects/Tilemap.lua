Tilemap = Class{__includes = Obj}

local ilist = {{-1,-1}, {0,-1}, {1,-1}, {1,0}, {1,1}, {0,1}, {-1,1}, {-1,0}}
local bmask_pair = {{221, 28}, {119, 7}, {85, 69}, {85,81}, {245, 4}, {125, 1}, {1, 2}, {247, 247}, {127,127} , {119, 112}, {221, 193}, {85, 21}, {85, 84}, {95, 64}, {215, 16}, {1, 2}, {223,223}, {253, 253}}


local bit = require("bit")
local FF = require 'lib/ff'
local band, bxor = bit.band, bit.bxor

function Tilemap:init(width, height, wallPercent)
    self.flag = 'visible'
    
    self.wallPercent = wallPercent or 0.45

    self.width = width
    self.height = height

    self._map =  {}

    self.quads, self.tile_set, self.tile_w, self.tile_h = load_tiles()

    self:generateCave(7)
end

function Tilemap:generateCave(interations)
    local w, h = self.width, self.height
    randMap(self._map, w, h, self.wallPercent)

    for i = 1, interations, 1 do
        automata(self._map, w, h)
    end

    FloodFill(self._map, w, h)
    SolveWallEdgeTiles(self._map, w, h)
end

function Tilemap:get(x, y)
    return self._map[x][y]
end

function Tilemap:set(x, y, value)
    self._map[x][y] = value
end

function Tilemap:getSize()
    return self.width, self.height
end

function Tilemap:mapSize()
    return self.width*self.tile_w, self.height*self.tile_h
end

function Tilemap:render()
    local w = self.width
    local h = self.height

    local tw = self.tile_w
    local th = self.tile_h

    love.graphics.setColor(1,1,1,1)

    for i = 1, w, 1 do
        for j = 1, h, 1 do
            local v = self._map[i][j]
            if v >= 10 then
                local t = self._map[i][j] - 10
                love.graphics.draw(self.tile_set, self.quads[t], (i-1)*tw, (j-1)*th)
            elseif v > 1 then
                -- love.graphics.setColor(0,1,0,1)
                -- love.graphics.rectangle("fill", i*TILE_SIZE, j*TILE_SIZE, TILE_SIZE, TILE_SIZE)
            elseif v == 1 then
                love.graphics.draw(self.tile_set, self.quads[7], (i-1)*tw, (j-1)*th)
            else 
                -- love.graphics.setColor(0.7,0.7,0.7,1)
                -- love.graphics.rectangle("fill", (i-1)*tw, (j-1)*th, tw, th)
                -- love.graphics.setColor(1,1,1,1)
                love.graphics.draw(self.tile_set, self.quads[16], (i-1)*tw, (j-1)*th)
            end
        end
    end
end

function load_tiles()
    local tile_set = graphics.tilemap

    local image_width = tile_set:getWidth()
    local image_height = tile_set:getHeight()

    local rows = 2
    local cols = 9
    local width = (image_width / cols)
    local height = (image_height / rows)

    local quads = {}

    for i=0, rows-1 do
        for j=0, cols-1 do
            table.insert(quads,
                love.graphics.newQuad(
                    (j)*(width),
                    (i)*(height),
                    width, height,
                    image_width, image_height))
        end
    end

    return quads, tile_set, width, height
end

function randMap(map, w, h, wallPercent)
    for i=1, w, 1 do
        map[i] = {}
        for j = 1, h, 1 do
            if (i == 1 or i == w or j == 1 or j == h) then
                map[i][j] = 1
            elseif (j >= h/2 - 1 and j <= h/2 + 1) then
                map[i][j] = 0
            else
                map[i][j] = (wallPercent < sigmoid(love.math.randomNormal(20, 0)) and 0 or 1)
                -- map[i][j] = (wallPercent < love.math.random() and 0 or 1)
            end
        end
    end
end

function automata(map, w, h)
    for i = 1, w, 1 do
        for j = 1, h, 1 do
            local walls = getWallCount(i, j, map, w, h)
            if (walls > 4) then
                map[i][j] = 1
            elseif walls < 4 then
                map[i][j] = 0
            end
        end
    end
end

function getWallCount(cX, cY, map, w, h)
    local count = 0
    for i = cX - 1, cX + 1, 1 do
        for j = cY - 1, cY + 1, 1 do
            if (i >= 1 and i <= w and j >= 1 and j <= h) then
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

function FloodFill(map, w, h)
    FF(math.floor(w/2), math.floor(h/2), map, 2)
    RestoreMapFill(map, w, h)
end

function RestoreMapFill(map, w, h)
    for i = 1, w, 1 do
        for j = 1, h, 1 do
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


function checkEdgeTileMask(b, msk_and, msk_xor)
    local k = band(b, msk_and)
    return bxor(k, msk_xor)
end


function SolveWallEdgeTiles(map, w, h)
    for i = 1, w, 1 do
        for j = 1, h, 1 do
            if isEdgeTile(i, j, map, w, h) then
                local b = binaryNear(i, j, map, w, h)
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

function isEdgeTile(cX, cY, map, w , h)
    for i = cX - 1, cX + 1, 1 do
        for j = cY - 1, cY + 1, 1 do
            if (i >= 1 and i <= w and j >= 1 and j <= h) then
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

function binaryNear(cX, cY, map, w, h)
    local t = {}
    for index, value in ipairs(ilist) do
        local i = cX+value[1]
        local j = cY+value[2]
        if (i>= 1 and i <= w and j >= 1 and j <= h) then
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