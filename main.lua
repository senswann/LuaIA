-- MOVE AN ANIMATED SPRITE ON A GRID
-- 
-- local flocking = require "flocking"
local path_finding = require("path_finding")
local flocking = require("flocking")
local raymanImpl = require("rayman")

RESTART = false

local player = {}
player.l = 10
player.c = 10
player.l_cible = player.l
player.c_cible = player.c
player.x = (player.c -1) * TILE_SIZE
player.y = (player.l -1) * TILE_SIZE
player.moving = false
player.sp_l = 1
player.sp_c = 1
player.maxframe = 9
player.SIZE = 64 
player.spritesheet = love.graphics.newImage("Player.png")
player.sprite = love.graphics.newQuad((player.sp_c-1)*player.SIZE, player.sp_l*player.SIZE, player.SIZE, player.SIZE, player.spritesheet:getDimensions())
player.anim_timer = 0.1
player.pace = 200

RAYMAN = {}
RAYMAN.l = 4
RAYMAN.c = 4
RAYMAN.l_cible = player.l
RAYMAN.c_cible = player.c
RAYMAN.x = (player.c -1) * TILE_SIZE
RAYMAN.y = (player.l -1) * TILE_SIZE
RAYMAN.moving = false
RAYMAN.sp_l = 1
RAYMAN.sp_c = 1
RAYMAN.maxframe = 9
RAYMAN.SIZE = 64 
RAYMAN.sprite = love.graphics.newImage("rayman.png")
RAYMAN.pace = 100


-- grid = 0 movable | 1 obstacle
local grid = {}
for l = 1, N_LINE do
  grid[l] = {}
  for c = 1, N_COL do
    if love.math.random(10) < 3 then
      grid[l][c] = 1
    else
      grid[l][c] = 0
    end
  end
end

grid[RAYMAN.l][RAYMAN.c] = 0
grid[player.l][player.c] = 0

local invertedGrid = {}
for l = 1, N_LINE do
    for c = 1, N_COL do
        -- Assurez-vous que la colonne existe dans la nouvelle table
        if not invertedGrid[c] then
            invertedGrid[c] = {}
        end
        -- Inverser l et c
        invertedGrid[c][l] = grid[l][c]
    end
end

-- point to reach
local goal_case= {};

-- path variables
local path = {}
local index = 1
local clickConfirm = false
local pathConfirm = false

-- RAYMAN Logic
local function getDistance(a, b)
  return math.abs(a.l - b.l) + math.abs(a.c - b.c)
end

function Restart()
  RESTART=false
  grid = {}
  for l = 1, N_LINE do
    grid[l] = {}
    for c = 1, N_COL do
      if love.math.random(10) < 3 then
        grid[l][c] = 1
      else
        grid[l][c] = 0
      end
    end
  end 

  for l = 1, N_LINE do
    for c = 1, N_COL do
        -- Assurez-vous que la colonne existe dans la nouvelle table
        if not invertedGrid[c] then
            invertedGrid[c] = {}
        end
        -- Inverser l et c
        invertedGrid[c][l] = grid[l][c]
    end
end

  player.l = 10
  player.c = 10

  RAYMAN.l = 4
  RAYMAN.c = 4

  grid[RAYMAN.l][RAYMAN.c] = 0
  grid[player.l][player.c] = 0

  RepoPlayer()
  RepoRayman()
end

function RepoPlayer()
    player.x = (player.c - 1) * TILE_SIZE 
    player.y = (player.l - 1) * TILE_SIZE 
end

function RepoRayman()
  RAYMAN.x = (RAYMAN.c - 1) * TILE_SIZE 
  RAYMAN.y = (RAYMAN.l - 1) * TILE_SIZE 
end

function getRandomPointToReach()
  goal_case = {love.math.random(N_LINE),love.math.random(N_COL)}
  if grid[goal_case[1]][goal_case[2]] == 1 then
    getRandomPointToReach()
  end
  -- print(goal_case[1], goal_case[2], grid[goal_case[1]][goal_case[2]] )
end

function love.load()
	RESTART=false
  RepoPlayer()
  RepoRayman()
  flocking.load()

end

function WaitUntilPlayerReachPoint()
  if  player.l == player.l_cible and  player.c == player.c_cible then
    return true
  else
    return false
  end
end

function love.update(dt)

  if love.mouse.isDown(1) and clickConfirm == false  then
    clickConfirm = true
    -- Récupérer les coordonnées de la souris
    local mouseX, mouseY = love.mouse.getPosition()

    -- Convertir les coordonnées de la souris en indices de grille
    local gridColumn = math.floor(mouseX / TILE_SIZE) + 1
    local gridRow = math.floor(mouseY / TILE_SIZE) + 1

    -- Vérifier si la position cliquée est valide sur la grille
    if grid[gridRow] and grid[gridRow][gridColumn] then
        -- Par exemple, vérifier si c'est un obstacle ou non
        if grid[gridRow][gridColumn] == 1 then
            -- print("C'est un obstacle !")
        else
            -- print("C'est une case libre.")
              local start = {x = player.l, y = player.c} 
              local goal = {x = gridRow, y = gridColumn}

              -- print("Start:", start.x, start.y)
              -- print("Goal:", goal.x, goal.y)

              local tmp_path = path_finding.A_star(start, goal, invertedGrid)
              -- print (path)
              if(tmp_path == nil) then
                -- print("Probleme lors de la requete")
                clickConfirm = false
              else
                for _, p in ipairs(tmp_path)do 
                  -- print("(" .. p.x .. ", " .. p.y .. ")")
                  table.insert(path, {x = p.x, y = p.y})
                end
                
                pathConfirm = true
              end
        end
    end
