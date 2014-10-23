MenuBackground = class()

local g = love.graphics

function MenuBackground:init()
  self:resize()
end

function MenuBackground:update()
  --
end

function MenuBackground:draw()
  local u, v = ctx.u, ctx.v

  --[[g.setColor(255, 255, 255)
  g.draw(self.canvas)

  g.setColor(0, 0, 0, 50)
  g.rectangle('fill', 0, 0, u, v)]]
end

function MenuBackground:resize()
  self.canvas = g.newCanvas()
  local working = g.newCanvas()
  local u, v = g.getDimensions()
  g.setColor(255, 255, 255)
  local image = data.media.graphics.map.backgroundSpirit
  local scale = v / image:getHeight()

  self.canvas:renderTo(function()
    g.draw(image, u / 2, v / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  end)

  data.media.shaders.horizontalBlur:send('amount', .002)
  data.media.shaders.verticalBlur:send('amount', .002 * (g.getWidth() / g.getHeight()))

  for i = 1, 4 do
    g.setShader(data.media.shaders.horizontalBlur)
    working:renderTo(function()
      g.draw(self.canvas)
    end)

    g.setShader(data.media.shaders.verticalBlur)
    self.canvas:renderTo(function()
      g.draw(working)
    end)
  end

  g.setShader()
end
