--[[
    Hexa
    
    a 2D tower defense game?
    
    credits: ?
    
    written in Lua, requires Love2D
    
    created for:
    Global Game Jam 2017 (globalgamejam.org)
    by Jeremy Harton (http://globalgamejam.org/users/jnharton)
]]--

-- place to store screen height and width for easy access
scr_h = 0
scr_w = 0

-- colors (ROYGBIV)
colors = {}

colors["red"] = { 255, 0, 0 }
colors["green"] = { 0, 255, 0 }
colors["blue"] = { 0, 0, 255 }
colors["purple"] = { 255, 255, 0 }

colormap = { "red", "orange", "yellow", "green", "blue", "indigo", "violet" }

colors2 = { {255,0,0}, {255,165,0}, {255,255,0}, {0,255,0}, {0,0,255}, {111,0,255}, {255, 0, 255} }

font = nil
hexfont = nil

-- screen constants
START = 0
GAME = 1
FINISH = 2

-- hex grid parameters
w = 24
h = 13

size = 25

temp = {6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 6}

-- player data
player_x = 12
player_y = 6

player = {}
player.x = 12
player.y = 6

pcenter = {}
pcenter.x = 0
pcenter.y = 0

-- game information
screen = START

paused = nil
focus_pause = nil
game_over = nil

board_wipe = nil

last_enemy_update = 0

enemies = {}

ci = 1
ci_min = 1
ci_max = 7

laser = {}

points = 0

kills = {}

kills["red"] = 0
kills["orange"] = 0
kills["yellow"] = 0
kills["green"] = 0
kills["blue"] = 0
kills["indigo"] = 0
kills["violet"] = 0

target = {}
target.x = 0
target.y = 0

rate = 0.3
rate2 = 0.6

laser_hit = {}
laser_hit.x = -1
laser_hit.y = -1

energy_shields = {
    { x=player_x-1, y=player_y-1, energy=6},
    { x=player_x,   y=player_y-1, energy=6},
    { x=player_x-1, y=player_y,   energy=6 },
    { x=player_x+1, y=player_y,   energy=6 },
    { x=player_x-1, y=player_y+1, energy=6 },
    { x=player_x,   y=player_y+1, energy=6 }
}

-- Load/Initialize
function love.load()
    -- grab screen size
    scr_h = love.graphics.getHeight()
    scr_w = love.graphics.getWidth()
    
    -- load fonts
    font = love.graphics.newFont(12)
    hexfont = love.graphics.newFont("HexFont.ttf", 72)
    
    -- set default font
    love.graphics.setFont( font )
    
    -- initialize game state
    laser.fire = false
    laser.width = 0
    laser.charge = 100
    laser.charge_rate = 1
    laser.time = 0
    
    paused = true
    focus_pause = false
    game_over = false
    
    board_wipe = false
end

-- Draw
function love.draw()
    if screen == START then
        love.graphics.setColor(255, 255, 0)
                
        love.graphics.setFont(hexfont)
        
        love.graphics.printf("START", scr_w / 6, scr_h / 2, scr_w / 6 * 4, "center")
        
        love.graphics.setFont(font)
        
        love.graphics.printf("enter - start", scr_w / 6, scr_h / 2 + 100, scr_w / 6 * 4, "center")
        love.graphics.printf("p - pause", scr_w / 6, scr_h / 2 + 125, scr_w / 6 * 4, "center")
        
        love.graphics.printf("q - change laser color left", scr_w / 6, scr_h / 2 + 175, scr_w / 6 * 4, "center")
        love.graphics.printf("e - change laser color right", scr_w / 6, scr_h / 2 + 200, scr_w / 6 * 4, "center")
        love.graphics.printf("1-7 - change laser color", scr_w / 6, scr_h / 2 + 225, scr_w / 6 * 4, "center")
        
        love.graphics.printf("MOUSE position - aim laser", scr_w / 6, scr_h / 2 + 250, scr_w / 6 * 4, "center")
        love.graphics.printf("MOUSE Click / space - shoot laser", scr_w / 6, scr_h / 2 + 275, scr_w / 6 * 4, "center")
    end
    
    if screen == GAME then
        if not game_over then
            love.graphics.setColor(66, 80, 244)
            
            -- main playing area
            drawHexGrid()
            
            -- top
            base = (scr_w / 10) * 3.25
            
            love.graphics.setColor(191, 193, 191)
            
            -- 5px per unit, 10 units per box, 5px internal hspace, 3px internal vspace
            love.graphics.rectangle("line", base + 0 * 65, 3, 60, 16)
            love.graphics.rectangle("line", base + 1 * 65, 3, 60, 16)
            love.graphics.rectangle("line", base + 2 * 65, 3, 60, 16)
            love.graphics.rectangle("line", base + 3 * 65, 3, 60, 16)
            love.graphics.rectangle("line", base + 4 * 65, 3, 60, 16)
            love.graphics.rectangle("line", base + 5 * 65, 3, 60, 16)
            love.graphics.rectangle("line", base + 6 * 65, 3, 60, 16)
            
            vspace = 3
            hspace = 5
            
            for n=1,7 do
                love.graphics.setColor( colors2[ n ] )
                love.graphics.rectangle("fill", base + ((n - 1) * 65) + hspace, 3 + vspace, 5 * kills[ colormap[n] ], 10)
            end
            
            -- right side
            love.graphics.setColor(255, 255, 255)
            love.graphics.print("Charge", 1245, 25)
            
            love.graphics.setColor(0, 255, 0)
            love.graphics.print(laser.charge, 1245, 45)
            
            love.graphics.setColor(255, 255, 255)
            love.graphics.print("Laser", 1245, 65)
            
            love.graphics.setColor(colors2[ci])
            love.graphics.rectangle("fill", 1245, 85, 50, 20)
            
            love.graphics.setColor(255, 255, 255)
            love.graphics.print("Points", 1245, 105)
            
            love.graphics.setColor(255, 255, 0)
            love.graphics.print(points, 1245, 125)
            
            love.graphics.setColor(191, 193, 191)
            love.graphics.rectangle("line", 1245, 150, 50, 510);
            
            love.graphics.setColor(0, 255, 0)
            love.graphics.rectangle("fill", 1250, 155 + (5 * (100 - laser.charge)), 40, laser.charge * 5);
            
            if not paused then
                if laser.fire then shoot() end
            else
                love.graphics.setColor(0, 255, 0)
                
                love.graphics.setFont(hexfont)
                love.graphics.printf("Paused", scr_w / 6, scr_h / 2, scr_w / 6 * 4, "center")
                love.graphics.setFont( font )
            end
        else
            screen = FINISH
        end
    end
    
    if screen == FINISH then
        love.graphics.setBackgroundColor(255, 0, 0)
        
        love.graphics.setColor(255, 255, 0)
        
        love.graphics.setFont(hexfont)
        love.graphics.printf("Game Over!", scr_w / 8, scr_h / 2, scr_w / 8 * 6, "center")
        love.graphics.setFont(font)
    end
end

-- Focus
function love.focus(f)
  if f then
    if focus_pause then
        focus_pause = false
        paused = false
    end
  else
    if not paused then
        focus_pause = true
    end
    
    paused = true
  end
end

-- Update
function love.update(dt)
    -- if game is running
    if not paused then
        
        -- deal with "destroyed" enemies
        if board_wipe then
            -- TODO play board wipe sound?
            
            -- a board wipe should clear the board and kill counters, but NOT count for points or kill counts
            for key, value in ipairs(enemies) do              
                for k in next, enemies do rawset(enemies, k, nil) end
            end
            
            -- clear kill counters
            for i=1,7 do
                color = colormap[i]
                kills[color] = 0
            end
            
            -- half points for each hex you destroyed to fill the bar
            points = points + 35
        else
            for index, value in ipairs(enemies) do
                if value.destroyed then
                    points = points + 1
                    
                    print("Kill!")
                    print("vc: " .. value.color)
                    print("colormap(vc): " .. colormap[value.color])
                    print("kills[" .. colormap[value.color] .. "]: " .. kills[ colormap[value.color] ])
                    
                    num_kills = kills[ colormap[value.color] ]
                    
                    if num_kills < 10 then
                        kills[ colormap[value.color] ] = num_kills + 1
                    end
                    
                    table.remove(enemies, index)
                end
            end
        end
        
        last_enemy_update = last_enemy_update + dt
        
        -- update enemy positions (3 seconds?)
        if last_enemy_update >= 3 then
            last_enemy_update = last_enemy_update - 3
            
            for index, enemy in ipairs(enemies) do
                -- what if more enemies in the way?
                enemy.x = enemy.x + 1
                
                if enemy.x == player_x and enemy.y == player_y then
                    game_over = true
                end
                
                -- energy shield effect
                for index2, shield in ipairs(energy_shields) do
                    if enemy.x == shield.x and enemy.y == shield.y then
                        if shield.energy > 0 then
                            enemy.destroyed = true
                            shield.energy = shield.energy - 1
                        end
                    end
                end
            end
        end
        
        -- decide if we should spawn more enemies
        local rem_enemies = table.getn(enemies)
        
        if rem_enemies == 0 or rem_enemies / 8 <= 5 then
            spawn_enemies()
        end
        
        -- handle time based adjustments to laser
        if laser.fire then
            laser.time = laser.time + dt
            
            if laser.charge > 0 then
                -- TODO remove this or keep?
                if laser.width > 0 and laser.width < 5 then laser.charge = laser.charge - 1 end
                if laser.width > 5 and laser.width < 10 then laser.charge = laser.charge - 2 end
                if laser.width > 10 and laser.width < 15 then laser.charge = laser.charge - 3 end
                if laser.width > 15 and laser.width < 20 then laser.charge = laser.charge - 4 end
                if laser.width > 25 then laser.charge = laser.charge - 5 end
                
                -- TODO is this an okay place to do this?
                --laser.charge = laser.charge - 20
                
                if laser.charge <= 0 then
                    laser.charge = 0
                    laser.fire = false
                    laser.width = 0
                end
            end
            
            if laser.charge > 50 then
                if laser.width < 25 then laser.width = laser.width + rate end
            else
                if laser.charge > 0 and laser.charge < 25 then
                    if laser.width > 5 then
                        laser.width = laser.width - rate2
                    end
                end
            end
        else
            laser.time = 0
            
            if laser.charge < 100 then
                laser.charge = laser.charge + laser.charge_rate
            end
        end
        
        -- clear board wipe 'flag'
        board_wipe = false
    end
end

-- Keyboard Handling
function love.keypressed( key, scancode, isrepeat )
    if screen == START then
        if key == 'return' then
            screen = GAME
            paused = false
        end
    end
    
    if screen == GAME then
        if key == 'p' then
            if paused then paused = false
            else           paused = true
            end
        end
        
        if not paused then
            if key == 'space' then
                laser.fire = true
                
                target.x = love.mouse.getX()
                target.y = love.mouse.getY()
                
                laser_hit.x = target.x
                laser_hit.y = target.y
            end
            
            if key == 'x' or key == 'X' then
                sum = 0
                
                for key, value in next, kills do
                    sum = sum + value
                end
                
                print('X destroy')
                print('sum: ' .. sum)

                -- TODO should display a message on activation.. also be nice to have a drawn animation
                if sum == 70 then
                    -- destroy all enemies (the quick and nasty route)
                    --for k in next, tab do rawset(tab, k, nil) end
                    board_wipe = true
                end
            end
            
            if key == '0' or key == '1' or key == '2' or key == '3' or key == '4' or key == '5' or key == '6' or key == '7' then
                color_index = tonumber(key)
                
                if color_index >= ci_min or color_index <= ci_max then
                    ci = color_index
                end
            end
            
            if key == 'q' or key == 'Q' then
                if ci > ci_min then
                    ci = ci - 1
                else
                    ci = ci_max
                end
            end
            
            if key == 'e' or key == 'E' then
                if ci < ci_max then
                    ci = ci + 1
                else
                    ci = ci_min
                end
            end
        end
    end
    
    if screen == FINISH then
        if key == 'r' or key == 'R' then
            -- reset game
        end
    end
end

function love.keyreleased( key, scancode )
    if screen == GAME then
        if not paused then
            if key == 'space' then
                if laser.fire then
                    laser.fire = false
                    laser.width = 0
                end
            end
        end
    end
end

-- Mouse Handling
function love.mousepressed( x, y, button, istouch )
    if not paused then
        laser.fire = true
        
        target.x = love.mouse.getX()
        target.y = love.mouse.getY()
        
        laser_hit.x = target.x
        laser_hit.y = target.y
    end
end

function love.mousereleased( x, y, button, istouch )
    if not paused then
        if laser.fire then
            laser.fire = false
            laser.width = 0
        end
    end
end

-- Miscellaneous
function spawn_enemies(start_x)
    local initial_x = start_x or 0
    
    -- initialize random number generator
    math.randomseed( os.time() )
    
    rval = math.random(ci_max)
    
    -- tests are to try and find a color we have less enemies of to dump on us
    tests = 0
    
    test = count_enemies( colormap[rval] )
    
    -- killed at least half that color enemies
    while test > 5 and tests < 7 do
        rval = math.random(ci_max)
        
        tests = tests + 1
    end
    
    --c = 1
    xv = 5
    
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+2, y=2 } )  -- 4,3
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+2, y=3 } )  -- 3,4
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+2, y=4 } )  -- 2,5
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+1, y=5 } )  -- 1,6
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+1, y=6 } )  -- 0,7
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+1, y=7 } )  -- 1,8
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+2, y=8 } )  -- 2,9
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+2, y=9 } ) -- 3,10
    table.insert(enemies, { color=rval, destroyed=false, health=5, x=initial_x+2, y=10 } ) -- 4,11
