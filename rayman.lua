local rayman = {}

local path_finding = require("path_finding")
local message = ""
local path = {}
local pathConfirm = false
local state = 0
local index = 1

local rayman_ = {}

function rayman.getMessage()
    return message
end

function rayman.getPath()
    return path
end

function rayman.getPathConfirm()
    return pathConfirm
end

function rayman.setState(_state)
    state = _state;
end

function rayman.getState()
    return state
end

function rayman.getRayman()
    print("rayman during get : ",RAYMAN.c,RAYMAN.l)
    return RAYMAN
end

local function Wait()
    message = "Rayman : En Attente"
    RAYMAN.sprite = love.graphics.newImage("rayman.png")
    pathConfirm = false
    RAYMAN.moving = false
end

local function Chase(player,invertedGrid)
    message = "Rayman : En Chasse"
    RAYMAN.sprite = love.graphics.newImage("globox.png")
    local start = {x = RAYMAN.l, y = RAYMAN.c} 
    local goal = {x = player.l, y = player.c}

     local tmp_path = path_finding.A_star(start, goal, invertedGrid)
    -- print (path)
     if(tmp_path == nil) then
     else
       for _, p in ipairs(tmp_path)do 
        -- print("(" .. p.x .. ", " .. p.y .. ")")
          table.insert(path, {x = p.x, y = p.y})
       end    
       pathConfirm = true
    end
end

local function Movement(dt)
    if RAYMAN.moving == true then
        if RAYMAN.l_cible < RAYMAN.l then
          RAYMAN.y = RAYMAN.y - RAYMAN.pace * dt
          if (RAYMAN.y / TILE_SIZE) + 1 < RAYMAN.l_cible then
            RAYMAN.moving = false
            RAYMAN.l = RAYMAN.l_cible
          end
        end
        
        if RAYMAN.l_cible > RAYMAN.l then
          RAYMAN.y = RAYMAN.y + RAYMAN.pace * dt
          if (RAYMAN.y / TILE_SIZE) + 1 > RAYMAN.l_cible then
            RAYMAN.moving = false
            RAYMAN.l = RAYMAN.l_cible
          end
        end
        
        if RAYMAN.c_cible > RAYMAN.c then
          RAYMAN.x = RAYMAN.x + RAYMAN.pace * dt
          if (RAYMAN.x / TILE_SIZE) + 1 > RAYMAN.c_cible then
            RAYMAN.moving = false
            RAYMAN.c = RAYMAN.c_cible
          end
        end
        
        if RAYMAN.c_cible < RAYMAN.c then
          RAYMAN.x = RAYMAN.x - RAYMAN.pace * dt
          if (RAYMAN.x / TILE_SIZE) + 1 < RAYMAN.c_cible then
            RAYMAN.moving = false
            RAYMAN.c = RAYMAN.c_cible
          end
        end
    end
end

local function Attack()
    message = "Rayman : Attaque"
    state = 0
    RESTART = true
end

local function WaitUntilRaymanReachPoint()
    if  RAYMAN.l == RAYMAN.l_cible and  RAYMAN.c == RAYMAN.c_cible then
      return true
    else
      return false
    end
  end

function rayman.Action(dt,player,invertedGrid)
    --wait
    if state == 0 then
        Wait()

    -- chase
    elseif state == 1 then
        if pathConfirm == false then
            -- print("chase")
            Chase(player,invertedGrid)
        end
        if path and pathConfirm then
          
            if(index<#path) then
                if RAYMAN.moving == false and WaitUntilRaymanReachPoint then
                    index = index +1
                    RAYMAN.l_cible = path[index].x
                    RAYMAN.c_cible = path[index].y
                    RAYMAN.moving = true
                end
              elseif index>=#path then
                -- print("index : ",index," length path : ",#path)
                  index = 1
                  path = {}
                  pathConfirm = false
            end
            Movement(dt)
        end

    --attack
    elseif state == 2 then
        Attack()
    end
end

return rayman