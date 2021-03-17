
Tilemap = require("mapgen")


MAP_W = 100
MAP_H = 100
AUTOMATA_INTER = 7
TILE_SIZE = 32

function love.load()
    love.keyboard.setKeyRepeat(false)
    love.window.setMode(1280, 720)
    -- seed = math.randomseed(os.time())
    seed = 10002
    seed = setSeed(seed)
    map = Tilemap:generateCave(MAP_W, MAP_H, AUTOMATA_INTER)
    cam_offsetX = 0
    cam_offsetY = 0

    mouse_x = 0
    mouse_y = 0


    load_tiles()
end

function load_tiles()
    image = love.graphics.newImage("tileset.png")

    local image_width = image:getWidth()
    local image_height = image:getHeight()

    rows = 2
    cols = 7
    width = (image_width / cols) -2
    height = (image_height / rows) -2

    quads = {}

    for i=0, rows-1 do
        for j=0, cols-1 do
            table.insert(quads,
                love.graphics.newQuad(
                    1+(j)*(width+2),
                    1+(i)*(height+2),
                    width, height,
                    image_width, image_height))
        end
    end
end

function love.draw()
    love.graphics.translate(cam_offsetX, cam_offsetY)
    -- for i in pairs(quads) do
    --     love.graphics.draw(image, quads[i], i*32, 32)    
    -- end
    debug_draw_tiles(Tilemap)
    draw_tiles(Tilemap)

    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Seed: " .. seed, -cam_offsetX, -cam_offsetY)
    love.graphics.print("Tile Pos: (" .. tile_pos_x .. ", " .. tile_pos_y .. ")" .. "Value: " .. map[tile_pos_x][tile_pos_y], mouse_x, -15+mouse_y)
end

function draw_tiles(map)
    love.graphics.setColor(1,1,1,1)
    for i = 1, map.w, 1 do
        for j = 1, map.h, 1 do
            local v = map[i][j]
            if v >= 10 then
                local t = map[i][j] - 10
                love.graphics.draw(image, quads[t], i*width, j*height)
            elseif v > 1 then
                -- love.graphics.setColor(0,1,0,1)
                -- love.graphics.rectangle("fill", i*TILE_SIZE, j*TILE_SIZE, TILE_SIZE, TILE_SIZE)
            elseif v == 1 then
                love.graphics.draw(image, quads[14], i*width, j*height)
            else 
                love.graphics.setColor(0.7,0.7,0.7,1)
                love.graphics.rectangle("fill", i*TILE_SIZE, j*TILE_SIZE, TILE_SIZE, TILE_SIZE)
                love.graphics.setColor(1,1,1,1)
            end
        end
    end
end

function debug_draw_tiles(map)
    for i = 1, map.w, 1 do
        for j = 1, map.h, 1 do
            if map[i][j] == 1 then
                love.graphics.setColor(0.38,0.26,0.11,1)
            elseif map[i][j] == 2 then
                love.graphics.setColor(1,0,0,1)
            else
                love.graphics.setColor(0.75,0.75,0.75,1)
            end
            love.graphics.rectangle("fill", i*TILE_SIZE, j*TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    love.graphics.setColor(255,255,255,255)
end

function love.update(dt)
    DebugCameraControl(500, dt)
    local x,y = love.mouse.getPosition()
    -- mouse_x, mouse_y = love.graphics.inverseTransformPoint(x,y)
    mouse_x, mouse_y = x-cam_offsetX, y-cam_offsetY
    tile_pos_x, tile_pos_y = math.floor(mouse_x/32), math.floor(mouse_y/32)
    tile_pos_x, tile_pos_y = clamp(tile_pos_x, 1, map.w), clamp(tile_pos_y, 1, map.h) 
end

function love.keypressed(key)
    if key == "space" then
        map = Tilemap:generateCave(MAP_W, MAP_H, AUTOMATA_INTER)
    end
end

function DebugCameraControl(speed, dt)
    if love.keyboard.isDown('up') then
        cam_offsetY = cam_offsetY + speed * dt
    end
    if love.keyboard.isDown('down') then
        cam_offsetY = cam_offsetY - speed * dt
    end
    if love.keyboard.isDown('left') then
        cam_offsetX = cam_offsetX + speed * dt
    end
    if love.keyboard.isDown('right') then
        cam_offsetX = cam_offsetX - speed * dt
    end
end

function clamp(v, min, max)
    if v < min then return min elseif v > max then return max else return v end
end
