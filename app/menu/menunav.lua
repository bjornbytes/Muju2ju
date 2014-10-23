MenuNav = class()

local g = love.graphics

function MenuNav:init()
  self.height = .04
  self.y = 0

  self.geometry = {
    quit = function()
      local u, v = ctx.u, ctx.v
      local size = (self.height * v) - 4
      return u - 2 - size, 2, size, size
    end
  }
end

function MenuNav:draw()
  local u, v = g.getDimensions()
  local yy = math.round((self.y + self.height) * v) + .5

  g.setColor(200, 200, 200)
  g.line(0, yy, u, yy)

  g.rectangle('line', self.geometry.quit())

  if false and ctx.user.username then
    g.setFont('inglobal', self.height * v - 4)
    g.print(ctx.user.username, u * .5 - g.getFont():getWidth(ctx.user.username) / 2, 2)
  end
end

function MenuNav:mousereleased(x, y, b)
  if b == 'l' then
    if math.inside(x, y, self.geometry.quit()) then
      love.event.quit()
    end
  end
end
