local rich = require 'lib/deps/richtext/richtext'

Tooltip = class()

local g = love.graphics

function Tooltip:init()
  self.active = false
  self.tooltip = nil
  self.tooltipText = nil
  self.x = nil
  self.y = nil
end

function Tooltip:update()
  self.active = false

  if not self.richOptions then self:resize() end
end

function Tooltip:draw()
  local mx, my = love.mouse.getPosition()
  self.x = self.x and math.lerp(self.x, mx, 15 * delta) or mx
  self.y = self.y and math.lerp(self.y, my, 15 * delta) or my

  if self.active then
    local u, v = self:getUV()
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

function Tooltip:setTooltip(str)
  self.tooltip = rich.new(table.merge({str}, self.richOptions))
  self.tooltipText = str:gsub('{%a+}', '')
  self.active = true
end

function Tooltip:unitTooltip(code)
  local unit = data.unit[code]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. unit.name .. '{normal}')
  table.insert(pieces, 'This unit is actually really cool.')
  return table.concat(pieces, '\n')
end

function Tooltip:runeTooltip(id)
  local rune = runes[id]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. rune.name .. '{normal}')
  table.insert(pieces, rune.description)
  return table.concat(pieces, '\n')
end

function Tooltip:skillTooltip(code, index)
  local skill = data.skill[code][data.unit[code].skills[index]]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. skill.name .. '{normal}')
  table.insert(pieces, skill.description)
  return table.concat(pieces, '\n')
end

function Tooltip:skillUpgradeTooltip(code, skill, index)
  local upgrade = data.skill[code][data.unit[code].skills[skill]].upgrades[index]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. upgrade.name .. '{normal}')
  table.insert(pieces, upgrade.description)
  return table.concat(pieces, '\n')
end

function Tooltip:resize()
  local u, v = self:getUV()
  self.richOptions = {}
  self.richOptions[2] = u * .375
  self.richOptions.white = {255, 255, 255}
  self.richOptions.red = {255, 100, 100}
  self.richOptions.green = {100, 255, 100}
  self.richOptions.title = Typo.font('inglobal', .04 * v)
  self.richOptions.normal = Typo.font('inglobal', .023 * v)
end

function Tooltip:getUV()
  if isa(ctx, Menu) then return ctx.u, ctx.v
  elseif isa(ctx, Game) then return ctx.hud.u, ctx.hud.v end
end
