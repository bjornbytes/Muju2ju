local Huju = extend(Unit)
Huju.code = 'huju'

Huju.width = 48
Huju.height = 48

Huju.maxHealth = 100
Huju.maxHealthPerMinute = 10
Huju.damage = 0
Huju.damagePerMinute = 0
Huju.attackRange = 0
Huju.attackSpeed = 2
Huju.speed = 55

Huju.channelDuration = 1

function Huju:activate()
	Unit.activate(self)

  self.channelTimer = 0
end

function Huju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- Movement
    --self:move() -- Needs custom AI

    if self.attackTimer == 0 and self.channelTimer == 0 then
      self.channelTimer = self.channelDuration
    end

    if self.channelTimer > 0 then
      self.channelTimer = timer.rot(self.channelTimer, function() self.attackTimer = self.attackSpeed end)
      
      -- Get allies in range.
      -- If no allies then stop channeling?
      -- Heal each ally, add extra effects too.
    end
  end
end

return Huju

