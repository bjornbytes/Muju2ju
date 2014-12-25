local FrozenOrb = extend(Spell)
FrozenOrb.code = 'frozenorb'

function FrozenOrb:activate()
  local unit = self:getUnit()

  self.team = unit.team
  self.returning = false

  self.damaged = {}

  self.x = unit.x
  self.y = unit.y
  self.prevx = unit.x

  ctx.event:emit('view.register', {object = self})
end

function FrozenOrb:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function FrozenOrb:update()
  local direction = self.ability:getUnitDirection() 
  local inRange = math.abs(self.ability.unit.x - self.x) < self.ability.range

  self.prevx = self.x

  if inRange and not self.returning then
   self.x = self.x + direction * self.speed * tickRate
  elseif not inRange or self.returning then
    if not self.returning then table.clear(self.damaged) end
    self.returning = true
    self.x = self.x - direction * self.speed * tickRate
  end

  if math.abs(self.x - self.ability.unit.x) <= self.ability.unit.width / 2 and self.returning then
    self:deactivate()
  end

  table.each(ctx.target:inRange(self, self.radius, 'enemy', 'unit'), function(target)
    if not self.damaged[target.id] then
      target.buffs:add('slow', {
        slow = self.slow,
        timer = self.duration
      })
      target:hurt(self.damage, unit)
      self.damaged[target.id] = true
    end
  end)
end

function FrozenOrb:draw()
	local g = love.graphics
  local x = math.lerp(self.prevx, self.x, tickDelta / tickRate)
  g.setColor(255, 255, 255)
  g.circle('fill', x, self.y, self.radius)
end

return FrozenOrb