end

function count_enemies(color)
    sum = 0
    
    for index, value in ipairs(enemies) do
        if color == colormap[value.color] then
            sum = sum + 1
        end
    end
    
    return sum
end

function numHexes(rowNum)
    return temp[rowNum]
end

-- extracted out hex generation
function generate_grid(hexmap)
    local start = {}
    
    start.x = -5
    start.y = -5
    
    local test = {}
    
    test.x = start.x
    test.y = start.y
    
    local hexNum = 0
    
    -- y
    for j=1,h do
        test.y = start.y + (j * 50)
        
        -- x
        for i=1,w do            
            -- offset every other line by half a hex
            if j % 2 == 0 then test.x = start.x + (i * 50) + 25
            else               test.x = start.x + (i * 50)      end
            
            -- generate hex corner coordinates
            local a = hex_corner(test, size, 0)
            local b = hex_corner(test, size, 1)
            local c = hex_corner(test, size, 2)
            local d = hex_corner(test, size, 3)
            local e = hex_corner(test, size, 4)
            local f = hex_corner(test, size, 5)
            
            -- group hex vertices together in a table
            --hex_vertices = { a, b, c, d, e, f }
            
            hexmap[hexNum] = { a, b, c, d, e, f }
            
            hexNum = hexNum + 1
        end
    end
