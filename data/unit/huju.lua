local Huju = extend(Unit)
Huju.code = 'huju'

Huju.width = 36
Huju.height = 36

Huju.maxHealth = 100
Huju.maxHealthPerMinute = 10
Huju.damage = 0
Huju.damagePerMinute = 0
Huju.attackRange = 150
Huju.attackSpeed = 2
Huju.speed = 55

Huju.channelDuration = 1
Huju.healAmount = 30

Huju.bulwarkStrength = 30
Huju.bulwarkMagicResist = 0

Huju.empowerDamage = 10
Huju.empowerPersist = 0
Huju.empowerAttackSpeed = 0

Huju.resurrectCooldown = 10

function Huju:activate()
	Unit.activate(self)

  self.channelTimer = 0
end

function Huju:update()
  if ctx.tag == 'server' then
    Unit.update(self)

    -- If I'm healing
    if self.channelTimer > 0 then
      self.channelTimer = timer.rot(self.channelTimer, function() self.attackTimer = self.attackSpeed end)
      
      -- If my target hasn't died yet and I'm still in range of them, heal them.
      if self.target and self:inRange() then
        self.target:heal(self.healAmount * tickRate)
      else

        -- If there's no target, we stop channeling and apply a partial cooldown.
        self.attackTimer = self.attackSpeed * (1 - (self.channelTimer / self.channelDuration))
        self.channelTimer = 0
      end
    else
      self.target = ctx.target:closest(self, 'ally', 'unit')

      -- If an ally exists
      if self.target then

        -- Try to move 'pretty close' to the closest ally
        if math.abs(self.target.x - self.x) > self.attackRange * .5 then
          self.x = self.x + self.speed * math.sign(self.target.x - self.x) * tickRate
        end

        -- If my cooldown is up and I am within heal range of the closest ally.
        if self.attackTimer == 0 and self:inRange() then

          -- Start healing the lowest person in range.
          local targets = ctx.target:inRange(self, self.attackRange, 'ally', 'unit')
          table.sort(targets, function(a, b) return a.health < b.health end)
          self.target = targets[1]
          if self.target then
            self.channelTimer = self.channelDuration
          end
        end
      end
    end
  end
end

return Huju

