HudPortrait = class()

local g = love.graphics

function HudPortrait:init()
  --
end

function HudPortrait:update()
  --
end

function HudPortrait:draw()
  local u, v = ctx.hud.u, ctx.hud.v

  local unit = self:getSelected()

  if unit then
    g.setColor(255, 255, 255)
    g.circle('line', .04 * v, .04 * v, .03 * v)
    g.setFont('pixel', 8)
    g.print(unit.class.name, .08 * v, .04 * v - g.getFont():getHeight() / 2)

    if unit.stance then
      local stances = table.keys(Unit.stances)
      for i = 1, #stances do
        g.setColor(255, 255, 255, unit.stance == stances[i] and 255 or 150)
        g.rectangle('line', .08 * v + (.03 * v) * (i - 1), .06 * v, .02 * v, .02 * v)
      end
    end
  end
end

function HudPortrait:mousereleased(x, y, b)
  if b ~= 'l' then return end

  local u, v = ctx.hud.u, ctx.hud.v

  local unit = self:getSelected()

  if unit and unit.stance then
    local stances = table.keys(Unit.stances)
    for i = 1, #stances do
      if math.inside(x, y, .08 * v + (.03 * v) * (i - 1), .06 * v, .02 * v, .02 * v) then
        unit.stance = stances[i]
        ctx.net:send()
      end
    end
  end
end

function HudPortrait:getSelected()
  local p = ctx.players:get(ctx.id)
  return p.selected and p.deck[p.selected].instance
end