end

function drawHexGrid()
    local hexNum = 0
    local n = 0
    
    local hexmap = {}
    
    generate_grid(hexmap)
    
    -- y
    for j=1,h do
        -- if we are inside the area we want then increment the index to temp
        if j > 1 and j < h then
            n = n + 1
        end
        
        -- x
        for i=1,w do
            if j > 1 and j < h then            
                local val1 = math.ceil( (w - numHexes(n)) / 2 )
                
                print('val1: ' .. val1)
                
                if i > val1 and i < val1 + numHexes(n) + 1 then
                    love.graphics.setColor(255, 255, 255)
                else
                    love.graphics.setColor(66, 80, 244)
                end
            end
            
            -- get vertices
            local vertices = hexmap[hexNum]
            
            --[[for i=1,6 do
                print('i: ' .. i)
                print('x: ' .. vertices[i].x )
                print('y: ' .. vertices[i].y )
            end]]--
            
            local a = vertices[1]
            local b = vertices[2]
            local c = vertices[3]
            local d = vertices[4]
            local e = vertices[5]
            local f = vertices[6]
            
            -- draw player
            if hexNum == player_y * w + player_x then
                local cx = e.x
                local cy = e.y + ((b.y - e.y) / 2)
                
                --love.graphics.setColor(0, 255, 255)
                love.graphics.setColor( colors2[ci] )
                
                love.graphics.polygon("fill", a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y, e.x, e.y, f.x, f.y)
                
                love.graphics.setColor(66, 80, 244)
                
                pcenter.x = cx
                pcenter.y = cy
            else
                -- draw energy shields
                local es = false
                local shield = nil
                
                for key, value in ipairs(energy_shields) do
                    if hexNum == value.y * w + value.x then
                        es = true
                        shield = value
                        break
                    end
                end
                
                if es then
                    cx = e.x
                    cy = e.y + ((b.y - e.y) / 2)
                    
                    if shield.energy == 0 then
                        love.graphics.polygon("line", a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y, e.x, e.y, f.x, f.y)
                    else
                        love.graphics.setColor(0, 255, 255)
                        
                        if shield.energy >= 1 then
                            love.graphics.polygon("fill", cx, cy, d.x, d.y, e.x, e.y)
                            
                            if shield.energy >= 2 then
                                love.graphics.polygon("fill", cx, cy, e.x, e.y, f.x, f.y)
                                
                                if shield.energy >= 3 then
                                    love.graphics.polygon("fill", cx, cy, f.x, f.y, a.x, a.y)
                                    
                                    if shield.energy >= 4 then
                                        love.graphics.polygon("fill", cx, cy, a.x, a.y, b.x, b.y)
                                        
                                        if shield.energy >= 5 then
                                            love.graphics.polygon("fill", cx, cy, b.x, b.y, c.x, c.y)
                                            
                                            if shield.energy >= 6 then
                                                love.graphics.polygon("fill", cx, cy, c.x, c.y, d.x, d.y)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    love.graphics.setColor(66, 80, 244)
                else
                    love.graphics.polygon("line", a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y, e.x, e.y, f.x, f.y)
                end
            end
            
            --love.graphics.print(hexNum, d.x, d.y)
            
            stack_data = {}
            
            -- draw enemies
            for index, value in ipairs(enemies) do
                if hexNum == value.y * w + value.x then
                    if laser_hit.x > d.x and laser_hit.x < f.x then
                        if laser_hit.y > e.y and laser_hit.y < b.y then
                            if ci == value.color then
                                value.destroyed = true
                                
                                laser_hit.x = -1
                                laser_hit.y = -1
                            end
                        end
                    end
                    
                    if not value.destroyed then
                        cx = e.x
                        cy = e.y + ((b.y - e.y) / 2)
                        
                        love.graphics.setColor( colors2[value.color] )
                        
                        love.graphics.polygon("fill", a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y, e.x, e.y, f.x, f.y)                    
                        
                        love.graphics.setColor(66, 80, 244)
                    end
                    
                    stack_data[hexNum] = (stack_data[hexNum] or 0) + 1
                end
            end
            
            if stack_data[hexNum] ~= nil then
                love.graphics.print(stack_data[hexNum], d.x + 25, d.y)
            end
            
            hexNum = hexNum + 1
        end
    end
