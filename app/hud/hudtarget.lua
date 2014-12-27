HudTarget = class()

local g = love.graphics

function HudTarget:init()
  self.x = nil
  self.y = nil
  self.alpha = nil

  self.prev = {
    x = self.x,
    y = self.y,
    alpha = self.alpha
  }
end

function HudTarget:update()
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.alpha = self.alpha

  local unit, ability = self:getTargetingInfo()
  if unit and ability then
    if ability.target == 'location' then
      self.x, self.y = ctx.view:screenPoint(ctx.target:location(unit, ability.range))
    elseif ability.target == 'unit' or ability.target == 'ally' or ability.target == 'enemy' then
      local teamFilter = ability.target == 'unit' and 'all' or ability.target
      local target = ctx.target:atMouse(unit, ability.range or math.huge, teamFilter, 'unit')
      local x, y = love.mouse.getPosition()
      if target then
        x, y = ctx.view:screenPoint(target.x, target.y)
      else
        x = math.clamp(x, unit.x - ability.range, unit.x + ability.range)
      end

      self.x, self.y = x, y
    end

    self.alpha = math.lerp(self.alpha or 0, 1, math.min(8 * tickRate, 1))
  else
    self.x = nil
    self.y = nil
    self.alpha = nil
  end
end

function HudTarget:draw()
  local unit, ability = self:getTargetingInfo()
  if unit and ability then
    local state = table.interpolate(self.prev, self, tickDelta / tickRate)
    local x, y, alpha = state.x, state.y, state.alpha

    if not x or not y or not alpha then return end

    local range = ability.range * ctx.view.scale
    local ux = ctx.view:screenPoint(unit:lerp().x)
    g.setColor(255, 255, 255, 25 * alpha)
    g.rectangle('fill', ux - range, 0, 2 * range, ctx.map.height * ctx.view.scale)

    g.setColor(255, 255, 255, 100 * alpha)

    g.line(ux - range, 0, ux - range, ctx.map.height * ctx.view.scale)
    g.line(ux + range, 0, ux + range, ctx.map.height * ctx.view.scale)

    g.setColor(255, 255, 255, 255 * alpha)

    local radius = 6 * alpha
    g.circle('line', x, y, radius)

    local z = 2 * alpha
    g.line(x - radius - z, y, x - radius + z, y)
    g.line(x + radius - z, y, x + radius + z, y)
    g.line(x, y - radius - z, x, y - radius + z)
    g.line(x, y + radius - z, x, y + radius + z)
  end
end

function HudTarget:getTargetingInfo()
  local p = ctx.players:get(ctx.id)
  if p and p.input and p.input.targeting then
    local unit = p.deck[p.selected].instance
    local ability = unit and data.ability[unit.class.code][data.unit[unit.class.code].abilities[p.input.targeting]]
    return unit, ability
  end
end
