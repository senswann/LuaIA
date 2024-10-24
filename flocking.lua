local flocking = {}

-- Constants
W_LIMIT = 10

N_BOIDS = 10
CVISUAL_RANGE = 10
DEAD_ANGLE = 60
V_TURN = 2
MINDISTANCE = 8  -- Augmenter la distance minimale pour activer la répulsion
VMAX = 100

AVOIDANCE = 20  -- Augmentation significative pour forcer la répulsion
COHESION = 0    -- Pas de force de cohésion
CENTERING = 3   -- Réduction supplémentaire de la force de centrage

-- boids table
local boids = {}
boids.list = {}
boids.img = love.graphics.newImage('shrek.png')
boids.w = boids.img:getWidth()
boids.h = boids.img:getHeight()


-- *****************
-- Fonctions
-- *****************

local function distance(pBoid1, pBoid2) 

  return math.sqrt((pBoid1.x - pBoid2.x)^2 + (pBoid1.y - pBoid2.y)^2)

end

-- Boids 
local function createBoid()

  local boid = {}
  boid.x = math.random(W_LIMIT, GRID_W - W_LIMIT) 
  boid.y = math.random(W_LIMIT, GRID_H - W_LIMIT)
  boid.vx = math.random(-VMAX, VMAX)  
  boid.vy = math.random(-VMAX, VMAX) 

  return boid

end

local function orbitAroundPlayer(pBoid, player, radius)
  local orbit = {}
  local angle = math.atan2(pBoid.y - player.y, pBoid.x - player.x)

  -- Crée une distance entre le boid et le joueur, pour une distance orbitale
  local distanceToPlayer = distance(pBoid, player)
  if distanceToPlayer > radius then
      orbit.dx = (player.x + TILE_SIZE/2 + radius * math.cos(angle) - pBoid.x)
      orbit.dy = (player.y + TILE_SIZE/2 + radius * math.sin(angle) - pBoid.y)
  else
      orbit.dx = 0
      orbit.dy = 0
  end

  -- Ajoute un effet de rotation
  orbit.dx = orbit.dx - (pBoid.vy * 0.5)
  orbit.dy = orbit.dy + (pBoid.vx * 0.5)

  return orbit
end


local function cohesion(pBoid, pVisualRange)

  local delta = {}
  local dVx = 0
  local dVy = 0
  local nearBoids = {}
  local sumX = 0
  local sumY = 0
  local sumVx = 0
  local sumVy = 0
  local n = 0

  for index, otherBoid in ipairs(boids.list) do

    if distance(pBoid, otherBoid) < pVisualRange then
      sumX = sumX + otherBoid.x
      sumY = sumY + otherBoid.y
      sumVx = sumVx + otherBoid.vx
      sumVy = sumVy + otherBoid.vy
      n = n + 1
    end
  end

  delta.dx = sumX/n - pBoid.x
  delta.dy = sumY/n - pBoid.y
  delta.dVx = sumVx/n - pBoid.vx 
  delta.dVy = sumVy/n - pBoid.vy
  
  return delta

end


local function keepDistance(pBoid, pMinDistance)

  local dist = {}
  dist.dx = 0
  dist.dy = 0
  
  for index, otherBoid in ipairs(boids.list) do
    if pBoid ~= otherBoid then
      if distance(otherBoid, pBoid) < pMinDistance then
        dist.dx = dist.dx + (pBoid.x - otherBoid.x)
        dist.dy = dist.dy + (pBoid.y - otherBoid.y)
      end
    end
  end

  return dist 

end


local function keepInside(pBoid, pVTurn, pLimit)

  local turn = {}
  turn.dVx = 0
  turn.dVy = 0


  if pBoid.x < pLimit then
    turn.dVx = pVTurn
  end

  if pBoid.x > GRID_W - pLimit then
    turn.dVx = - pVTurn
  end

  if pBoid.y < pLimit then
    turn.dVy = pVTurn 
  end

  if pBoid.y > GRID_H - pLimit then
    turn.dVy = - pVTurn 
  end

  return turn 

end

-- ****************************
-- INITIALISATION
-- ****************************

local function initDemo()
  
  for n = 1, N_BOIDS do
    table.insert(boids.list, createBoid())
  end

end


function flocking.load()

  initDemo()

end


-- ******************
-- UPDATE
-- ******************

function flocking.update(dt,player)
  for index, boid in ipairs(boids.list) do 

    -- align position and speed with that of others
    cohesionForce = cohesion(boid, CVISUAL_RANGE)
    -- boids avoid each other
    avoidanceForce = keepDistance(boid, MINDISTANCE)
    -- boids return to the center when approching window’s edges
    centeringForce = keepInside(boid, V_TURN, W_LIMIT)
     -- Nouvelle force pour orbiter autour du joueur
    orbitForce = orbitAroundPlayer(boid, player, 10)


    -- boids speed adjustement according all forces
    -- we could add ponderations
    boid.vx = boid.vx + (avoidanceForce.dx * AVOIDANCE
                          + centeringForce.dVx * CENTERING
                          + (cohesionForce.dx 
                            + cohesionForce.dVx) * COHESION
                            + orbitForce.dx
                        ) * dt

    boid.vy = boid.vy + (avoidanceForce.dy * AVOIDANCE
                        + centeringForce.dVy * CENTERING
                        + (cohesionForce.dy 
                          + cohesionForce.dVy) * COHESION
                          + orbitForce.dy
                        ) * dt

    -- speed limitation
    if math.abs(boid.vx) > VMAX then
      boid.vx = boid.vx/math.abs(boid.vx) * VMAX
    end
    if math.abs(boid.vy) > VMAX then
      boid.vy = boid.vy/math.abs(boid.vy) * VMAX
    end

    -- move boid according to its speed
    boid.x = boid.x + boid.vx * dt
    boid.y = boid.y + boid.vy * dt

  end
end


-- ***************
-- DRAWING 
-- ***************

function flocking.draw()
  for index, boid in ipairs(boids.list) do
    love.graphics.draw(boids.img, boid.x, boid.y, -math.atan2(boid.vx, boid.vy), .67, .67, boids.w/2, boids.h/2)
  end
end

return flocking