end

function sine()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    
    center = Point(sw / 2, sh / 2, 0)
    
    points = {}
    
    n = 0
    
    for i=0,8 do
        px = (center.x + i)
        py = center.y * math.sin(i/4 * math.pi)
        
        love.graphics.points(px, py)
        
        if i > 0 then
            plx = (center.x + (i - 1))
            py = center.y * math.sin((i - 1)/4 * math.pi)
            
            love.graphics.line(plx, ply, px, py)
        end
    end
    
    --[[for i=0,96 do
        n = i % 96
        
        --table.insert(points, center.x + i))
        --table.insert(points, center.y * math.sin(n * math.pi/4))
        
        px = (center.x + i)
        py = center.y * math.sin(n * math.pi/4)
        
        love.graphics.points(px, py)
        
        if i > 0 then
            plx = (center.x + (i - 1))
            ply = center.y + math.sin(((n-1) % 96) * math.pi/4)
            
            love.graphics.line(plx, ply, px, py)
        end
    end]]--
end

-- function: shoot
function shoot()
    --[[r = 200
    theta = 45
    
    -- x = r cos(theta)
    -- y = r sin(theta)
    
    --
    rads = deg_to_rad(theta)
    
    print('degrees: ' .. theta)
    print('radians: ' .. rads)
    
    print('cos(' .. theta .. ') = ' .. math.cos(rads))
    print('sin(' .. theta .. ') = ' .. math.sin(rads))
    
    x = r * math.round( math.cos(rads) )
    y = r * math.round( math.sin(rads) )
    
    print('x: ' .. x)
    print('y: ' .. y)]]--
    
    love.graphics.setColor( colors2[ci] )
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth( math.floor(laser.width) )
    
    love.graphics.line(pcenter.x, pcenter.y, target.x, target.y)
    
    love.graphics.setColor( 255, 255, 255 )
    love.graphics.setLineStyle("smooth")
    love.graphics.setLineWidth(1)
