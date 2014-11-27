local rich = require 'lib/deps/richtext/richtext'

MenuTooltip = class()

local g = love.graphics

function MenuTooltip:init()
  self.tooltip = nil
  self.tooltipText = nil
  self.x = nil
  self.y = nil
end

function MenuTooltip:update()
  --
end

function MenuTooltip:draw()
  if self.tooltip then
    local u, v = ctx.u, ctx.v
    local mx, my = love.mouse.getPosition()
    self.x = self.x and math.lerp(self.x, mx, 10 * delta) or mx
    self.y = self.y and math.lerp(self.y, my, 10 * delta) or my
    local font = Typo.font('inglobal', .023 * v)
    local textWidth, lines = font:getWrap(self.tooltipText, .375 * u)
    local xx = math.round(math.min(self.x + 8, u - textWidth - (.03 * u)))
    local yy = math.round(math.min(self.y + 8, v - (lines * font:getHeight()) - 7 - (.03 * u)))
    g.setFont(font)
    g.setColor(30, 50, 70, 240)
    g.rectangle('fill', xx, yy, textWidth + 14, lines * font:getHeight() + 16 + 5)
    g.setColor(10, 30, 50, 255)
    g.rectangle('line', xx + .5, yy + .5, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
    self.tooltip:draw(xx + 8, yy + 4)
  end
end

function MenuTooltip:setTooltip(str)
  self.tooltip = rich.new(table.merge({str}, self.richOptions))
  self.tooltipText = str:gsub('{%a+}', '')
end

function MenuTooltip:unitTooltip(code)
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. data.unit[code].name .. '{normal}')
  table.insert(pieces, 'This unit is actually really cool.')
  return table.concat(pieces, '\n')
end

function MenuTooltip:resize()
  self.richOptions = {}
  self.richOptions[2] = ctx.u * .375
  self.richOptions.white = {255, 255, 255}
  self.richOptions.red = {255, 100, 100}
  self.richOptions.green = {100, 255, 100}
  self.richOptions.title = Typo.font('inglobal', .04 * ctx.v)
  self.richOptions.normal = Typo.font('inglobal', .023 * ctx.v)
end