end

  if path and clickConfirm and pathConfirm then
    -- print("path found",index,#path)
    if(index<#path) then
      if player.moving == false and WaitUntilPlayerReachPoint then
          index = index +1
          --print("move to (" .. path[index].x .. ", " .. path[index].y .. ")")
          player.l_cible = path[index].x
          player.c_cible = path[index].y
          player.moving = true
          
          -- check la directions
          if player.l_cible > player.l then
            player.sp_l = 3
          elseif player.l_cible < player.l then
            player.sp_l = 1
          elseif player.c_cible > player.c then
            player.sp_l = 4
          elseif player.c_cible < player.c then
            player.sp_l = 2
          end
      end
   elseif index>=#path then
        index = 1
        path = {}
        clickConfirm = false
    end
  end

    if player.moving == true then
      
      if player.l_cible < player.l then
        player.y = player.y - player.pace * dt
        if (player.y / TILE_SIZE) + 1 < player.l_cible then
          player.moving = false
    player.l = player.l_cible
    RepoPlayer()
        end
      end
      
      if player.l_cible > player.l then
        player.y = player.y + player.pace * dt
        if (player.y / TILE_SIZE) + 1 > player.l_cible then
          player.moving = false
    player.l = player.l_cible
    RepoPlayer()
        end
      end
      
      if player.c_cible > player.c then
        player.x = player.x + player.pace * dt
        if (player.x / TILE_SIZE) + 1 > player.c_cible then
          player.moving = false
    player.c = player.c_cible
    RepoPlayer()
        end
      end
      
      if player.c_cible < player.c then
        player.x = player.x - player.pace * dt
        if (player.x / TILE_SIZE) + 1 < player.c_cible then
          player.moving = false
    player.c = player.c_cible
    RepoPlayer()
        end
      end
    
    end

    player.Animate(dt)

    local distance = getDistance(RAYMAN, player)

    -- Check distance for state changes
    if distance <= 0.5 and raymanImpl.getState() == 1 then
        -- Attack if Rayman is at 1 case max and was chasing (state = 1)
        -- print("stat 2")
        raymanImpl.setState(2)

    elseif distance <= 3 then
        -- Chase if Rayman is at 3 cases or less
        -- print("stat 1")
        raymanImpl.setState(1)

    elseif distance >= 5 and raymanImpl.getState() == 1 then
        -- Wait if Rayman was chasing (state = 1) but is now 5 cases or more away
        -- print("stat 0")
        raymanImpl.setState(0)
    end

    raymanImpl.Action(dt,player,invertedGrid)
    
    flocking.update(dt,player)

    -- restart logic
    if RESTART then
      Restart()
    end
end

function love.draw()
  
  for i=1, N_COL - 1 do
    love.graphics.line(i*TILE_SIZE, 0, i*TILE_SIZE, GRID_H)
  end

  for i=1, N_LINE - 1 do
    love.graphics.line(0, i*TILE_SIZE, GRID_W, i*TILE_SIZE)
  end

  for l=1, N_LINE do
    for c=1, N_COL do
      if grid[l][c] == 1 then
        love.graphics.rectangle('fill', (c-1)*TILE_SIZE, (l-1)*TILE_SIZE, TILE_SIZE, TILE_SIZE)
      end
    end
  end
  
  --local x = (player.c-1) * TILE_SIZE 
  --local y = (player.l-1) * TILE_SIZE 
  love.graphics.draw(RAYMAN.sprite, RAYMAN.x, RAYMAN.y)
  love.graphics.draw(player.spritesheet, player.sprite, player.x, player.y)

  if path and clickConfirm and pathConfirm then
    love.graphics.print("move to (" .. path[index].x .. ", " .. path[index].y .. ")",10, 130)
  end

  love.graphics.print(raymanImpl.getMessage(),10, 140)
  -- love.graphics.setColor(255, 0, 0)
  -- love.graphics.print("Player.x :"..tostring(player.x), 10, 10)
  -- love.graphics.print("Player.y :"..tostring(player.y), 10, 30)
  -- love.graphics.print("Player.c :"..tostring(player.c), 10, 50)
  -- love.graphics.print("Player.c_cible :"..tostring(player.c_cible), 10, 70)
  -- love.graphics.print("Player.l :"..tostring(player.l), 10, 90)
  -- love.graphics.print("Player.l_cible :"..tostring(player.l_cible), x)
  -- love.graphics.print("Player.moving :"..tostring(player.moving), 10, 130)
  -- love.graphics.setColor(1, 1, 1)

  flocking.draw()
end


function player.Animate(dt)

  player.anim_timer = player.anim_timer - dt
  if player.anim_timer <= 0 then
    player.anim_timer = 0.1
    player.sp_c = player.sp_c + 1
    if player.sp_c > player.maxframe then
      player.sp_c = 1
    end
  end

  player.sprite:setViewport((player.sp_c-1)*player.SIZE, (player.sp_l-1)*player.SIZE, player.SIZE, player.SIZE)

end


function love.keypressed(key)

  if key == "escape" then
    love.event.quit()
  end

end
