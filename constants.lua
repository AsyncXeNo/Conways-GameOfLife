CELL_SIZE = 32

love.window.setMode(0, 0, { fullscreen = true })
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getMode()


C = WINDOW_HEIGHT / CELL_SIZE

CELL_COLS = math.floor(WINDOW_WIDTH / CELL_SIZE)
CELL_ROWS = math.floor(WINDOW_HEIGHT / CELL_SIZE)

X_MARGIN = (WINDOW_WIDTH % CELL_SIZE) / 2
Y_MARGIN = (WINDOW_HEIGHT % CELL_SIZE) / 2

FONTPATH = 'assets/helsinki.ttf'
FONTSIZE = 35


function toboolean(num)
    if num == 0 then return false else return true end
end

function round(num)
    return math.floor(num+0.5)
end
