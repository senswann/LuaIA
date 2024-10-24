local path_finding = {}

local function distance_diagonale_euclidienne(x1, y1, x2, y2)
    local dx = math.abs(x1 - x2)
    local dy = math.abs(y1 - y2)
    return math.sqrt(dx * dx + dy * dy)
end

local function distance_manhattan(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

function path_finding.A_star(start, goal, grid)
    local openSet = {}
    local closedSet = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}

    local function init()
        for y = 1, #grid do
            gScore[y] = {}
            fScore[y] = {}
            closedSet[y] = {}
            for x = 1, #grid[y] do
                gScore[y][x] = math.huge
                fScore[y][x] = math.huge
                closedSet[y][x] = false
            end
        end

        -- print(start.y,start.x)

        gScore[start.y][start.x] = 0
        fScore[start.y][start.x] = distance_diagonale_euclidienne(start.x, start.y, goal.x, goal.y)
        table.insert(openSet, {x = start.x, y = start.y})
    end

    local function inOpenSet(x, y)
        for _, node in ipairs(openSet) do
            if node.x == x and node.y == y then
                return true
            end
        end
        return false
    end

    local function getLowestFNode()
        local lowestIndex = 1
        local lowestF = fScore[openSet[1].y][openSet[1].x]
        for i, node in ipairs(openSet) do
            local score = fScore[node.y][node.x]
            if score < lowestF then
                lowestF = score
                lowestIndex = i
            end
        end
        return table.remove(openSet, lowestIndex)
    end

    local function reconstructPath(cameFrom, current)
        local total_path = {current}
        while cameFrom[current.y] and cameFrom[current.y][current.x] do
            current = cameFrom[current.y][current.x]
            table.insert(total_path, 1, current)
        end
        return total_path
    end

    local function getNeighbors(node)
        local neighbors = {}
        local directions = {
            {x = -1, y = 0}, {x = 1, y = 0},
            {x = 0, y = -1}, {x = 0, y = 1},
        }
    
        for _, d in ipairs(directions) do
            local nx, ny = node.x + d.x, node.y + d.y
            -- Vérifie si les coordonnées sont dans les limites de la grille et si la case n'est pas un mur
            if nx > 0 and ny > 0 and nx <= #grid[1] and ny <= #grid and grid[ny][nx] == 0 then
                table.insert(neighbors, {x = nx, y = ny})
            end
        end
    
        return neighbors
    end

    init()

    while #openSet > 0 do
        local current = getLowestFNode()
        if current.x == goal.x and current.y == goal.y then
            return reconstructPath(cameFrom, current)
        end

        closedSet[current.y][current.x] = true

        for _, neighbor in ipairs(getNeighbors(current)) do
            -- Vérifie si le voisin est un mur ou s'il est déjà dans closedSet
            if closedSet[neighbor.y][neighbor.x] or grid[neighbor.y][neighbor.x] == 1 then
                goto continue
            end

            local tentative_gScore = gScore[current.y][current.x] + distance_diagonale_euclidienne(current.x, current.y, neighbor.x, neighbor.y)

            if not inOpenSet(neighbor.x, neighbor.y) then
                table.insert(openSet, neighbor)
            elseif tentative_gScore >= gScore[neighbor.y][neighbor.x] then
                goto continue
            end

            
            cameFrom[neighbor.y] = cameFrom[neighbor.y] or {}
            cameFrom[neighbor.y][neighbor.x] = current
            gScore[neighbor.y][neighbor.x] = tentative_gScore
            fScore[neighbor.y][neighbor.x] = gScore[neighbor.y][neighbor.x] + distance_diagonale_euclidienne(neighbor.x, neighbor.y, goal.x, goal.y)

            -- print("fScore : ",fScore[neighbor.y][neighbor.x])
            -- print("Neighbor : ",neighbor.y,neighbor.x)

            ::continue::
        end
    end

    return nil
end

return path_finding