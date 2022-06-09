inspect = require 'inspect'

require 'constants'
require 'cell'
socket = require 'socket'

grid = {}

function addRow(pos)
    if pos == 'up' or pos == -1 then
        cellRows = cellRows + 1
        topLeftRowIndex = topLeftRowIndex + 1
        local row = {}
        for _=1,cellCols do
            table.insert(row, Cell:new(false))
        end
        table.insert(grid, 1, row)
    elseif pos == 'down' or pos == 1 then
        cellRows = cellRows + 1
        local row = {}
        for _=1,cellCols do
            table.insert(row, Cell:new(false))
        end
        table.insert(grid, row)
    end
end


function addCol(pos)
    if pos == 'left' or pos == -1 then
        cellCols = cellCols + 1
        topLeftColIndex = topLeftColIndex + 1
        for _,row in ipairs(grid) do
            table.insert(row, 1, Cell:new(false))
        end
    elseif pos == 'right' or pos == 1 then
        cellCols = cellCols + 1
        for _,row in ipairs(grid) do
            table.insert(row, Cell:new(false))
        end
    end
end


function updateGrid()
    for _,cell in ipairs(grid[1]) do
        if cell.alive then
            addRow(-1)
            break
        end
    end
    for _,cell in ipairs(grid[#grid]) do
        if cell.alive then
            addRow(1)
            break
        end
    end
    for _,row in ipairs(grid) do
        if row[1].alive then
            addCol(-1)
            break
        end
    end
    for _,row in ipairs(grid) do
        if row[#row].alive then
            addCol(1)
            break
        end
    end

    local newGrid = {}
    for rowIndex,row in ipairs(grid) do
        local newRow = {}
        for colIndex,col in ipairs(row) do
            local cell = grid[rowIndex][colIndex]
            local aliveCount = 0
            if grid[rowIndex - 1] then
                if grid[rowIndex - 1][colIndex + 1] and grid[rowIndex - 1][colIndex + 1].alive then aliveCount = aliveCount + 1 end
                if grid[rowIndex - 1][colIndex - 1] and grid[rowIndex - 1][colIndex - 1].alive then aliveCount = aliveCount + 1 end
                if grid[rowIndex - 1][colIndex] and grid[rowIndex - 1][colIndex].alive then aliveCount = aliveCount + 1 end
            end
            if grid[rowIndex] then
                if grid[rowIndex][colIndex + 1] and grid[rowIndex][colIndex + 1].alive then aliveCount = aliveCount + 1 end
                if grid[rowIndex][colIndex - 1] and grid[rowIndex][colIndex - 1].alive then aliveCount = aliveCount + 1 end
            end
            if grid[rowIndex + 1] then
                if grid[rowIndex + 1][colIndex + 1] and grid[rowIndex + 1][colIndex + 1].alive then aliveCount = aliveCount + 1 end
                if grid[rowIndex + 1][colIndex] and grid[rowIndex + 1][colIndex].alive then aliveCount = aliveCount + 1 end
                if grid[rowIndex + 1][colIndex - 1] and grid[rowIndex + 1][colIndex - 1].alive then aliveCount = aliveCount + 1 end
            end

            if cell.alive then
                if not (aliveCount == 2 or aliveCount == 3) then
                    table.insert(newRow, false)
                else
                    table.insert(newRow, true)
                end
            else
                if aliveCount == 3 then
                    table.insert(newRow, true)
                else
                    table.insert(newRow, false)
                end
            end
        end
        table.insert(newGrid, newRow)
    end

    for rowIndex,row in ipairs(grid) do
        for colIndex,col in ipairs(row) do
            grid[rowIndex][colIndex].alive = newGrid[rowIndex][colIndex]
        end
    end
end


function love.load()
    love.window.setTitle('Game Of Life')
    love.keyboard.setKeyRepeat(true)
    windowWidth, windowHeight = WINDOW_WIDTH, WINDOW_HEIGHT
    cellRows, cellCols = CELL_ROWS, CELL_COLS
    playing = false
    speed = 500
    timer = socket.gettime()*1000
    for _=1,cellRows do
        local row = {}
        for _=1,cellCols do
            table.insert(row, Cell:new(false))
        end
        table.insert(grid, row)
    end
    topLeftColIndex = 1
    topLeftRowIndex = 1

    font = love.graphics.newFont(FONTPATH, FONTSIZE)
    love.graphics.setFont(font)

    mainCanvas = love.graphics.newCanvas(windowWidth, windowHeight)
    menuCanvas = love.graphics.newCanvas(windowWidth, windowHeight)
    quitCanvas = love.graphics.newCanvas(windowWidth, windowHeight)

    activeCanvas = menuCanvas
end


function love.keypressed(key, scancode)
    -- if key == 'escape' then love.event.quit() end
    if activeCanvas == menuCanvas then
        activeCanvas = mainCanvas
    elseif key == 'escape' then
        love.event.quit()
    elseif activeCanvas == quitCanvas and key ~= 'f4' then
        activeCanvas = mainCanvas
    elseif key == 'kp+' and playing then
        speed = speed / 2
    elseif key == 'kp-' and playing then
        speed = speed * 2
    elseif key == 'right' or key == 'd' then
        if not grid[1][topLeftColIndex+CELL_COLS] then addCol('right') end
        topLeftColIndex = topLeftColIndex + 1
    elseif key == 'left' or key == 'a' then
        if not grid[1][topLeftColIndex-1] then addCol('left') end
        topLeftColIndex = topLeftColIndex - 1
    elseif key == 'up' or key == 'w' then
        if not grid[topLeftRowIndex-1] then addRow('up') end
        topLeftRowIndex = topLeftRowIndex - 1
    elseif key == 'down' or key == 's' then
        if not grid[topLeftRowIndex+CELL_ROWS] then addRow('down') end
        topLeftRowIndex = topLeftRowIndex + 1
    elseif key == 'space' and not playing then
        updateGrid()
    elseif key == 'p' then
        playing = not playing
        timer = os.time()
    end
end


function love.quit()
    if activeCanvas ~= quitCanvas then
        activeCanvas = quitCanvas
        return true
    end
end


function love.update(dt)
    if playing then
        if socket.gettime()*1000 - timer >= speed and not selected and activeCanvas == mainCanvas then
            updateGrid()
            timer = socket.gettime()*1000
        end
        if love.mouse.isDown(1) then
            if not selected then
                local x, y = love.mouse.getPosition()
                x = x - X_MARGIN
                y = y - Y_MARGIN
                selected = {x, y}
            end
            if selected then
                local x, y = unpack(selected)
                local currentX, currentY = love.mouse.getPosition()
                currentX = currentX - X_MARGIN
                currentY = currentY - Y_MARGIN

                xDiff = round((currentX - x) / CELL_SIZE)
                yDiff = round((currentY - y) / CELL_SIZE)
                if xDiff ~= 0 or yDiff ~= 0 then
                    selected = {currentX, currentY}
                    if xDiff > 0 then
                        while not grid[1][topLeftColIndex - xDiff] do
                            addCol(-1)
                        end
                    elseif xDiff < 0 then
                        while not grid[1][topLeftColIndex - xDiff + CELL_COLS] do
                            addCol(1)
                        end
                    end
                    if yDiff > 0 then
                        while not grid[topLeftRowIndex - yDiff] do
                            addRow(-1)
                        end
                    elseif yDiff < 0 then
                        while not grid[topLeftRowIndex - yDiff + CELL_ROWS] do
                            addRow(1)
                        end
                    end

                    topLeftColIndex = topLeftColIndex - xDiff
                    topLeftRowIndex = topLeftRowIndex - yDiff

                    selected = {currentX, currentY}
                end
            end
        end
        if not love.mouse.isDown(1) then
            selected = nil
        end
    else
        if love.mouse.isDown(1) then
            local x, y = love.mouse.getPosition()
            x = math.floor((x - X_MARGIN) / CELL_SIZE) + topLeftColIndex
            y = math.floor((y - Y_MARGIN) / CELL_SIZE) + topLeftRowIndex
            if grid[y] then
                local cell = grid[y][x]
                if cell then cell.alive = true end
            end
        elseif love.mouse.isDown(2) then
            local x, y = love.mouse.getPosition()
            x = math.floor((x - X_MARGIN) / CELL_SIZE) + topLeftColIndex
            y = math.floor((y - Y_MARGIN) / CELL_SIZE) + topLeftRowIndex
            if grid[y] then
                local cell = grid[y][x]
                if cell then cell.alive = false end
            end
        end
    end
end


function love.mousepressed(x, y, button, istouch, presses)
    if activeCanvas == menuCanvas then
        activeCanvas = mainCanvas
    -- elseif activeCanvas == mainCanvas then
    --     selected = {x, y}
    end
end


function love.draw()
    love.graphics.setCanvas(activeCanvas)
    love.graphics.clear(0, 0, 0, 255)
    if activeCanvas == mainCanvas then
        if playing then
            love.graphics.setColor(0, 0, 55/255)
        else
            love.graphics.setColor(0, 0, 0)
        end
        love.graphics.rectangle('fill', 0, 0, windowWidth, windowHeight)
        for rowIndex=topLeftRowIndex,topLeftRowIndex+CELL_ROWS-1 do
            row = grid[rowIndex]
            for colIndex=topLeftColIndex,topLeftColIndex+CELL_COLS-1 do
                x = colIndex-topLeftColIndex
                y = rowIndex-topLeftRowIndex
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(grid[rowIndex][colIndex]:getSprite(), x*CELL_SIZE+X_MARGIN, y*CELL_SIZE+Y_MARGIN)
            end
        end
    elseif activeCanvas == menuCanvas then
        love.graphics.clear(0, 0, 0, 255)
        love.graphics.setColor(245/255, 1, 245/255)
        love.graphics.printf('Welcome to my Implementation of Conway\'s Game of Life.', 0, windowHeight / 12 - FONTSIZE / 2, windowWidth, 'center')
        love.graphics.printf('Here are the rules\n1. Alive cells with exactly two or three alive neighbours live on.\n2. Dead cells with exactly three alive neighbours become alive.\n3. All other cells die or remain dead.\n\nControls\nLeft click: Make cell alive\nRight click: Make cell dead\nSpace: One step forward in time\nP: Keep stepping forward in time automatically / Stop stepping forward\nKeypad plus: Increase speed\nKeypad minus: Decrease speed\nw/a/s/d: Scroll\nClick and Drag: Scroll while in Play Mode\nEscape: Quit\n\n\n PRESS ANY KEY TO CONTINUE', 0, windowHeight / 8, windowWidth, 'center')
        love.graphics.setColor(1, 1, 1)
    elseif activeCanvas == quitCanvas then
        love.graphics.clear(0, 0, 0, 255)
        love.graphics.setColor(1, 125/255, 125/255)
        love.graphics.printf('Are you sure you want to quit?\nPress quit again to exit, any other key to go back.', 0, windowHeight / 2 - (FONTSIZE), windowWidth, 'center')
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.setCanvas()
    love.graphics.draw(activeCanvas, 0, 0)
end
