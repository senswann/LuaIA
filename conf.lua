-- LÖVE configuration file
TILE_SIZE = 64
N_LINE = 12
N_COL = 16
GRID_W = TILE_SIZE * N_COL 
GRID_H = TILE_SIZE * N_LINE

function love.conf(w)
  w.title = "LOVE IA"
  w.window.width = GRID_W
  w.window.height = GRID_H 
  w.window.msaa = 4 -- antialiasing activation
end
