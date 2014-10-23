MenuNav = class()

local g = love.graphics

function MenuNav:init()
  self.height = .04
  self.y = 0
end

function MenuNav:draw()
  local u, v = g.getDimensions()
  local yy = math.round((self.y + self.height) * v) + .5

  g.setColor(255, 255, 255, 100)
  g.line(0, yy, u, yy)
end
