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
  local damage = self.damage
  local range = self.range
  local heal = 0

  if self:hasUpgrade('essenceFlame') then
    damage = damage * self.upgrades.essenceflame.damageMultiplier
    range = range * self.upgrades.essenceflame.rangeMultiplier
  end

  if self:hasUpgrade('sanctuary') then
    heal = self.upgrades.sanctuary.maxHealthHeal
  end

  self:createSpell({
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
EssenceFlame.description = 'Burst deals 50% more damage and the radius is increased by 20%.'
EssenceFlame.damageMultiplier = 1.5
EssenceFlame.rangeMultiplier = 1.2

local Sanctuary = {}
Sanctuary.code = 'sanctuary'
Sanctuary.name = 'Sanctuary'
Sanctuary.description = 'Burst heals allies in the area of effect for 15% of their maximum health.'
Sanctuary.maxHealthHeal = .15

Burst.upgrades = {EssenceFlame, Sanctuary}

return Burst