end

--[[
code/pseudocode http://www.redblobgames.com/grids/hexagons/
]]--

function hex_corner(center, size, i)
    local angle_deg = 60 * i + 30
    local angle_rad = math.pi / 180 * angle_deg
    
    local point = {}
    
    point.x = center.x + size * math.cos(angle_rad)
    point.y = center.y + size * math.sin(angle_rad)
    
    return Point(center.x + size * math.cos(angle_rad), center.y + size * math.sin(angle_rad))
end

-- takes in a 'Cube' table
function cube_round(c)
    local rx = math.round(c.x)
    local ry = math.round(c.y)
    local rz = math.round(c.z)

    local x_diff = math.abs(rx - c.x)
    local y_diff = math.abs(ry - c.y)
    local z_diff = math.abs(rz - c.z)

    if x_diff > y_diff and x_diff > z_diff then
        rx = -ry-rz
    elseif y_diff > z_diff then
        ry = -rx-rz
    else
        rz = -rx-ry
    end

    return Cube(rx, ry, rz)
end

-- takes in a 'Cube' table
function cube_to_hex(c) -- axial
    local q = c.x
    local r = c.z
    
    return Hex(q, r)
end

function hex_to_cube(hex) -- axial
    local x = hex.q
    local z = hex.r
    local y = -x-z
    
    return Cube(x, y, z)
end

function hex_round(h)
    return cube_to_hex( cube_round( hex_to_cube(h) ) )
end

-- note: pointy top hexes
function pixel_to_hex(x, y)
    local q = (x * math.sqrt(3)/3 - y / 3) / size
    local r = y * 2/3 / size
    
    return cube_to_hex(cube_round(Cube(q, -q-r, r))) -- using offset coordinates
end

-- Math Functions? (https://love2d.org/wiki/General_math)

-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci)
    local deci = 10^(deci or 0)
    
    return math.floor(n*deci+.5)/deci
end

function deg_to_rad(degrees)
    return math.pi / 180 * degrees
end

-- Utility table creators
function Point(_x, _y, _z)
    return {
        x = _x,
        y = _y,
        z = _z
    }
end

function Hex(_q, _r)
    return {
        q = _q,
        r = _r
    }
end

function Cube(_x, _y, _z)
    return {
        x = _x,
        y = _y,
        z = _z
    }
end