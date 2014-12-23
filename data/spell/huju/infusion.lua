local Infusion = extend(Spell)
Infusion.code = 'infusion'

local g = love.graphics

function Infusion:activate()
  local unit, ability = self:getUnit(), self:getAbility()
  self.x = unit.x
  self.y = unit.y
  self.team = unit.team

  self.timer = ability.duration

  ctx.event:emit('view.register', {object = self})
end

function Infusion:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Infusion:update()
  local unit, ability = self:getUnit(), self:getAbility()

  self.timer = timer.rot(self.timer, function()
    ctx.spells:remove(self)
  end)

  table.each(ctx.target:inRange(self, ability.range, 'ally', 'unit', 'player'), function(ally)
    ally:heal(ally.maxHealth * ability.maxHealthHeal / ability.duration * tickRate, unit)
  end)
end

function Infusion:draw()
  local ability = self:getAbility()
  g.setColor(self:getUnit().team == ctx.players:get(ctx.id).team and {0, 255, 0} or {255, 0 , 0})
  g.circle('line', self.x, self.y, ability.range)
end

return Infusion
