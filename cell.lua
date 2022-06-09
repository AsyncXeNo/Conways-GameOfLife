love.graphics.setDefaultFilter("nearest", "nearest")
Cell = {
    sprites = {
        alive = love.graphics.newImage('assets/alive.png'),
        dead = love.graphics.newImage('assets/dead.png')
    }
}
Cell.__index = Cell


function Cell:new(alive)
    obj = {}

    obj.alive = alive or false

    setmetatable(obj, self)
    return obj
end


function Cell:getSprite()
    if self.alive then return self.sprites.alive else return self.sprites.dead end
end


return Cell
