local Burst = extend(Ability)
Burst.code = 'burst'

----------------
-- Meta
----------------
Burst.name = 'Burst'
Burst.description = 'Burst things'


----------------
-- Data
----------------
Burst.passive = true
Burst.damage = 50
Burst.range = 100


----------------
-- Behavior
----------------
function Burst:die()
  local damage = self.damage * (self:hasUpgrade('essenceflame') and 1.5 or 1)
  local range = self.range * (self:hasUpgrade('essenceflame') and 2 or 1)
  local heal = self:hasUpgrade('sanctuary') and self.damage or 0

  ctx.spells:add(data.spell.bruju.burst, {
    owner = self,
    damage = damage,
    range = range,
    heal = heal
  })
end


----------------
-- Upgrades
----------------
local EssenceFlame = {}
EssenceFlame.code = 'essenceflame'
EssenceFlame.name = 'Essence Flame'
EssenceFlame.description = 'Burst deals 50% increased damage and the radius is increased by 100%.'

local Sanctuary = {}
Sanctuary.code = 'sanctuary'
Sanctuary.name = 'Sanctuary'
Sanctuary.description = 'Burst heals allies in the area of effect for 15% of their maximum health.'

Burst.upgrades = {DamageRange, Sanctuary}

return Burst
